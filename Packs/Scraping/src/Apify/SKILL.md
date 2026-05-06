---
name: Apify
description: "Social media and business data scraping via Apify actors — Twitter, Instagram, LinkedIn, TikTok, YouTube, Google Maps, Amazon, and more. Use when scraping social platforms or e-commerce sites."
---

# Apify - Social Media & Web Scraping

Direct TypeScript access to 9 popular Apify actors with 99% token savings.

## 🔌 File-Based MCP

This skill is a **file-based MCP** - a code-first API wrapper that replaces token-heavy MCP protocol calls.

**Why file-based?** Filter data in code BEFORE returning to model context = 97.5% token savings.

**Architecture:** See `~/.claude/PAI/DOCUMENTATION/FileBasedMCPs.md`

## 🎯 Overview

Direct TypeScript access to the 9 most popular Apify actors without MCP overhead. Filter and transform data in code BEFORE it reaches the model context.

## 📊 Available Actors

### Social Media (5 platforms)
- **Instagram** (145k users, 4.60★) - Profiles, posts, hashtags, comments
- **LinkedIn** (26k users, 4.10★) - Profiles, jobs, posts
- **TikTok** (90k users, 4.61★) - Profiles, videos, hashtags, comments
- **YouTube** (40k users, 4.40★) - Channels, videos, comments, search
- **Facebook** (35k users, 4.56★) - Posts, groups, comments

### Business & Lead Generation
- **Google Maps** (198k users, 4.76★) - **HIGHEST VALUE!**
  - Search businesses, extract contacts, reviews, images
  - Perfect for lead generation

### E-commerce
- **Amazon** (8k users, 4.97★) - Products, reviews, pricing

### Web Scraping
- **Web Scraper** (94k users, 4.39★) - General-purpose, works with ANY website

## 🚀 Quick Start

### Basic Usage Pattern

```typescript
import { scrapeInstagramProfile, searchGoogleMaps } from 'actors'

// 1. Call the actor wrapper
const profile = await scrapeInstagramProfile({
  username: 'target_username',
  maxPosts: 50
})

// 2. Filter in code - BEFORE data reaches model!

## Deep References

| Reference | Content |
|-----------|---------|
| `references/examples.md` | Full examples by use case (social media, lead gen, e-commerce) |
| `references/advanced-patterns.md` | Multi-platform listening, lead enrichment, competitive analysis |
| `references/actor-catalog.md` | Detailed actor parameters, config, and API reference |

## When to Use This vs BrightData

- **Apify:** Social media platforms, business data, e-commerce — uses specialized actors
- **BrightData:** Generic URL scraping with anti-bot escalation — no specialized knowledge

## Configuration

```bash
export APIFY_TOKEN="apify_api_xxxx"  # Get from https://console.apify.com/account/integrations
```

## Output
- Produces: Filtered, structured data from platform APIs
- Format: JSON arrays (pre-filtered in code before reaching context)
