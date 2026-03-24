# Protocol v0 — 定版

## 节点

| 节点 | 角色 | 名称 |
|------|------|------|
| 本地 Mac | Emperor | emperor |
| 腾讯云 | Prime | prime |

## 目录结构

两端相同：
```
~/openclaw-multinode/
├── handoff/
│   ├── outbox/     # 准备发送
│   ├── inbox/      # 收到待处理
│   ├── archive/    # 处理完归档
│   └── tmp/        # 写入中的临时文件
├── scripts/
├── logs/
├── schemas/
└── ...
```

## 任务单位

一个任务一个目录：
```
handoff/outbox/task-20260324-0001/
├── task.json
└── (以后可加: input.txt, output.txt, transcript.json, artifact-001.png, log.txt)
```

## 文件命名

- 目录名：`task-YYYYMMDD-NNNN`
- task.json：固定名
- result.json：固定名

## 写入规则：先 tmp，后 rename

1. 写到 `handoff/tmp/task-XXXX/`
2. 写完后 `mv` 到 `handoff/outbox/task-XXXX/`

## rsync 命令

SSH 别名（~/.ssh/config）：
```
Host prime
  HostName <腾讯云IP>
  User ubuntu
```

**Mac 推送任务：**
```bash
rsync -avz --ignore-existing \
  ~/openclaw-multinode/handoff/outbox/ \
  prime:~/openclaw-multinode/handoff/inbox/
```

**Mac 拉取结果：**
```bash
rsync -avz --ignore-existing \
  prime:~/openclaw-multinode/handoff/outbox/ \
  ~/openclaw-multinode/handoff/inbox/
```

## 脚本

| 脚本 | 位置 | 作用 |
|------|------|------|
| send_task.sh | Mac scripts/ | 创建任务 + 推送 |
| pull_results.sh | Mac scripts/ | 拉取结果到 inbox |
| process_once.sh | 腾讯云 scripts/ | 处理一个未处理任务 |

## 最小闭环

```
Step 1  Mac: send_task.sh 创建 task.json → outbox/
Step 2  Mac: rsync push → 腾讯云 inbox/
Step 3  腾讯云: 读取 inbox/task.json
Step 4  腾讯云: 处理 → 写 result.json → outbox/
Step 5  Mac: rsync pull → 本地 inbox/
Step 6  Mac: 读取 inbox/result.json
```

## 处理规则

- Mac 端：写任务 → rsync push → rsync pull → 读结果 → 归档
- 腾讯云端：读任务 → 处理 → 写结果 → 归档原任务

## v0 先不做

- sshfs
- 自动双向实时同步
- 数据库 task ledger
- 三节点路由
- API 服务
