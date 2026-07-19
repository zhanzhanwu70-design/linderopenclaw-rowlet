# 每日 Agent × 軟體開發情報 — 2026-07-19

> 主題：**agent economics 正式進入 CFO 級語言（OpenAI scorecard） + LRM 突破 convex optimization 30 年 open problem（GPT-5.6 Sol + Lean） + cross-vendor MCP/skill 三件 trending 同爆 + WAM adversarial fragility 呼應 Anthropic Containment + LongStraw close RL long-context gap**。
> 來源：HN frontpage 504 pts、GitHub Trending 今日（KnockOutEZ/wigolo +203 stars / ibelick/ui-skills +123 stars / tirth8205/code-review-graph）、OpenAI News 7/17、arXiv 2607.15207 / 2607.14952、Anthropic Engineering 持續 featured、LangChain blog 系列（昨天已記錄）。
> 與昨日（2026-07-18）延續：hallmark / Copilot SDK / Containment / SearchOS / Seed / Pay-i — 今日出現「cross-vendor MCP / skill 第二波 + agent economics 正式化 + LRM 數學突破 + WAM adversarial」四條新線。

---

## 今日 5 個重點

### 1. OpenAI《A scorecard for the AI age》— 「Useful Intelligence per Dollar」成為 AI 時代正式 metric
**發生什麼**：OpenAI 7/17 釋出《A scorecard for the AI age》。Brad Lightcap 主筆，直接面對 CFO 提問：「怎麼從 AI spend 拿到更多 value？」。提出 **Useful Intelligence per Dollar** 作為新 scorecard，回答四個子問題：(a) AI 完成多少有用的 work？(b) 每個成功任務的成本？(c) 人能否依賴結果？(d) 每個 AI dollar 是否在使用增長時產生更多價值？**反直覺關鍵**：便宜的 token 不一定省錢 — 低價 model 可能要更多 attempts / human review；高價 model 可能一次完成。真正的成本 = full cost of successful outcome vs outcome 創造的 value。
**為什麼重要**：**agent economics 從 vendor 行銷話術正式進入 CFO 級語言**。昨日 LangChain × Pay-i 的 per-call accounting 是 micro/operational 實作，今日 OpenAI scorecard 是 macro/strategic 框架 — 兩者同天發表，正式把 *agent economics* 列為 strategic concern 而非 cost center 細節。對 OpenClaw 的具體含義：(a) `TOOLS.md` 裡的 per-token cost tracking 應該升級為 per-outcome 三欄紀錄（work done / resources consumed / result reliability）；(b) `agent-cost-report` skill（昨日啟發）需要擴充為 `agent-useful-intelligence-report` — 月底給 Linder 一份「這個月 rowlet 替你完成哪些 work / cost / 哪些可依賴」三軸報告。
**來源**：
- https://openai.com/index/a-scorecard-for-the-ai-age/ （OpenAI News 7/17）
- raw snapshot：`raw/sources/2026-07-19/openai-scorecard-useful-intelligence.md`

### 2. GPT-5.6 Sol Pro 證明 1996 年 convex optimization open problem — HN 504 pts + Lean formal verification
**發生什麼**：UC Berkeley IEOR 教學教授（PhD applied math）仿照 OpenAI 之前 CDC proof 的 prompting 方法，在 *148 分鐘單次 session* 內讓 GPT-5.6 Sol Pro 產生 convex optimization oracle complexity 的 lower bound 證明 — **該問題自 1996 年 Protasov 給出 upper bound O(d²) 後 lower bound 幾乎不存在**。結果已通過 Lean 形式化驗證。HN 504 points 上 frontpage，math 版 Reddit 熱議。**披露**：作者本人即為 preprint 作者；結果尚未 peer-reviewed。
**為什麼重要**：*LRM (Large Reasoning Model) 第一次在 convex optimization 上完成 closed formal-verified proof，而且是第三方研究者用 prompt engineering 達到 milestone*。三層含義：(a) **proof engineering 是新 LRM productivity unit** — 「單次 148 分鐘 coherent reasoning session」成為 agent harness design 的新 baseline（與昨日 Anthropic《Harness design for long-running application development》3/24 post 共構）；(b) **Lean / Coq 形式化驗證 = LRM correctness checker** — 對 Linder 寫論文或做數學工作是直接可用工具，可整合進 OpenClaw deep-research skill；(c) **prompt templates 是 reproducible skill** — CDC proof prompt pattern 可遷移到 convex optimization，代表 prompt libraries 應 ingest 為 reusable assets。
**來源**：
- https://news.ycombinator.com/item?id=48957779 （HN 504 pts）
- https://old.reddit.com/r/math/comments/1uxj3cy/after_openais_cdc_proof_announcement_gpt56_used_a/
- raw snapshot：`raw/sources/2026-07-19/gpt56-convex-optimization-lean-proof.md`

### 3. GitHub Trending 今日三件 cross-vendor MCP / skill 同爆 — wigolo + code-review-graph + ui-skills
**發生什麼**：今日 GitHub Trending 出現三件 cross-vendor 工具，**共同模式**：(a) 同一行 install 命令覆蓋多 vendor agent；(b) local-first 無 API key / 無 cloud；(c) 走 MCP 作為 universal interface；(d) 有量化 benchmark 結果。
- **KnockOutEZ/wigolo (+203 stars today)**：local-first web intelligence for AI agents。`npx wigolo init --agents=claude-code,cursor,codex,gemini-cli,vscode,windsurf,zed,antigravity` 一次寫完 8 個 vendor 的 MCP config。Tagline：「No API keys, no cloud, $0/query」。
- **tirth8205/code-review-graph (trending)**：tree-sitter 建 structural map + MCP interface + 多語言 README（英中簡中日韓印地），給 AI coding tool 提供精準 context。「benchmarked context reductions on reviews and large-repo workflows」。
- **ibelick/ui-skills (+123 stars today, 5,044 stars total)**：「Skills for Design Engineers」。昨日 Nutlope/hallmark 的姊妹篇 — design-engineering skills 成為 skill 主流類別。
**為什麼重要**：**昨日 hallmark + Copilot SDK 的「cross-vendor skill 範式」爆發，今日升級為「cross-vendor MCP / skill 範式」第二波**。對 OpenClaw 的具體含義：(a) **`skills/` 目錄 frontmatter 應正式加 `platforms:` 與 `mcp:` 兩個欄位** — 不寫這兩欄的 skill 在 2 個月後的 distribution 會被邊緣化；(b) **local-first 是 OpenClaw 的天然賣點** — wigolo 強調 "$0/query, no cloud"，與 OpenClaw self-hosted 同構；(c) **code-review-graph 是 graphify as code 的姊妹專案** — tree-sitter + persistent graph + MCP 是 LLM Wiki graphify 的同構思維，OpenClaw 可以 ingest 為 code-intel skill。
**來源**：
- https://github.com/KnockOutEZ/wigolo （+203 stars today）
- https://github.com/tirth8205/code-review-graph （trending）
- https://github.com/ibelick/ui-skills （+123 stars today）
- raw snapshot：`raw/sources/2026-07-19/cross-vendor-mcp-trifecta-wigolo-code-review-ui-skills.md`

### 4. arXiv 2607.15207「BadWAM」— World-Action Model 的 imagination-action drift 是 adversarial-fragile
**發生什麼**：World-Action Models (WAMs) 把「action generation + future world prediction」耦合，當作 robustness / interpretability / safety 的來源 — 直覺是：機器人可以對 imagined future 檢查自己的 action。但 BadWAM 證明這個假設脆弱。提出 BadWAM 統一框架，用小型視覺擾動打破 imagination-action alignment。兩種 attack：(a) **action-only attack** — 直接 drive 任務失敗動作；(b) **imagination-preserving attack** — 保持 imagined future 接近 clean，但動作 desynchronized。實驗結果：action-only attack 把 WAM 任務成功率從 96.5% 大幅降低。
**為什麼重要**：**直接呼應昨日 Anthropic《How we contain Claude across products》**。Containment doctrine 強調「verifier 應在環境邊界而非 imagination layer」；BadWAM 提供對位證據：把 imagination 當作 alignment safety 機制是 *adversarial-fragile*，不能作為唯一防線。對 OpenClaw 的 *Risk and Consequence Principle* 是 structural validation：(a) **multi-layer defense** — 不能依賴單一 verification layer；(b) **prompt-imagination ≠ actual action** — 即使 prompt 看起來正確，agent 仍可能 *act wrong*；(c) 可在 `wiki/concepts/containment-architecture.md`（昨日啟發）加一節「imagination layer 不能是唯一 verifier」。
**來源**：
- https://arxiv.org/abs/2607.15207
- raw snapshot：`raw/sources/2026-07-19/badwam-longstraw-papers.md`

### 5. arXiv 2607.14952「LongStraw」— 2M token RL post-training 在固定 GPU budget 下可行
**發生什麼**：HuggingFace Daily Papers 7/17 列出 LongStraw。核心問題：inference 已達 million-token context，但 RL post-training 仍卡在 256K token。LongStraw 的 architecture-aware execution stack：shared prompt 評估一次（無 autograd）、只保留後續 tokens 需要的 model state、response branches 一次 replay 一個進 autograd。結果：live training graph 從 full prompt+response 縮到 single response branch，用 replay time 換 GPU memory。實作於 Qwen3.6-27B（hybrid recurrent + full attention）+ GLM-5.2（compressed-attention MoE）兩種架構。
**為什麼重要**：**RL post-training 跟上 inference context length 的基礎設施級貢獻**。對 OpenClaw 短期無直接應用（OpenClaw 不做 fine-tuning），但對 *agent learning* 主題是新的 RL engineering baseline。三層含義：(a) **agent RL training 的 long-context 解鎖** — 之後可能看到 1M+ token RL-tuned LRM；(b) **architecture-aware 的工程典範** — 不是 universal fix 而是 per-model-family 的 execution stack；(c) 對 Linder 的工作：LongStraw 的「replay time 換 GPU memory」思路可借鏡到 OpenClaw 的 memory architecture（例如 agent memory persistence 的 replay strategy）。
**來源**：
- https://arxiv.org/abs/2607.14952
- https://huggingface.co/papers/2607.14952
- raw snapshot：`raw/sources/2026-07-19/badwam-longstraw-papers.md`

---

## 對 OpenClaw / Linder 的啟發

1. **從 cost-per-token 升級為 useful-intelligence-per-outcome**。把昨日的 `agent-cost-report` skill 擴充為 `agent-useful-intelligence-report`：每個 cron 結束時記錄「work done / resources consumed / result reliability」三欄，月底彙整成 Linder 可讀的 CFO-style scorecard。Schema 對位 OpenAI 的四個子問題（work / cost / reliability / value-creating-growth）。**今晚可寫 50 行 cron patch**。

2. **OpenClaw skills 應正式採 cross-vendor + MCP-friendly frontmatter**。今日三件 trending（wigolo / code-review-graph / ui-skills）共同模式：同一 install 命令跨 8+ vendor agent、local-first、MCP universal interface。OpenClaw 的 `~/.openclaw/skills/` SKILL.md 應加兩個 frontmatter 欄位：`platforms: [claude-code, codex, cursor, openclaw]` 與 `mcp: { server: <name>, tools: [...] }`。**這是 2 個月後 skill distribution 的入場券**。

3. **Lean / Coq 作為 deep-research skill 的 correctness verifier**。GPT-5.6 Sol Pro + Lean verification 證明 LRM 可達到 formal-verified math。對 Linder 寫論文或數學類工作，可整合 Lean 形式驗證進 `deep-research` skill 流程：research → LRM draft → Lean verify → final output。**先做 spike**：`spike` skill 跑 1 個 Lean 4 + GPT-5.6 證明 simple theorem 測可行性。

---

## 值得追蹤的 repo / paper / article

- **OpenAI《A scorecard for the AI age》** — https://openai.com/index/a-scorecard-for-the-ai-age/ （Useful Intelligence per Dollar，7/17）
- **HN 504 pts：GPT-5.6 Sol Pro convex optimization proof + Lean verification** — https://news.ycombinator.com/item?id=48957779
- **KnockOutEZ/wigolo** — https://github.com/KnockOutEZ/wigolo （+203 stars today，local-first cross-vendor MCP web intelligence）
- **tirth8205/code-review-graph** — https://github.com/tirth8205/code-review-graph （tree-sitter + MCP code intelligence）
- **ibelick/ui-skills** — https://github.com/ibelick/ui-skills （+123 stars today，Design Engineering skills）
- **arXiv:2607.15207 BadWAM** — https://arxiv.org/abs/2607.15207 （World-Action Model adversarial fragility）
- **arXiv:2607.14952 LongStraw** — https://arxiv.org/abs/2607.14952 （2M token RL post-training on fixed GPU budget）
- **Moonshine AI moonshine-micro** — https://github.com/moonshine-ai/moonshine/tree/main/micro （HN 277 pts，TTS + STT <500kb，給 local agent 用）

---

## 下一步建議

1. **今晚寫 `agent-useful-intelligence-report` skill**（50 行 cron patch），把昨日啟發的 `agent-cost-report` 升級為 CFO-style scorecard；跑 3 天試驗後請 Linder 檢視格式。
2. **加 `platforms:` 與 `mcp:` 兩個 frontmatter 欄位**到所有現有 OpenClaw SKILL.md（skill-creator skill 一次 batch 處理），寫一個 `wiki/concepts/cross-vendor-skill-bridge.md` 對位昨日的 `cross-vendor-skill.md` 草案。
3. **安排 `lean-formal-verify` spike**：用 GPT-5.6 Sol Pro + Lean 4 跑 1 個 simple theorem（如 group theory 基礎定理），驗證 LLM Wiki deep-research skill 可整合 Lean correctness verifier。如果成功，列入 v2 roadmap。
