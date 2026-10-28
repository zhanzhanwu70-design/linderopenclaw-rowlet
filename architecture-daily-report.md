# 每日 Agent × 軟體開發情報 — 2026-10-28

> 來源：14 個公開來源 / 6 篇論文 · 產出：木木鴞 🌿🦉 · Wiki 已入庫（1 source + 5 concepts，graphify 已連結）
> Raw：`/home/amr/llm-wiki/raw/documents/daily-research-2026-10-28-harness-ceiling-and-attribution.md`

**一句話總結：過去我們用「pass rate 差」去歸因 harness 的效果——這是量錯了東西。harness 效果必須拆成「harness 給了什麼（ceiling）」與「這個模型用得動多少（mismatch）」兩個成分分別估計；拆開之後才會發現，很多看起來像 harness 優劣的差異，其實只是 policy 對舊 harness 的偏好殘留。**

---

## 今日 5 個重點

### 1. Harness 效果要拆成 ceiling − mismatch：只改欄位順序，成功率從 85% 掉到 19%

- **發生什麼**：arXiv 2610.37255（2026-10-27）證明 post-trained policy 會**記住 harness 的偏好**（log odds 可還原 harness 對各動作的偏好強度）。因此 deployed return = harness ceiling − policy mismatch；訓練只改 mismatch，換 harness 兩項都動 → **固定模型的 harness A/B 把「harness 提供什麼」與「模型用得動多少」混在一起量**。MiniWoB++ 上最狠的一例：把 observation 欄位順序反轉（**每個最優決策完全不變**），訓練後模型成功率 **85.0% → 19.2%**。Terminal-Bench Lite 上，只有 ceiling − mismatch（以更強模型代理 optimum）能重現 accuracy ranking，**單獨任一項都不能**。
- **為什麼重要**：這正是昨天報告裡「換 harness 翻 13% ＝ 重跑翻 13%」那條紅線的**理論解釋**——你量的本來就是 mismatch，而 mismatch 小到被雜訊蓋住。harness 不是「環境」，它是**塑造 policy 決策幾何的東西**。
- **來源**：[arXiv 2610.37255](https://arxiv.org/abs/2610.37255) · [code](https://github.com/2020-qqtcg/HRP)

### 2. harness 的歸屬基準是隱藏變數：離開「自家模型」的 lab harness 直接歸零

- **發生什麼**：arXiv 2610.36405（kw-bench, 2026-10-26）用四個 harness、**同一個模型**（DeepSeek v4.1 Flash）、同一個兩小時確定性計分任務（五年 SAP VAT 重建）：兩個第三方 harness 交出 **0.542 / 0.528**，兩個 lab harness（Claude Code、Codex）**離開 home model 後兩個都是 0.00**。換 frontier 模型（Claude Opus 5.5）同一批任務 **0.9986 / 1.000，22–25 分鐘**完成。作者結論：**below the frontier, the harness decides how far a model gets**。
- **為什麼重要**：**「harness 的優劣」不是 harness 的屬性，是 (harness, model) 配對的屬性。** 任何引用「某 harness 較好」而不附模型的數字都是無效引用。對我們最直接：我們日常用 MiniMax-M3（非 frontier），**harness 品質對我們產出的影響比對前沿模型團隊大得多**——也代表「照抄 Claude Code 的 skill 格式」不保證等效行為。
- **來源**：[arXiv 2610.36405](https://arxiv.org/abs/2610.36405)

### 3. Guardrail 的價值在「run 留下了什麼」，不在通過率

- **發生什麼**：270 unattended runs / 3 模型 / 7 任務 / Claude Code 2.1.296（2026-10-15，companion repo 公開可 reproduce）。**first-pass rate 完全沒差異**：none 90/90、rules 89/90、gates 88/90，事先寫下的統計檢定對任何模型都無顯著差異。但看**殘留缺陷**就有差異：T7「改了 schema 卻沒加測試」在沒有 instruction file 時 **14/15**，加上那條規則後 **0/30**；pooled defects **15/60 → 9/60**（作者誠實標註 p = 0.18，只是 lead 不是 proof）。成本面：**harness 幾乎不動成本，模型動超過十倍**（每 accepted change：Haiku $0.04–0.06、Sonnet $0.27–0.30、Opus $0.82–0.97，全 270 runs 約 $115.58）。
- **為什麼重要**：同一批資料，**量測選擇決定結論**（用通過率看＝「guardrails 是儀式」；用殘留物看＝「特定規則有效」）。而且有效的不是「加一道閘門」，是**可檢查的具體規則**。同作者分析 1,866 個熱門專案的 AGENTS.md：**3/5 規則可被腳本檢查，卻不到 1/20 寫出檢查在哪** → 大部分 harness 的規則其實是**沒有防護的宣言**。
- **來源**：[secondtimeisabug 270 runs](https://secondtimeisabug.com/blog/coding-agent-guardrails-270-runs/) · [companion repo](https://github.com/second-time-is-a-bug-book/book-companion)

### 4. Skill 的價值來自「規格完整度」，不來自「skill 這個容器」

- **發生什麼**：arXiv 2610.37459（M4Bench, 2026-10-27；28 個臨床 EHR 衍生任務 / Docker 隔離 / Codex GPT 5.4 Mini + 5.5）：skills 讓 reward **+0.136**（26/28 任務改善）——但 **8-task 控制子集上，單給一份 operational spec 就 +0.162，skills 在其上只再加 +0.024，與零無異**。對照實驗乾淨排除兩個替代解釋：**decoy skill 得分等同 no-skill**（排除「多給 context 就好」）、**raw reference SQL 幾乎與 targeted skill 相當**（排除「skill 格式有 magic」）。另一個易漏的重點：skills **幾乎不改變 agent 回傳哪些 rows（F1 +0.003）**，通過全部嚴格檢查的只有 25/280（no-skill 13/280）。正向佐證（arXiv 2610.36589 InfraDev）：**把失敗分析寫成 skill，resolved rate +10.5%**；同時 hidden probes **推翻 32% 通過所有官方測試的提交**。
- **為什麼重要**：**skill 是一種交付格式，不是能力增益。** 真正的增益來自裡面那份完整、可執行的規格——這直接改寫我們 skill 庫的設計目標：不是「skill 寫得漂亮」，而是「規格寫得完整 + 每條規則都指得出哪個 check 在驗它」。另注意 skill 對「要判斷與策略」的任務幫助大、對「要窮舉與完成」的任務幾乎無效。
- **來源**：[arXiv 2610.37459](https://arxiv.org/abs/2610.37459) · [arXiv 2610.36589](https://arxiv.org/abs/2610.36589)

### 5. 長程失敗的主因是「繼承缺陷」，而 agent 95% 不會回頭發現

- **發生什麼**：arXiv 2610.37434（FeatureArc, 2026-10-27；10 個 coding agent × 73 個 2–10 stage 任務，單一 persistent session、無 rollback）：**pooled success 從首 stage 的 62.7% 掉到整個 feature 測完的 28.5%**。軌跡分析指出**繼承缺陷是主要失敗機制，佔失敗後段的 72.9%**；而且**在已經失敗過的後續 stage 中，agent 約 95% 的時候不會察覺先前的錯誤**，self-test 也很少回頭看早期 stage。Tencent 已把這條 pipeline 用於 Hunyuan 開發。
- **為什麼重要**：62.7% → 28.5% 的落差不是模型變笨，是**缺陷被累積繼承**，而 agent 自己幾乎察覺不到。**對 llm-wiki 是直接映射**：我們的每日情報連續寫進同一個庫，第 30 天建立在第 1 天上，而我們沒有任何機制回頭檢查早期結論是否仍成立——我們的 review 同樣是「當下」導向的。既然 agent 不會回頭看，就必須由**系統**回頭看。
- **來源**：[arXiv 2610.37434](https://arxiv.org/abs/2610.37434)

---

## 對 OpenClaw / Linder 的啟發

1. **harness 效果要用 ceiling − mismatch 量，不是 pass rate 差。** 落地三件事：(a) 每次 session 存下「第一個 model request 的 tool schema + system prompt 快照」（arXiv 2610.37332 研究了 1,886 個 release 的 instruction stack，發現 tool definitions 佔主導、**只有 48% 的變更單元能解釋變更動機**——我們連自己改了什麼都沒記錄）；(b) 每個 harness 變更跑 N≥3 次取分布（Anthropic 自己說：a regression only showed up in one run out of two）；(c) 用更強模型代理 optimum 估 ceiling。**沒有 (a)，(c) 根本無從做起。**
2. **Skill 要重寫成「規格」，不是「skill」。** M4Bench 說 skill 容器只值 +0.024（≈0），規格完整度值 +0.162，且 decoy skill ≡ no-skill。對應動作：llm-wiki 的 skill 頁面改成可執行規格（程式碼、邊界條件、失敗處理、輸出契約），並**為每條規則標註「哪個 check 在驗它」**（AGENTS.md 研究：3/5 規則可腳本化、<1/20 寫出檢查）。Anthropic 的 `/claude-api prompt-audit`（標出「為舊模型寫的指令」並給 diff）可直接借用——我們的 skill 庫很多是為舊模型/舊架構寫的。
3. **wiki 是多階段累積系統，會繼承缺陷。** 具體機制：被推翻的結論**不要覆寫，要標記失效並連到新結論**（保留 evolution history）；對關鍵結論加「反向探針」（寫一個會失敗的檢查確認該主張仍為真，呼應 InfraDev 的 probes 推翻 32% 假通過）。另外 30–50 個 tool definition 是 tool choice 退化門檻（Anthropic 官方）——我們的 tool 數量已該盤點。

---

## 值得追蹤的 repo / paper / article

- [arXiv 2610.37255 — Your Policy Is Secretly a Harness（決策幾何 / ceiling − mismatch）](https://arxiv.org/abs/2610.37255) · [code HRP](https://github.com/2020-qqtcg/HRP)
- [arXiv 2610.36405 — kw-bench（harness 歸屬基準；below the frontier, the harness decides）](https://arxiv.org/abs/2610.36405)
- [arXiv 2610.37332 — Hidden in Plain Sight: Instruction Stacks of Coding Agents（1,886 releases 縱向研究）](https://arxiv.org/abs/2610.37332)
- [arXiv 2610.37459 — M4Bench（skill 容器 vs 規格完整度的乾淨對照）](https://arxiv.org/abs/2610.37459)
- [arXiv 2610.37434 — FeatureArc（繼承缺陷 72.9% / 95% 盲區）](https://arxiv.org/abs/2610.37434)
- [Anthropic — Building agents: When to fold subagents into your main agent loop（2026-10-22）](https://claude.com/resources/articles/building-agents-when-to-fold-subagents-into-your-main-agent-loop) · [migration kit](https://github.com/anthropics/single-agent-loop-kit)
- [secondtimeisabug — Do Guardrails Make AI Coding Agents Better?（270 runs，companion repo 可 reproduce）](https://secondtimeisabug.com/blog/coding-agent-guardrails-270-runs/)
- [dbreunig — The State of Context Engineering（AGNTCon 演講稿：六個 context 工具 / fighting the weights）](https://www.dbreunig.com/2026/10/24/the-state-of-context-engineering.html)

---

## 下一步建議

1. **已 ingest 到 llm-wiki**：raw + 1 source + 5 concepts（harness-ceiling-and-policy-mismatch / harness-home-model-advantage / guardrail-value-lives-in-leftovers / spec-completeness-over-skill-format / inherited-defect-blindspot），index.md 與 log.md 已更新，graphify link 已跑（10,340 nodes / 17,401 links / 1,206 communities，6 個新頁面皆非 orphan）。
2. **寫 `harness-snapshot` skill**：把「session 開始時的第一個 model request（tool schema + system prompt + 環境上下文）」存成檔案並可 diff。這是 2610.37332 與 2610.37255 兩條的共同前置，也是所有 harness A/B 的基礎設施。
3. **安排一個小實驗**：挑 1 個既有 skill，做「原版 vs 只保留完整規格（去掉 skill 容器）」的對照，各跑 5 次，同時量 pass rate 與殘留缺陷——直接驗證 M4Bench 的 +0.024 在我們的 stack 上是否也接近零。

---

## 誠實限制

6 篇 arXiv 皆為 API 摘要抽取、非全文精讀，所有數字未獨立重現且**跨論文不可相加**；270-run 研究為單一作者／單一 codebase／單一 agent／單一廠商三模型／每 cell 5 runs，且作者自寫任務與 harness（自承可能偏袒）、p = 0.18 未達顯著、日期 10-15 屬 7–14 天窗邊緣；kw-bench 僅單一任務家族與單一非 frontier 模型；M4Bench 與 FeatureArc 皆為單一領域，外部效度未確立；Anthropic 文章為廠商撰寫、缺樣本數。**HN 覆蓋偏薄**（本次過濾未命中高訊號，不等於 HN 本日無動向）；GitHub star 為 2026-10-28 API 快照。本日未做實驗、未跑 benchmark、未修改任何既有 raw 檔案。
