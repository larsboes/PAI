# BlindSpot — Verification

## File Verification

```bash
SKILL_DIR="$HOME/.claude/skills/BlindSpot"

[ -f "$SKILL_DIR/SKILL.md" ]              && echo "OK SKILL.md"         || echo "MISSING SKILL.md"
[ -f "$SKILL_DIR/Workflows/QuickScan.md" ] && echo "OK QuickScan"       || echo "MISSING QuickScan"
[ -f "$SKILL_DIR/Workflows/DeepScan.md" ]  && echo "OK DeepScan"        || echo "MISSING DeepScan"
[ -f "$SKILL_DIR/Workflows/SessionReview.md" ] && echo "OK SessionReview" || echo "MISSING SessionReview"
```

## Frontmatter Check

```bash
head -1 "$SKILL_DIR/SKILL.md" | grep -q "^---" && echo "OK frontmatter" || echo "ERROR"
grep -q "^name: BlindSpot" "$SKILL_DIR/SKILL.md" && echo "OK name" || echo "ERROR"
```

## Functional Test

Trigger with: "what did we miss?" or "blind spot check" or "premortem" in conversation.
