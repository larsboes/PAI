# Kai Core Install - Verification Checklist

## Mandatory Completion Checklist

**IMPORTANT:** All items must be verified before considering this pack installed.

### Directory Structure

- [ ] `$PAI_DIR/skills/` directory exists
- [ ] `$PAI_DIR/skills/CORE/` directory exists
- [ ] `$PAI_DIR/skills/CORE/USER/` directory exists (v1.1.0)
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/` directory exists (v1.1.0)
- [ ] `$PAI_DIR/skills/CORE/Workflows/` directory exists
- [ ] `$PAI_DIR/skills/CreateSkill/` directory exists
- [ ] `$PAI_DIR/Tools/` directory exists

### Core Files

- [ ] `$PAI_DIR/skills/CORE/SKILL.md` exists
- [ ] `$PAI_DIR/skills/CORE/Workflows/UpdateDocumentation.md` exists
- [ ] `$PAI_DIR/skills/CreateSkill/SKILL.md` exists

### USER/ Files (v1.1.0)

- [ ] `$PAI_DIR/skills/CORE/USER/README.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/BASICINFO.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/CONTACTS.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/IDENTITY.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/TECHSTACKPREFERENCES.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/ASSETMANAGEMENT.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/SECURITYSYSTEM.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/DEFINITIONS.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/CORECONTENT.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/RESUME.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/REMINDERS.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/ALGOPREFS.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/ART.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/ABOUTME.md` exists
- [ ] `$PAI_DIR/skills/CORE/USER/TELOS.md` exists

### SYSTEM/ Files (v1.1.0)

- [ ] `$PAI_DIR/skills/CORE/SYSTEM/README.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/PAISYSTEMARCHITECTURE.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/SKILLSYSTEM.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/MEMORYSYSTEM.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/THEHOOKSYSTEM.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/THEDELEGATIONSYSTEM.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/THENOTIFICATIONSYSTEM.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/AGENTS.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/ACTIONS.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/PIPELINES.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/TOOLS.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/CLIFIRSTARCHITECTURE.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/THEFABRICSYSTEM.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/SCRAPINGREFERENCE.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/TERMINALTABS.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/DOCUMENTATIONINDEX.md` exists
- [ ] `$PAI_DIR/skills/CORE/SYSTEM/BACKUPS.md` exists

### Tools

- [ ] `$PAI_DIR/Tools/SkillSearch.ts` exists
- [ ] `$PAI_DIR/Tools/GenerateSkillIndex.ts` exists
- [ ] `$PAI_DIR/Tools/PaiArchitecture.ts` exists

### Generated Files

- [ ] `$PAI_DIR/skills/skill-index.json` exists (run GenerateSkillIndex.ts)
- [ ] `$PAI_DIR/skills/CORE/PaiArchitecture.md` exists (run PaiArchitecture.ts generate)

---

## Functional Tests

### Test 1: Verify Directory Structure

```bash
ls -la $PAI_DIR/skills/
# Expected: CORE/ CreateSkill/ skill-index.json

ls -la $PAI_DIR/skills/CORE/
# Expected: SKILL.md USER/ SYSTEM/ Workflows/

ls -la $PAI_DIR/Tools/
# Expected: SkillSearch.ts GenerateSkillIndex.ts PaiArchitecture.ts
```

### Test 2: Verify USER/ Directory

```bash
ls $PAI_DIR/skills/CORE/USER/ | wc -l
# Expected: 15 (files)

ls $PAI_DIR/skills/CORE/USER/
# Expected: README.md BASICINFO.md CONTACTS.md IDENTITY.md TECHSTACKPREFERENCES.md
#           ASSETMANAGEMENT.md SECURITYSYSTEM.md DEFINITIONS.md CORECONTENT.md
#           RESUME.md REMINDERS.md ALGOPREFS.md ART.md ABOUTME.md TELOS.md
```

### Test 3: Verify SYSTEM/ Directory

```bash
ls $PAI_DIR/skills/CORE/SYSTEM/ | wc -l
# Expected: 17 (files)

ls $PAI_DIR/skills/CORE/SYSTEM/
# Expected: README.md PAISYSTEMARCHITECTURE.md SKILLSYSTEM.md MEMORYSYSTEM.md
#           THEHOOKSYSTEM.md THEDELEGATIONSYSTEM.md THENOTIFICATIONSYSTEM.md
#           AGENTS.md ACTIONS.md PIPELINES.md TOOLS.md CLIFIRSTARCHITECTURE.md
#           THEFABRICSYSTEM.md SCRAPINGREFERENCE.md TERMINALTABS.md
#           DOCUMENTATIONINDEX.md BACKUPS.md
```

### Test 4: Test Skill Search

```bash
bun run $PAI_DIR/Tools/SkillSearch.ts --list
# Expected: Lists all indexed skills with icons
```

### Test 5: Search for Specific Skill

```bash
bun run $PAI_DIR/Tools/SkillSearch.ts "create skill"
# Expected: Returns CreateSkill in results
```

### Test 6: Check Architecture Status

```bash
bun run $PAI_DIR/Tools/PaiArchitecture.ts status
# Expected: Shows installed packs, bundles, system health
```

### Test 7: Verify System Health

```bash
bun run $PAI_DIR/Tools/PaiArchitecture.ts check
# Expected: All systems show healthy status
```

### Test 8: Verify CORE Skill Content

```bash
cat $PAI_DIR/skills/CORE/SKILL.md | head -20
# Expected: Shows YAML frontmatter with name: CORE
```

### Test 9: Verify Documentation Headers

```bash
head -30 $PAI_DIR/skills/CORE/USER/IDENTITY.md
# Expected: Shows documentation header with PURPOSE, LOCATION, CUSTOMIZATION

head -30 $PAI_DIR/skills/CORE/SYSTEM/SKILLSYSTEM.md
# Expected: Shows documentation header with PURPOSE, LOCATION, CUSTOMIZATION
```

### Test 10: Verify Skill Index Format

```bash
cat $PAI_DIR/skills/skill-index.json | head -30
# Expected: JSON with generated timestamp, totalSkills count, skills object
```

---

## Integration Tests

### Test A: Skill Routing

In a Claude Code session:
1. Say "search for a skill"
2. AI should use SkillSearch tool
3. Results should be returned

### Test B: Architecture Tracking

In a Claude Code session:
1. Say "what's installed in my PAI system?"
2. AI should read Architecture.md or run PaiArchitecture.ts
3. Should show installed packs

### Test C: Response Format (if configured)

In a Claude Code session:
1. Ask AI to complete a task
2. Response should include structured sections (📋 SUMMARY, 🎯 COMPLETED, etc.)

### Test D: USER/ Configuration Access

In a Claude Code session:
1. Say "what are my tech preferences?"
2. AI should read USER/TECHSTACKPREFERENCES.md
3. Should show your configured preferences

### Test E: SYSTEM/ Documentation Access

In a Claude Code session:
1. Say "how does the skill system work?"
2. AI should read SYSTEM/SKILLSYSTEM.md
3. Should explain skill configuration

---

## Quick Verification Script

```bash
#!/bin/bash
PAI_CHECK="${PAI_DIR:-$HOME/.config/pai}"

echo "=== Kai Core Install v1.1.0 Verification ==="
echo ""

# Check directories
echo "📁 Directory Structure:"
for dir in "skills" "skills/CORE" "skills/CORE/USER" "skills/CORE/SYSTEM" "skills/CORE/Workflows" "skills/CreateSkill" "Tools"; do
  if [ -d "$PAI_CHECK/$dir" ]; then
    echo "  ✓ $dir/"
  else
    echo "  ❌ $dir/ MISSING"
  fi
done

echo ""

# Check core files
echo "📄 Core Files:"
for file in "skills/CORE/SKILL.md" "skills/CreateSkill/SKILL.md"; do
  if [ -f "$PAI_CHECK/$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ❌ $file MISSING"
  fi
done

echo ""

# Check USER/ files
echo "👤 USER/ Files:"
USER_COUNT=$(ls "$PAI_CHECK/skills/CORE/USER/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$USER_COUNT" -ge 15 ]; then
  echo "  ✓ USER/ directory has $USER_COUNT files (expected: 15)"
else
  echo "  ⚠️  USER/ directory has $USER_COUNT files (expected: 15)"
fi

# Check SYSTEM/ files
echo "⚙️  SYSTEM/ Files:"
SYSTEM_COUNT=$(ls "$PAI_CHECK/skills/CORE/SYSTEM/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SYSTEM_COUNT" -ge 17 ]; then
  echo "  ✓ SYSTEM/ directory has $SYSTEM_COUNT files (expected: 17)"
else
  echo "  ⚠️  SYSTEM/ directory has $SYSTEM_COUNT files (expected: 17)"
fi

echo ""

# Check tools
echo "🔧 Tools:"
for file in "Tools/SkillSearch.ts" "Tools/GenerateSkillIndex.ts" "Tools/PaiArchitecture.ts"; do
  if [ -f "$PAI_CHECK/$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ❌ $file MISSING"
  fi
done

echo ""

# Check generated files
echo "📋 Generated Files:"
if [ -f "$PAI_CHECK/skills/skill-index.json" ]; then
  echo "  ✓ skill-index.json"
else
  echo "  ⚠️  skill-index.json not generated - run: bun run $PAI_CHECK/Tools/GenerateSkillIndex.ts"
fi

echo ""
echo "=== Verification Complete ==="
```

---

## Success Criteria

Installation is complete when:

1. ✅ All directory structure items are checked
2. ✅ All core files are present
3. ✅ All 15 USER/ files are present
4. ✅ All 17 SYSTEM/ files are present
5. ✅ All tools are installed
6. ✅ `bun run $PAI_DIR/Tools/SkillSearch.ts --list` returns skill list
7. ✅ `bun run $PAI_DIR/Tools/PaiArchitecture.ts check` shows healthy status
8. ✅ Documentation headers are present in USER/ and SYSTEM/ files
