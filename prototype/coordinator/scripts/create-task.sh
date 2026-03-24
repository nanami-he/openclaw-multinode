#!/bin/bash
# create-task.sh — 创建一个新任务
# 用法: ./create-task.sh <task_id> <task_type> <instructions> [target_node]

set -euo pipefail

TASK_ID="${1:?用法: create-task.sh <task_id> <task_type> <instructions> [target_node]}"
TASK_TYPE="${2:?需要 task_type: analysis|translation|writing|search|custom}"
INSTRUCTIONS="${3:?需要 instructions}"
TARGET="${4:-tencent_node}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HANDOFF_DIR="$(dirname "$SCRIPT_DIR")/handoff"

# 先写到 tmp
TASK_DIR="$HANDOFF_DIR/tmp/$TASK_ID"
mkdir -p "$TASK_DIR"

cat > "$TASK_DIR/task.json" <<EOF
{
  "task_id": "$TASK_ID",
  "task_type": "$TASK_TYPE",
  "instructions": "$INSTRUCTIONS",
  "created_by": "mac_node",
  "target_node": "$TARGET",
  "status": "pending",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "priority": "normal"
}
EOF

# 原子 rename 到 outbox
mv "$TASK_DIR" "$HANDOFF_DIR/outbox/"

echo "✅ 任务 $TASK_ID 已创建 → outbox/$TASK_ID/"
