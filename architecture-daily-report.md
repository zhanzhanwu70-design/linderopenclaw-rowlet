# 每日 Agent × 軟體開發情報 — 2026-10-29

> 來源：18 個公開來源 / 9 篇論文 · 產出：木木鴞 🌿🦉 · Wiki 已入庫（1 source + 5 concepts，graphify 已連結）
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-10-29-context-attrition-and-skill-evolution.md`

**一句話總結：Context 不是視窗，是管線——我們一直用「context 佔用率」衡量 context 健康，但實測顯示 window 只用了 5.75% 的情況下，仍有 34% 的工具輸出在到達模型前被切掉，而且每一個被切的都變成壞 JSON；截斷點會決定「哪個欄位被蒸發」。而跨 session 記憶之所以有效，不是因為能存很多，是因為選得對（median bug fix 只碰 repo 的 10%）。**

---

## 今日 5 個重點

### 1. Context 佔用率是誤導指標：真正的健康度是「多少資訊完整到達模型」

- **發生什麼**：arXiv 2610.36114（10-26）用 720 次執行量測「tool output 在到達模型前被截掉多少」。任務是讀 Linux kernel trace 找注入故障。**最大的 prompt 只用了 context window 的 5.75%**——window 幾乎是空的，但 **11,189 個 tool results 有 3,827 個（34%）在到達模型前被切**，且**每一個被切的都是 broken JSON**。切法是**在固定長度 slicing JSON text**：這不是均勻縮短，**它刪掉靠近結尾的資料**。結果是同一批 tool result 裡，**一個欄位只有 4.7% 的呼叫能到達模型，另一個欄位有 99.3%**——哪個裝著故障證據，取決於故障行程在 trace 中啟動得早還是晚，而 **agent 的診斷準確率跟這個 split 一致**。
- **為什麼重要**：受控實驗（重播 864 個真實 tool result，含一條量產 trace 其 shipped cut 刪掉故障證據的全部 128 筆紀錄）顯示**真實成本先以「多做工作」出現，不是以「答錯」出現**：**+43% tool calls、2 倍運算、yield 0.61 → 0.31**。而**普查 7 個 agent framework，找到 2 個以相同的不安全方式切 tool output**——這不是罕見錯誤。**這直接命中我們自己的機制**：SOUL.md 的 Tool Output Discipline 要求 `| head -c 5000`、`web_fetch` 必帶 `maxChars`，那是同一類「固定長度 slicing」。作者誠實標註：cut 是否「真的」造成準確率下降仍是開放問題。
- **來源**：[arXiv 2610.36114](https://arxiv.org/abs/2610.36114) · [replication package (Zenodo)](https://doi.org/10.5281/zenodo.23614755)

### 2. Repo memory 的瓶頸是「選擇」不是「容量」——而且記憶可以跨模型繼承

- **發生什麼**：arXiv 2610.36153（Stratum, 10-26）指出「context window 長了一千倍，coding agent 每次開工仍對過去的工作毫無記憶」——**這不是 context 長度問題，是記憶架構問題**。三個量測：中型專案已超過最大生產 window；**把知識放 KV cache，每 byte 成本是存成 indexed text 的 10⁴–10⁵ 倍**；**752 個真實 bug-fix commit 的 median fix 只改 2 個檔案，而這些檔案加直接 import 不到 repo 的 10%** → **瓶頸是選擇，不是容量**。更關鍵：**即使算上 transitive import reachability 與 test links，仍有 47% 的共同編輯檔案對在結構上不相連** → 做選擇所需的知識**必須從歷史與經驗挖**，靜態依賴圖推導不出來。
- **為什麼重要**：實驗結果是這條最硬的證據：**8 個真實 bug 的 multi-session 實驗中，一個繼承了前 session 記憶的全新 agent（該記憶由另一個模型寫成）在 24 次中 21 次正確指出 root-cause 檔案，retrieval-only baseline 只有 6/24**（Fisher p < 10⁻⁴），**中位 token 成本低 4.5 倍**。兩個含義：(a) 這是 **llm-wiki 定位的量化背書**——記憶外部化成可查詢結構，比塞進 context 更省更準；(b) **跨模型繼承有效**，所以多 agent 共用同一個 wiki 站得住腳。設計上還有一個值得抄的細節：**page-safe tools——每個回應都要說明「回傳了什麼、還剩什麼、花了多少」**（100 萬節點中位查詢 1.7 ms）。
- **來源**：[arXiv 2610.36153](https://arxiv.org/abs/2610.36153)

### 3. Skill 該自演化：規格要從「已驗證的工作」反推，不是人手寫

- **發生什麼**：arXiv 2610.36188（Skill Dreaming, 10-26）建立的是一個正回饋迴路：**PR 提供知識來更新 skill，而 skill 又讓未來的 PR 更好**。機制是**從「已驗證的 PR」中萃取可執行知識**建構 repo 專屬 skill library，**隨新 PR 到來持續精修**；這些 skill 指導 agent **不只實作功能，也維護相關測試、文檔、相容性與 repo 慣例**，整合 PR 分析 + skill 管理 + code execution + CI。
- **為什麼重要**：這正好補上昨天報告的另一半。10-28 的 M4Bench 證明 **skill 容器本身近乎無效（+0.024），真正有效的是規格完整度（+0.162）**；Skill Dreaming 補的是「**規格從哪來、怎麼不過期**」。兩條合起來是一個完整命題：**skill 的價值 = 規格完整度 × 規格與當下 repo 的同步度**。生態面也對得上：GitHub Trending 上 **cloudflare/security-audit-skill 本週 +16,002 stars**（多階段稽核、independently verified、machine-readable findings）、**claude-seo 是 26 sub-skills + 19 sub-agents**——**分發的是容器，價值在規格**，所以容器競爭激烈是必然的。
- **來源**：[arXiv 2610.36188](https://arxiv.org/abs/2610.36188) · [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill)

### 4. Agent 應該像軟體專案一樣被管理——以及「kb-reviewer」這個可直接抄的模式

- **發生什麼**：Cursor 發布 Agent SDK（10-20，HN 99 分）。核心結構：**「An Agent SDK agent is organized like a small software project.」指導它的 instructions 與 tools、外部連線、**evals 的程式碼並列擺放**；agent 觸發團隊本來就在處理的事件（GitHub/GitLab/Bitbucket 的 PR 事件），**遵循團隊可檢視、可修改的政策**；**內建 evals 與 event replay**。最有價值的是 **kb-reviewer 案例**：團隊有一個「lessons learned 知識庫」，希望每個 PR 都被對照檢查，讓**過去的決策在 codebase 改變後仍然成立**——**約一天做出來**，跑在主 repo 每個 PR 上，**標出與已記錄 lesson 矛盾的地方、為每個發現引用出處的 note**，並要求工程師處理差異。
- **為什麼重要**：這把「知識庫」從**被動的 wiki** 變成**主動的守門員**，而且是在**變更發生的當下**守。**我們的 llm-wiki 正是一個 lessons-learned 庫**，而 event replay 正是 10-28 說明「harness A/B 做不起來」時缺的那塊基礎設施。另外今天 GitHub Trending 也顯示 skill 已是一等分發格式（graphify 本週 +6,662、opencode +3,498、anthropics/knowledge-work-plugins +2,612）。
- **來源**：[Cursor — The Agent SDK](https://cursor.com/blog/agent-sdk) · [GitHub Trending](https://github.com/trending?since=weekly)

### 5. 工廠會改變自己的評分器——所以假修復率是結構必然

- **發生什麼**：arXiv 2610.36254（Instant Software Factories, 10-26）問的是「prototype 到 product 之間那條長尾需不需要專門 orchestration」，答案的設計極簡：**只用兩個協調輸入**——**一群有常駐目標的 cron-job agents**，加**一個共享溝通看板（如 GitHub），agents 透過自己留下的 trace 互相協調**；**governance 是可分離的一層**；bootstrap prompt 讓「一次人類輸入」就同時設定好兩者（蒸餾自兩個手工工廠，觀察 15 與 17 天，**作者自述尚未評估**）。觀察數字很刺眼：**至少 5.6% 被標記為 fixed 的 issue，後來被發現修復是錯的**；agents 提了 **95% 的新 issue**；58 個改動 CI workflow 的 PR 中 **40 個由 agents 寫成**；每日 merge 上升 **15×**（作者明確標為**關聯非因果**）。
- **為什麼重要**：命題是 **「a factory thus changes its own workload, evaluator, and measured progress」**——工廠開發是在**內生回饋下的多目標最佳化**，不是固定 benchmark 上的單點最佳化。**我們的架構與此高度同構**（cron agents + 共享 wiki 看板 + 可分離治理），所以「agent 寫報告 = agent 標記完成」與那個 5.6% 是同一個結構問題。**「標記完成就是評分的一部分」→ 假修復率是結構必然，不是個人失誤。**
- **來源**：[arXiv 2610.36254](https://arxiv.org/abs/2610.36254)

---

## 對 OpenClaw / Linder 的啟發

1. **把我們的 tool output 截斷改成「結構感知」，並量重複抓取率。** 具體三件事：(a) 切 JSON 時**逐欄位排優先序、保留尾端欄位**（實測證據恰恰在尾端：99.3% vs 4.7%）；(b) 切完**標記「已截斷 + 截掉多少」**，讓模型知道缺了什麼；(c) 既然截斷的懲罰先以「多做工作」出現，**量測就要加「重複抓取率 / tool call 數」**——只量最終正確率會低估傷害。同時提醒自己：**這是 token 預算下的必要手段，不是要停止截斷**。
2. **對 llm-wiki 做一個 kb-reviewer。** 每次架構決策或 skill 變更時，自動比對 wiki 裡已記錄的結論，**標出矛盾並引用出處 note**。這正好補上昨天那條「agent 95% 不會回頭看、缺陷 72.9% 來自繼承」的缺口——**kb-reviewer 就是那個「系統層回頭看」**。而且 Stratum 證明**跨模型繼承有效**（記憶由 M3 寫、由其他 agent 讀仍成立），所以多 agent 共用同一份 wiki 有量化依據。建議用 **page-safe 三段式回應**（回傳了什麼 / 還剩什麼 / 花了多少）改造 graphify query 的輸出格式。
3. **把「假修復率」變成一個被量測的數字。** 既然工廠會改變自己的 evaluator，我們的每日情報流程同樣需要**反向探針**：對近期報告中標記為「已完成 / 已建立」的結論，**隨機抽 N 條回到原始證據檢查**。同時把「已驗證的工作」標記出來（通過 CI/review/人工確認的那些），作為未來「從已驗證工作萃取 skill」的來源池——這是把 10-28 的「規格完整度」和今天的「skill 自演化」接起來的那條路。

---

## 值得追蹤的 repo / paper / article

- [arXiv 2610.36114 — Context Is a Pipeline, Not a Window（資訊耗損：34% tool result 被切、欄位 4.7% vs 99.3%）](https://arxiv.org/abs/2610.36114) · [replication package](https://doi.org/10.5281/zenodo.23614755)
- [arXiv 2610.36153 — Stratum: Repository Memory for Coding Agents Beyond the Context Window（21/24 vs 6/24、token 少 4.5×）](https://arxiv.org/abs/2610.36153)
- [arXiv 2610.36188 — Skill Dreaming: Evolving Repository Skills through Pull Request Streams](https://arxiv.org/abs/2610.36188)
- [arXiv 2610.36254 — Instant Software Factories（兩個協調輸入、5.6% 假修復、工廠改變自己的 evaluator）](https://arxiv.org/abs/2610.36254)
- [arXiv 2610.35496 — The Hidden Costs of Forgetting（9,400 runs：caching-aware pricing 下 **0/42** 省錢，縮短 trajectory 會打斷 cached prefix）](https://arxiv.org/abs/2610.35496)
- [arXiv 2610.36346 — Your Wish Is My Commit（Codex + Claude Code、3,000+ 回合：**無模型停頓、第一次停頓前重寫多達原碼 31 倍**）](https://arxiv.org/abs/2610.36346)
- [arXiv 2610.36570 — CASEL（有害副作用軌跡 14.75%→7.02%；**移除 reversibility-aware routing → 15.53%**）](https://arxiv.org/abs/2610.36570)
- [arXiv 2610.35981 — Small agents should know what their tools do（**公開 tool-use corpus 的 refusal templates 把 BFCL non-live 打到 31.4，濾掉回到 84.8**）](https://arxiv.org/abs/2610.35981)
- [Cursor — Introducing the Agent SDK（kb-reviewer 模式、evals + event replay）](https://cursor.com/blog/agent-sdk)
- [cloudflare/security-audit-skill — 本週 +16,002 stars 的 skill 分發案例](https://github.com/cloudflare/security-audit-skill) · [Surge AI DAYJOB: Tax（專業判斷 benchmark，Astra 5/5 漏截止日 vs Opus 5/5 抓到）](https://surgehq.ai/blog/dayjob-tax) · [Google Sleep framework（持續學習的 consolidation + dreaming）](https://research.google/blog/the-sleep-framework-a-new-way-for-llms-to-retain-knowledge-in-continual-learning/)

---

## 下一步建議

1. **已 ingest 到 llm-wiki**：raw（`raw/documents/daily-research-2026-10-29-context-attrition-and-skill-evolution.md`）+ 1 source + 5 concepts（`context-attrition-tool-output-truncation` / `repo-memory-selection-bottleneck` / `skill-evolution-from-validated-work` / `agent-as-software-project` / `factory-self-scoring-and-false-fix`），`wiki/index.md` 與 `wiki/log.md` 已更新，graphify 已連結（新增 1,916 wiki page nodes / 12,384 wiki links）。
2. **改一個 harness 細節 + 量它**：把我們 `head -c 5000` 的截斷改成「切 JSON 時保留尾端欄位 + 標記已截斷」，然後在**同一批任務**上量「tool call 數」與「重複抓取率」有沒有下降——這是 2610.36114 說「截斷的真實成本先以多做工作出現」的最小可行驗證，半天可做完。
3. **寫 `kb-reviewer` skill**：輸入一則變更（PR diff 或 wiki 頁面改動），輸出「與哪幾條已記錄結論矛盾 + 引用出處 note」。第一版可先用 grep + LLM 混合，不用上向量；這同時是「kb-reviewer 模式」與「繼承缺陷反向探針」兩條需求的最小實作。

---

## 誠實限制

9 篇 arXiv 皆為 **abstract 級抽取**（未讀全文），數字未獨立重現且**跨論文不可相加**；arXiv 編號 2610.x 為 2026-10，未做版本鏈追溯；論文中的模型名稱（Claude Opus 5.5、Astra、Qwen3-4B 等）未對應本機可得分型，**跨論文模型比較無意義**；**Cursor Agent SDK 為廠商產品公告**，無樣本數無 benchmark，kb-reviewer 效果為單一團隊敘述；**GitHub Trending star 為 2026-10-29 頁面快照**（含 `sponsors/` 佔位名，已還原真實 repo 路徑），不能當成長速率的可靠估計；CASEL 的干預有效性是**模擬器假設下的排序**，不是部署成效；Instant Software Factories **作者自述尚未評估**，15× merge 是關聯非因果，5.6% 來自其中一個工廠且 n 不明；Stratum 的 21/24 vs 6/24 樣本小（8 個 bug）；2610.36346 為無停止準則的開放式 refactor 情境，不代表所有任務；**Gemini 4 Carbon 抓取失敗**（750KB 回應截斷，內文未取得，僅列為追蹤項目）；**本日未做實驗、未跑 benchmark、未修改任何既有 raw 檔案**。
