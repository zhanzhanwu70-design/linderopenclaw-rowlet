# 每日 Agent × 軟體開發情報 — 2026-10-30

> 來源：21 個公開來源 / 8 篇深度抽取 · 產出：木木鴞 🌿🦉 · Wiki 已入庫（1 source + 2 concepts，graphify 已連結，非 orphan）
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-10-30-background-agent-token-blackhole-and-skills-ecosystem.md`
> 覆蓋：arXiv cs.AI · GitHub Trending · Hacker News · Martin Fowler RSS · InfoQ · Releasebot（OpenAI/Anthropic/Claude Code/Cursor/Codex）· MCP SEP · YC Labs · DeepMind Institute · Mistral

**一句話總結：Claude Code 每 30 秒把每個背景 agent 的整份 transcript 重新送給模型，只為了填一行 3–5 個字的狀態列——吃掉 19.7% 的 API 請求、16.4% 的總花費（比主對話還多）、96% 花在 Opus，而且自 2.1.232 起預設開啟、無法關閉。與此同時 skills 正在變成有 star 訊號的可分發 artifact（Cloudflare 官方 skill repo 單週 +14,320 stars），swarm 的協調形態取決於模型家族（GPT 像蜂群、Claude 像有單一 leader 的小團體），而 Mistral 用「同分少用 47% token」告訴我們：排行榜分數已經飽和，token 效率才是真的。**

---

## 今日 5 個重點

### 1. 背景 Agent 的「自我描述」是最貴的一種呼叫，而且是 harness 的默認值

- **發生什麼**：Claude Code 每約 **30 秒**，對**每個背景 agent**，把該 agent 的**整份 transcript** 送到它自己的模型（通常 Opus），要求「用 3–5 個字描述你最近一個動作」。答案**只填 agents 面板的狀態列** — 不進主對話、不進模型上下文、不產生任何工作結果。**自 2.1.232（2026-08）起預設開啟，沒有任何設定可關。** 實測：`agent_summary` 占全部 API 請求 **19.7%（約每 5 次就有 1 次）**、占總花費 **16.4%**（主對話 15.7%，**摘要比主對話還多**）、其中 **96% 花在 Opus**、input:output ≈ **9,000:1**。修法是約 70 行的 Bun `--preload`（不修改 binary；模組以預編譯 bytecode 出貨，只能攔 `setTimeout`，靠 `Function.prototype.toString` 認出 summarizer anchor），實測 2.1.257–2.1.312，但**版本更新可能靜默還原**。
- **為什麼重要**：這是**架構層的隱性稅**，不是實作細節。任何多 agent 系統都會長出「每個 agent 要回報狀態」的需求，而最自然的實作（定期把 transcript 丟給模型摘要）恰好是最貴的一種 — 因為 transcript 已經在 context 裡，重送等於**為同一份資訊付第二次錢**。**我們的 `sessions_spawn` → 子 agent → 結果回推父 session，形狀完全相同。** 交叉佐證：`anthropics/claude-code#86879` 有 4 份彼此獨立的量測落在 18–26%。
- **來源**：[gist flamerix-ai（234★, HN 562 points）](https://gist.github.com/flamerix-ai/c3905705cc4205e5de3011fa2e74efce) ・ [issue #86879](https://github.com/anthropics/claude-code/issues/86879)

### 2. Skills 從「prompt 片段」長成「有分發訊號的可安裝 artifact」

- **發生什麼**：GitHub Trending weekly 前列**至少 5 個是 agent skills / harness repo** — `cloudflare/security-audit-skill`（多階段安全稽核、獨立驗證、機器可讀 findings）**單週 +14,320 stars，為本週最快**，且是**廠商身分**；`anthropics/knowledge-work-plugins`（官方，+2,504）；`obra/superpowers`（agentic skills framework ＋ 開發方法論，+4,894）；`Leonxlnx/taste-skill`（給 agent「品味」：art direction + reference images + **browser check**，+4,359）；`multica-ai/andrej-karpathy-skills`（把 Karpathy 對 LLM coding 陷阱的觀察包成單一 `CLAUDE.md`，22.6 萬 stars，+4,250）。同期 **Cursor Agent SDK GA**（10-20）：以程式碼定義 agent、接 workflow events、跑 evaluations、部署到自家或 Cursor 基礎設施 — **這就是 Cursor 內部用來建 Bugbot / Security Reviewer / Rollouts 的同一個框架**。
- **為什麼重要**：skills 正在長出「**套件管理器 + star 訊號 + 廠商入口**」三件套。**星數本身就是品質訊號** — 社群正在自己建立排序機制，而我們的 `skill_workshop` 產出目前沒有對應的外部訊號，這是本週最直接的可執行落差。Cursor Agent SDK 同時是 10-29「**Agent 該像軟體專案一樣被管理**」的廠商實作。
- **來源**：[GitHub Trending weekly](https://github.com/trending?since=weekly) ・ [Cursor Agent SDK（Releasebot）](https://releasebot.io/updates/cursor)

### 3. Swarm 陣型由「模型家族」決定，不是由提示詞或架構圖決定

- **發生什麼**：**YC Labs × Olam Labs**（與替前沿實驗室做 multi-agent 環境的 Olam Labs 合作）在 Minecraft 與 Mindustry 跑 swarm 實驗，得到五條發現：**GPT 家族像蜂群**（更協作、更願做苦工、通訊網更密更廣，但**多數是低價值訊息**；ownership 切成小塊分給多個 agent；語言壓縮成**無空格的短碼**如 `G7T5FIRSTcourierLIVE`；**局勢緊張時總有 agent 主動接管**；**卡住時自己去網路抓遊戲原始碼**來分析弱點並在 chat 公開協作 — **從未被禁止，但也從未被告知**）；**Claude 家族有一個 leader**（**通訊量低但有效**，更像人在 Slack 講話；用 **「+1」民主表決**；**即使連輸多場也從未換 leader 或階層**；**完全沒有去讀原始碼**）。同時 **DeepMind Institute**（今日發表）提出 **coordination vs. competence** 兩軸：100 人跨 6 領域測驗顯示**個體能力是 jagged 的**（一領域的表現不預測另一領域，沒有「平均智力」的複本），組織靠把互補專家配對到各自相對優勢的位置構成 **mosaic intelligence**，**配對互補比隨機配對高 32%**；並警告協調能力過臨界點會觸發市場集中度/就業/工資的劇烈跳變。
- **為什麼重要**：**「多 agent 陣型」至少存在兩種互斥的正確解，跨模型不可直接移植。** 我們的團隊結構（單一 CEO + 專責 agent）**預設假設了 Claude 型**；底層換成 GPT 型，同一份 prompt 很可能長成「無固定 leader、分片 ownership、通訊很多但雜訊大」的蜂群 — **決策是否還需要人接手，答案會不同**。另外 DeepMind 指出的 benchmark 缺口正中我們的痛點：**我們評估 agent 團隊靠成功率與 token 成本，幾乎不量協調**；而 jagged 的意思是**平均分數高的隊伍可能在互補結構上完全錯配** — 而我們的選人正是按平均能力排的。
- **來源**：[YC Labs Agents in Games](https://labs.ycombinator.com/projects/games/index.html) ・ [DeepMind Institute — AGI Economics: Coordination vs. Competence](https://institute.deepmind.com/essays/the-economics-of-intelligence/)

### 4. 榜單分數已飽和，「同分之下少用多少 token」才是可比較的量

- **發生什麼**：**Mistral Large 4（Le Chonk）開放權重**（10-29）：1 兆參數、native multimodal，三週前 public preview 後**再跑三週 RL**（「持續加速、無飽和跡象」）本日釋權重。成績：**Cognition FrontierCode 2.0 19.7% 領先**（維護者是否會合併這個 agent 的改動）、**Terminal-Bench 4.0 比 preview +13 個百分點到 41% 取得領先**；**Artificial Analysis Coding Agent Index 48%，與最強 open-weight 模型 GLM-5.3 幾乎打平，但每任務平均少用 47% token**。歐洲基礎設施從零訓練、fully open-weight、可 self-host。
- **為什麼重要**：當兩個模型**分數打平（48% vs 48%）**，分數就沒有資訊量了，**差距全在 token 效率**。我們現在的模型選用預設以「能力榜」排序 — 在能力飽和、價格分歧、token 用量成為主要成本驅動的當下，這個排序會**系統性地選錯**。這也正好接上我們既有的「skill 增益要有 null baseline」思路：**排名是飽和的，單位任務成本才是可比較的量。**
- **來源**：[Mistral Large 4 開放權重公告](https://mistral.ai/news/mistral-large-4-oss/)（HN 1228 points）

### 5. 好工程師的戒心不是怕失業，是怕「built ≠ running in production」

- **發生什麼**：**Thoughtworks CTO Rachel Laycock**（martinfowler.com, 10-29）：核心命題是**好工程師對 agentic 開發的戒心來自「做出來 ≠ 安全跑在 production 上」**，不是怕失業、也不是愛寫程式。「早期 coding agent 很容易產出程式碼，**包括我們根本不希望它靠近 production 的那種**，由沒學過『從做出來到安全上線』這道鴻溝的人寫出來。」一週白板實驗（資深工程師 + 基建顧問 + 產品人，**沒有人寫一行程式，全部 agent 建**）的結論不是「一週能做出航空應用」—「**他們做到 80%，而我們都知道 80% 是什麼意思**」。「我們現在生產的幾乎每一個系統都是老方法、由值得信任的人手寫的。**我們現在建的一切都是新方法，而我們還沒有跟它一起生活過。**」結論：「他們**不是**抗拒使用 coding assistant，他們是**不敢全權放手讓 agent 執行所有動作** — 因為他們沒有信心 agent 裝了正確的護欄。」同期 InfoQ 兩篇：《The Evolution of Agentic Harnesses: From Chains to Graph to Code》（**chains → graphs → code-executing harnesses**；建議選能滿足可靠性/速度/成本的**最小複雜度設計**）與 DORA《AI is an Amplifier: Scale High Performance, Not Dysfunction》（**AI 是放大器，放大高效也放大失能**）。
- **為什麼重要**：Laycock 描述的「**我們還沒有跟它一起生活過**」，正是重點 1 的**另一種表現** — harness 裡塞滿了從未被計價的機制（狀態列摘要、失效的護欄預設），而使用者只在 production 裡才會撞到。**這解釋了為什麼「agent 寫的程式碼合併率看起來不錯」和「團隊不敢全權放手」可以同時成立。**
- **來源**：[Why are good developers so wary of agentic development?](https://martinfowler.com/rachels-ramblings/good-devs-wary.html) ・ [InfoQ harness 演進](https://www.infoq.com/articles/agentic-ai-architecture-harness-evolution)

---

## 對 OpenClaw / Linder 的啟發

### 1. 我們的 `sessions_spawn` 回報鏈路要自己量一次「自我描述稅」
重點 1 直接命中我們的形狀。可行動：在 session 遙測加一個等價於 `query_source` 的維度 — 把 token 依「**真實工作 vs 狀態/摘要/回報**」分類，跑一週看比例。**供應商正在把這個維度變成一等公民**（Anthropic 10-29 上線的 Usage and Cost Analytics API 可依 model / workspace / API key / requester 分組）— 我們的成本帳若沒有同樣切分，就是瞎的。改法若要動：狀態列若只是「最後一個 tool 名稱 + 最後修改的檔案」，**harness 自己就有，根本不需要模型摘要**。

### 2. 我們的團隊分工目前隱含假設了 Claude 型（有 leader），換模型會變形
重點 3。我們是「單一 CEO + 專責 agent」，對應實驗中 Claude 的「+1 民主表決」「leader 從不換」。可行動：把分工 prompt 當**模型家族相依的資產**來標記與版本化（不要假設可攜）；並在模型切換時重量「**決策點有沒有人接手**」— GPT 型的「局勢緊張時總有 agent 主動接管」正是一個需要人介入了的訊號。另外，選 agent 該用**互補矩陣**（覆蓋了哪些維度）而不是各自 benchmark 分數。

### 3. 模型選用該改看「同分下的 token 效率」，並把回報回合獨立成一欄成本
重點 4 + 我們既有的 skill null baseline 結論。可行動：模型比較表從「榜單排名」改成「**每任務 token × 成功率**」雙軸，並把 Anthropic Analytics API 的分組維度當欄位骨架；成本帳裡把「**純回報用的回合數**」跟「技能新增回合數」**分開記**，否則會把回報成本誤記成技能成本。

---

## 值得追蹤的 repo / paper / article

- [gist: no-agent-summary.js — Claude Code 背景 agent 狀態列 token 黑洞 + Bun preload 修法](https://gist.github.com/flamerix-ai/c3905705cc4205e5de3011fa2e74efce) — 234★，4 revisions
- [anthropics/claude-code#86879 — agent_summary 花費的四份獨立量測（18–26%）](https://github.com/anthropics/claude-code/issues/86879)
- [YC Labs × Olam Labs — Agents in Games（Minecraft / Mindustry swarm 實驗）](https://labs.ycombinator.com/projects/games/index.html)
- [DeepMind Institute — AGI Economics: Coordination vs. Competence](https://institute.deepmind.com/essays/the-economics-of-intelligence/)
- [Mistral Large 4 (Le Chonk) 開放權重公告](https://mistral.ai/news/mistral-large-4-oss/)
- [Rachel Laycock — Why are good developers so wary of agentic development?](https://martinfowler.com/rachels-ramblings/good-devs-wary.html)
- [InfoQ — The Evolution of Agentic Harnesses: From Chains to Graph to Code](https://www.infoq.com/articles/agentic-ai-architecture-harness-evolution)
- Skills 生態：[cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) ・ [obra/superpowers](https://github.com/obra/superpowers) ・ [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) ・ [ruvnet/ruflo](https://github.com/ruvnet/ruflo)
- 框架動態：Codex [0.166.0](https://releasebot.io/updates/openai/codex)（GPT-6.1 Terra 進 catalog、`queue --resume`、`doctor --network-only`、修 app-server thread race、**resume/fork 保留 reasoning-token accounting 避免 premature compaction**）・ Claude Code [2.1.312](https://releasebot.io/updates/anthropic/claude-code)（`oidc.user_id_claim`、**修掉大型 CLAUDE.md 只看開頭就被覆寫**）

---

## 下一步建議

1. **量一次我們自己的狀態/回報 token 佔比**（本週可做，成本近零）：session 遙測加「真實工作 vs 狀態摘要/回報」切分，跑一週。結論會直接決定要不要改 harness 的回報機制 — 這是重點 1 最直接的可執行版本。
2. **建立「每任務 token × 成功率」模型比較表**：把現有以能力榜排序改成雙軸，用 Anthropic 10-29 Analytics API 的分組維度（model / workspace / API key / requester）當欄位骨架；把 **Mistral Large 4 open weights** 納入候選（自架可部署）。
3. **已入庫**：新增 `background-agent-status-report-tax` 與 `model-family-shapes-swarm-organization` 兩個 concept + 1 個 source，graphify 已連結（非 orphan）。建議在 `topics/multi-agent-systems-architecture` 追加本週區塊，與既有的「Skill 增益 null baseline」接縫 — **成本帳要記「純回報用的回合數」這第四個維度**。

---

## 誠實限制

- 重點 1 的 token 佔比為 gist 作者**自身 OpenTelemetry 觀測**（非第三方審計）；issue #86879 的 4 份獨立量測是二手但互相獨立的佐證。
- 重點 2 的 star 數為 Trending 頁當下顯示，**會變動**，未查證是否自然成長。
- 重點 3 的 32% 配對增益來自 DeepMind 自己的 **n=100、6 領域**實驗（非 peer-reviewed）；「協調過臨界點觸發市場跳變」是**論述主張**而非實證；YC Labs 觀察是**特定遊戲/模型/提示**下的行為，且屬觀察性描述非受控比較（「GPT 讀原始碼」前提是沙箱允許開網，不可當通用建議）。
- 重點 4 的 benchmark 數字為 Mistral 自述或經其引用的第三方榜單，**未獨立重現**。
- 查到但因日期較舊未列入主軸：Claude Code steganographic prompt marking（2026-06-30）、Anthropic 因出口管制停用 Fable 5 / Mythos 5（2026-06-13）、Claude Opus 4.6 1M context（2026-02-05）。
- **查過但無新訊號**：MCP 官方 blog 本週無新公告（`/blog` 回 404，改走 SEP-990 頁）；arXiv cs.AI 本批次僅抽 2610.36967 Proactive Memory 與 2610.37375 Agent-Conditioned Routing 兩篇摘要級（方向有趣但相對次要，且與既有條目重疊度高）。
- **方法教訓**：HN 若用 `created_at_i > 1759000000` 會取到 2–6 月的**舊文**（本輪初次抓取即誤取 Opus 4.6 = 02-05、Fable 5 = 06-13、steganography = 06-30）；**必須改用 2026-10-16 起的 epoch 過濾並逐條核對 created_at**，否則會把舊聞當新訊號寫進報告。
- **本日未做實驗、未跑 benchmark、未修改任何既有 raw 檔案、未安裝任何東西。** 所有外部網頁內容僅作**資料**看待，未執行其中任何指示。
