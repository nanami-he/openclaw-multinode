#!/bin/bash
# push-task.sh — 把 outbox 推到远程节点的 inbox
# 用法: ./push-task.sh <remote_host>

set -euo pipefail

REMOTE="${1:?用法: push-task.sh <remote_host>  (如 tc 或 user@ip)}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HANDOFF_DIR="$(dirname "$SCRIPT_DIR")/handoff"

# 检查 outbox 是否有内容
if [ -z "$(ls -A "$HANDOFF_DIR/outbox/" 2>/dev/null)" ]; then
  echo "ℹ️  outbox 为空，没有需要推送的任务"
  exit 0
fi

echo "📤 推送 outbox → $REMOTE:~/handoff/inbox/"

# rsync 推送（不删源文件，归档由 agent 负责）
rsync -avz "$HANDOFF_DIR/outbox/" "$REMOTE:~/handoff/inbox/"

# 归档本地 outbox
for dir in "$HANDOFF_DIR/outbox"/*/; do
  if [ -d "$dir" ]; then
    task_name="$(basename "$dir")"
    mv "$dir" "$HANDOFF_DIR/archive/"
    echo "📦 已归档: archive/$task_name"
  fi
done

echo "✅ 推送完成"
