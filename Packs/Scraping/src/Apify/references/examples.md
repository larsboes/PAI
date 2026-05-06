const viral = profile.latestPosts?.filter(p => p.likesCount > 10000)

// 3. Only filtered results reach model context
console.log(viral) // ~10 posts instead of 50
```

## 📚 Examples by Use Case

### Social Media Monitoring

**Instagram - Track engagement:**
```typescript
import { scrapeInstagramProfile, scrapeInstagramPosts } from 'actors'

// Get profile with recent posts
const profile = await scrapeInstagramProfile({
  username: 'competitor',
  maxPosts: 100
})

// Filter in code - only high-performing posts from last 30 days
const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000)
const topRecent = profile.latestPosts
  ?.filter(p =>
    new Date(p.timestamp).getTime() > thirtyDaysAgo &&
    p.likesCount > 5000
  )
  .sort((a, b) => b.likesCount - a.likesCount)
  .slice(0, 10)

// Only 10 posts reach model instead of 100!
```

**LinkedIn - Job search:**
```typescript
import { searchLinkedInJobs } from 'actors'

const jobs = await searchLinkedInJobs({
  keywords: 'AI engineer',
  location: 'San Francisco',
  remote: true,
  maxResults: 200
})

// Filter in code - only senior roles at well-funded startups
const topJobs = jobs.filter(j =>
  j.seniority?.includes('Senior') &&
  parseInt(j.applicants || '0') > 50
)
```

**TikTok - Trend analysis:**
```typescript
import { scrapeTikTokHashtag } from 'actors'

const videos = await scrapeTikTokHashtag({
  hashtag: 'ai',
  maxResults: 500
})

// Filter in code - only viral content
const viral = videos
  .filter(v => v.playCount > 1000000)
  .sort((a, b) => b.playCount - a.playCount)
  .slice(0, 20)
```

### Lead Generation (Business Intelligence)

**Google Maps - Local business leads:**
```typescript
import { searchGoogleMaps } from 'actors'

// Search with contact info extraction
const places = await searchGoogleMaps({
  query: 'restaurants in Austin',
  maxResults: 500,
  includeReviews: true,
  maxReviewsPerPlace: 20,
  scrapeContactInfo: true // Extracts emails from websites!
})

// Filter in code - only highly-rated with email/phone
const qualifiedLeads = places
  .filter(p =>
    p.rating >= 4.5 &&
    p.reviewsCount >= 100 &&
    (p.email || p.phone)
  )
  .map(p => ({
    name: p.name,
    rating: p.rating,
    reviews: p.reviewsCount,
    email: p.email,
    phone: p.phone,
    website: p.website,
    address: p.address
  }))

// Export leads - only qualified results!
console.log(`Found ${qualifiedLeads.length} qualified leads`)
```

**Google Maps - Review sentiment analysis:**
```typescript
import { scrapeGoogleMapsReviews } from 'actors'

const reviews = await scrapeGoogleMapsReviews({
  placeUrl: 'https://maps.google.com/maps?cid=12345',
  maxResults: 1000
})

// Filter in code - analyze sentiment by rating
const recentNegative = reviews
  .filter(r => {
    const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000)
    return (
      r.rating <= 2 &&
      new Date(r.publishedAtDate).getTime() > thirtyDaysAgo &&
      r.text.length > 50
