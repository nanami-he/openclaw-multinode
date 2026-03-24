# Handoff Protocol

## Directory Structure

```
handoff/
├── outbox/     # 准备发送（Mac 推任务 / 腾讯云推结果）
├── inbox/      # 收到待处理
├── archive/    # 处理完归档
└── tmp/        # 写入中的临时文件（原子写入用）
```

每个节点都有完整的 handoff/ 目录。

## 任务单位：一个任务一个目录

```
outbox/task_001/
├── task.json       # 任务定义
└── (后续可加附件、截图、视频片段等)
```

处理完后：

```
outbox/task_001/
├── task.json
└── result.json     # 处理结果
```

归档后：

```
archive/task_001/
├── task.json
└── result.json
```

## 写入规则：先 tmp，后 rename

不要直接写到 outbox/。流程：

1. 写到 `tmp/task_001.json`（或 `tmp/task_001/` 目录）
2. 写完后原子 rename 到 `outbox/task_001/`

这样另一边不会读到半截文件。

## 同步方向：单向明确

**A. Mac 推任务到云端：**
```bash
rsync -avz --remove-source-files handoff/outbox/ tc:~/handoff/inbox/
```
> `--remove-source-files`：推完后本地 outbox 清空（移到本地 archive 先再推，或推后手动归档）

**B. Mac 拉结果回本地：**
```bash
rsync -avz --remove-source-files tc:~/handoff/outbox/ handoff/inbox/
```

**原则：单向 rsync，不要双向魔法同步。**

## 谁删文件

- **发送方**：不删除原始任务，推完后本地归档
- **接收方**：处理完后，从 inbox 移到 archive
- **拉回结果后**：本地归档
- **不要自动删**，先保证不丢证据

## 最小 agent 动作

**Mac agent（Executive）：**
1. write file → 写 task.json 到 tmp/
2. exec rename → 原子移到 outbox/
3. exec rsync push → 推到腾讯云 inbox/
4. exec rsync pull → 拉腾讯云 outbox/ 结果
5. read file → 读 result.json

**腾讯云 agent（Coordinator）：**
1. scan inbox/ → 发现新任务
2. read task → 读 task.json
3. process → 处理
4. write result → 写 result.json 到 outbox/
5. archive → 从 inbox 移到 archive

## 文件命名

```
{task_id}/task.json
{task_id}/result.json
```

task_id 格式建议：`task_{序号}` 或 `task_{日期}_{序号}`

## 不做的事（v0）

- ❌ sshfs
- ❌ API
- ❌ 自动发现
- ❌ 双向同步
- ❌ 自动删除
