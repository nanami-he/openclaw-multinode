# Protocol

## Overview

Communication between nodes follows a simple artifact-based protocol:

1. Coordinator creates a `task.json` in the shared handoff directory
2. Worker picks up the task, processes it
3. Worker produces a `result.json` in the shared handoff directory
4. Coordinator reads the result

## Handoff directory structure

```
shared/handoff/
├── inbox/      # Incoming tasks/results
├── outbox/     # Outgoing tasks/results
├── completed/  # Archived completed tasks
└── failed/     # Archived failed tasks
```

## Task lifecycle

```
pending → accepted → in_progress → completed
                   ↘ failed → retried → ...
```

## File naming convention

```
{timestamp}_{task_id}_{type}.json

Example:
20260324_023000_task_001_task.json
20260324_023500_task_001_result.json
```

## Minimal handoff flow

```
Node A                          Node B
  │                               │
  ├─ write task.json ────────────►│
  │                               ├─ read task.json
  │                               ├─ process
  │                               ├─ write result.json
  │◄──────────────── result.json ─┤
  ├─ read result.json             │
  ├─ update ledger                │
```

## Security model (future)

- Node authentication via shared token or A2A
- Workspace sovereignty: no direct write access
- Artifacts signed or checksummed
