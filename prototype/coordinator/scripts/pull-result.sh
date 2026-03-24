#!/bin/bash
# pull-result.sh — 从远程节点拉取结果
# 用法: ./pull-result.sh <remote_host>

set -euo pipefail

REMOTE="${1:?用法: pull-result.sh <remote_host>  (如 tc 或 user@ip)}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HANDOFF_DIR="$(dirname "$SCRIPT_DIR")/handoff"

echo "📥 拉取 $REMOTE:~/handoff/outbox/ → inbox/"

rsync -avz "$REMOTE:~/handoff/outbox/" "$HANDOFF_DIR/inbox/"

if [ -z "$(ls -A "$HANDOFF_DIR/inbox/" 2>/dev/null)" ]; then
  echo "ℹ️  没有新结果"
  exit 0
fi

echo "📋 收到的结果:"
ls "$HANDOFF_DIR/inbox/"

echo ""
echo "提示: 读取结果后，将目录移到 archive/ 归档"
echo "  mv handoff/inbox/<task_id> handoff/archive/"
