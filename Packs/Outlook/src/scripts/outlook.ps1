# outlook.ps1 - Outlook COM Bridge for WSL/pi
# Called from WSL via: powershell.exe -ExecutionPolicy Bypass -NoProfile -File outlook.ps1 <command> [params]

param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet("search","read","send","reply","forward","folders","save-attachment","mark-read","mark-unread")]
    [string]$Command,

    [string]$Subject = "",
    [string]$Sender = "",
    [string]$To = "",
    [string]$Cc = "",
    [string]$Bcc = "",
    [string]$Body = "",
    [string]$BodyHtml = "",
    [string]$FromDate = "",
    [string]$ToDate = "",
    [string]$Folder = "Inbox",
    [string]$Id = "",
    [string]$SavePath = "",
    [string]$Attachments = "",
    [int]$Limit = 10,
    [int]$AttachmentIndex = 0,
    [int]$UnreadOnly = 0,
    [int]$ReplyAll = 0,
    [int]$Html = 0
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

# ── Helpers ──────────────────────────────────────────────────────────────────

function JsonOut($obj) {
    $obj | ConvertTo-Json -Depth 5 -Compress
}

function ErrorOut($msg) {
    JsonOut @{ error = "$msg" }
    exit 1
}

function Build-DaslPart([string]$field, [string]$op, [string]$value) {
    $escaped = $value.Replace("'", "''")
    $q = [char]34
    $sq = [char]39
    return "${q}${field}${q} ${op} ${sq}${escaped}${sq}"
}

function Get-SmtpAddress($mail) {
    try {
        if ($mail.SenderEmailType -eq "SMTP") {
            return $mail.SenderEmailAddress
        }
        $sender = $mail.Sender
        if ($sender) {
            return $sender.PropertyAccessor.GetProperty("http://schemas.microsoft.com/mapi/proptag/0x39FE001E")
        }
    } catch {}
    return $mail.SenderEmailAddress
}

# ── Connect to Outlook ───────────────────────────────────────────────────────

try {
    $ol = [Runtime.InteropServices.Marshal]::GetActiveObject("Outlook.Application")
} catch {
    try {
        $ol = New-Object -ComObject Outlook.Application
    } catch {
        ErrorOut "Cannot connect to Outlook. Is it running?"
    }
}
$ns = $ol.GetNamespace("MAPI")

# ── Folder Resolution ────────────────────────────────────────────────────────

$folderMap = @{
    "Inbox" = 6; "Posteingang" = 6;
    "SentMail" = 5; "Sent" = 5; "Gesendete Elemente" = 5;
    "Drafts" = 16; "Entwuerfe" = 16;
    "Deleted" = 3; "Trash" = 3;
    "Outbox" = 4; "Postausgang" = 4;
    "Junk" = 23; "Spam" = 23;
    "Calendar" = 9; "Kalender" = 9;
    "Contacts" = 10; "Kontakte" = 10;
    "Tasks" = 13; "Aufgaben" = 13;
    "Notes" = 12; "Notizen" = 12;
}

function Get-TargetFolder([string]$FolderName) {
    # Direct default folder mapping
    if ($folderMap.ContainsKey($FolderName)) {
        return $ns.GetDefaultFolder($folderMap[$FolderName])
    }

    # Path-based: "Company/Team" or "Inbox/Subfolder"
    $parts = $FolderName -split "/"
    $root = $null

    if ($folderMap.ContainsKey($parts[0])) {
        $root = $ns.GetDefaultFolder($folderMap[$parts[0]])
        $startIdx = 1
    } else {
        # Search top-level folders by name
        $storeRoot = $ns.DefaultStore.GetRootFolder()
        foreach ($f in $storeRoot.Folders) {
            if ($f.Name -eq $parts[0]) {
                $root = $f
                $startIdx = 1
                break
            }
        }
        if (-not $root) {
            # Try flat search across all top-level and their children
            foreach ($f in $storeRoot.Folders) {
                foreach ($sf in $f.Folders) {
                    if ($sf.Name -eq $FolderName) { return $sf }
                }
            }
            ErrorOut "Folder not found: $FolderName"
        }
    }

    # Navigate subpath
    for ($i = $startIdx; $i -lt $parts.Count; $i++) {
        $found = $false
        foreach ($sf in $root.Folders) {
            if ($sf.Name -eq $parts[$i]) {
                $root = $sf
                $found = $true
                break
            }
        }
        if (-not $found) {
            ErrorOut "Subfolder not found: $($parts[$i]) in $($root.Name)"
        }
    }

    return $root
}

# ── Mail → Object ────────────────────────────────────────────────────────────

function Mail-ToObject($mail, [int]$withBody = 0) {
    $attachList = @()
    try {
        for ($i = 1; $i -le $mail.Attachments.Count; $i++) {
            $a = $mail.Attachments.Item($i)
            $attachList += @{
                name = $a.FileName
                size = $a.Size
                index = $i
            }
        }
    } catch {}

    $smtpAddr = Get-SmtpAddress $mail

    # Resolve importance
    $imp = "normal"
    try {
        switch ([int]$mail.Importance) {
            0 { $imp = "low" }
            1 { $imp = "normal" }
            2 { $imp = "high" }
        }
    } catch {}

    $obj = @{
        id             = $mail.EntryID
        subject        = if ($mail.Subject) { $mail.Subject } else { "" }
        sender         = if ($mail.SenderName) { $mail.SenderName } else { "" }
        senderEmail    = if ($smtpAddr) { $smtpAddr } else { "" }
        to             = $(try { if ($mail.To) { $mail.To } else { "" } } catch { "" })
        cc             = $(try { if ($mail.CC) { $mail.CC } else { "" } } catch { "" })
        date           = $mail.ReceivedTime.ToString("yyyy-MM-dd HH:mm")
        unread         = [bool]$mail.UnRead
        importance     = $imp
        hasAttachments = ($mail.Attachments.Count -gt 0)
        attachments    = @($attachList)
    }

    if ($withBody) {
        $obj["body"] = if ($mail.Body) { $mail.Body } else { "" }
        if ($Html) {
            $obj["bodyHtml"] = if ($mail.HTMLBody) { $mail.HTMLBody } else { "" }
        }
    }

    return $obj
}

# ── Commands ──────────────────────────────────────────────────────────────────

function Do-Search {
    $folder = Get-TargetFolder $Folder
    $items = $folder.Items
    $items.Sort("ReceivedTime", $true)

    # Build DASL filter
    $filters = @()

    if ($Subject) {
        $filters += Build-DaslPart "urn:schemas:httpmail:subject" "LIKE" "%$Subject%"
    }
    if ($Sender) {
        $filters += Build-DaslPart "urn:schemas:httpmail:fromname" "LIKE" "%$Sender%"
    }
    if ($UnreadOnly) {
        $q = [char]34
        $filters += "${q}urn:schemas:httpmail:read${q} = 0"
    }
    if ($FromDate) {
        $filters += Build-DaslPart "urn:schemas:httpmail:datereceived" ">=" "$FromDate"
    }
    if ($ToDate) {
        $filters += Build-DaslPart "urn:schemas:httpmail:datereceived" "<=" "$ToDate"
    }

    if ($filters.Count -gt 0) {
        $dasl = "@SQL=" + ($filters -join " AND ")
        $items = $items.Restrict($dasl)
    }

    $results = @()
    $count = 0
    foreach ($item in $items) {
        if ($count -ge $Limit) { break }
        try {
            $results += Mail-ToObject $item
            $count++
        } catch { continue }
    }

    JsonOut @{
        count  = $results.Count
        folder = $Folder
        emails = @($results)
    }
}

function Do-Read {
    if (-not $Id) { ErrorOut "Missing -Id parameter" }

    try {
        $mail = $ns.GetItemFromID($Id)
    } catch {
        ErrorOut "Email not found with ID: $Id"
    }

    $obj = Mail-ToObject $mail 1
    JsonOut $obj
}

function Do-Send {
    if (-not $To) { ErrorOut "Missing -To parameter" }
    if (-not $Subject -and -not $Body) { ErrorOut "Missing -Subject or -Body parameter" }

    $mail = $ol.CreateItem(0)
    $mail.To = $To
    if ($Cc) { $mail.CC = $Cc }
    if ($Bcc) { $mail.BCC = $Bcc }
    if ($Subject) { $mail.Subject = $Subject }

    # Support \n for newlines from CLI
    $bodyText = if ($Body) { $Body.Replace('\n', "`n") } else { "" }

    if ($BodyHtml) {
        $mail.HTMLBody = $BodyHtml.Replace('\n', "`n")
    } else {
        $mail.Body = $bodyText
    }

    if ($Attachments) {
        foreach ($path in ($Attachments -split ",")) {
            $p = $path.Trim()
            if ($p -and (Test-Path $p)) {
                $mail.Attachments.Add($p) | Out-Null
            }
        }
    }

    $mail.Send()
    JsonOut @{ success = $true; message = "Email sent to $To"; subject = $mail.Subject }
}

function Do-Reply {
    if (-not $Id) { ErrorOut "Missing -Id parameter" }

    $original = $ns.GetItemFromID($Id)
    $reply = if ($ReplyAll) { $original.ReplyAll() } else { $original.Reply() }

    if ($Body) {
        $bodyText = $Body.Replace('\n', "`n")
        $reply.Body = $bodyText + "`n`n" + $reply.Body
    }

    if ($Attachments) {
        foreach ($path in ($Attachments -split ",")) {
            $p = $path.Trim()
            if ($p -and (Test-Path $p)) {
                $reply.Attachments.Add($p) | Out-Null
            }
        }
    }

    $reply.Send()
    JsonOut @{ success = $true; message = "Reply sent to $($original.SenderName)" }
}

function Do-Forward {
    if (-not $Id) { ErrorOut "Missing -Id parameter" }
    if (-not $To) { ErrorOut "Missing -To parameter" }

    $original = $ns.GetItemFromID($Id)
    $fwd = $original.Forward()
    $fwd.To = $To
    if ($Cc) { $fwd.CC = $Cc }

    if ($Body) {
        $bodyText = $Body.Replace('\n', "`n")
        $fwd.Body = $bodyText + "`n`n" + $fwd.Body
    }

    $fwd.Send()
    JsonOut @{ success = $true; message = "Forwarded to $To" }
}

function Do-Folders {
    $storeRoot = $ns.DefaultStore.GetRootFolder()
    $results = @()
    $queue = New-Object System.Collections.Queue
    $maxDepth = 3

    foreach ($f in $storeRoot.Folders) {
        $queue.Enqueue(@{ folder = $f; path = $f.Name; depth = 1 })
    }

    while ($queue.Count -gt 0) {
        $item = $queue.Dequeue()
        $f = $item.folder
        $p = $item.path
        $d = $item.depth

        $results += @{
            name   = $f.Name
            path   = $p
            count  = $f.Items.Count
            unread = $f.UnReadItemCount
            depth  = $d
        }

        if ($d -lt $maxDepth) {
            try {
                foreach ($sf in $f.Folders) {
                    $queue.Enqueue(@{ folder = $sf; path = "$p/$($sf.Name)"; depth = ($d + 1) })
                }
            } catch {}
        }
    }

    JsonOut @{ folders = @($results) }
}

function Do-SaveAttachment {
    if (-not $Id) { ErrorOut "Missing -Id parameter" }
    if (-not $SavePath) { ErrorOut "Missing -SavePath parameter" }

    $mail = $ns.GetItemFromID($Id)

    if ($mail.Attachments.Count -eq 0) {
        ErrorOut "No attachments on this email"
    }

    # Ensure save directory exists
    if (-not (Test-Path $SavePath)) {
        New-Item -ItemType Directory -Path $SavePath -Force | Out-Null
    }

    $saved = @()
    if ($AttachmentIndex -gt 0) {
        $a = $mail.Attachments.Item($AttachmentIndex)
        $target = Join-Path $SavePath $a.FileName
        $a.SaveAsFile($target)
        $saved += @{ name = $a.FileName; path = $target; size = $a.Size }
    } else {
        # Save all
        for ($i = 1; $i -le $mail.Attachments.Count; $i++) {
            $a = $mail.Attachments.Item($i)
            $target = Join-Path $SavePath $a.FileName
            $a.SaveAsFile($target)
            $saved += @{ name = $a.FileName; path = $target; size = $a.Size }
        }
    }

    JsonOut @{ success = $true; saved = @($saved) }
}

function Do-MarkRead {
    if (-not $Id) { ErrorOut "Missing -Id parameter" }
    $mail = $ns.GetItemFromID($Id)
    $mail.UnRead = $false
    $mail.Save()
    JsonOut @{ success = $true; message = "Marked as read: $($mail.Subject)" }
}

function Do-MarkUnread {
    if (-not $Id) { ErrorOut "Missing -Id parameter" }
    $mail = $ns.GetItemFromID($Id)
    $mail.UnRead = $true
    $mail.Save()
    JsonOut @{ success = $true; message = "Marked as unread: $($mail.Subject)" }
}

# ── Dispatch ──────────────────────────────────────────────────────────────────

switch ($Command) {
    "search"          { Do-Search }
    "read"            { Do-Read }
    "send"            { Do-Send }
    "reply"           { Do-Reply }
    "forward"         { Do-Forward }
    "folders"         { Do-Folders }
    "save-attachment" { Do-SaveAttachment }
    "mark-read"       { Do-MarkRead }
    "mark-unread"     { Do-MarkUnread }
    default           { ErrorOut "Unknown command: $Command" }
}
