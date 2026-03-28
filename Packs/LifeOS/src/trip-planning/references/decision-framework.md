# Decision Framework for Trips

How to structure trip decisions cleanly.

## Decision Format

For each decision, use this template:

```markdown
## Decision: [What needs to be decided?]

### Options
1. **[Option A]** — [cost, tradeoffs]
2. **[Option B]** — [cost, tradeoffs]
3. **[Option C]** — [cost, tradeoffs]

### Criteria
- Cost: [$X - $Y range]
- Time: [Duration impact]
- Fit: [Does it work with your schedule/goals?]

### Analysis
[Why each option scores differently on criteria]

### Chosen
**[Option X] because [reason]**

### Once Decided
[What happens next? Who needs to know? When is it due?]
```

## Decision Log Template

```markdown
# Trip: [Location] — Decision Log

| Decision | Options | Chosen | Why | Deadline | Status |
|----------|---------|--------|-----|----------|--------|
| Transport | Flight vs Train | Flight (13h vs 24h) | Fits schedule | Jan 15 | ✅ Booked |
| Dates | Mar 5-12 vs Mar 12-19 | Mar 5-12 | Conflicts less | Jan 10 | ✅ Confirmed |
| Accommodation | Hotel vs Hostel | Hotel (quieter, wifi) | Need to work | Jan 20 | 🔄 Searching |
| Activities | Conference only vs explore | Both (conference + 2 days exploring) | Experiences focus | Jan 25 | 📝 Planning |
```

## Key Principle: Don't Relitigate

Once you've decided and logged it, **don't bring it back up**. This kills momentum.

If circumstances change (someone cancels, price drops), make a NEW decision entry.

## Common Decision Points

### Before You Book Anything

| Decision | Factors |
|----------|---------|
| **Dates** | Your schedule, destination events, cost differences |
| **Purpose** | Work? Leisure? Conference? Mix? |
| **Alone or group?** | Travel style, cost, scheduling complexity |
| **Budget cap** | What's your total? Work backward from there |

### After Dates Locked

| Decision | Factors |
|----------|---------|
| **Transport mode** | Time vs cost vs comfort |
| **Accommodation area** | Walkability, wifi, cost, vibe |
| **How long to stay** | Can be extended or shortened, what's the sweet spot? |

### After Location Locked

| Decision | Factors |
|----------|---------|
| **Work commitments** | How many hours/day? Time of day? Flexibility? |
| **Must-do activities** | Events, conferences, specific people to see |
| **Explore vs plan** | How structured vs spontaneous? |

## Decision Anxiety Check

If you're anxious about a decision, ask:

1. **Is this reversible?** (Most travel decisions are — you can change plans)
2. **What's the cost of delay?** (Prices go up, availability decreases)
3. **What's the cost of wrong choice?** (Usually small for travel)
4. **Do you have enough info to decide?** (If yes, decide now; if no, gather 1-2 more data points, then decide)

Most travel decisions matter far less than they feel in the moment.

## Example: Conference Trip Decision Log

```markdown
# Trip: [Conference Name] [City]

## Decision: Dates

**Options:**
- Option A: June 5-9 (conference days only)
- Option B: June 4-10 (arrive day early, leave day after)

**Chosen:** June 4-10
**Why:** Worth 2 extra days to explore the city, not rushed

**Deadline:** April 1
**Status:** ✅ Confirmed

---

## Decision: Transport

**Options:**
- Flight ([Home City] → [Destination]): 2.5 hours, €80-150
- Train ([Home City] → [Destination]): 8 hours, €40-80

**Chosen:** Flight
**Why:** Short window, need to work before conference, can't lose 8 hours each way

**Booked:** [Airline], June 4 @ 10am, return June 10 @ 4pm
**Cost:** €120

---

## Decision: Hotel Area

**Options:**
- Innere Stadt (touristy, central): €150/night
- Wieden (quieter, local): €80/night
- Alsergrund (university area, young): €70/night

**Chosen:** Wieden
**Why:** Balance of quiet (need to work mornings) and walkable

**Booked:** Pension Wieden, June 4-10
**Cost:** €480 (negotiated to €450)
```
