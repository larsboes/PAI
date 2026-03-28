# Art Skill Integration

Two built-in themes. Choose per video based on content, or ask the user.

## Themes

| Theme | When to Use | Look |
|-------|------------|------|
| **apple** | Product demos, presentations, clean explainers | White background, blue accents, crisp snappy animations |
| **charcoal** | Cinematic, moody, artistic, data viz, storytelling | Dark slate, purple accents, organic gestural animations |

**When unclear, ask the user:** "Apple-style (clean white) or charcoal (dark cinematic)?"

Users can also customize via `~/.claude/PAI/USER/SKILLCUSTOMIZATIONS/Art/PREFERENCES.md`.

## Usage

```typescript
import { selectTheme, PAI_THEME } from './Tools/Theme'

// Option 1: Select explicitly
const theme = selectTheme('apple')    // or 'charcoal'

// Option 2: Use default (charcoal)
const theme = PAI_THEME
```

## Theme Quick Reference

### Apple (clean white)
```
background: #FFFFFF          accent: #0071E3 (Apple blue)
text: #1D1D1F               animations: crisp, snappy springs
```

### Charcoal (dark cinematic)
```
background: #0f172a          accent: #8b5cf6 (purple)
text: #f1f5f9               animations: organic, gestural springs
```

## Using Themes in Components

```typescript
import { selectTheme, titleScreenStyle, fadeInterpolation } from './Tools/Theme'

export const MyScene: React.FC<{ themeName: 'apple' | 'charcoal' }> = ({ themeName }) => {
  const theme = selectTheme(themeName)
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const opacity = interpolate(
    frame,
    fadeInterpolation(theme).inputRange,
    fadeInterpolation(theme).outputRange,
    { extrapolateRight: 'clamp' }
  )

  const scale = spring({
    frame, fps,
    config: theme.animation.springDefault
  })

  return (
    <AbsoluteFill style={titleScreenStyle(theme)}>
      <h1 style={{
        ...theme.typography.title,
        color: theme.colors.text,
        opacity,
        transform: `scale(${scale})`
      }}>
        Title Here
      </h1>
    </AbsoluteFill>
  )
}
```
