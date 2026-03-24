# Protocol v0

## 核心原则

1. **Artifact-based**：节点间传文件，不传大段文本
2. **One task = one directory**：一个任务一个目录，方便扩展
3. **Atomic write**：先写 tmp，后 rename
4. **Unidirectional rsync**：推任务 / 拉结果，单向明确
5. **Archive, don't delete**：归档而非删除

## 最小双节点闭环

```
Mac (Executive)                    腾讯云 (Coordinator)
    │                                    │
    ├─ write task.json ──► tmp/          │
    ├─ rename ──► outbox/task_001/       │
    ├─ rsync push ──────────────────────►├─ inbox/task_001/
    │                                    ├─ read task.json
    │                                    ├─ process
    │                                    ├─ write result.json ──► outbox/task_001/
    │                                    ├─ archive task
    │                                    │
    ├─ rsync pull ◄──────────────────────┤
    ├─ inbox/task_001/result.json        │
    ├─ read result.json                  │
    ├─ archive task                      │
```

## task.json schema

见 `/schemas/task.json`

## result.json schema

见 `/schemas/result.json`

## v0 验证目标

只要以下 4 条成立，v0 就算通过：

1. 两个 OpenClaw 实例都能独立存在
2. 节点 A 能把 task.json 给节点 B
3. 节点 B 能返回 result.json
4. 全流程不依赖长文本上下文中继
