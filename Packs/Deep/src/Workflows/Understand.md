# Understand Workflow

Running the **Understand** workflow in the **DeepDebug** skill to build understanding of unfamiliar code/system...

## Overview

For when you're debugging in unfamiliar territory — code you didn't write, libraries you don't know, systems you haven't seen before. Understanding FIRST, fixing SECOND.

---

## When to Use

- Working in a new codebase
- Debugging a library/framework issue
- The code uses patterns you haven't seen
- The system architecture is unclear
- Error messages reference internals you don't understand

---

## The Understanding Protocol

### Step 1: Orient (2 minutes)

**Big picture first. Don't dive into details.**

```bash
# Project structure
ls -la && find . -name "*.md" -maxdepth 2
cat README.md

# Architecture clues
find . -name "*.config.*" -o -name "*.yml" -o -name "Makefile" | head -20
cat package.json  # or equivalent

# Entry points
grep -r "main\|entry\|start" package.json tsconfig.json
```

Questions to answer:
- What is this project/module? (one sentence)
- What language/framework/paradigm?
- Where are the entry points?
- What's the dependency graph?

### Step 2: Trace the Path (5 minutes)

**Follow the execution path from entry to error:**

```bash
# Find where the error originates
rg "ErrorMessage" --type ts -l
rg "functionName" --type ts -l

# Trace callers
rg "functionName\(" --type ts

# Check types/interfaces
rg "interface.*TypeName\|type.*TypeName" --type ts
```

Build a mental model:
- Entry point → ... → ... → Error location
- What data flows through?
- What transformations happen?

### Step 3: Read the Tests (3 minutes)

Tests are documentation of INTENDED behavior:

```bash
find . -name "*.test.*" -o -name "*.spec.*" | xargs grep -l "featureName"
```

- What do the tests expect?
- What edge cases are tested?
- What's NOT tested (potential gaps)?

### Step 4: Check the Docs

```bash
# Internal docs
find . -name "*.md" | xargs grep -l "featureName"

# External docs
code_search "library-name featureName usage"
web_search "library-name version featureName"
```

### Step 5: Summarize Understanding

Before proceeding to fix, write (to yourself or the user):

```markdown
## My Understanding

**System:** [What it is, one sentence]
**Flow:** Entry → A → B → C → [Error here]
**The code expects:** [What should happen]
**What actually happens:** [What goes wrong]
**My confusion:** [What I still don't understand]
**Hypothesis:** [Based on understanding so far]
```

---

## When Understanding Is Sufficient

You're ready to move to Investigate/Fix when you can answer:
- [ ] What is this code TRYING to do?
- [ ] What data goes in and comes out?
- [ ] Where in the flow does it break?
- [ ] What's the intended behavior vs actual behavior?

If you can't answer these → keep reading, or ask the user.

---

## Anti-Patterns

| Bad | Good |
|-----|------|
| Jump to fixing without understanding | Read source, tests, docs first |
| Read only the broken line | Read the whole function and its callers |
| Assume you know how the library works | Check the docs for YOUR version |
| Ignore the test suite | Tests show intended behavior |
| Be afraid to say "I don't understand this" | Ask the user for context |
