---
name: Investigation
description: "OSINT and people-finding — structured investigations across people, companies, domains, investments, and threat intel using 279+ public sources. Ethical framework built in. USE WHEN OSINT, due diligence, company intel, background check, find person, locate, people search, reconnect, public records, reverse lookup, social media search, verify identity, domain lookup, entity lookup, organization lookup, company lookup, threat intel, domain recon, subdomain enumeration."
---

# Investigation

Unified skill for OSINT and investigation workflows.

## Workflow Routing

| Request Pattern | Route To |
|---|---|
| Find person, locate, reconnect, lost contact, old friend | `PrivateInvestigator/Workflows/FindPerson.md` |
| Social media investigation, cross-platform search | `PrivateInvestigator/Workflows/SocialMediaSearch.md` |
| Public records, voter registration, court records | `PrivateInvestigator/Workflows/PublicRecordsSearch.md` |
| Reverse phone/email/image/username lookup | `PrivateInvestigator/Workflows/ReverseLookup.md` |
| Verify identity, confirm correct person | `PrivateInvestigator/Workflows/VerifyIdentity.md` |
| People lookup, background check (structured OSINT) | `OSINT/Workflows/PeopleLookup.md` |
| Company intel, business databases, tech profiling | `OSINT/Workflows/CompanyLookup.md` |
| Investment due diligence, vet company, is this legit | `OSINT/Workflows/CompanyDueDiligence.md` |
| Entity/threat intel, IP check, malicious actor | `OSINT/Workflows/EntityLookup.md` |
| Domain/subdomain recon, DNS, certificate transparency | `OSINT/Workflows/DomainLookup.md` |
| Organization, NGO, government agency research | `OSINT/Workflows/OrganizationLookup.md` |
| Find new OSINT sources | `OSINT/Workflows/DiscoverOSINTSources.md` |

## Resources

| File | Purpose |
|------|---------|
| `OSINT/SOURCES.JSON` | 279 OSINT sources across 8 categories |
| `OSINT/SOURCES.md` | Human-readable source reference |
| `OSINT/EthicalFramework.md` | Authorization, legal, ethical boundaries |
| `OSINT/Methodology.md` | Collection methods, verification, reporting |
| `OSINT/EntityTools.md` | Threat intel, scanning, malware analysis |
| `OSINT/CompanyTools.md` | Business databases, DNS, tech profiling |
| `OSINT/PeopleTools.md` | People search, social media, public records |

## Authorization (REQUIRED before any investigation)

- [ ] Explicit authorization confirmed
- [ ] Scope defined
- [ ] Legal compliance verified

**STOP if unchecked.** See `OSINT/EthicalFramework.md`.

## Agent Fleet Patterns

| Scale | Agents |
|-------|--------|
| Quick lookup / reverse lookup | 4-6 |
| Standard investigation | 8-16 |
| People-finding (PI mode) | 15 (5 types × 3) = 45 parallel threads |
| Comprehensive due diligence | 24-32 |

Use PerplexityResearcher (current web), ClaudeResearcher (academic depth), GeminiResearcher (multi-perspective), GrokResearcher (fact-checking).

## People-Finding Confidence Scoring

| Level | Criteria | Action |
|-------|----------|--------|
| HIGH | 3+ unique identifiers match across independent sources | Safe to act |
| MEDIUM | 2 identifiers match, timeline consistent | Verify before acting |
| LOW | Single source or name-only match | Needs more investigation |
| POSSIBLE | Partial match | Do not act without more data |
