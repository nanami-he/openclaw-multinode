#!/bin/bash
# refresh-status.sh — Chamberlain 端：扫描本地 handoff，写成 JSON，推到 Prime HTTP 根目录

set -euo pipefail

REPO_DIR="/Users/nanami/Desktop/openclaw-multinode"
HANDOFF="$REPO_DIR/handoff"
STATUS_FILE="/tmp/status-chamberlain.json"

# 扫描目录，返回 JSON 数组字符串
scan_dir() {
    local dir="$1"
    local result=""
    if [ -d "$dir" ]; then
        local items=""
        for tdir in "$dir"/task-*; do
            [ -d "$tdir" ] || continue
            local tid=$(basename "$tdir")
            local status="pending"
            if [ -f "$tdir/result.json" ]; then
                status=$(python3 -c "import json,sys; print(json.load(open('$tdir/result.json')).get('status','unknown'))" 2>/dev/null || echo "unknown")
            fi
            items="${items:+$items,}{\"id\":\"$tid\",\"status\":\"$status\"}"
        done
        echo "[${items}]"
    else
        echo "[]"
    fi
}

cat > "$STATUS_FILE" <<EOF
{
  "node": "chamberlain",
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "outbox":  $(scan_dir "$HANDOFF/outbox"),
  "inbox":   $(scan_dir "$HANDOFF/inbox"),
  "archive": $(scan_dir "$HANDOFF/archive")
}
EOF

# 推到 Prime HTTP 根目录
rsync -avz --ignore-existing "$STATUS_FILE" prime:~/status-chamberlain.json
echo "✅ Chamberlain 状态已推送"
