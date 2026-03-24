# openclaw-multinode

A prototype for multi-instance OpenClaw collaboration using private workspaces and shared artifact-based handoff.

## Why

OpenClaw works very well for single-instance multi-agent workflows. This project explores a different direction: collaboration across multiple OpenClaw instances on different machines, while keeping private workspaces and exchanging structured artifacts instead of repeatedly relaying large text context.

This is different from sub-agent decomposition within a single instance: the goal is collaboration across multiple OpenClaw instances, each with its own workspace, memory, tools, and model specialization.

## Core idea

- Each OpenClaw instance keeps its own workspace and memory
- Instances collaborate through artifact-based handoff
- Coordination relies on structured task/result schemas, not raw text relay
- Model specialization remains possible across nodes

## Milestones

### v0 — Artifact handoff loop established

Validated:
- task.json creation on Emperor side
- artifact handoff via rsync
- result.json return from Prime
- no long text relay required in the loop

### v0.5 — Prime identity established

Validated:
- Prime workspace is active
- Prime correctly identifies itself as the Prime Minister node
- Prime understands its role and escalation path to the Lord Chamberlain

### v1 — Prime OpenClaw execution established

Validated:
- Prime OpenClaw can be invoked from shell
- Prime reads task.json from handoff
- Prime processes the task with Prime-specific role awareness
- Prime writes structured result.json
- JSON validation and delayed archive flow work
- Emperor can pull back the final result

This means the system is no longer just a file-sync demo.
One OpenClaw instance is now processing a task handed off by another OpenClaw instance.

## Current status

v1 milestone reached.

The project now supports:
- two-node artifact handoff
- Prime role-aware execution through OpenClaw
- structured task/result exchange
- delayed archive after JSON validation

Current focus:
- stabilizing the two-node workflow
- preparing the Lord Chamberlain node
- documenting the path toward multi-node coordination

## Node roles

| Role | Node | Description |
|------|------|-------------|
| Emperor | 七海様 | Human owner, ultimate authority |
| Lord Chamberlain | Local Mac | Closest node to the Emperor, high-privilege execution |
| Prime Minister | Cloud node | Default online coordinator and execution |
| Cabinet | Future | Specialist execution nodes |

## Quick overview

```bash
# Clone
git clone https://github.com/nanami-he/openclaw-multinode.git
cd openclaw-multinode

# Read the design
cat docs/architecture.md
cat docs/protocol.md
cat schemas/task.json
cat schemas/result.json

# Run a task (Emperor side)
bash scripts/send_task.sh analysis "Your task instructions"

# Process a task (Prime side)
bash scripts/process_once.sh

# Pull results (Emperor side)
bash scripts/pull_results.sh
```

## Architecture

```
Emperor (human)
    │
    ▼
Lord Chamberlain (local Mac)          Prime Minister (cloud)
┌──────────────────────┐              ┌──────────────────────┐
│ OpenClaw GW          │              │ OpenClaw GW          │
│ Workspace (chamberlain)│            │ Workspace (prime)     │
│ send_task.sh         │──rsync push──│                      │
│ pull_results.sh      │◄──rsync pull─│ process_once.sh      │
└──────────────────────┘              └──────────────────────┘
       │                                        │
       │         handoff/{outbox,inbox}/        │
       │         task.json / result.json        │
       └────────────────────────────────────────┘
```

## How handoff works

**Lord Chamberlain sends a task:**
```json
{
  "task_id": "task-20260324-0001",
  "task_type": "analysis",
  "created_by": "chamberlain",
  "target_node": "prime",
  "status": "pending",
  "instructions": "Your task here"
}
```

**Prime Minister returns a result:**
```json
{
  "task_id": "task-20260324-0001",
  "status": "completed",
  "produced_by": "prime",
  "summary": "Structured result here",
  "artifacts": []
}
```

Full schema: [schemas/task.json](schemas/task.json) | [schemas/result.json](schemas/result.json)

## Relationship to OpenClaw

This is an experimental external prototype inspired by OpenClaw.
It is not affiliated with the OpenClaw core team.

## Related

- [OpenClaw Feature Request #53025](https://github.com/openclaw/openclaw/issues/53025)

## License

MIT
