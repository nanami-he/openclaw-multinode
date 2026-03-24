#!/bin/bash
# pull_results.sh — 从腾讯云拉取结果到本地 inbox
# 用法: ./pull_results.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HANDOFF="$REPO_DIR/handoff"
LOGS="$REPO_DIR/logs"

echo "📥 从腾讯云拉取结果..."

rsync -avz --ignore-existing \
  prime:~/openclaw-multinode/handoff/outbox/ \
  "$HANDOFF/inbox/" \
  2>&1 | tee "$LOGS/pull-$(date +%Y%m%d-%H%M%S).log"

if [ -z "$(ls -A "$HANDOFF/inbox/" 2>/dev/null)" ]; then
  echo "ℹ️  没有新结果"
  exit 0
fi

echo ""
echo "📋 收到的结果:"
ls "$HANDOFF/inbox/"
echo ""
echo "提示: 读取后手动归档:"
echo "  mv handoff/inbox/<task_id> handoff/archive/"
