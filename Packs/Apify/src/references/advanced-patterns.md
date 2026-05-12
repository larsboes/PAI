    )
  })

// Identify common complaints
const complaints = recentNegative.map(r => r.text)
```

### E-commerce & Competitive Intelligence

**Amazon - Price monitoring:**
```typescript
import { scrapeAmazonProduct } from 'actors'

const product = await scrapeAmazonProduct({
  productUrl: 'https://www.amazon.com/dp/B08L5VT894',
  includeReviews: true,
  maxReviews: 200
})

// Filter in code - only recent negative reviews
const recentNegative = product.reviews
  ?.filter(r => {
    const weekAgo = Date.now() - (7 * 24 * 60 * 60 * 1000)
    return (
      r.rating <= 2 &&
      new Date(r.date).getTime() > weekAgo
    )
  })

console.log(`Price: $${product.price}`)
console.log(`Rating: ${product.rating}/5`)
console.log(`Recent issues: ${recentNegative?.length} complaints`)
```

### Custom Web Scraping

**Any Website - Custom extraction:**
```typescript
import { scrapeWebsite } from 'actors'

const products = await scrapeWebsite({
  startUrls: ['https://example.com/products'],
  linkSelector: 'a.product-link',
  maxPagesPerCrawl: 100,
  pageFunction: `
    async function pageFunction(context) {
      const { request, $, log } = context

      return {
        url: request.url,
        title: $('h1.product-title').text(),
        price: $('span.price').text(),
        inStock: $('.in-stock').length > 0,
        description: $('.description').text()
      }
    }
  `
})

// Filter in code - only available products under $100
const affordable = products.filter(p =>
  p.inStock &&
  parseFloat(p.price.replace('$', '')) < 100
)
```

## 🎨 Advanced Patterns

### Pattern 1: Multi-Platform Social Listening

```typescript
import {
  scrapeInstagramHashtag,
  scrapeTikTokHashtag,
  searchYouTube
} from 'actors'

// Run all platforms in parallel
const [instagramPosts, tiktokVideos, youtubeVideos] = await Promise.all([
  scrapeInstagramHashtag({ hashtag: 'ai', maxResults: 100 }),
  scrapeTikTokHashtag({ hashtag: 'ai', maxResults: 100 }),
  searchYouTube({ query: '#ai', maxResults: 100 })
])

// Combine and filter - only viral content across all platforms
const allViral = [
  ...instagramPosts.filter(p => p.likesCount > 10000),
  ...tiktokVideos.filter(v => v.playCount > 100000),
  ...youtubeVideos.filter(v => v.viewsCount > 50000)
]

console.log(`Found ${allViral.length} viral posts across 3 platforms`)
```

### Pattern 2: Lead Enrichment Pipeline

```typescript
import { searchGoogleMaps, scrapeLinkedInProfile } from 'actors'

// 1. Find businesses on Google Maps
const restaurants = await searchGoogleMaps({
  query: 'restaurants in SF',
  maxResults: 100,
  scrapeContactInfo: true
})

// 2. Filter for qualified leads
const qualified = restaurants.filter(r =>
  r.rating >= 4.5 &&
  r.email &&
  r.reviewsCount >= 50
)

// 3. Enrich with LinkedIn data (if available)
const enriched = await Promise.all(
  qualified.map(async (restaurant) => {
    // Try to find LinkedIn company page
    // ... additional enrichment logic
    return restaurant
  })
)
```

### Pattern 3: Competitive Analysis Dashboard

