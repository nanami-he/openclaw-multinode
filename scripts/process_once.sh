#!/bin/bash
# process_once.sh — Prime 端：扫描 inbox，处理一个未处理任务
# 用法: ./process_once.sh
#
# 职责分工：
#   shell: 扫描任务 → 调 CLI → 校验结果 → 归档
#   Prime OpenClaw: 读 task.json → 执行 → 写 result.json

set -euo pipefail

REPO_DIR="$HOME/openclaw-multinode"
HANDOFF="$REPO_DIR/handoff"
OPENCLAW_BIN="$HOME/.npm-global/bin/openclaw"  # Prime 上的 openclaw 路径

# ── 1. 扫描 inbox，找到第一个任务 ──
TASK_DIR=$(find "$HANDOFF/inbox" -name "task.json" -type f 2>/dev/null | head -1)

if [ -z "$TASK_DIR" ]; then
  echo "ℹ️  inbox 为空，没有待处理任务"
  exit 0
fi

TASK_DIR_PATH=$(dirname "$TASK_DIR")
TASK_ID=$(basename "$TASK_DIR_PATH")

echo "📋 发现任务: $TASK_ID"
cat "$TASK_DIR"
echo ""

# ── 2. 创建 outbox 输出目录 ──
mkdir -p "$HANDOFF/outbox/$TASK_ID"

# ── 3. 调用 Prime OpenClaw agent 处理任务 ──
echo "⚡ 调用 Prime agent 处理中..."
$OPENCLAW_BIN agent --agent main --local --timeout 120 --message "
You are Prime Minister, the default online coordinator node.

Process exactly one task.

Task directory: ~/openclaw-multinode/handoff/inbox/$TASK_ID/

Instructions:
1. Read ~/openclaw-multinode/handoff/inbox/$TASK_ID/task.json
2. Perform the task described there
3. Write a valid result.json to: ~/openclaw-multinode/handoff/outbox/$TASK_ID/result.json
4. The result.json must follow this schema:
   {
     \"task_id\": \"$TASK_ID\",
     \"status\": \"completed\" | \"failed\",
     \"processed_at\": \"<ISO 8601 timestamp>\",
     \"produced_by\": \"prime\",
     \"summary\": \"<short structured result>\",
     \"artifacts\": []
   }
5. Keep the output structured and concise
6. Do not relay long text context
7. Do not modify unrelated files
8. Stop after writing result.json
" 2>&1 | tee "$HANDOFF/tmp/${TASK_ID}.agent.log"

echo ""
echo "🔍 校验结果..."

# ── 4. 校验 result.json 是否存在且有效 ──
RESULT_FILE="$HANDOFF/outbox/$TASK_ID/result.json"

if [ ! -f "$RESULT_FILE" ]; then
  echo "❌ result.json 未生成，任务处理失败"
  echo "   检查日志: $HANDOFF/tmp/${TASK_ID}.agent.log"
  # 不归档，保留在 inbox 等待重试
  exit 1
fi

# JSON 基本校验：能被 python 解析且包含必需字段
VALID=$(python3 -c "
import json, sys
try:
    data = json.load(open('$RESULT_FILE'))
    required = ['task_id', 'status', 'processed_at', 'produced_by']
    missing = [k for k in required if k not in data]
    if missing:
        print(f'MISSING: {missing}')
        sys.exit(1)
    print('VALID')
except Exception as e:
    print(f'PARSE_ERROR: {e}')
    sys.exit(1)
" 2>&1)

if [ "$VALID" != "VALID" ]; then
  echo "❌ result.json 校验失败: $VALID"
  echo "   文件内容:"
  cat "$RESULT_FILE"
  echo ""
  echo "   不归档，保留在 inbox 等待重试"
  exit 1
fi

echo "✅ result.json 校验通过"

# ── 5. 只有校验通过后才归档 ──
mv "$HANDOFF/inbox/$TASK_ID" "$HANDOFF/archive/"
echo "📦 任务已归档 → archive/$TASK_ID"

# ── 6. 清理 agent 日志（可选） ──
rm -f "$HANDOFF/tmp/${TASK_ID}.agent.log"

echo "✅ 任务 $TASK_ID 处理完成"
