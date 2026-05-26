# HEARTBEAT.md - rowlet

## Task System（CEO 模式）

CEO = **roaringmoon**，統一發放任務、標記 done。

### 每次 Heartbeat 執行流程

#### Step 1: 檢查被指名的 pending task
```bash
flock ~/.openclaw/task-queue/.lock -c "cat ~/.openclaw/task-queue/task_queue.json" > /tmp/task_queue_read.json
```

找到：`status=pending AND to=rowlet` 的 task

#### Step 2: 開始執行 → 更新為 running
```bash
flock ~/.openclaw/task-queue/.lock -c "python3 << 'EOF'
import json
with open('/tmp/task_queue_read.json') as f:
    d = json.load(f)
for t in d['tasks']:
    if t['id'] == '<task_id>':
        t['status'] = 'running'
        t['started_at'] = $(date +%s)
        t['run_count'] = t.get('run_count', 0) + 1
with open('~/.openclaw/task-queue/task_queue.json', 'w') as f:
    json.dump(d, f, indent=2)
EOF"
```

#### Step 3: 執行任務（研究、寫作、分析等）

#### Step 4: 過程中主動回報進度給 CEO（roaringmoon）
```bash
# 使用 sessions_send 發送進度更新給 CEO
# RoaringMoon channel: 1482561255955763293
sessions_send sessionKey: "agent:roaringmoon:discord:channel:1482561255955763293" message: "<task_id> 進度更新：目前完成...，遇到...，下一步..."
```

#### Step 5: 任務完成 → 標記等待 CEO 檢視
```bash
flock ~/.openclaw/task-queue/.lock -c "python3 << 'EOF'
import json
with open('/tmp/task_queue_read.json') as f:
    d = json.load(f)
for t in d['tasks']:
    if t['id'] == '<task_id>':
        t['status'] = 'completed'
        t['completed_at'] = $(date +%s)
        t['needs_ceo_review'] = True
        t['result'] = '<任務摘要>'
with open('~/.openclaw/task-queue/task_queue.json', 'w') as f:
    json.dump(d, f, indent=2)
EOF"
```

#### Step 6: 通知 CEO 檢視
```bash
# 發送最終結果給 CEO 的 mailbox
# RoaringMoon channel: 1482561255955763293
sessions_send sessionKey: "agent:roaringmoon:discord:channel:1482561255955763293" message: "✅ <task_id> 已完成，需要 CEO 檢視。摘要：<result>"
```

### CEO Mailbox 檢視職責（RoaringMoon）
RoaringMoon 的 heartbeat 還需要：
- 檢查所有 `needs_ceo_review=True` 的 task
- 讀取 agent 傳來的進度訊息
- 確認結果後標記 `done`
- 有需要時發回修改意見

### 沒有任務時
回覆：`HEARTBEAT_OK`

---

## Shared Memory（共享記憶三層）

每次 heartbeat 結束前，檢查並更新共享記憶：

### Step 7: 更新 Shared Memory（可選，若有任務完成）

#### 7a. 寫入 Episodic（日誌）
```bash
# 每次任務完成後寫入月誌（append-only）
YEAR_MONTH=$(date +%Y-%m)
JSON_LINE='{"ts":'$(date +%s)'000,"agent":"rowlet","event":"task_completed","task_id":"<task_id>","summary":"<任務摘要>"}'
echo $JSON_LINE >> ~/.openclaw/shared-memory/memory/episodic/${YEAR_MONTH}.jsonl
```

#### 7b. 寫入 Semantic（事實庫）
```bash
# 如果任務結果有值得記住的事實，更新 facts.json
python3 << 'EOF'
import json
f = '~/.openclaw/shared-memory/memory/semantic/facts.json'
with open(f) as fp:
    d = json.load(fp)
# 讀取舊 facts
facts = d.get('facts', [])
# 新增事實（每個 task 完成後，提取 1-3 個關鍵fact）
new_facts = [
    {
        "id": "<uuid>",
        "content": "<值得記住的事實>",
        "source": "rowlet",
        "ts": $(date +%s)000
    }
]
facts.extend(new_facts)
d['facts'] = facts
d['updated_at'] = $(date +%s)000
d['updated_by'] = "rowlet"
with open(f, 'w') as fp:
    json.dump(d, fp, indent=2, ensure_ascii=False)
EOF
```

#### 7c. 寫入 Approved（知識庫，需 CEO 審核）
```bash
# 如果有需要變成長期知識的內容，寫到 approved/ 並通知 CEO
# 檔案命名：YYYY-MM-DD_topic-slug.md
cat > ~/.openclaw/shared-memory/memory/approved/2026-05-26_task001_report.md << 'REPORT'
# 任務報告：<task_id>

## 摘要
<任務結果摘要>

## 關鍵發現
- ...

## 待 CEO 審核
- [ ] 確認內容準確
- [ ] 移動到合适的位置（wiki 或歸檔）
REPORT

# 通知 CEO 有新知識等待審核
sessions_send sessionKey: "agent:roaringmoon:discord:channel:1482561255955763293" message: "📄 <task_id> 完成，已寫入 shared-memory/memory/approved/ 待你審核"
```

### Step 8: 讀取 Shared Memory（每次 heartbeat 一樣會讀）

```bash
# 讀取最近的事件日誌，了解最近發生了什麼
tail -20 ~/.openclaw/shared-memory/memory/episodic/$(date +%Y-%m).jsonl

# 讀取事實庫，了解已確認的資訊
cat ~/.openclaw/shared-memory/memory/semantic/facts.json

# 讀取待審核的知識
ls ~/.openclaw/shared-memory/memory/approved/
```

---
## Agent Channel IDs（from openclaw.json）
```
roaringmoon: 1482561255955763293
charizard:  1482097593784733839（主要）, 1482374570278129724（monitor）
mrmime:    1482069603512221927
rowlet:    1482363974119854234
gengar:    1484513576482902158
celesteela: 1482607890098421842
picturecat: 1481665581189959872
greninja:  1382962403720827011
flaaffy:   1494534371292614729
```
