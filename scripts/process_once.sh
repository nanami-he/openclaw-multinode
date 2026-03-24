#!/bin/bash
# process_once.sh — 腾讯云端：扫描 inbox，处理一个未处理任务
# 用法: ./process_once.sh

set -euo pipefail

REPO_DIR="$HOME/openclaw-multinode"
HANDOFF="$REPO_DIR/handoff"

# 找到第一个未处理任务
TASK_DIR=$(find "$HANDOFF/inbox" -name "task.json" -type f 2>/dev/null | head -1)

if [ -z "$TASK_DIR" ]; then
  echo "ℹ️  inbox 为空，没有待处理任务"
  exit 0
fi

TASK_FILE="$TASK_DIR"
TASK_DIR_PATH=$(dirname "$TASK_FILE")
TASK_ID=$(basename "$TASK_DIR_PATH")

echo "📋 发现任务: $TASK_ID"
cat "$TASK_FILE"
echo ""

# 读取任务信息
TASK_TYPE=$(python3 -c "import json; print(json.load(open('$TASK_FILE'))['task_type'])")
INSTRUCTIONS=$(python3 -c "import json; print(json.load(open('$TASK_FILE'))['instructions'])")

echo "🔄 处理中... (类型: $TASK_TYPE)"

# === placeholder: 以后这里调用 OpenClaw agent ===
RESULT_SUMMARY="任务已处理完成。类型: $TASK_TYPE, 指令: $INSTRUCTIONS"

# 写结果到 tmp，再原子 rename 到 outbox
RESULT_TMP="$HANDOFF/tmp/$TASK_ID"
mkdir -p "$RESULT_TMP"

cat > "$RESULT_TMP/result.json" <<EOF
{
  "task_id": "$TASK_ID",
  "status": "completed",
  "processed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "produced_by": "prime",
  "summary": "$RESULT_SUMMARY",
  "artifacts": []
}
EOF

# 原子 rename 到 outbox
mkdir -p "$HANDOFF/outbox/$TASK_ID"
cp "$HANDOFF/inbox/$TASK_ID/task.json" "$HANDOFF/outbox/$TASK_ID/task.json"
mv "$RESULT_TMP/result.json" "$HANDOFF/outbox/$TASK_ID/result.json"
rmdir "$RESULT_TMP" 2>/dev/null || true

echo "✅ 结果已写入 → outbox/$TASK_ID/result.json"

# 原任务移到 archive
mv "$HANDOFF/inbox/$TASK_ID" "$HANDOFF/archive/"
echo "📦 任务已归档 → archive/$TASK_ID"
