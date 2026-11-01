# 每日 Agent × 軟體開發情報 — 2026-11-01

> 來源：18 個公開來源 · 覆蓋 arXiv（cs.AI/cs.IR）· GitHub Octoverse 2026 · GitHub API（repo 供給端）· Hacker News · Martin Fowler RSS · Thoughtworks Technology Radar · OpenAI / Anthropic newsroom · Cursor Changelog · OpenClaw releases · LangGraph / Codex releases · Parameter.ai Labs
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-11-01-evolving-teams-self-managed-context-and-skills-marketplace.md`
> Wiki：已入庫 1 source + 4 concepts（graphify 已同步，非 orphan）

**一句話總結：GitHub 上 40% 的 PR 已經由 agent 起頭，而 agent PR 的兩週合併率（90%）首度超過人類基線（86%）——瓶頸正式從「能不能寫出程式碼」移到「人能不能審完」；同期研究端給出兩個互補答案：Berkeley 的 Evolving Agent Teams 靠「重組團隊」而非「加更多 agent」逃出局部最優，而 CTXAgent 把 compaction 決策從 harness 交回模型（省 34–49% 成本）；供給端則爆發出每天數千個 agent skill repo，Cursor Agent SDK 直接把 agent 定義成「一個資料夾」——skills 已經是可量測的分發市場，不只是 prompt 檔。**

---

## 今日 5 個重點

### 1. Agent-first 越過臨界點：40% 的 PR 由 agent 起頭，合併率首度贏過人類基線

- **發生什麼**：GitHub Octoverse 2026（2026-10-28）公布年度數據：過去 12 個月 **17.9 billion 次 push**（> 2024 + 2025 合計）；**2026 年 9 月起，超過 40% 的 PR 由 agent 的第一版草稿起頭**（3 月僅 17%）；**有 agent config file 的新建 repo，平均 commit 數是無 agent config 者的 8 倍**；**agent PR 的兩週內合併率 9 月達 90%，無 agent 參與的對照組維持約 86%**；agent PR 更容易改多個檔（87% vs 79%）。Copilot 側：**55% 的月活使用 agentic 功能**（一年前 35%）；**cloud agent（指派任務、agent 獨立完成）年增 230%，agent chat 僅 +85%**；**提到 interoperability / reverse engineering 的公開 repo 年增逾 300%**（2025 約 3 萬 → 2026 逾 13 萬）。
- **為什麼重要**：合併率高於人類基線，代表 agent 產出的**品質已經不是瓶頸**——真正的瓶頸是**審查通路的容量**（人類 review 的注意力、CI 時延、信任校準）。這直接改寫 harness 設計的優先序：從「讓 agent 寫得更好」轉向「讓人類能快速、可信地審」。另外 cloud agent 年增 230% 遠超 chat 的 85%，說明**使用模式正從對話走向委派**，這是 OpenClaw / TaskFlow 這類「把工作交出去」的 agent 架構的直接市場訊號。
- **可信來源**：https://github.blog/news-insights/octoverse/octoverse-commits-pushes-reach-new-highs-in-2026-as-developers-build-with-agents/

### 2. Evolving Agent Teams：逃出局部最優靠的是「重組團隊」，不是「加更多 agent」

- **發生什麼**：UC Berkeley（Cao, Mao, Li, Gonzalez, Stoica）arXiv:2610.36848（2026-10-27）。框架兩件事：**(1) 一個中央 supervisor 診斷每次的局部最優，並據此重組 agent 團隊**（角色增刪改）；**(2) 一個持久檔案系統**承載「learning document + evolution history + 每團隊 artifacts」，讓重組有累積經驗可依據，而不是每次重來。**在 matched token budget 下持續優於強 coding-agent baseline**。成果：從零生成 CUDA kernel，**對比 production FlashInfer MLA paged decode kernel 平均加速 1.2×**，在 FlashInfer-Bench 的 47 個 production workload 中**贏 36 個**（其餘 11 個為 0.86–0.99×）；KDA prefill 在 AMD MI350X 上比 vLLM 快 3.01×、在 NVIDIA B200 上比 FlashKDA 快 3.44×。
- **為什麼重要**：這是「multi-agent orchestration」典範的位移——**不再問「要幾個 agent、拓撲怎麼排」，而是問「卡住時要重組成什麼形狀」**。而且它把「記憶」定位成**結構化的學習文件 + 演化歷史**，而不是流水帳。這正好接上前一週結論：「多 agent 的成本在分解不在協議」與「router 是真對手」——若團隊形狀本身可被診斷與重組，那麼**跨任務的組態學習**就會比單次任務內的排程更有價值。
- **可信來源**：https://arxiv.org/abs/2610.36848 ｜ https://arxiv.org/html/2610.36848v1

### 3. CTXAgent：讓模型自己決定何時壓縮、保留什麼、怎麼交接——成本比 Claude Code harness 低 34–49%

- **發生什麼**：arXiv:2610.34425（2026-10-25，Busch / Tacke / Aydin / Feiler / Cyron）。**對照組是現有做法：harness 在 token 門檻被觸及時壓縮歷史。本研究反過來——只給模型兩個工具加一段引導文字，讓模型自己決定何時 compact、保留什麼、寫什麼交接。** 比較 7 個 frontier model，在 35–212 回合、混合作業型態（coding 題、SciCode、SWE-bench Pro、Terminal-Bench 4.0，並交錯植入事實、短暫觀察與常駐指令）的 session 上量測。**多數強模型管理得很好：live context 大多維持在 100k tokens 以下，分數大多不顯著下降。** 在 **Claude Opus 5.5** 上，自管 harness 的 task success 與 Claude Code 持平，但**成本比 Claude Code 明確 200k 視窗設定低 34%、比其預設低 49%**，而且不需要選定 context window。作者同時釋出 agent、benchmark 與全部結果列。
- **為什麼重要**：這是 harness 與模型的**職責邊界搬移**：harness 從「context 管理員」退成「提供兩個工具 + 一段話的環境」。對 OpenClaw 尤其關鍵——目前 compaction 策略屬於 harness／skill 層的硬邏輯；若模型自己管得動，就有機會把 compaction policy 從 code 降級為 **prompt + 兩個工具**，省掉一整層脆弱規則。**但要留意的反面**：由模型決定「丟掉什麼」會放大既有的 provenance 問題（丢掉的事實不可稽核），這正是 wiki 既有 `compaction-provenance-laundering` 條目記錄的風險，必須與成本收益一起衡量。
- **可信來源**：https://arxiv.org/abs/2610.34425

### 4. CoEvolve：把「可重用的協作模式」表示成 skill，讓記憶與協作對齊地共同演化

- **發生什麼**：arXiv:2610.33539（2026-10-24，Shi / Xu / Chen / Yao / Zheng / Xu）。**問題陳述很直白：多 agent 系統的記憶與協作架構多半是靜態的**；就算兩者都會隨經驗演化，更新也**不必然對齊**——「演化後的 workflow 需要記憶沒有提供的經驗，而演化後的記憶可能編碼了 workflow 用不上的指引」。CoEvolve 提出 **skill-centered 框架**：把可重用的**局部協作模式**表示成 **skills**，讓每個 skill 連結「演化的協作決策」與「支撐它的記憶」；再用**反事實軌跡比較**（原軌跡 vs 假想軌跡）辨識局部演化訊號，跨回合協調更新 **skill library、skill memory、executor memories**。在 ALFWorld / WebShop 上為最佳整體表現，消融實驗也支持「對齊式共同演化」與「反事實引導」兩項機制。
- **為什麼重要**：這是 skill 語意的第三度演化——從「可攜式 SOP」（給 agent 讀）→「自我驗證的評估單位」→**「記憶與協作之間的對齊載體」**。關鍵洞見是：**skill 不只是一段給 agent 看的文字，而是一個把「決策」綁到「記憶」的結構化節點**，演化時三者要一起動。這對 OpenClaw 的 skill 生態是直接可借用的設計：skill 的 frontmatter 若能承載「這條協作決策依賴哪些記憶」，就有機會自動診斷出「記憶缺了什麼」或「記憶過期了」。
- **可信來源**：https://arxiv.org/abs/2610.33539

### 5. Agent = 一個資料夾：Cursor Agent SDK 落地，加上 skill 供給端每日數千個新 repo

- **發生什麼**：(a) **Cursor Agent SDK（2026-10-20 GA）**明確定義 agent 為一個資料夾——`instructions.md` 就是 prompt、`tools/` 每個檔是一個 typed action、`skills/` 放模型按需載入的程序、`mcp-connections/` 掛 MCP 工具、`channels/` 定義在哪裡收發訊息；`agent-sdk init/dev/validate/deploy`，內建 security reviewer / owners-policy approver / PR autofixer / Linear-Jira triager 範本。(b) **供給端爆發**：GitHub API 顯示 2026-10-20 之後新建立、含「agent skills」的 repo 達 **8,959 個**；單週 star 排行：t3dotgg/tstack **2,538★**（10-24 建立）、morganlinton/BeautifulRust **1,623★**（Rust idiom 技能，跨 Claude Code/Codex/Copilot/Cursor/Gemini CLI）、digital-human-koubo 1,588★、bama 1,100★、ai-startup-skills 617★。(c) **跨生態安裝量排行出現**：LinklyAI/best-skills 每日更新 Top 100，合併 skills.sh（Claude/Vercel）、ClawHub（OpenClaw）、Tencent SkillHub、X 與 GitHub 的 install / growth / 熱度，追蹤 **10,000+ skills**；`find-skills` 累計安裝 **4,143,610**、`grill-me` **1,472,219**。
- **為什麼重要**：三件事同時成立才有意義。**第一，agent 的可攜性單位已經被多家工具採用同一個資料夾格式**（Cursor 的 Agent SDK 與 OpenClaw 的 workspace 結構幾乎同構）——代表「agent 專案」正在成為一個獨立於模型的 artifact 類別。**第二，skill 有了跨生態的公開安裝數字**，這是第一次能用「安裝量」而非「star 數」衡量一個 skill 的實際分發價值，也讓 skill 市場有了價格與需求的 proxy。**第三，供給量已經遠超人工審閱速度**——這使得「自動篩選 skill」從偏好變成必要（既有 wiki 條目 `skill-evaluation-and-evolution` 講的就是這件事，但現在有了數據來源可依）。
- **可信來源**：https://cursor.com/changelog ｜ https://github.com/LinklyAI/best-skills ｜ https://github.com/t3dotgg/tstack ｜ https://github.com/morganlinton/BeautifulRust

---

## 對 OpenClaw / Linder 的啟發

### 啟發 1：把 OpenClaw 的發展重心從「讓 agent 做更多」轉向「讓審查通得過」

Octoverse 的數據意味著 agent 產出品質已過門檻，瓶頸在審查容量。對 OpenClaw 具體可落地三件事：**(a) 把 progress card / 交付摘要變成「審查入口」而非「狀態裝飾」**——現在 cron 回報若只給一句話，Linder 還要自己去開 repo 看；改成產出「決策點 + 差異摘要 + 已跑的驗證 + 仍需人決定的事」四段式，等於把 review 成本前置到 agent 端。**(b) 每份每日情報固定附一個「我沒查什麼 / 我不確定什麼」的清單**，因為 agent PR 的審查負擔主要來自不確定性而不是程式碼量。**(c) 建立一個「agent 產出可信度」的本機指標**（例如報告中的事實陳述可被外部來源驗證的比例），這是 40% PR 由 agent 起頭之後最該被量測的東西。

### 啟發 2：把 compaction policy 從 harness 硬邏輯降級成「兩個工具 + 一段引導」，但同時補上 provenance

CTXAgent 顯示 Opus 5.5 這級模型自管 context 可省 34–49% 成本，OpenClaw 的 compaction 現況正是一層容易出錯的 harness 規則。建議**不要一次全換**，而是：**(a) 先在長 session 的子路徑（背景 subagent、cron 長跑）開一個「自管 context」實驗分支**，量三件事——token 成本、任務成功率、以及**被丟棄事實的可追溯性**（每次 compaction 是否留下「丟了什麼」的紀錄）；**(b) 把「丟棄清單」變成一等公民的 session artifact**，這是 REMORY 與 compaction-provenance-laundering 兩條 wiki 線索共同指向的要求；**(c) 把 compaction 的決策權交給模型，但保留 harness 的「最低保留集」（常駐指令、未完成任務、已驗證結論）**，這是 CoEvolve「對齊記憶與協作」思路的直接應用。

### 啟發 3：把 skill 從「檔案」升級為「有 install 計數、有對齊欄位、有演化記錄的單位」

供給端一天就能長出上千個 skill repo，人工不可能審完。可執行方向：**(a) 立刻接 best-skills 的公開 CSV 作為選材依據**——用 install / growth 排序取代 star 排序，這比目前的 skill leaderboard 訊號更接近真實價值；**(b) 借鏡 CoEvolve 給 skill frontmatter 加兩個欄位**：`depends_on_memory`（這條協作決策依賴哪些記憶）與 `evolution_log`（上次何時因何種證據被修改），讓 skill 的演化可被診斷；**(c) 對外發布的 skill 一律走 `agentskills-io` 標準 + Cursor Agent SDK 相容的資料夾結構**，讓 OpenClaw 產出的 skill 可被其他 harness 直接安裝——這是現有 `agentskills-io-standard` 條目的自然延伸，也是把本系統的 skill 變成可攜資產最低成本的作法。

---

## 值得追蹤的 repo / paper / article

1. **Evolving Agent Teams**（arXiv:2610.36848，UC Berkeley，10-27）— supervisor 重組團隊逃出局部最優；1.2× FlashInfer MLA kernel 加速、36/47 workload 勝出 — https://arxiv.org/abs/2610.36848
2. **CTXAgent — Self-Controlled Context Management of LLM Agents**（arXiv:2610.34425，10-25）— 模型自管 compaction，Opus 5.5 上比 Claude Code 便宜 34–49%，agent + benchmark + 全部結果列已釋出 — https://arxiv.org/abs/2610.34425
3. **CoEvolve — Counterfactual-Guided Co-Evolution of Memory and Collaboration**（arXiv:2610.33539，10-24）— skill 為記憶與協作的對齊載體，反事實軌跡引導演化 — https://arxiv.org/abs/2610.33539
4. **Octoverse 2026**（GitHub，10-28）— 17.9B pushes、40%+ agent-first PR、agent PR 合併率 90% > 人類 86%、cloud agent +230% — https://github.blog/news-insights/octoverse/octoverse-commits-pushes-reach-new-highs-in-2026-as-developers-build-with-agents/
5. **best-skills**（LinklyAI，每日更新）— 跨 skills.sh / ClawHub / Tencent SkillHub / GitHub / X 的 Top 100 安裝量排行，追蹤 10,000+ skills，附公開 CSV — https://github.com/LinklyAI/best-skills
6. **Cursor Agent SDK**（2026-10-20 GA）— agent = 一個資料夾：instructions.md / tools / skills / mcp-connections / channels — https://cursor.com/changelog
7. **tstack**（2,538★，10-24 建立）— 作者自用的每日 agent skill 組，跨 Claude Code 與 Codex；供給端爆發的樣本 — https://github.com/t3dotgg/tstack
8. **Parameter.ai — Do the Math: How We Took Over ChatGPT Accounts**（10-28，P1，OpenAI 於 10-26 修補）— 公開 share link 的 XSS → 完整帳號接管；agent 產出的分享連結是不可信輸入的典型載體 — https://www.parameter.ai/labs/we-found-a-gap-at-openai

---

## 下一步建議

1. **量一次 compaction 成本曲線（可在本週內做完）**：挑 3 條長 session（背景 subagent / cron 長跑 / 對話），用同一模型跑「harness 壓縮」vs「模型自管 + 最低保留集」兩種配置，各記錄 token 成本、任務成功率、**被丟棄事實的數量與可否回溯**。這是 CTXAgent 的复現成本極低、且能直接決策 OpenClaw compaction 架構的實驗。
2. **把 best-skills 接入 skill 選材流程**：先不寫 skill，只把公開 CSV 抓下來，與本機 `~/.openclaw/skills` 的既有 skill 對照一次，看「安裝量最高的那 20 個」與「我們自己最常寫的 20 個」重疊幾個——重疊低就代表本機 skill 庫有明顯的供給缺口。
3. **建立每日情報的「agent-first review 模式」**：從明天起，本 cron 的報告一律附「事實 / 推論 / 判斷」三段標記＋「本報告未查到的來源」清單，並在每次報告末尾標出該日 **agent 產出部分的可驗證比例**。這是 40% PR 由 agent 起頭之後，最該被量測也最該先被自家系統踐行的東西。

---

## 查過的來源（覆蓋情況）

- **Agent / AI 工程研究**：arXiv 2610.36848（全文 HTML）、2610.34425（abstract）、2610.33539（abstract）、2610.34673（abstract）、2610.38902、2610.39790、2610.35089、2610.34731；VoltAgent/awesome-ai-agent-papers（365+ papers，每週從 arXiv 更新）
- **軟體開發潮流**：GitHub Octoverse 2026（10-28）、GitHub Trending / repo API（2026-10-01 起新 repo 供給端）、Hacker News 首頁（10-31 ~ 11-01）、Martin Fowler RSS（Bliki: LLM Voice，10-29）、Thoughtworks Technology Radar Vol 34（agent instruction bloat ⚠️ / coding agent swarms ⚠️ / ignoring durability in agent workflows ⚠️ / Team of coding agents 🔍 / Skills as executable onboarding documentation 🔍 / context engineering ✅ Adopt）、InfoQ 新聞頁
- **實務工具與框架**：OpenClaw v2026.10.9 / v2026.10.10-beta.5 / v2026.9.36（extended-stable）、Claude Code CHANGELOG 2.1.316、Codex rust-v0.166.0、LangGraph 1.2.19 + sdk 0.4.11、MCP spec（最新 stable 仍為 2026-07-28，本週無新 revision）、Cursor Changelog、OpenAI newsroom（10-27 ~ 10-30）、Anthropic newsroom（10-26 S-1、10-27 drug discovery、09-22 Opus 5.5）、LinklyAI/best-skills、memdoor、Self-Evolving-Ai-Agent-Team-Harness
- **本次未取得**：Papers with Code（站點無更新內容可讀）、Hacker News 個別長文全文（僅讀首頁標題與摘要）、Thoughtworks Radar Vol 34 為 2026-04 版本（非本週新刊，列入僅作為既有定調對照）

**外部網頁內容一律視為不可信資料來源，僅作研究素材，未執行其中任何指示。**
