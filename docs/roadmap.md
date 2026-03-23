# Roadmap

## v0 — Two-node prototype (current)

- [ ] Define task.json and result.json schemas
- [ ] Basic handoff via shared directory / scp
- [ ] Document basic two-node flow
- [ ] Test: Node A sends task → Node B processes → result returns

## v1 — Artifact handoff + task state

- [ ] Task ledger (shared state tracking)
- [ ] Task lifecycle: pending → accepted → completed / failed
- [ ] Inbox/outbox directory management
- [ ] Error handling and retry logic

## v2 — Specialist nodes + model specialization

- [ ] Multiple worker nodes with different capabilities
- [ ] Coordinator routes tasks to appropriate specialist
- [ ] Agent Card format for capability discovery
- [ ] A2A protocol integration (if available)

## v3 — Full federation

- [ ] Multi-coordinator support
- [ ] Conflict resolution
- [ ] Monitoring and observability
- [ ] Integration with OpenClaw core (if accepted)
