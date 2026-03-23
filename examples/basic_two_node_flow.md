# Basic Two-Node Flow

The simplest possible collaboration between two OpenClaw instances.

## Setup

- **Node A** (local Mac): coordinator, creates tasks
- **Node B** (remote server): worker, processes tasks

## Step-by-step

### 1. Node A creates a task

```json
{
  "task_id": "task_001",
  "task_type": "analysis",
  "input_ref": "shared/handoff/input/sample.txt",
  "instructions": "Summarize the key points from this document.",
  "created_by": "node_local",
  "target_node": "node_remote",
  "status": "pending",
  "priority": "normal",
  "created_at": "2026-03-24T02:30:00+09:00"
}
```

Save to: `shared/handoff/outbox/20260324_023000_task_001_task.json`

### 2. Transfer to Node B

Via shared directory, scp, or any transport:

```bash
scp shared/handoff/outbox/*_task_001_task.json user@node-b:~/shared/handoff/inbox/
```

### 3. Node B reads and processes

Node B's agent:
1. Reads the task from inbox
2. Processes according to instructions
3. Writes output to its local workspace

### 4. Node B produces result

```json
{
  "task_id": "task_001",
  "produced_by": "node_remote",
  "status": "completed",
  "summary": "Document covers three main topics: X, Y, Z. Key takeaway is...",
  "artifacts": [
    "output/task_001_summary.md"
  ],
  "completed_at": "2026-03-24T02:35:00+09:00",
  "token_usage": {
    "input": 1200,
    "output": 450
  }
}
```

Save to: `shared/handoff/outbox/20260324_023500_task_001_result.json`

### 5. Transfer result back to Node A

```bash
scp user@node-b:~/shared/handoff/outbox/*_task_001_result.json shared/handoff/inbox/
```

### 6. Node A reads result

Done. Node A now has the structured result and can continue its workflow.

## What this proves

- Nodes can exchange structured work without sharing full context
- Each node keeps its own workspace and memory
- The handoff is artifact-based, not text-relay-based
- Token cost is proportional to the actual work, not repeated context passing
