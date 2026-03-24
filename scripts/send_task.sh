#!/bin/bash
# send_task.sh — 创建任务并推送到腾讯云
# 用法: ./send_task.sh <task_type> <instructions> [input_ref]

set -euo pipefail

TASK_TYPE="${1:?用法: send_task.sh <task_type> <instructions> [input_ref]}"
INSTRUCTIONS="${2:?需要 instructions}"
INPUT_REF="${3:-}"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HANDOFF="$REPO_DIR/handoff"
LOGS="$REPO_DIR/logs"

# 生成 task_id: task-YYYYMMDD-NNNN
DATE_PART=$(date +%Y%m%d)
EXISTING=0
for d in "$HANDOFF"/outbox/task-${DATE_PART}-* "$HANDOFF"/archive/task-${DATE_PART}-*; do
  [ -d "$d" ] && EXISTING=$((EXISTING + 1))
done
SEQ=$(printf "%04d" $((EXISTING + 1)))
TASK_ID="task-${DATE_PART}-${SEQ}"

TASK_DIR="$HANDOFF/tmp/$TASK_ID"
mkdir -p "$TASK_DIR"

# 写 task.json
cat > "$TASK_DIR/task.json" <<EOF
{
  "task_id": "$TASK_ID",
  "task_type": "$TASK_TYPE",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "created_by": "chamberlain",
  "target_node": "prime",
  "status": "pending",
  "input_ref": "$INPUT_REF",
  "instructions": "$INSTRUCTIONS"
}
EOF

# 原子 rename 到 outbox
mv "$TASK_DIR" "$HANDOFF/outbox/"

echo "✅ 任务创建: $TASK_ID → outbox/$TASK_ID/task.json"

# 推送到腾讯云
echo "📤 推送到腾讯云..."
rsync -avz --ignore-existing \
  "$HANDOFF/outbox/" \
  prime:~/openclaw-multinode/handoff/inbox/ \
  2>&1 | tee "$LOGS/send-${TASK_ID}.log"

echo "✅ 推送完成"
