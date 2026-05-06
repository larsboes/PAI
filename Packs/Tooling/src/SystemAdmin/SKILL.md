---
name: SystemAdmin
description: "Linux system administration via CLI — systemd services, journalctl logs, networking (ip/ss/nftables), process management, disk/memory diagnostics, and performance troubleshooting. Direct commands, no GUIs. Use when managing services, debugging system issues, checking resources, or configuring networking."
---

# System Admin — Linux CLI

Everything you need to manage a Linux box. Direct commands.

## Quick Reference: First Response Commands

```bash
# What's wrong right now?
journalctl -p err --since "1 hour ago" --no-pager
systemctl --failed
dmesg --level=err,warn | tail -20

# Resource snapshot
free -h && echo "---" && df -h / && echo "---" && uptime

# What's eating resources?
ps aux --sort=-%mem | head -10    # top memory consumers
ps aux --sort=-%cpu | head -10    # top CPU consumers
iotop -b -n 1 2>/dev/null || iostat -x 1 1  # disk I/O

# Network
ss -tulnp                         # listening ports
ip -br addr                       # all interfaces with IPs
curl -sf http://localhost:PORT/health && echo OK || echo FAIL
```

## Systemd Services

```bash
# Manage services
systemctl start|stop|restart|reload SERVICE
systemctl enable|disable SERVICE      # start on boot
systemctl status SERVICE              # current state + recent logs
systemctl is-active SERVICE           # just active/inactive

# See all services
systemctl list-units --type=service --state=running
systemctl list-units --type=service --state=failed

# Service logs
journalctl -u SERVICE -f              # follow live
journalctl -u SERVICE --since today   # today's logs
journalctl -u SERVICE -n 100 --no-pager  # last 100 lines

# Create a service
cat > /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=app
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now myapp
```

## Journalctl (Logs)

```bash
# Filter by priority
journalctl -p crit                    # critical only
journalctl -p err                     # errors and above
journalctl -p warning                 # warnings and above

# Time-based
journalctl --since "2024-01-15 10:00" --until "2024-01-15 11:00"
journalctl --since "30 min ago"
journalctl -b                         # this boot only
journalctl -b -1                      # previous boot

# Output formats
journalctl -u SERVICE -o json-pretty  # structured JSON
journalctl -u SERVICE -o short-iso    # ISO timestamps
journalctl -u SERVICE --output=cat    # message only, no metadata

# Disk usage
journalctl --disk-usage
journalctl --vacuum-size=500M         # trim to 500MB
journalctl --vacuum-time=7d           # keep only 7 days
```

## Networking

```bash
# Interfaces
ip -br link                           # all interfaces
ip -br addr                           # IPs per interface
ip route                              # routing table
ip neigh                              # ARP table

# Ports & Connections
ss -tulnp                             # listening TCP/UDP with process
ss -s                                 # socket summary
ss -tnp state established             # active connections
ss -tnp dst :443                      # connections to port 443

# DNS
resolvectl status                     # DNS config (systemd-resolved)
dig +short example.com                # resolve hostname
dig +trace example.com                # full resolution path

# Firewall (nftables)
nft list ruleset                      # show all rules
nft add rule inet filter input tcp dport 8080 accept  # allow port

# Quick connectivity test
ping -c 3 8.8.8.8                     # basic connectivity
curl -sf --max-time 5 https://example.com > /dev/null && echo OK
traceroute -n example.com             # path to destination
mtr -n --report example.com           # combined ping+traceroute
```

## Process Management

```bash
# Find processes
pgrep -a nginx                        # find by name
ps aux | grep '[n]ginx'               # grep without self-match
pidof nginx                           # just the PIDs
lsof -i :3000                         # what's on port 3000

# Signals
kill PID                              # SIGTERM (graceful)
kill -9 PID                           # SIGKILL (force)
kill -HUP PID                         # reload config
pkill -f "pattern"                    # kill by command pattern

# Resource limits
ulimit -a                             # show current limits
prlimit --pid PID                     # per-process limits
cat /proc/PID/limits                  # see actual limits
```

## Workflow Routing

| Trigger | Workflow |
|---------|----------|
| "service not starting", "systemd", "unit file" | `Workflows/Services.md` |
| "out of memory", "disk full", "slow" | `Workflows/Diagnostics.md` |
| "networking", "can't connect", "port" | `Workflows/Networking.md` |
| "logs", "what happened", "errors" | `Workflows/Logs.md` |
| "cron", "scheduled task", "timer" | `Workflows/Scheduling.md` |

## Deep References

- `references/systemd.md` — Unit file syntax, timers, socket activation, dependencies
- `references/performance.md` — perf, strace, bpftrace, flamegraphs
- `references/disk.md` — LVM, RAID, fstab, mount options, inode exhaustion
- `references/security.md` — SSH hardening, fail2ban, audit logs, SELinux
- `references/containers.md` — cgroups, namespaces, systemd-nspawn

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/syscheck.sh` | Full system health check (CPU, mem, disk, services, logs) |
| `scripts/port-check.sh` | Check if port is open, who owns it, firewall status |
| `scripts/log-errors.sh` | Aggregate recent errors across all services |
| `scripts/disk-hogs.sh` | Find largest files/directories consuming disk |

## Output
- Produces: Diagnostic reports, commands to execute, or unit files
- Format: Shell commands or systemd configuration
