## Tool Integration

### Primary Tools

**IPInfo API** (ipinfo.io)
- API Key: `process.env.IPINFO_API_KEY`
- Capabilities: Geolocation, ASN, organization, abuse contacts, privacy detection
- Rate limits: Check API plan
- Client: `Tools/IpinfoClient.ts`

**System Tools** (always available)
- `whois` - Domain and IP WHOIS lookups
- `dig` - DNS queries
- `nslookup` - DNS resolution
- `curl` - HTTP requests, API calls

**MCP Tools** (security profile required)
- `httpx` - HTTP probing and technology detection
- `naabu` - Port scanning
- Note: Requires security MCP profile (`~/.claude/MCPs/swap-mcp security`)

### Future Tool Integration

**Shodan** (when API key added)
- Search for exposed services
- Historical scan data
- Vulnerability information

**Censys** (when API key added)
- Certificate searches
- Host discovery
- Internet-wide scanning data

**SecurityTrails** (when API key added)
- Historical DNS records
- WHOIS history
- Subdomain discovery

**VirusTotal** (when API key added)
- Domain/IP reputation
- Passive DNS
- Malware associations

## TypeScript Utilities

Located in `Tools/` directory:

**IpinfoClient.ts**
- IPInfo API wrapper with error handling
- Batch lookup support
- Rate limiting
- Response parsing

**DnsUtils.ts**
- DNS enumeration helpers
- Record type queries
- Zone transfer attempts
- Subdomain brute forcing

**WhoisParser.ts**
- WHOIS data parsing
- Structured output from raw WHOIS
- Registration date extraction
- Contact information parsing

**CidrUtils.ts**
- CIDR notation parsing
- IP range calculation
- Range validation
- IP address generation from CIDR

