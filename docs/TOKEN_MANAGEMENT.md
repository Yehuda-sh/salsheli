# TOKEN_MANAGEMENT - Machine-Readable AI Guide

## BUDGET
```
total: 190000
alerts:
  50%: show_message
  70%: ultra_concise_mode
  85%: save_and_end
  90%: emergency_end
```

## READING RULES - DEFAULT: ZERO!

```yaml
ZERO_READING (default):
  - bug_fix
  - typo
  - simple_change
  - known_task
  → DO NOT read any docs!

SELECTIVE_READING (only if needed):
  new_provider: CODE.md (Provider section only)
  new_ui: DESIGN.md (Component section only)
  firebase: TECH.md (Security section only)
  repeated_error: LESSONS_LEARNED.md (search specific)
  
FULL_READING (rare):
  - big_feature
  - architectural_change
  - user_explicitly_asks
```

## CHECKPOINT PROTOCOL

```yaml
FREQUENCY: EVERY file change (not 3-5!)

AFTER_EACH_EDIT:
  1. add_observations:
     entityName: "Current Session"
     contents: ["Modified: file.dart - what changed"]
  
  2. update CHANGELOG.md:
     [In Progress] - Modified: file.dart
  
  3. if session ends → checkpoint exists!

FORMAT:
  ## [In Progress] - YYYY-MM-DD
  Modified: file.dart - description
  Status: complete/in-progress/blocked
  Next: next_step
```

## RESPONSE PROTOCOL

```yaml
DEFAULT: Ultra-Concise

FORMAT:
  "Fixed X in Y
  ✅ Changes: - what changed
  ✅ Done"

NO:
  - explanations
  - long_examples
  - quoted_docs
  - step_by_step_descriptions

SAVINGS: 150 tokens → 15 tokens = 90% less!
```

## ALERT ACTIONS

```yaml
50% (95K):
  show: "📊 50%"
  action: continue_normal

70% (133K):
  show: "⚠️ 70% - Ultra-Concise ON"
  action: 1-2_sentences_max

85% (161K):
  show: "🚨 85% - Saving"
  action:
    - save_checkpoint
    - update_memory
    - update_changelog
    - summarize_3_sentences
    - end_session

90%+:
  show: "❌ Limit"
  action: emergency_checkpoint_and_end
```

## BATCHING

```yaml
RULE: 1-2 files per session

EXAMPLE:
  Batch1: model.dart + test → end
  Batch2: provider.dart + test → end
  Batch3: screen.dart + strings → end
  Batch4: integration + fixes → end

USER_SAYS "המשך" → continue_next_batch
```

## WORKFLOW

```yaml
START_SESSION:
  - dont_read_docs (unless needed)
  - search_nodes("last session")
  - start_immediately

DURING_SESSION:
  - ultra_concise_responses
  - checkpoint_every_change
  - alert_at_50_70_85

END_SESSION:
  - update_memory
  - update_changelog
  - suggest "המשך" if incomplete
```

## DOC READING MAP

```yaml
bug_fix: 0 tokens (read nothing)
provider: CODE.md ~3K tokens
ui: DESIGN.md ~2K tokens
firebase: TECH.md ~2.5K tokens
error: LESSONS_LEARNED.md ~1.5K tokens
big_feature: GUIDE+CODE+DESIGN ~10K tokens
```

---

End of Token Management Guide
Version: 1.0 | Date: 26/10/2025
Optimized for AI parsing - minimal formatting, maximum data density.
