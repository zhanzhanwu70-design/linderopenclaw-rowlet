# task_20260526_001：Hermes Agent Tool/Thinking Realtime Display 研究與 OpenClaw 改良計畫

日期：2026-05-26
負責：rowlet / 木木梟
狀態：完成研究與實作規格，供 charizard 接續實作

## 1. Executive Summary

Hermes Agent 的做法不是把每個 token / 每個工具細節都丟給使用者，而是分層呈現：

1. **即時狀態層**：status line / spinner 顯示「正在思考」「正在跑哪個工具」與 elapsed time。
2. **關鍵進度層**：tool start / tool generating / tool completed 顯示一行可讀摘要，例如 `🔍 search query 1.2s`、`💻 $ command 3.4s`。
3. **結果摘要層**：工具完成後只顯示可判斷進展的摘要；檔案修改額外顯示 bounded diff。
4. **Thinking 層**：reasoning 可以展開或收合；即時串流時會 buffer 到自然邊界，避免一個 token 一行。
5. **詳細資料層**：詳細 args、raw stdout、完整 reasoning 只在 verbose/details expanded 時顯示。

OpenClaw 目前其實已經具備大部分事件骨架：

- `/app/dist/selection-BeP8qtCb.js`
  - `handleToolExecutionStart`：emit `stream: "tool" phase:"start"`，以及 tracked item start。
  - `handleToolExecutionUpdate`：emit `stream: "tool" phase:"update"`、command output delta。
  - `handleToolExecutionEnd`：emit `stream: "tool" phase:"result"`、command output end、patch summary、approval event。
  - `handleMessageUpdate`：處理 `thinking_start` / `thinking_delta` / `thinking_end`，並透過 `emitReasoningStream` 串到 channel。
- `/app/dist/tool-display-CePrqCCy.js`
  - `resolveToolDisplay()`、`formatToolSummary()` 已經能根據工具與 args/meta 產生 tool label/detail。
- `/app/dist/channel-streaming-CEw8ZK0Y.js`
  - `buildChannelProgressDraftLine()` / `formatChannelProgressDraftText()` 負責 progress line 格式與裁切。
- `/app/extensions/discord/src/monitor/message-handler.process.ts`
  - `onToolStart` / `onItemEvent` / `onPlanUpdate` / `onApprovalEvent` / `onCommandOutput` / `onPatchSummary` / `onReasoningStream` 已接到 Discord draft preview。
- `/app/extensions/discord/src/monitor/message-handler.draft-preview.ts`
  - `pushToolProgress()` / `pushReasoningProgress()` 會維護 progress lines，並用 draft message 即時更新。

主要缺口不是「沒有事件」，而是：**哪些事件該變成使用者看得到的 progress line、用什麼 detail level、如何避免 raw stdout / trivial details 淹沒畫面**。

---

## 2. Hermes Agent Display 觀察

### 2.1 文件與程式依據

研究來源：

- Hermes docs：`/docs/user-guide/tui`
  - TUI status line 即時顯示 `thinking… / running…`。
  - default visibility：thinking expanded、tools expanded、activity hidden by default。
  - `/details` 可切換 hidden / collapsed / expanded，並可針對 thinking/tools/subagents/activity 設定。
- Hermes docs：`/docs/developer-guide/agent-loop`
  - AIAgent callback surfaces：`tool_progress_callback`、`thinking_callback`、`reasoning_callback`、`tool_gen_callback`、`status_callback`。
- Hermes source：`agent/display.py`
  - `build_tool_preview(tool_name,args)`：每個工具選 primary arg，輸出短 preview。
  - `get_cute_tool_message(tool_name,args,duration,result)`：工具完成時輸出一行 compact summary。
  - `render_edit_diff_with_delta()`：write/patch/skill_manage 成功後才 bounded 顯示 diff。
  - `KawaiiSpinner`：非 TTY 避免動畫刷爆 log；TUI 用自己的 status widget。
- Hermes source：`cli.py`
  - `_on_tool_gen_start()`：工具參數生成時顯示 `preparing tool…`。
  - `_on_tool_progress()`：tool.started 更新 spinner；tool.completed 視 `tool_progress_mode` 輸出 stacked scrollback line。
  - `_stream_reasoning_delta()`：reasoning 即時串流，但以 box/buffer 形式，避免碎片化。
  - `_flush_reasoning_preview()`：在自然邊界或長度門檻 flush reasoning preview。

### 2.2 Hermes 的核心 UX 原則

1. **狀態先於細節**：先讓使用者知道 agent 沒卡住：thinking / running / tool name / elapsed。
2. **一個 tool 一行摘要**：工具完成通常是一行，不把完整 args/result 展開。
3. **重要結果才補充**：檔案改動顯示 diff；命令失敗顯示 error；approval 顯示可採取行動的資訊。
4. **避免重複**：連續相同工具可在 `new` 模式去重；TUI status 只顯示目前活動。
5. **details mode 分層**：一般使用者看 compact；debug/verbose 才看 expanded/raw。
6. **Thinking 可看但要整理**：buffer 到自然語意邊界，限制行數/長度，避免 token spam。

---

## 3. OpenClaw 現況整理

### 3.1 Tool event pipeline

目前 `/app/dist/selection-BeP8qtCb.js` 已產生以下事件：

- tool start：
  - `emitAgentEvent({ stream:"tool", data:{ phase:"start", name, toolCallId, args }})`
  - `emitTrackedItemEvent({ kind:"tool", phase:"start", status:"running" })`
  - exec / apply_patch 另有 command / patch item start。
- tool update：
  - `emitAgentEvent({ stream:"tool", data:{ phase:"update", partialResult }})`
  - exec 會額外 emit command item update 與 `emitAgentCommandOutputEvent(... phase:"delta")`。
- tool result：
  - `emitAgentEvent({ stream:"tool", data:{ phase:"result", result }})`
  - tracked item end，狀態 completed/failed。
  - exec end 會 emit command output；patch end 會 emit patch summary；approval pending 會 emit approval event。

### 3.2 Thinking / reasoning pipeline

`handleMessageUpdate()` 對 provider assistant event：

- `thinking_start` / `thinking_delta`：open reasoning stream，append raw stream；若 `ctx.state.streamReasoning` 則 `ctx.emitReasoningStream(...)`。
- `thinking_end`：emit reasoning end。

Discord channel 端：

- `message-handler.process.ts` 的 `onReasoningStream`：`statusReactions.setThinking()` + `draftPreview.pushReasoningProgress(payload?.text)`。
- `message-handler.draft-preview.ts` 的 `pushReasoningProgress()`：merge raw reasoning、normalize line，更新 preview lines。

### 3.3 Discord progress draft 現況

`message-handler.draft-preview.ts`：

- `pushToolProgress()`：只接受 `isChannelProgressDraftWorkToolName()` 判斷為 work tool 的工具；去掉 message/reply/reaction/typing 等 trivial 工具。
- `pushReasoningProgress()`：把 reasoning line 加進同一組 `previewToolProgressLines`。
- `formatChannelProgressDraftText()`：最多顯示 `progress.maxLines`，每行 72 chars compact。

`channel-streaming-CEw8ZK0Y.js`：

- `buildChannelProgressDraftLine()` 已有 event 類型：tool / item / plan / approval / command-output / patch。
- `commandText` 可設定 raw/status；但目前 default raw，容易讓 exec stdout 過多。

---

## 4. 「關鍵資訊」vs「攏常細節」分界

### 4.1 應該顯示（關鍵資訊）

#### Thinking

顯示：

- 新階段：`Analyzing request`、`Planning tool use`、`Checking result`。
- 一句短 reasoning snapshot：最多 120 chars，最好取最新完整句或條列標題。
- 長時間無輸出時：`Still reasoning… 24s`。
- thinking 結束後若進入 tool：保留最後一條有意義 reasoning line，不顯示完整 scratchpad。

不顯示：

- token 級碎片。
- provider internal tags：`<thinking>`、`Reasoning:` 前綴。
- 敏感推理全文、chain-of-thought 逐字稿；預設只顯示摘要/狀態，expanded 才可看更長但仍 bounded。

#### Tool Start

顯示：

- tool label + primary detail：`📖 Read: path`、`🌐 Fetch: domain`、`💻 Exec: git status`。
- mutating / approval / external network 類工具加醒目 label：`✍️ Write`、`🔧 Patch`、`🔐 Approval requested`。
- 批量/長任務顯示規模：`3 files`、`12 images`、`timeout 60s`。

不顯示：

- 完整 JSON args。
- API keys、headers、完整 env。
- 內部 sessionKey / runId / toolCallId，除非 debug mode。

#### Tool Update

顯示：

- 長任務有狀態變化：download %, pages processed, background process started, approval pending。
- exec 的 bounded status：`running 12s`、`exit 1`、`approval pending`。

不顯示：

- 每一行 stdout/stderr。
- 重複 running update。
- 小工具完成太快的 update。

#### Tool End

顯示：

- 成功/失敗/blocked + duration。
- exec：只顯示 exit code、duration、必要時最後 1-2 行錯誤摘要。
- apply_patch/write/edit：顯示 `N modified / added / deleted`，可選 bounded diff。
- web_fetch/read：顯示 title/domain/status/bytes 或 `read 120 lines`。
- image/OCR/analysis：顯示結果摘要與 confidence/problem flags。

不顯示：

- 完整 tool result、完整 HTML、完整 stdout、大型 JSON。
- 已由最終回覆自然說明的中間細節。
- messaging/reaction/typing 類 delivery plumbing。

### 4.2 建議 display modes

新增或明確化三層模式：

| Mode | 適用 | 顯示內容 |
|---|---|---|
| `compact` | 預設 Discord/Telegram | 只顯示 thinking snapshot、tool start/end summary、approval、error、patch summary |
| `expanded` | 開發/debug channel | 顯示 tool args primary fields、bounded command output、bounded reasoning preview |
| `debug` | 本機/TUI/Control UI | 顯示 toolCallId、raw event tag、完整 bounded details |

---

## 5. OpenClaw 改良計畫

### Phase 1：建立統一的 Display Policy / Significance Classifier

新增建議檔案：

- `src/plugin-sdk/channel-progress-policy.ts`（若 source tree 可改）
- compiled 對應：`/app/dist/channel-streaming-CEw8ZK0Y.js` 所屬 source module

核心 API：

```ts
type ProgressDisplayMode = "compact" | "expanded" | "debug";
type ProgressImportance = "hidden" | "low" | "normal" | "high" | "critical";

type ProgressDecision = {
  importance: ProgressImportance;
  line?: ProgressLine;
  replaceKey?: string;      // e.g. reasoning, toolCallId
  allowRawDetail?: boolean;
  ttlMs?: number;
};

function classifyProgressEvent(input: ChannelProgressInput, options: {
  mode: ProgressDisplayMode;
  commandText: "status" | "raw";
  maxDetailChars: number;
}): ProgressDecision
```

規則：

- hide：message/reply/reaction/typing；empty reasoning；duplicate update；tool update 無新資訊。
- critical：approval requested、tool failed、permission denied、security warning。
- high：patch/write/edit summary、exec non-zero、external send result、cron created/deleted。
- normal：tool start for work tools、plan update first meaningful step、web fetch/read/search start/end。
- low：fast read/list/status 類工具，可只留當前狀態，不進歷史 lines。

### Phase 2：改造 `buildChannelProgressDraftLine()`

目標檔案：

- `/app/dist/channel-streaming-CEw8ZK0Y.js`
  - source function：`buildChannelProgressDraftLine()`
  - source function：`buildChannelProgressDraftLineForEntry()`
  - source function：`formatChannelProgressDraftText()`

建議修改：

1. 在 `buildChannelProgressDraftLine()` 前先跑 classifier。
2. `input.event === "item"` 時，若 `input.phase === "update"` 且沒有 `summary/progressText/meta`，直接 hidden。
3. `command-output` compact mode 預設不要顯示 raw output，只顯示 `completed` / `exit N` / `approval pending`。
4. patch 顯示 summary 與 top changed files，不顯示完整 diff。
5. tool start 顯示 `resolveToolDisplay({ detailMode:"summary" })`；expanded/debug 才用 `detailMode:"explain"`。
6. 每行 72 chars 可以保留，但 reasoning line 建議 120 chars，因為自然語句比 tool detail 長。

### Phase 3：Reasoning / Thinking 整合成一等 progress event

目標檔案：

- `/app/dist/selection-BeP8qtCb.js`
  - `handleMessageUpdate()` 的 thinking event 分支。
- `/app/extensions/discord/src/monitor/message-handler.process.ts`
  - `onReasoningStream`。
- `/app/extensions/discord/src/monitor/message-handler.draft-preview.ts`
  - `pushReasoningProgress()`、`normalizeReasoningProgressLine()`、`mergeReasoningProgressText()`。

建議修改：

1. 在 `handleMessageUpdate()` 中 emit structured item event：

```js
emitTrackedItemEvent(ctx, {
  itemId: `reasoning:${ctx.params.runId}`,
  phase: evtType === "thinking_end" ? "end" : "update",
  kind: "analysis",
  title: "Reasoning",
  status: evtType === "thinking_end" ? "completed" : "running",
  summary: summarizeThinking(thinkingContent || thinkingDelta),
});
```

2. 新增 `summarizeThinking()`：
   - strip `Reasoning:` / XML thinking tags。
   - collapse whitespace。
   - 如果是短句：原樣顯示。
   - 如果很長：取最後一個完整句；沒有句號則取前 120 chars。
   - drop repetitive prefix / duplicate line。

3. `pushReasoningProgress()` 不再把整個 raw accumulated text 當一條 line；改接收 already summarized 的 `summary`，或內部調 `summarizeThinkingProgress()`。

4. Thinking 和 tool line 共用 `replaceKey`：同一輪只保留一條最新 thinking line，避免 thinking line 佔滿 `maxLines`。

### Phase 4：Progress Draft Controller 加去重 / 取代 / 優先級

目標檔案：

- `/app/extensions/discord/src/monitor/message-handler.draft-preview.ts`
  - `previewToolProgressLines` 目前是 string array，建議升級成 object array。

建議資料結構：

```ts
type ProgressDraftLine = {
  key?: string;              // reasoning 或 toolCallId
  text: string;
  importance: "low"|"normal"|"high"|"critical";
  ts: number;
};
```

新行策略：

- 有 `key`：replace 舊行，不 append。
- `critical/high` 永遠保留，低重要性可被擠掉。
- `maxLines` 裁切時優先保留：critical > high > newest normal > newest low。
- 重複 normalized text 直接略過。
- tool start 如果 1 秒內就有 tool end，可以只顯示 end summary。

### Phase 5：Config 增加 Display Policy

建議 config schema：

```json5
channels: {
  discord: {
    streaming: {
      mode: "progress",
      progress: {
        toolProgress: true,
        displayMode: "compact",       // compact | expanded | debug
        commandText: "status",        // status by default, raw only expanded/debug
        maxLines: 8,
        maxLineChars: 96,
        reasoning: {
          enabled: true,
          mode: "summary",            // hidden | summary | expanded
          maxChars: 120,
          replacePrevious: true
        },
        tools: {
          showStart: true,
          showUpdates: "significant", // none | significant | all
          showEnd: true,
          minDurationMsForHistory: 800,
          rawOutputMaxChars: 0
        }
      }
    }
  }
}
```

安全預設：

- `commandText: "status"`。
- `rawOutputMaxChars: 0`。
- reasoning 預設 summary，不顯示完整 chain-of-thought。
- `debug` mode 只建議 Control UI / owner DM，不建議公開 Discord channel。

---

## 6. 建議修改檔案清單（給 Charizard）

### 必改

1. `/app/dist/channel-streaming-CEw8ZK0Y.js`
   - `buildChannelProgressDraftLine()`：接 classifier，根據 event/phase/status 過濾與摘要。
   - `compactChannelProgressDraftLine()`：max char 建議可 config 化。
   - `formatChannelProgressDraftText()`：支援 line object / priority / replaceKey（若先做小改，可仍維持 string array）。

2. `/app/extensions/discord/src/monitor/message-handler.draft-preview.ts`
   - `pushToolProgress()`：從 string array 改為 structured progress lines，支援 replace/dedupe/importance。
   - `pushReasoningProgress()`：改 summary 化，不 append raw accumulated reasoning。
   - `normalizeReasoningProgressLine()`：新增 tag stripping、sentence boundary、max chars。

3. `/app/extensions/discord/src/monitor/message-handler.process.ts`
   - `onReasoningStream`：傳 structured summary 或至少傳 `{text, phase}`。
   - `onItemEvent`：若 item kind analysis/reasoning，走 reasoning-specific path，而不是一般 tool line。
   - `onCommandOutput`：compact mode 只顯示 status/exit code；raw output 由 config 控制。

### 應改

4. `/app/dist/selection-BeP8qtCb.js`
   - `handleMessageUpdate()`：thinking events emit structured item events，讓所有 channel 不只 Discord 能用。
   - `handleToolExecutionUpdate()`：exec partial output 先摘要/限流，再進 live event。

5. `/app/dist/tool-display-CePrqCCy.js`
   - `TOOL_DISPLAY_CONFIG` 增補常用工具的 primary detail keys。
   - `resolveToolDisplay()` 支援 `phase/status/duration` 或從 meta 顯示更好的 summary。

### 測試

6. `/app/extensions/discord/src/monitor/message-handler.process.test.ts`
   - 增加：reasoning 顯示摘要、不顯示 raw `<thinking>`。
   - 增加：commandText=status 時不顯示 raw stdout。
   - 增加：patch summary 保留、read/list 快速細節不刷屏。

7. channel streaming SDK tests（若 source tree 有對應測試）
   - `buildChannelProgressDraftLine()` 對 tool/item/command-output/patch/reasoning 的 snapshot tests。

---

## 7. 最小可行實作（MVP）

如果 Charizard 要快速落地，建議先做 MVP：

1. `message-handler.draft-preview.ts`
   - `pushReasoningProgress()`：只保留最後一條 reasoning line；長度限制 120；strip `Reasoning:` 與 thinking tags。
2. `channel-streaming-CEw8ZK0Y.js`
   - `command-output` compact 改成只顯示 status/exit code，不帶 raw output。
   - `item` update 無 `summary/progressText/meta` 時 return undefined。
3. `message-handler.process.ts`
   - `onCommandOutput` 只在 phase end 顯示；若 exitCode=0 顯示 `completed`，非 0 顯示 `exit N`。
4. 加 tests：
   - reasoning 不重複 append。
   - exec raw output 被隱藏。
   - patch summary 仍顯示。

MVP 預期效果：

- Discord progress draft 會像 Hermes 一樣「看到 agent 正在做什麼」，但不被 raw stdout/細碎 thinking 淹沒。
- Charizard 可先不碰 deeper `selection` event generation，只改 channel display 層。

---

## 8. 驗證標準

1. Thinking：
   - 顯示「最新一條 reasoning 摘要」，不顯示 `<thinking>` tag。
   - 多次 delta 不會塞滿 progress maxLines。
2. Tool start：
   - read/write/exec/web_fetch 顯示工具名 + primary detail。
   - message/reaction/typing 不顯示。
3. Tool end：
   - exec success：`💻 Exec: completed` 或簡短 command + completed。
   - exec fail：`💻 Exec: exit N`，可附最後錯誤摘要（bounded）。
   - patch/write：顯示 changed summary。
4. 即時性：
   - 長任務 5 秒內出現 progress draft；第二個 work event 立即 start（現有 gate 已支援）。
5. 安全：
   - raw args/result 不包含 secrets。
   - public channel 不顯示完整 chain-of-thought。

---

## 9. 結論

OpenClaw 不需要重做整套 event pipeline；目前 `selection` → `agent events/item events` → `message-handler.process.ts` → `draft-preview.ts` → Discord draft stream 的鏈路已存在。

最值得改的是 **display policy**：

- 把 tool/thinking event 轉成「可讀、短、去重、有優先級」的 progress line。
- Compact mode 預設只顯示關鍵資訊。
- Expanded/debug 再顯示 raw details。
- Thinking 預設 summary，不做 chain-of-thought 全量外洩。

這樣可以達到 Hermes 類似的 realtime observability，同時更適合 Discord / Telegram 這類訊息型介面。