#!/bin/bash
# process-task.sh — 处理 inbox 中的任务（腾讯云端）
# 用法: ./process-task.sh <task_id>

set -euo pipefail

TASK_ID="${1:?用法: process-task.sh <task_id>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HANDOFF_DIR="$(dirname "$SCRIPT_DIR")/handoff"

TASK_DIR="$HANDOFF_DIR/inbox/$TASK_ID"

if [ ! -d "$TASK_DIR" ]; then
  echo "❌ 任务 $TASK_ID 不在 inbox 中"
  echo "📋 当前 inbox:"
  ls "$HANDOFF_DIR/inbox/" 2>/dev/null || echo "(空)"
  exit 1
fi

TASK_FILE="$TASK_DIR/task.json"
if [ ! -f "$TASK_FILE" ]; then
  echo "❌ $TASK_DIR 中没有 task.json"
  exit 1
fi

echo "📋 读取任务:"
cat "$TASK_FILE"
echo ""

# 读取任务类型
TASK_TYPE=$(python3 -c "import json; print(json.load(open('$TASK_FILE'))['task_type'])")
INSTRUCTIONS=$(python3 -c "import json; print(json.load(open('$TASK_FILE'))['instructions'])")

echo "🔄 处理中... (类型: $TASK_TYPE)"

# === 这里是 placeholder ===
# 以后这里会调用 OpenClaw agent 处理
# 现在先输出模拟结果
RESULT="模拟结果: 任务 '$INSTRUCTIONS' 已处理完成 (类型: $TASK_TYPE)"

# 写结果到 outbox（先 tmp 再 rename）
RESULT_TMP="$HANDOFF_DIR/tmp/${TASK_ID}_result"
mkdir -p "$RESULT_TMP"

cat > "$RESULT_TMP/result.json" <<EOF
{
  "task_id": "$TASK_ID",
  "status": "completed",
  "processed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "produced_by": "tencent_node",
  "summary": "$RESULT",
  "artifacts": []
}
EOF

# 原子 rename 到 outbox
OUTBOX_DIR="$HANDOFF_DIR/outbox/$TASK_ID"
mkdir -p "$OUTBOX_DIR"
cp "$HANDOFF_DIR/inbox/$TASK_ID/task.json" "$OUTBOX_DIR/task.json"
mv "$RESULT_TMP/result.json" "$OUTBOX_DIR/result.json"
rm -rf "$RESULT_TMP"

echo "✅ 结果已写入 → outbox/$TASK_ID/result.json"

# 归档 inbox 中的任务
mv "$TASK_DIR" "$HANDOFF_DIR/archive/"
echo "📦 任务已归档 → archive/$TASK_ID"
