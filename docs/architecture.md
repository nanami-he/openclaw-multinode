# Architecture

## Design principles

1. **Private workspaces** — each node owns its workspace, memory, and tools
2. **Artifact-based handoff** — nodes exchange structured outputs, not raw text
3. **Task ledger** — shared coordination layer for task state and ownership
4. **Sovereignty** — external access to workspace is read-only by default; write via task submission

## Minimum viable architecture

```
Node A (coordinator / local)
├── OpenClaw Gateway
├── Private workspace
├── Private memory
└── shared/handoff/
    ├── outbox/   → task.json files sent to Node B
    └── inbox/    → result.json files received from Node B

Node B (worker / remote)
├── OpenClaw Gateway
├── Private workspace
├── Private memory
└── shared/handoff/
    ├── inbox/    → task.json files received from Node A
    └── outbox/   → result.json files sent to Node A
```

## Roles (future)

| Role | Description |
|------|-------------|
| Coordinator | Assigns tasks, tracks state, collects results |
| Worker | Executes specific tasks, produces artifacts |
| Specialist | Specialized in one domain (analysis, writing, etc.) |

## What this is NOT

- Not a replacement for OpenClaw's built-in multi-agent
- Not a message queue or event bus
- Not a shared filesystem (each node keeps sovereignty)

## Communication layers (future)

| Layer | Purpose | Transport |
|-------|---------|-----------|
| Control plane | Task assignment, status updates | A2A protocol / API |
| Data plane | Artifact exchange | Shared dir / object storage / scp |
| Discovery | Find available nodes | Agent Cards / config |
