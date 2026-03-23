/**
 * PAI Themes for Remotion
 *
 * Two built-in themes:
 * - "apple": Clean white, minimal, crisp animations (Apple keynote style)
 * - "charcoal": Dark slate, purple accents, organic feel
 *
 * Choose per video based on content, or ask the user.
 * Override via ~/.claude/PAI/USER/SKILLCUSTOMIZATIONS/Art/PREFERENCES.md
 */

// ─── Shared constants ───────────────────────────────────────────────

const SHARED_TYPOGRAPHY = {
  fontFamily: 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
  fontFamilyMono: 'ui-monospace, SFMono-Regular, "SF Mono", Menlo, monospace',
  title: { fontSize: 72, fontWeight: 'bold' as const, lineHeight: 1.1 },
  subtitle: { fontSize: 48, fontWeight: '600' as const, lineHeight: 1.2 },
  heading: { fontSize: 36, fontWeight: '600' as const, lineHeight: 1.3 },
  body: { fontSize: 24, fontWeight: 'normal' as const, lineHeight: 1.5 },
  caption: { fontSize: 18, fontWeight: 'normal' as const, lineHeight: 1.4 },
  small: { fontSize: 14, fontWeight: 'normal' as const, lineHeight: 1.4 },
}

const SHARED_SPACING = {
  page: 100,
  section: 60,
  element: 30,
  tight: 15,
  paragraphGap: 24,
  listItemGap: 16,
}

const SHARED_BORDER_RADIUS = {
  small: 8,
  medium: 16,
  large: 24,
  full: 9999,
}

// ─── Apple Theme ────────────────────────────────────────────────────

const APPLE_THEME = {
  name: 'apple' as const,
  colors: {
    background: '#FFFFFF',
    backgroundAlt: '#F5F5F7',
    backgroundDark: '#E8E8ED',
    accent: '#0071E3',            // Apple blue
    accentLight: '#2997FF',
    accentDark: '#0056B3',
    accentMuted: '#5AC8FA',
    text: '#1D1D1F',              // Near black
    textMuted: '#6E6E73',
    textDark: '#86868B',
    paperGround: '#FBFBFD',
    coolWash: 'rgba(0, 113, 227, 0.05)',
    warmWash: 'rgba(255, 149, 0, 0.05)',
    success: '#34C759',
    warning: '#FF9500',
    error: '#FF3B30',
    info: '#0071E3',
  },
  typography: SHARED_TYPOGRAPHY,
  animation: {
    springFast: { damping: 20, stiffness: 180 },    // Crisp, precise
    springDefault: { damping: 16, stiffness: 120 },
    springSlow: { damping: 14, stiffness: 90 },
    springBouncy: { damping: 10, stiffness: 140 },
    fadeFrames: 20,         // Snappier fades
    quickFade: 10,
    slowFade: 30,
    staggerDelay: 8,
    staggerFast: 4,
    staggerSlow: 12,
  },
  spacing: SHARED_SPACING,
  effects: {
    textShadow: 'none',
    boxShadow: '0 2px 8px rgba(0,0,0,0.08)',
    boxShadowLarge: '0 8px 24px rgba(0,0,0,0.12)',
    glow: 'none',
  },
  borderRadius: SHARED_BORDER_RADIUS,
} as const

// ─── Charcoal Theme ─────────────────────────────────────────────────

const CHARCOAL_THEME = {
  name: 'charcoal' as const,
  colors: {
    background: '#0f172a',        // Deep slate
    backgroundAlt: '#1e293b',
    backgroundDark: '#020617',
    accent: '#8b5cf6',            // Purple/violet
    accentLight: '#a78bfa',
    accentDark: '#7c3aed',
    accentMuted: '#6366f1',
    text: '#f1f5f9',              // Light text
    textMuted: '#94a3b8',
    textDark: '#64748b',
    paperGround: '#F5F5F0',
    coolWash: 'rgba(139, 92, 246, 0.1)',
    warmWash: 'rgba(251, 191, 36, 0.1)',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    info: '#3b82f6',
  },
  typography: SHARED_TYPOGRAPHY,
  animation: {
    springFast: { damping: 15, stiffness: 150 },    // Organic, gestural
    springDefault: { damping: 12, stiffness: 100 },
    springSlow: { damping: 10, stiffness: 80 },
    springBouncy: { damping: 8, stiffness: 120 },
    fadeFrames: 30,
    quickFade: 15,
    slowFade: 45,
    staggerDelay: 10,
    staggerFast: 5,
    staggerSlow: 15,
  },
  spacing: SHARED_SPACING,
  effects: {
    textShadow: '0 2px 4px rgba(0,0,0,0.5)',
    boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06)',
    boxShadowLarge: '0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05)',
    glow: '0 0 20px rgba(139, 92, 246, 0.5)',
  },
  borderRadius: SHARED_BORDER_RADIUS,
} as const

// ─── Theme selection ────────────────────────────────────────────────

export type ThemeName = 'apple' | 'charcoal'

export const THEMES = {
  apple: APPLE_THEME,
  charcoal: CHARCOAL_THEME,
} as const

/**
 * Select theme based on content:
 * - Technical/product demos, presentations, clean explainers → apple
 * - Cinematic, moody, artistic, data viz, storytelling → charcoal
 * - When unclear → ask the user
 */
export function selectTheme(name: ThemeName) {
  return THEMES[name]
}

// Default export — charcoal for backward compat
export const PAI_THEME = CHARCOAL_THEME

// Type exports
export type PAITheme = typeof APPLE_THEME | typeof CHARCOAL_THEME
export type PAIColors = PAITheme['colors']
export type PAITypography = PAITheme['typography']
export type PAIAnimation = PAITheme['animation']

// Utility: Get interpolate input/output for fade
export const fadeInterpolation = (theme: PAITheme = PAI_THEME, startFrame = 0) => ({
  inputRange: [startFrame, startFrame + theme.animation.fadeFrames],
  outputRange: [0, 1] as [number, number],
})

// Utility: Style preset for centered title screen
export const titleScreenStyle = (theme: PAITheme = PAI_THEME) => ({
  backgroundColor: theme.colors.background,
  display: 'flex' as const,
  justifyContent: 'center' as const,
  alignItems: 'center' as const,
  fontFamily: theme.typography.fontFamily,
})

// Utility: Style preset for content screen
export const contentScreenStyle = (theme: PAITheme = PAI_THEME) => ({
  backgroundColor: theme.colors.background,
  padding: theme.spacing.page,
  fontFamily: theme.typography.fontFamily,
})
