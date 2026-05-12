```typescript
import {
  scrapeInstagramProfile,
  scrapeYouTubeChannel,
  scrapeTikTokProfile
} from 'actors'

async function analyzeCompetitor(username: string) {
  // Gather data from all platforms
  const [instagram, youtube, tiktok] = await Promise.all([
    scrapeInstagramProfile({ username, maxPosts: 30 }),
    scrapeYouTubeChannel({ channelUrl: `https://youtube.com/@${username}`, maxVideos: 30 }),
    scrapeTikTokProfile({ username, maxVideos: 30 })
  ])

  // Calculate engagement metrics in code
  return {
    username,
    instagram: {
      followers: instagram.followersCount,
      avgLikes: average(instagram.latestPosts?.map(p => p.likesCount) || []),
      engagementRate: calculateEngagement(instagram)
    },
    youtube: {
      subscribers: youtube.subscribersCount,
      avgViews: average(youtube.videos?.map(v => v.viewsCount) || [])
    },
    tiktok: {
      followers: tiktok.followersCount,
      avgPlays: average(tiktok.videos?.map(v => v.playCount) || [])
    }
  }
}
```

## 💰 Token Savings Calculator

**Example: Instagram profile with 100 posts**

**MCP Approach:**
```
1. search-actors → 1,000 tokens
2. call-actor → 1,000 tokens
3. get-actor-output → 50,000 tokens (100 unfiltered posts)
TOTAL: ~52,000 tokens
```

**File-Based Approach:**
```typescript
const profile = await scrapeInstagramProfile({
  username: 'user',
  maxPosts: 100
})

// Filter in code - only top 10 posts
const top = profile.latestPosts
  ?.sort((a, b) => b.likesCount - a.likesCount)
  .slice(0, 10)

// TOTAL: ~500 tokens (only 10 filtered posts reach model)
```

**Savings: 99% reduction (52,000 → 500 tokens)**

## 🔧 Actor Reference

### Social Media

#### Instagram
- `scrapeInstagramProfile(input)` - Profile + posts
- `scrapeInstagramPosts(input)` - Posts from user
- `scrapeInstagramHashtag(input)` - Posts by hashtag
- `scrapeInstagramComments(input)` - Comments on post

#### LinkedIn
- `scrapeLinkedInProfile(input)` - Profile + experience + email
- `searchLinkedInJobs(input)` - Job listings
- `scrapeLinkedInPosts(input)` - Posts from profile/company

#### TikTok
- `scrapeTikTokProfile(input)` - Profile + videos
- `scrapeTikTokHashtag(input)` - Videos by hashtag
- `scrapeTikTokComments(input)` - Comments on video

#### YouTube
- `scrapeYouTubeChannel(input)` - Channel + videos
- `searchYouTube(input)` - Search videos
- `scrapeYouTubeComments(input)` - Comments on video

#### Facebook
- `scrapeFacebookPosts(input)` - Posts from pages
- `scrapeFacebookGroups(input)` - Group posts
- `scrapeFacebookComments(input)` - Post comments

### Business & Lead Generation

#### Google Maps
- `searchGoogleMaps(input)` - Search places (with contact extraction!)
- `scrapeGoogleMapsPlace(input)` - Single place details
- `scrapeGoogleMapsReviews(input)` - Place reviews

### E-commerce

#### Amazon
- `scrapeAmazonProduct(input)` - Product details + reviews
- `scrapeAmazonReviews(input)` - Product reviews only

### Web Scraping

#### General Web
- `scrapeWebsite(input)` - Custom multi-page crawling
- `scrapePage(url, pageFunction)` - Single page extraction

## ⚙️ Configuration

**Environment Variables:**
```bash
# Required - Get from https://console.apify.com/account/integrations
APIFY_TOKEN=apify_api_xxxxx...
```

**Actor Run Options:**
```typescript
{
  memory: 2048,    // MB: 128, 256, 512, 1024, 2048, 4096, 8192
  timeout: 300,    // seconds
  build: 'latest'  // or specific build number
}
```

## 🎯 When to Use This vs MCP

**Use File-Based (this skill):**
- ✅ Need to filter large datasets (>100 results)
- ✅ Want to transform/aggregate data in code
- ✅ Multiple sequential operations
- ✅ Control flow (loops, conditionals)
- ✅ Maximum token efficiency

**Use MCP:**
- ❌ Simple single operations with small results (<10 items)
- ❌ One-off exploratory queries
- ❌ Don't want to write code

## 🔗 Links

- Apify Platform: https://apify.com
- Actor Store: https://apify.com/store
- API Docs: https://docs.apify.com/api/v2

---

**Remember: Filter data in code BEFORE returning to model context. This is where the 99% token savings happen!**
