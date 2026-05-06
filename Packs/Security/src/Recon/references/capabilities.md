## Core Capabilities

### Passive Reconnaissance (No Authorization Required)
- WHOIS lookups (domain and IP)
- DNS enumeration (A, AAAA, MX, NS, TXT, CNAME, SOA, etc.)
- Certificate transparency searches (subdomains, certificate history)
- IPInfo API (geolocation, ASN, organization, abuse contacts)
- Reverse DNS lookups
- BGP/ASN information gathering
- Historical DNS data
- Public database searches

### Active Reconnaissance (Requires Explicit Authorization)
- Port scanning (naabu MCP)
- Service detection and banner grabbing (httpx MCP)
- Technology fingerprinting
- Live host discovery
- HTTP/HTTPS probing
- SSL/TLS analysis

**CRITICAL AUTHORIZATION REQUIREMENTS:**

Active reconnaissance MUST have:
1. **Explicit user confirmation** for each active scan
2. **Documented authorization** (pentest engagement, bug bounty program, owned assets)
3. **Scope validation** (ensure target is in-scope)
4. **Rate limiting** (respectful scanning, no DoS)
5. **Session logging** (record all active recon for audit trail)

**Default behavior is PASSIVE ONLY.** Always confirm before active techniques.

## Available Workflows

### 1. `PassiveRecon.md` - Safe Reconnaissance
Non-intrusive intelligence gathering using public sources:
- WHOIS data
- DNS records
- Certificate transparency
- IPInfo lookups
- Reverse DNS
- No active scanning

**Input:** Domain, IP, or netblock
**Output:** Passive intelligence report
**Authorization:** None required

### 2. `IpRecon.md` - IP Address Investigation
Comprehensive IP address reconnaissance:
- IPInfo lookup (location, ASN, org, abuse contact)
- Reverse DNS
- WHOIS netblock info
- Certificate search (if IP has certs)
- Optional: Port scan (with authorization)
- Optional: Service detection (with authorization)

**Input:** Single IP address
**Output:** IP reconnaissance report
**Authorization:** Required for active scanning

### 3. `DomainRecon.md` - Domain Investigation
Full domain mapping and enumeration:
- WHOIS domain registration
- DNS records (all types)
- Subdomain enumeration (certificate transparency)
- Mail server configuration (MX, SPF, DMARC, DKIM)
- IP addresses behind domain
- Certificate analysis
- Technology stack detection
- Historical data

**Input:** Domain name
**Output:** Domain reconnaissance report
**Authorization:** Required for active subdomain probing

### 4. `NetblockRecon.md` - CIDR Range Scanning
Network range reconnaissance:
- CIDR parsing and validation
- Range size calculation
- WHOIS netblock ownership
- Optional: Live host discovery (with authorization)
- Optional: Port scan range (with authorization)
- ASN/organization mapping
- Interesting host identification

**Input:** CIDR notation (e.g., 192.168.1.0/24)
**Output:** Netblock scan report
**Authorization:** Required for active scanning

### 5. ASN Investigation
ASN and BGP reconnaissance (performed inline using WHOIS, IPInfo, and public BGP data):
- ASN to CIDR range mapping
- Organization information
- All IP ranges owned by ASN
- BGP peer relationships
- Geographic distribution
- Hosting/ISP identification

**Input:** ASN number (e.g., AS15169)
**Output:** ASN mapping report
**Authorization:** None required (passive data)

