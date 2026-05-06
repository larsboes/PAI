---
name: Recon
description: "Network reconnaissance — subdomain enumeration, port scanning, DNS/WHOIS/ASN lookups, endpoint discovery, mass scanning, and corporate structure mapping. Use for attack surface discovery and bug bounty."
---

# recon

**Infrastructure and Network Reconnaissance**


## Purpose

Technical reconnaissance of network infrastructure including domains, IP addresses, netblocks, and ASNs. Combines passive intelligence gathering with authorized active scanning to map attack surfaces and identify assets.


## When to Use This Skill

**Core Triggers - Use this skill when user says:**

### Direct Recon Requests
- "do recon on [target]" or "run recon"
- "perform reconnaissance on [target]" or "conduct recon"
- "do infrastructure recon" or "network reconnaissance"
- "basic recon", "quick recon", "simple recon"
- "comprehensive recon", "deep recon", "full reconnaissance"
- "recon [target]" (just recon + target)
- "passive recon", "active recon"

### Infrastructure & Network Mapping
- "map infrastructure for [domain]" or "map network"
- "enumerate [domain] infrastructure" or "discover assets"
- "find subdomains of [domain]" or "enumerate subdomains"
- "scan [target]" or "port scan [IP/netblock]"
- "what services are running on [IP]"
- "investigate [IP address/domain/netblock]"

### IP & Domain Investigation
- "recon this IP" or "investigate this IP address"
- "look up [IP]" or "IP lookup [address]"
- "what is [IP]" or "who owns [IP]"
- "domain recon" or "domain investigation"
- "DNS recon", "DNS enumeration"
- "WHOIS [domain/IP]"

### ASN & Netblock Research
- "investigate [ASN]" or "research ASN"
- "scan [CIDR range/netblock]"
- "find IPs in [netblock]"
- "enumerate netblock" or "netblock scanning"

### Passive vs Active Recon
- "passive recon on [target]" (no authorization required)
- "active scan [target]" (requires explicit authorization)
- "safe reconnaissance" (passive only)
- "authorized scan" (active techniques)

### Use Case Indicators
- Investigating IP addresses for ownership, location, and services
- Mapping domain infrastructure and DNS configuration
- Scanning netblocks or CIDR ranges for live hosts
- Researching ASN ownership and IP allocations
- Attack surface enumeration and network mapping
- Called by OSINT for infrastructure mapping of entities

## Relationship with Other Security Skills

**OSINT → recon (Common Pattern):**
- OSINT identifies entities, companies, people (social/public records focus)
- Recon maps their technical infrastructure (network/system focus)
- Example flow: OSINT finds company → Recon maps their domains/IPs/infrastructure

**recon → webassessment:**
- Recon identifies web applications and services
- Web assessment tests those applications for vulnerabilities
- Example: Recon finds subdomain api.target.com → Web assessment fuzzes/tests it

**Workflow Integration:**
```typescript
// OSINT skill discovers company infrastructure
const domains = await osintFindCompanyDomains("Acme Corp");

// Calls recon skill to map technical details
const infraMap = await reconDomain(domains[0]);

// Recon identifies web apps
const webApps = infraMap.subdomains.filter(s => s.hasHTTP);

// Calls web assessment for testing
await webAssessment(webApps);
```


## Deep References

| Reference | Content |
|-----------|---------|
| `references/capabilities.md` | Passive vs active recon capabilities, full technique list |
| `references/tools.md` | Tool integration details, primary tools, TypeScript utilities |
| `references/output-formats.md` | Report templates for IP, domain, netblock, ASN recon |

## Output
- Produces: Reconnaissance reports with discovered subdomains, IPs, services
- Format: Structured markdown reports per output-formats.md templates
