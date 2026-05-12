# Systemd — Complete Reference

## Unit File Locations

| Path | Priority | Use For |
|------|----------|---------|
| `/etc/systemd/system/` | Highest | Admin-created services |
| `/run/systemd/system/` | Runtime | Transient units |
| `/usr/lib/systemd/system/` | Lowest | Package-installed |

## Unit File Template

```ini
[Unit]
Description=My Service
Documentation=https://example.com/docs
After=network-online.target postgresql.service
Wants=network-online.target
Requires=postgresql.service

[Service]
Type=notify              # simple|forking|oneshot|notify|dbus
User=app
Group=app
WorkingDirectory=/opt/myapp
ExecStartPre=/opt/myapp/check-config.sh
ExecStart=/opt/myapp/bin/server --config /etc/myapp/config.yaml
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -TERM $MAINPID

# Restart behavior
Restart=on-failure
RestartSec=5
StartLimitBurst=5
StartLimitIntervalSec=60

# Environment
Environment=NODE_ENV=production
EnvironmentFile=-/etc/myapp/env    # - means optional

# Security hardening
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
ReadWritePaths=/var/lib/myapp /var/log/myapp

# Resource limits
MemoryMax=512M
CPUQuota=200%
TasksMax=256

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
```

## Service Types

| Type | Behavior | Use When |
|------|----------|----------|
| `simple` | ExecStart IS the main process | Most services (default) |
| `forking` | ExecStart forks, parent exits | Legacy daemons (nginx, apache) |
| `oneshot` | Runs once, then exits | Setup scripts, migrations |
| `notify` | Service signals ready via sd_notify | Services that need init time |
| `exec` | Like simple but waits for exec() | When you need exec confirmation |

## Timers (Replacement for Cron)

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily backup timer

[Timer]
OnCalendar=*-*-* 02:00:00    # daily at 2am
# Or interval-based:
# OnBootSec=5min              # 5 min after boot
# OnUnitActiveSec=1h          # every hour after last run
Persistent=true               # run if missed while off
RandomizedDelaySec=300        # ±5min jitter

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/backup.service
[Unit]
Description=Daily backup

[Service]
Type=oneshot
ExecStart=/opt/scripts/backup.sh
```

```bash
# Enable timer
systemctl enable --now backup.timer

# List timers
systemctl list-timers --all

# See next trigger
systemctl status backup.timer
```

## Calendar Expressions

| Expression | Meaning |
|-----------|---------|
| `*-*-* *:*:00` | Every minute |
| `*-*-* *:00:00` | Every hour |
| `*-*-* 00:00:00` | Daily at midnight |
| `Mon *-*-* 09:00:00` | Every Monday at 9am |
| `*-*-01 00:00:00` | First of every month |
| `*-01,07-01 00:00:00` | Jan 1 and Jul 1 |

```bash
# Test calendar expressions
systemd-analyze calendar "Mon *-*-* 09:00:00"
systemd-analyze calendar "daily"
```

## Dependency Management

```ini
# Hard dependency (fails if dep fails)
Requires=postgresql.service
After=postgresql.service

# Soft dependency (continues if dep fails)
Wants=redis.service
After=redis.service

# Ordering only (no dependency)
Before=nginx.service

# Conflict (can't run together)
Conflicts=apache2.service
```

## Useful Commands

```bash
# Reload after editing unit files
systemctl daemon-reload

# Show full unit file
systemctl cat SERVICE

# Show overrides
systemctl show SERVICE -p FragmentPath
systemd-delta                    # show all overrides

# Override without editing original
systemctl edit SERVICE           # creates override in /etc/systemd/system/SERVICE.d/
systemctl edit --full SERVICE    # full copy to override

# Analyze boot
systemd-analyze                  # boot time
systemd-analyze blame            # slow services
systemd-analyze critical-chain   # dependency chain

# Temporary service (runs once, no unit file)
systemd-run --unit=temp-task --remain-after-exit /path/to/script.sh

# User services (no root needed)
systemctl --user enable myservice
# Unit files in ~/.config/systemd/user/
```

## Socket Activation

```ini
# myapp.socket
[Unit]
Description=My App Socket

[Socket]
ListenStream=8080
Accept=no

[Install]
WantedBy=sockets.target
```

Service starts on first connection. Zero resource use until needed.

## Journal Storage

```bash
# Config: /etc/systemd/journald.conf
[Journal]
Storage=persistent         # auto|volatile|persistent|none
Compress=yes
SystemMaxUse=500M          # max disk usage
MaxRetentionSec=30day      # max age
```
