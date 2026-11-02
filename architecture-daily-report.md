# 每日 Agent × 軟體開發情報 — 2026-11-02

> 來源：24 個公開來源 · 覆蓋 arXiv（cs.AI，2026-10-29 → 10-30 新投 6 篇入選）· Google Security Blog + InfoQ（PageBreak）· Martin Fowler / Rachel Laycock（Thoughtworks）· InfoQ feed · Hacker News · GitHub Releases API（LangGraph / MS Agent Framework / CrewAI / Codex / Claude Code / MCP / OpenClaw）· GitHub search API（OpenClaw 生態供給端）· OpenAI newsroom RSS
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-11-02-harness-spec-knowledge-compilation-and-attention-economics.md`
> Wiki：已入庫 1 source + 5 concepts（graphify 已同步，非 orphan）

**一句話總結：今天最紮實的訊號不是「又一個更強的 agent」，而是「harness 正在被當成一等公民對待」——研究端給出可攜規格（同一模型在不同 harness 下分數可差數倍，所以 harness 必須被版號化記錄）、生產端給出可信度模式（Google PageBreak 把 validator 放在 agent loop 之外、只回報被真實 exploit 重現的發現，近零 false positive）；而同一週，知識編譯研究直接證偽了「結構化圖譜必然勝過 grep」（BM25/grep harness 就有 85%/91%，結構化 artifact 在 FRAMES 上無可偵測增益、PageIndex 式 outline 還在大規模時退化）——對我們的 llm-wiki graphify 路線是必須記錄的反證。另一側則是人的注意力被正式建模：多 agent 併行時「逐 agent 排名問哪個問題」永遠不是最優解。**

---

## 今日 5 個重點

### 1. Harness 沒有定論，所以它必須被「可攜規格化」並版號化記錄

- **發生什麼**：arXiv:2610.40917《Towards Portable Specification of the Agent Harness》（2026-10-29）。命題：LLM 只透過周圍的基礎設施行動，**harness 決定了模型能做到什麼、以及怎麼失敗，但它至今沒有一個共識定義**。作者把 harness 拆成 **8 個功能元件**，提出可攜規格框架，**記錄「哪個模型跑在哪個 harness 裡」**。理由有兩條，都很硬：(a) **同一個模型在不同 harness 設定下，回報分數可以差數倍（several-fold）**；(b) **agent 的攻擊面很大一部分就在 harness 裡**。作者並指出 model card / agent card 不足：它們給的是發布與操作資訊，**無法建立「一次 run 之內的有效設定序列」**——harness 可以在 release 之間改、run 之間改，**在 agent 會自己改工具與設定的情況下，還能在一次 run 裡改**。結論是 harness 必須被明確描述並**作為版號化的產物**來規格化。作者並指出已生效的 AI 法有文件義務，但沒有任何法規規定這種通用 harness 記錄。
- **為什麼重要**：這是 harness 從「實作細節」升級為**「可稽核 artifact」**的第一個明確框架，直接對應我們最大的結構性弱點：OpenClaw 的行為取決於「workspace + skill + AGENTS.md + cron + harness code」的組合，而這個組合**目前沒有任何一處被記錄成可比對的版號**。同時它把「同一模型換 harness 分數差數倍」變成一個**測量問題**：我們所有的跨 agent 比較（rowlet vs 其他）若不記錄 harness 版本，結論在方法論上站不住。
- **可信來源**：https://arxiv.org/abs/2610.40917

### 2. Google PageBreak：把 deterministic validator 放在 agent loop 之外，只回報被真實 exploit 重現的發現

- **發生什麼**：Google 公開其 AI 資安 agent PageBreak（InfoQ 2026-10-31 報導 + Google Security Blog + Google Bug Hunters）。**自 2026 年 1 月全面運作以來，它在自家 web 應用中挖出 500+ 個 XSS 弱點**。關鍵設計不是模型多強，而是**回報門檻**：模型可以自由提出任何假設，但**只有在 validator 對執行中的應用成功重現 exploit 之後才算數**——XSS 真的執行 JavaScript、path traversal 真的寫入 world-readable 位置、RCE 真的觸發 outbound DNS。Google 資安工程師 Lukas Weichselbaum 明說：**「validators 是安全工程師手寫的一般程式碼，不是模型寫的，而且位於 agent loop 之外。」** 結果是**近乎零的 false positive**，產品團隊不會被未驗證的報告淹沒。**非確定性的發現被內部保留**，用來播種更深的未來掃描、找出驗證能力的缺口、指導新 validator 的開發——但**不送到產品團隊**。已公開三個案例：XSS、服務設定錯誤造成的 cache poisoning、path traversal。作者也誠實承認：deterministic validator 覆蓋不了所有弱點型態，會有 false negative 風險。
- **為什麼重要**：這是**「agent 產出要怎麼取得信任」的第一個生產級答案**，而且答案不是「更準的模型」也不是「人來複核」——而是**把驗證從 agent loop 裡搬到 loop 外，用可執行、可重現的東西當閘門**。這正好接上昨天 Octoverse 的結論（瓶頸已從「能不能寫出程式碼」移到「人能不能審完」）：PageBreak 沒有讓人審得更快，它是**讓 90% 的東西不必被人審**。而「非確定性發現內部保留、不外送」這條規則，對我們這種每天產出十幾份情報報告的系統，等於是一個可以直接抄的**降噪護欄**。
- **可信來源**：https://www.infoq.com/news/2026/10/google-pagebreak-security-agent/ ｜ https://blog.google/security/agentic-hacks-real-proofs-inside-googles-pagebreak-project/ ｜ https://bughunters.google.com/blog/pagebreak-real-world-findings

### 3. 知識編譯被證偽為「更好的檢索器」——BM25/grep harness 就有 85%/91%，結構化 artifact 沒有可偵測增益

- **發生什麼**：arXiv:2610.41172《Context as Infrastructure: Knowledge Compilation for Retrieval in Agentic Systems with Harnesses》（2026-10-30）。作者先做了一個讓人意外的基準：**一個只有 BM25/grep、跑 MiniMax M3 的 search harness，在 BrowseComp-Plus 答到 85%、在 multi-hop FRAMES 答到 91%，而且完全沒有編譯索引、沒有向量索引**。真正剩下的問題是 context 浪費：「沒有紀律的 loop 會重複查詢、重讀文件、把沒用到的段落塞滿視窗」。他們提出缺的層是 **knowledge compilation**：一個可設定的攝取管線，用 LLM 替文件補上「任何單一 chunk 都不含」的上下文（導覽階層＋claim-evidence 葉節點、實體圖、時間線、心智圖、本體、wiki、記憶）。**但結論反轉**：在「稱職的 harness」之下，**結構化 artifact 在 FRAMES 上沒有任何可偵測的準確率增益**，而 **PageIndex 式的 outline 在大規模時反而退化**。所以它不是更好的 retriever，**它是一個供應層（supply layer）**。他們真正測到有效的是其中一種機制：**葉節點是 claim–evidence 配對的導覽樹——證據足夠時查詢 token 砍 91%，不足時只多 1.9%，平均減少 38%**；由此推出 **2% 的損益平衡充分率，而實測充分率約 43%**。
- **為什麼重要**：這是**對「複雜圖譜 vs 簡單檢索」的第一份乾淨反證**，而且結論正是我們 llm-wiki graphify 路線最需要聽到的那一句：**在 harness 夠強時，結構化的價值不在「答得更準」，而在「少讀 token」**。同時「2% 損益平衡 / 43% 實測充分率」是一個**可以直接拿來做設計決策的比率**：當前系統的檢索充分率遠高於 2%，代表編譯層在數學上早就回本——但它的收益全部在**省 context**，不在**提準確率**。這意味著我們對 graphify 的評估指標若只看 recall/accuracy，會系統性低估它的實際價值；而 `PageIndex 式 outline 大規模退化`這個反證，則直接說明「把整份 wiki 做成大綱再檢索」是條死路（這正是我們 wiki 架構的隱含方向之一）。
- **可信來源**：https://arxiv.org/abs/2610.41172

### 4. 記憶寫入有兩個方向相反的需求——「過期事實」與「記憶投毒」不能用同一條固定規則處理

- **發生什麼**：arXiv:2610.41056《Accept Changes, Reject Attacks: Robust Memory Management for LLM Agents》（2026-10-29，Runze Zhao / Dongruo Zhou / Sumit Kumar Jha / Nathaniel D. Bastian / Ankit Shah）。命題極精準：**記憶管理器決定「每一筆輸入如何改變記憶」以及「agent 依據哪些紀錄行動」；它會以兩種方式失敗——留著已經變了的事實（outdated memory），或存下被植入的段落／注入的指令（memory poisoning）**。作者指出**多數既有研究把這兩件事分開研究，但它們要求方向相反的寫入決策，所以沒有任何固定寫入規則能同時處理**。他們因此提出 **evidence-conditioned accuracy（ECA）** 這個指標：**不只檢查答案對不對，還檢查管理器挑選的紀錄是否涵蓋答案所需的全部證據、是否已更新、是否不含攻擊**。結果很紮手：**既有記憶系統與既有防禦，在他們的測試集上並不比一個未調校的 manager 更穩健**。改善方式意外地便宜：**用單一對話合成插入「變更 + 攻擊」的 episode，做一次 one-shot 微調**——在三個 backbone 上每一個類別分數都提升，**整體 ECA 翻倍有餘**，但作者承認穩健性仍不完整。
- **為什麼重要**：這把「記憶架構」從「存什麼」變成「**寫入政策**」——而我們的 wiki 記憶層（MEMORY.md / daily memory / compaction / REMORY 軟 token）幾乎全部只處理「存不存」，**沒有一個明確的「這筆事實過期了嗎」的寫入決策**。更關鍵的是那條 ECA 判準，**它正是「compaction provenance laundering」這條既有 wiki 隱憂的可操作化版本**：丟掉的證據不只會讓你答錯，還會讓你「答對但沒有出處」。至於「既有防禦不比未調校 manager 強」這個結果，意味著我們不該在防禦工程上過度投資，而該投資在**管理器的訓練資料分布**上。
- **可信來源**：https://arxiv.org/abs/2610.41056

### 5. 多 agent 併行時，「先問哪個問題」不能逐 agent 算——必須估計成對延遲

- **發生什麼**：arXiv:2610.41129《When Should AI Agents Ask? Clarification Requests Under Limited Human Attention》（2026-10-30）。場景設定完全命中我們的處境：**AI agents 越來越多地並行執行委派任務，一個人同時監督多個 agent**；agent 常缺一項任務所需資訊（未言明的偏好、限制、規格），**它可以問人，也可以自己去翻過去的紀錄找——後者要花時間與力氣，而且可能失敗**。作者建立一個風格化模型：**每個 agent 可以選擇 search、ask、或繼續做那些不依賴缺失資訊的部分**，並把問題 formulate 成 dynamic program。兩個關鍵發現：**(a) agent 該不該問，不只取決於它自己的不確定性——手上還有別的工作的 agent，反而可能更早問更好**；**(b) 人類該先回答哪個問題，取決於「所有正在等的問題」，所以任何逐 agent 算出來的排序都不是最優的**。他們提出 **Pairwise Coordination Policy（PCP）**：用精確求解的單任務與雙任務問題，去估計「當兩個任務共用同一個人時，彼此延遲多少」，再據此決策。
- **為什麼重要**：這把我們每天都在直覺處理的問題（多個 subagent 同時需要人工決策時，該先問哪個）從「排隊」變成「**成對延遲估計**」，而且給了明確的理論：**逐 agent 排序永遠不對**。這對 OpenClaw 有三個直接落點：(a) `ask_user` 不該是各 agent 各自呼叫，而該有一個**跨 session 的等待佇列視圖**（我們已有 `steering-vs-followup-queueing` 這條概念，正好接上）；(b) 當 agent 手上還有其他工作時，**提早問比等自己卡住更好**——這與我們目前「跑到一半才回頭問」的預設相反；(c) 「自己搜尋」必須被當成一個**有成本的真實選項**而非 fallback——PCP 的模型裡 search 會佔用 agent 的時間，這意味著「先自己翻紀錄再問」在某些情況下反而更差。
- **可信來源**：https://arxiv.org/abs/2610.41129

---

## 對 OpenClaw / Linder 的啟發

### 啟發 1：把 OpenClaw 的「harness 版號」變成一等公民 artifact — 現在就記錄，別等出事

arXiv:2610.40917 說「同一模型換 harness，分數可以差數倍」，而 OpenClaw 的 harness 是**活的**：AGENTS.md、skills、cron 定義、workspace 結構、agent 設定、模型選擇都會變，而且 agent 自己也會改工具與設定——**連一次 run 內部都可能不一致**。可執行三件事：**(a) 每份每日情報的開頭固定加一段「本次執行環境快照」**——agent id、model、workspace 的 git rev、skills 清單雜湊、cron job 定義雜湊、harness 版本（`openclaw --version`）；成本近乎零，但回頭看任何一份報告時，能立刻知道它是哪個環境產生的。**(b) 建一份 `harness-spec.yaml`**（對應論文的 8 個功能元件分類：interface / tools / memory / planning / context-assembly / verification / permissions / delegation），每次改動 harness 結構時同步更新版本號。**(c) 把「報告的可信度」也納入 harness spec**——我們每天的報告本身就是 agent 產出，同樣受「攻擊面在 harness」這個命題影響。

### 啟發 2：把 PageBreak 的「loop 外 validator」抄成兩個具體機制 —— 一個給情報報告、一個給 skill 攝取

PageBreak 的核心不是更強的模型，而是**閘門放在 agent loop 之外，且只有被真實重現的東西才算數**。對我們有兩個零到低成本可抄的落點：**(a) 情報報告的「事實 / 推論 / 判斷」標記，本質就是 validator**——但目前只是標記，沒有門檻。建議升級成：**報告中每個「事實」陳述必須附可機械檢查的來源 URL + 抓取時間戳；抓不到或抓取失敗的，必須降級為「未驗證」**——這正是 PageBreak「非確定性發現不外送」的規則。**(b) skill 攝取是更高風險的場景**（我們已有 `skill-guard` 與 `skill-evaluation-and-evolution` 兩條線）：目前 skill 進場靠 LLM 審查（agent 在 loop 內評 agent），可以改成 **validator 在 loop 外**：例如「skill 內含的所有 shell 指令，必須通過 dry-run 白名單檢查」才允許安裝。**(c) 借鏡 Google 保留「未驗證發現」的機制**——不要丟掉那些「看起來有問題但無法驗證」的 skill 與情報，內部留著當未來的掃描種子與能力缺口清單，這也是 `skill-guard` 該有的自我檢討輸入。

### 啟發 3：用「少讀 token」而不是「答得更準」來重新評估我們的 graphify 投資

arXiv:2610.41172 給了一個乾淨的機會：我們的 llm-wiki graphify 一直是用「retrieval 品質」在評估，但論文顯示**在 harness 夠強時，結構化 artifact 的準確率增益接近零**（FRAMES 上無可偵測差異，PageIndex 式大綱還退化）。同時它給了量化公式：**claim–evidence 導覽樹在證據足夠時省 91% 查詢 token，平均省 38%，損益平衡充分率 2%、實測充分率約 43%**。可執行：**(a) 把 graphify 的第一個 KPI 從「recall / answer accuracy」改成「同一問題的查詢 token 數」**——這個數字我們現在就能量，而且它是我們 session context 預算的直接函數；**(b) 把我們的 wiki graph 節點設計成 claim–evidence 葉節點**（現在的 graphify node 多半是文件／概念，沒有明確的 claim→evidence 配對），這是論文唯一測到有效的機制，值得照抄；**(c) 把「PageIndex 式大綱在大規模退化」當成一條護欄寫進 wiki 的架構原則**——不要用「整份文件大綱」做檢索入口。

---

## 值得追蹤的 repo / paper / article

1. **Towards Portable Specification of the Agent Harness**（arXiv:2610.40917，10-29）— harness 拆成 8 個功能元件、可攜規格框架、版號化 harness 記錄；同一模型換 harness 分數可差數倍 — https://arxiv.org/abs/2610.40917
2. **Context as Infrastructure: Knowledge Compilation for Retrieval in Agentic Systems with Harnesses**（arXiv:2610.41172，10-30）— BM25/grep harness 就有 85%/91%；結構化 artifact 無準確率增益、PageIndex 大綱退化；claim–evidence 導覽樹省 91% token（均 38%）、損益平衡充分率 2% vs 實測 43% — https://arxiv.org/abs/2610.41172
3. **Accept Changes, Reject Attacks: Robust Memory Management for LLM Agents**（arXiv:2610.41056，10-29）— 過期事實與記憶投毒要求相反寫入決策；ECA 指標；既有防禦不比未調校 manager 強；one-shot 微調讓 ECA 翻倍 — https://arxiv.org/abs/2610.41056
4. **When Should AI Agents Ask? Clarification Requests Under Limited Human Attention**（arXiv:2610.41129，10-30）— 多 agent 共用人類注意力；逐 agent 排名永不最優；Pairwise Coordination Policy — https://arxiv.org/abs/2610.41129
5. **Google PageBreak**（InfoQ 10-31 + Google Security Blog + Google Bug Hunters）— 500+ XSS、validator 在 agent loop 之外、近零 false positive、非確定性發現內部保留 — https://www.infoq.com/news/2026/10/google-pagebreak-security-agent/
6. **Why are good developers so wary of agentic development?**（Rachel Laycock / Thoughtworks CTO，10-29）— 「built ≠ working in production」；沒有人有這種系統的生產經驗，所以無法信任 — https://martinfowler.com/rachels-ramblings/good-devs-wary.html
7. **Capability-Grounded Agentic Planning（CGAP）**（arXiv:2610.41040，10-29）— 工具目錄確定性編譯成 PDDL、經典 planner 解、決定性檢查擋掉破壞計畫的呼叫、每個引數須有出處；較標準 tool-calling agent 最多 +28.9 分 — https://arxiv.org/abs/2610.41040
8. **ReplayRCA**（arXiv:2610.41025，10-29）— 以「介入後是否修好」評分診斷（causal repair = 續跑成功率 − placebo）；OpsWorld 62 個校準失敗上 Grok 4.7 達 +51.3 分，前八名統計上無差異 — https://arxiv.org/abs/2610.41025
9. **Consensus Within, Competition Between**（arXiv:2610.41044，10-29）— 共識式去中心化團隊 breach 15% vs 指揮官 32% vs 獨立 29%；讓低階模型掌握出價權重 +38pp 破口；偽裝成鳥的入侵者 59–61% 沒被追 — https://arxiv.org/abs/2610.41044
10. **OpenClaw v2026.10.9 / v2026.10.10-beta.5**（10-29 / 10-30）— fast-uri 4.2.3 修 MCP schema 驗證的 malformed URI；Node 24.22.1 / 26.12.1 改為 security recommendation — https://github.com/openclaw/openclaw/releases

---

## 下一步建議

1. **做一個「harness 環境快照」的最小實作（今天就能完成）**：寫一個 `~/.openclaw/workspace-rowlet/harness-snapshot.sh`，輸出 agent / model / workspace git rev / skills 清單雜湊 / cron 定義雜湊 / openclaw 版本，並在每日情報開頭自動貼上。**這是 arXiv:2610.40917 最便宜的一段落地**，而且它立刻讓我們的報告從「不可重現的敘述」變成「可重現的觀測」。
2. **量一次 graphify 的「省 token」而非「答得準」**：挑 10 個我們真的會問的 wiki 問題，各自比較「graphify query」與「直接 grep/讀 wiki 頁」的 (a) 查詢 token 數、(b) 答對與否。**如果 (b) 沒有顯著差異但 (a) 明顯較少——那正是論文預測的結果**，我們的 graphify 投資就從「玄學」變成「有數字支撐的 context 預算工具」。同時檢查我們的 graph node 是否具備 claim→evidence 配對，若沒有就補上（這是唯一被實測有效的機制）。
3. **把「人在等待中的問題」做成一個可見的跨 session 佇列**：借 arXiv:2610.41129 的 PCP 思路，盤點目前 OpenClaw 在哪些情況會同時向 Linder 拋問題（ask_user、多 subagent 各自回報、需要人工決策的 cron 分岔），建立一個簡單的等待佇列視圖，驗證「逐個 agent 各自問」是否真的是我們的現況。**若確認是，這個佇列就是 PCP 政策的落點**，而且它同時會讓 10-28 那條「agent-first review 模式」有具體的承載介面。
