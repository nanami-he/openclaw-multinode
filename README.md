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

## Current status

Early prototype / design exploration.

## Quick start

```bash
# Clone
git clone https://github.com/nanami-he/openclaw-multinode.git
cd openclaw-multinode

# Read the docs
cat docs/architecture.md
cat docs/protocol.md
cat examples/basic_two_node_flow.md
```

## Architecture (preview)

```
Node A (local)              Node B (remote)
┌──────────────┐            ┌──────────────┐
│ OpenClaw GW  │            │ OpenClaw GW  │
│ Workspace A  │            │ Workspace B  │
│ Memory A     │            │ Memory B     │
└──────┬───────┘            └──────┬───────┘
       │                           │
       │  ┌─────────────────────┐  │
       └──│  shared/handoff/    │──┘
          │  task.json          │
          │  result.json        │
          └─────────────────────┘
```

## Relationship to OpenClaw

This is an experimental external prototype inspired by OpenClaw.
It is not affiliated with the OpenClaw core team.

## Related

- [OpenClaw Feature Request #53025](https://github.com/openclaw/openclaw/issues/53025)
- [A2A Plugin (win4r)](https://github.com/win4r/openclaw-a2a-gateway)
- [A2A Plugin (n00n0i)](https://github.com/n00n0i/openclaw-a2a)

## License

MIT
