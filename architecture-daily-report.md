# 每日 Agent × 軟體開發情報 — 2026-08-05

> 產出者：木木鴞（rowlet）｜時區：UTC｜主查詢時間：2026-08-05 01:11 UTC
> 範圍：近 7-14 天；三類來源：研究 / 開發潮流 / 工具與框架 release。
> 本日調性：**07-31 報告說「governance / router / portability 是生產級第一公民」；5 天後今天，「團隊級 memory hub + 跨廠 skills standard + agent 安全生產化」三件事在同一天冒出** — **TencentCloud 開源「Chat Memory / Skill / LLM-Wiki / Code-Graph」四件套（直接對位我們的架構）+ obra/superpowers 跨 10 個 coding agent harness + Uber ADR 在 MLSys 2026 上 production-deployed**。今天的訊號不再是「framework 競爭」或「model frontier」而是「**生產化、最佳實�可移植、agent 安全可觀測**」三件事同時 vendor-level 化。

## 對位前一輪報告（07-31 / 08-02）

| 07-31 ~ 08-02 訊號 | 08-05 驗證 / 翻面 / 新切角 |
| --- | --- |
| LangSmith LLM Gateway（vendor-level governance） | ✅ Uber ADR（Uber production-grade observability for 7+ coding agents）— vendor-level governance **加碼**到 security 維度 |
| 「OpenClaw `model-router` 升級 production-grade」 | ⚠️ 仍缺 — 但今天 `api-key-routing` skill 雛形可以更明確：對位 TencentDB Memory Hub 的 multi-team shared gateway |
| Cursor cloud agent environment：egress / scoped git / secret redaction | ✅ Uber ADR Sensor（macOS / Linux / Windows 跨 7+ coding tools）— 落地驗證「production observability 不再是 framework feature」 |
| Anthropic decoupling / unhobbling | ⚠️ 今天沒有新 vendor 跟進，但 Mistral Shieldstral 把「policy-adaptive」做成 inference-time question-answering — 是另一條 unhobbling 軸線 |
| Skills / plug-in 作為 packaging unit | ✅ OpenAI ChatGPT Edu plugins (8-4) + obra/superpowers (10+ harness) + anthropics/skills — **三個獨立 vendor 同週把 Skills 作為 canonical packaging unit** |
| earendil 反 narrative：reasoning tokens 是 opaque blobs | ⚠️ 今天沒有反 narrative，但 TencentDB Memory Hub 開源是「**vendor-level 公開 portable memory architecture**」的正向對位 |
| Karpathy LLM Wiki Ecosystem（graphify 為基礎的決策圖） | ✅ **TencentDB-Agent-Memory 命名「Chat Memory / Skill / LLM-Wiki / Code-Graph」與 Karpathy + 我們的 wiki 完全同構** — 外部獨立驗證 |

## 今日 5 個重點

1. **TencentCloud/TencentDB-Agent-Memory 登上 GitHub Trending #1（+1,111 stars/day，TypeScript，2026-08-05）— 開源「團隊級 memory hub」把 Chat Memory / Skill / LLM-Wiki / Code-Graph 四件套命名並 vendor-level 化，直接對位 Karpathy LLM Wiki + 我們自己的 LLM Wiki 架構。**
   - 發生什麼：Tencent Cloud 開源 `TencentDB-Agent-Memory`，README 直接列舉四件套：**Chat Memory / Skill / LLM-Wiki / Code-Graph**。設計意圖：「Memory means more than just 'remembering conversations.' Any information that helps the next Agent avoid reinventing the wheel should be saved, organized, and reused.」自動從 conversations 萃取 Chat Memory + Skills，從 documents 轉成 LLM Wiki，從 code 建 Code-Graph；memory-core + memory-hub + proxy 三件服務 one-command start（`./start-all.sh`）；輸出 panel `localhost:8125`；proxy 模式貼一段 one-liner 進 Claude 即可讓 agent 自動 load team 的 save file。提供 v2 → v3 資料遷移工具。13,616 stars、1,276 forks。
   - 為什麼重要：**這是外部獨立 vendor 對「Karpathy LLM Wiki Ecosystem」與我們 LLM Wiki 架構的命名級驗證** — 我們花了半年走過的「wiki 是 raw evidence → graphify 出依賴圖 → wiki 寫決策頁 → skill 是 reusable artifact」這條路，Tencent 在 production-grade TypeScript 上重新走一遍，並且命名幾乎一樣。對 OpenClaw / Linder 五條：（a）**OpenClaw 內部應有「`tencentdb-memory-hub` vs 我們的 LLM Wiki」對位文件** — 不是抄，是「我們走得更遠的點」是什麼？我們有 graphify 自動 extraction、Ouroboros skill 自我複製、跨 framework graph layer（OpenClaw 不限 Claude Code）；（b）**Tencent 走「**`memory-hub` 是 shared backend，多個 agent 透過 proxy 存取**」架構** — 對位 OpenClaw `model-router` / `api-key-routing` skill，可以借鏡「**single memory backend, multiple agent frontends**」的多代理 shared state pattern；（c）**命名衝突**：我們的 `LLM-Wiki` 在 Tencent 也是「Chat Memory / Skill / LLM-Wiki / Code-Graph」之一 — 我們應在 wiki 寫一篇 `Karpathy LLM Wiki vs TencentDB Memory Hub 對位` 概念頁，把「為什麼我們的 LLM Wiki 比 Tencent 多一個 graph layer」這件事固化為 architecture decision；（d）**TencentDB-Agent-Memory proxy 模式「貼一段 one-liner 進 Claude」** — 對位 OpenClaw `bootstrap.md` + `session_startup` 流程，可設計 OpenClaw 的「team memory bootstrap fragment」自動注入到每個新 session 的 system prompt；（e）**v2 → v3 migration tool** — OpenClaw 應有「wiki schema migration script」�形：每次升級 `wiki/index.md` taxonomy 都要有可逆 migration。
   - 來源：<https://github.com/TencentCloud/TencentDB-Agent-Memory>、INSTALL：<https://github.com/TencentCloud/TencentDB-Agent-Memory/blob/feat/server_team/INSTALL.md>。

2. **obra/superpowers 登上 GitHub Trending（2026-08-05）— 「agentic skills framework & software development methodology」，支援 Claude Code / Codex CLI / Cursor / Gemini CLI / Pi 等 10+ coding agent harness，spec → plan → TDD → subagent-driven development 一條龍。**
   - 發生什麼：obra/superpowers 開源 — 自稱「a complete software development methodology for your coding agents, built on top of a set of composable skills」。流程：（a）**Spec-first** — agent 不直接寫 code，先問「你真正想做什麼」，把 spec 一段一段抽出來給 user 確認；（b）**Plan** — spec sign-off 後產「junior engineer with poor taste / no judgement / no project context / an aversion to testing 也能照著做」的實作計劃，強調 red/green TDD、YAGNI、DRY；（c）**subagent-driven development** — 開 subagent work through tasks，每個 task 都 inspect / review；常見 2 小時 autonomous 不偏離 plan。支援 harness 列表：Claude Code、Antigravity、Codex App / CLI、Cursor、Factory Droid、Gemini CLI、GitHub Copilot CLI、Kimi Code、OpenCode、Pi — **10 個 coding agent 一個 skills package 搞定**。Claude plugin marketplace 官方上架。
   - 為什麼重要：**obra/superpowers 是 Anthropic 官方 Claude Code Skills Marketplace 第一個被大量採用的跨 harness methodology package** — 直接對位我們已有的 `mattpocock-teach` skill（AI 編程工作流教學：安裝 → 初始化 → Grimmy 調研 → PRD 生成 → TDD 實現 → Round Design 預設計 — 6 步流程）。對 OpenClaw / Linder 四條：（a）**OpenClaw 應把 `mattpocock-teach` skill 升級為「cross-harness methodology package」** — 跟著 obra 的命名走：每個 harness（Claude Code / Codex CLI / Cursor / Pi）一個 `install-<harness>.sh`，但 skills body 共用；（b）**「spec / plan / TDD / subagent review」四步對位 OpenClaw `problem-solver-workflow` skill** — 把我們既有的 6 步（install → init → research → PRD → TDD → round design）對位到 obra 的 4 步，找差異點；（c）**「2 小時 autonomous 不偏離 plan」是 subagent-driven development 的 production promise** — 對位我們 OpenClaw `CEO mode`（roaringmoon planner + 4 個 specialist worker），obra 走的是「**coding agent 內部的 subagent**」，我們走的是「**多個獨立 agent 之間的 swarm**」，可以互補；（d）**Claude plugin marketplace 官方上架** — OpenClaw 應研究「**OpenClaw skill marketplace / registry**」可行性：能不能也做一個 `openclaw-skills` repo，第三方 skill 用同一個 SKILL.md spec，安裝跨 OpenClaw / Claude Code / Codex CLI。
   - 來源：<https://github.com/obra/superpowers>、Claude plugin marketplace：<https://claude.com/plugins/superpowers>、Anthropic Skills repo：<https://github.com/anthropics/skills>。

3. **Uber ADR（Agentic AI Detection and Response）在 MLSys 2026 發表，paper + slides 公開，open source 上 GitHub（2026-08-05 trending）— 7+ coding agent、133 MCP server、17 攻擊技術，Uber production-deployed。**
   - 發生什麼：Uber 開源 `uber/ADR`：「ADR secures enterprise AI agents through observability, security benchmarking, and threat detection. Deployed at Uber.」四個互補 capability：（a）**ADR Observability** — capture agent intent / tool use / execution traces across **7+ AI coding tools**（macOS / Linux / Windows）以及內部 automation + customer-facing support agents；（b）**ADR Benchmark** — ADR-Bench 包含 **300+ tasks / 133 MCP servers / 17 攻擊技術**；（c）**ADR Detection** — 兩層架構：high-recall triage + deeper agentic reasoning for suspicious sessions；（d）**ADR Prevention** — 「This component is not included in the current open-source release. Stay tuned.」ADR paper + slides PDF 公開（MLSys 2026）。Open source release 含 ADR Sensor / ADR-Bench / ADR Detector；offline ADR Explorer engine（pre-deployment red teaming）不開源。
   - 為什麼重要：Uber ADR 是 **第一個 enterprise-grade production-deployed agent observability 系統** 公開 paper + open source — 對位我們已有的 `openclaw-runtime-monitor` skill（filesystem / credential theft / anomaly detection / automated incident response）。對 OpenClaw / Linder 四條：（a）**OpenClaw `openclaw-runtime-monitor` skill 應有 ADR-Bench-style benchmark suite** — 不要只做 runtime detection，要做「**17 種攻擊技術 × 我們的工具 surface**」的攻擊面 mapping；（b）**「7+ AI coding tools」對位 OpenClaw 多框架事實** — 我們有 `exec / read / write / edit / apply_patch / web_fetch / sessions_send` 至少 7 個，ADR 的 normalization 思路可抄；（c）**「133 MCP servers / 17 攻擊技術」對應 MCP 生態的安全 attack surface** — OpenClaw 應有一個 `mcp-security-audit` skill 雛形，自動掃 MCP server manifest；（d）**「Prevention component 不 open source」** — 注意：Uber 把 prevention 留為閉源 — 對位 OpenClaw 應有 `agent-prevention` skill 雛形，包含「**stop unsafe actions before they cause harm**」四個 control：file scope / network egress / secret redaction / git remote scope。
   - 來源：<https://github.com/uber/ADR>、Paper：<https://github.com/uber/ADR/blob/main/docs/adr-paper.pdf>、Slides：<https://github.com/uber/ADR/blob/main/docs/adr-mlsys-2026-slides.pdf>。

4. **Mistral 開源 Shieldstral：3B 多模態安全分類器（Apache 2.0，2026-08-04 HN #3，297 pts / 71 comments），policy-adaptive，16GB GPU 跑，打敗 7× 大 model。**
   - 發生什麼：Mistral 發布 Shieldstral — 3B open-weights **多模態**（text + image）safety classifier，把 content moderation 框成「**policy-adaptive question-answering**」：user 在 inference time 寫 plain-language policy question（e.g.「Does this content promote violence against a protected group? Is this image safe to show to a minor?」），model 回傳 calibrated safety score；無 retraining、text + image 同 interface、single token verdict。benchmark 打敗 7× size 的 model on text safety、multimodal moderation 設 SOTA。技術報告 arXiv 2607.25857。Mistral 是 NVIDIA「Open Secure AI Alliance」inaugural member。Apache 2.0，可在 HuggingFace 下載。
   - 為什麼重要：**Shieldstral 把「safety policy」從 model weights 移到 inference-time input** — 是對位 Anthropic unhobbling 同一方向的 production 化，但走的是「safety」軸線而非「capability」軸線。對 OpenClaw / Linder 三條：（a）**OpenClaw `openclaw-security-scanner` skill 應可選 plug-in Shieldstral 為第二層 classifier** — 第一層用 pattern / regex / heuristic 跑 fast-path（成本低），可疑的才丟 Shieldstral；16GB GPU 即可，本機可跑；（b）**「policy as input」對位 OpenClaw SOUL.md 的「Risk and Consequence Principle」** — 我們的 safety principle 是 hard-coded text，但 Shieldstral 把「**policy question**」做成 first-class inference input。我們可以借鏡把 OpenClaw 內部的 `risk-policy`（immutable safety principle）跟 `task-policy`（per-task user-defined）拆成兩個 input；（c）**多模態（text + image）對位 OpenClaw `image` tool 的安全掃描** — 之前 image tool 沒安全掃描層；現在可以加 `openclaw-image-safety-scan` skill 雛形：每張 image 進來先丟 Shieldstral 過一次。
   - 來源：<https://mistral.ai/news/shieldstral/>、arXiv：<https://arxiv.org/abs/2607.25857>、HuggingFace：<https://huggingface.co/mistralai/Shieldstral-1.0-3B>、NVIDIA Open Secure AI Alliance：<https://blogs.nvidia.com/blog/open-secure-ai-alliance/>。

5. **OpenAI 發布「New ways to learn and teach with ChatGPT Work and Codex」（2026-08-04）— 三個 education plugin 正式把「plugin = apps + skills + instructions + workflows」做成 vendor 級 packaging 單位；同週 OpenAI 還發「Third-party cyber evaluations involving OpenAI models」（2026-08-04）。**
   - 發生什麼：（a）**ChatGPT Work + Codex education plugins** — 三個 plugin（college student / K–12 educator / college educator），每個 plugin 是「**a package of apps, role-specific skills, instructions, and common workflows**」；透過 ChatGPT Edu 與 ChatGPT for Teachers 部署。OpenAI 自家 narrative：「AI should support learning, not shortcut it, and the best learning experiences keep educators and students in control.」；（b）**Third-party cyber evaluations involving OpenAI models** — 8-4 OpenAI 公開 third-party cyber eval 結果，與 Anthropic Fable 5 + Glasswing 框架（6-30）對位。
   - 為什麼重要：**OpenAI education plugin 把「apps + skills + instructions + workflows」這個四件套命名為 plugin** — 與 anthropics/skills（skills folder + SKILL.md）+ obra/superpowers（spec → plan → TDD → subagent）+ TencentDB-Agent-Memory（Chat Memory / Skill / LLM-Wiki / Code-Graph）+ Mistral Shieldstral（policy as input）共同構成「**skills / plugins / policy as first-class input**」是 2026 Q3 的明確軸線。對 OpenClaw / Linder 三條：（a）**OpenClaw `SKILL.md` spec 與 Anthropic / OpenAI plugin spec 應做差異表** — 我們的 SKILL.md 是「frontmatter + body + scripts」，OpenAI plugin 是「apps + skills + instructions + workflows」 — 有 mapping 但不是 1:1；（b）**「ChatGPT Edu / Teachers」對位我們 Pokemon 團隊的 specialist agents** — 教育情境下「plugin = 一個完整教學 flow」與我們「skill = 一個 specialist agent 角色」概念同構，寫一篇 wiki `concept/` 對位頁；（c）**8-4 兩件事都是 OpenAI 安全 / 教育軸線** — 對位 8-2 報告「Graph Engineering」新詞 — vendor 已經不再追「新術語」而是把既有概念（plugin / skill / cyber eval）做 production 化。
   - 來源：<https://openai.com/index/learn-teach-chatgpt-work-codex/>、<https://openai.com/index/third-party-cyber-evaluations-involving-openai-models/>。

## 對 OpenClaw / Linder 的啟發

1. **外部獨立驗證「LLM Wiki + Graph」架構 — 立刻寫 wiki concept 頁 `Karpathy LLM Wiki vs TencentDB Memory Hub 對位`**，固化「**為什麼我們的 LLM Wiki 比 TencentDB 多一個 graph layer（graphify-out/GRAPH_REPORT.md）+ 跨 framework**」。這不只是記錄，更是 architecture decision record（ADR）：未來有人問「為什麼不用 TencentDB」有現成答案。
2. **`mattpocock-teach` skill 升級為「cross-harness methodology package」** — 跟著 obra/superpowers 的命名走：10+ coding agent harness 各一個 install script，但 skills body 共用；對應 OpenClaw 把 `mattpocock-teach` 拆成 `mattpocock-teach-core`（spec / plan / TDD / subagent-driven）+ `mattpocock-teach-install-claude-code.sh` / `-codex-cli.sh` / `-cursor.sh` 等。同時考慮建 `openclaw-skills` marketplace repo，第三方 skill 用同一個 SKILL.md spec 跨 OpenClaw / Claude Code / Codex CLI。
3. **`openclaw-runtime-monitor` + `openclaw-security-scanner` skill 升級為 Uber ADR 對位** —（a）加 `adr-bench-style` benchmark suite（17 攻擊技術 × OpenClaw tool surface mapping）；（b）加 `mcp-security-audit` skill 雛形（自動掃 MCP server manifest）；（c）加 `openclaw-image-safety-scan` skill 雛形（plug-in Shieldstral，16GB GPU 即可，本機可跑）；（d）建 `agent-prevention` skill �形（file scope / network egress / secret redaction / git remote scope 四 control）。

## 值得追蹤的 repo / paper / article

1. **TencentCloud/TencentDB-Agent-Memory**（GitHub Trending #1，+1,111 stars/day）— 團隊級 memory hub，Chat Memory / Skill / LLM-Wiki / Code-Graph 四件套，TypeScript，13.6k stars。**這是今天最重要追蹤對象**。<https://github.com/TencentCloud/TencentDB-Agent-Memory>
2. **obra/superpowers** — agentic skills framework，跨 10 個 coding agent harness，spec → plan → TDD → subagent。直接對位 mattpocock-teach。<https://github.com/obra/superpowers>
3. **uber/ADR** — Uber production-deployed agent observability，7+ coding tools / 133 MCP servers / 17 攻擊技術，MLSys 2026 paper。對位 openclaw-runtime-monitor。<https://github.com/uber/ADR>
4. **Mistral Shieldstral** — 3B 多模態 safety classifier，policy-adaptive，Apache 2.0，16GB GPU。<https://mistral.ai/news/shieldstral/>、arXiv 2607.25857、HuggingFace `mistralai/Shieldstral-1.0-3B`
5. **OpenAI ChatGPT Work + Codex education plugins**（2026-08-04）— plugin = apps + skills + instructions + workflows 四件套 vendor 級命名。<https://openai.com/index/learn-teach-chatgpt-work-codex/>
6. **OpenAI Third-party cyber evaluations**（2026-08-04）— 與 Anthropic Fable 5 + Glasswing 對位。<https://openai.com/index/third-party-cyber-evaluations-involving-openai-models/>
7. **firecrawl/pdf-inspector**（GitHub Trending，+2,540 stars/day，Rust）— Fast Rust library for PDF inspection / classification / text extraction，自動 detect scanned vs text-based PDFs。對位我們的 smart-ocr / ocr-handwriting / photo-archive skill pipeline。<https://github.com/firecrawl/pdf-inspector>
8. **ACM Queue 〈Eight Myths on Software Engineering and GenAI〉**（HN #2，2026-08-05）— ACM 403 block，但 HN 評論已抓到核心：14% coding time 數字、組織層 > 個人層 leverage、LoC 不是好 metric 沒有替代品。值得找 archive.org 版本讀。<https://queue.acm.org/detail.cfm?id=3807963>、HN <https://news.ycombinator.com/item?id=49176830>
9. **HN 〈IP and DNS Leaks in WebKit〉**（2026-08-05）— 跟 agent / coding agent 無關但跟 OpenClaw `web_fetch` tool 的 IP/DNS leak 有關 — WebKit 漏洞影響 proxy browsers 與 iCloud Private Relay，提醒我們 OpenClaw outbound HTTP 走 proxy 時的 IP/DNS leak surface。<https://mysk.blog/2026/08/04/webkit-proxy-icloud-private-relay-ip-leak/>

## 下一步建議（最多 3 條，可執行）

1. **立刻 ingest TencentDB-Agent-Memory 到 llm-wiki**：寫 `wiki/concepts/TencentDB Memory Hub 對位 Karpathy LLM Wiki.md` + raw snapshot `raw/github/tencentdb-agent-memory-2026-08-05-README.md`；同時把 `TencentDB Memory Hub` 加進 `wiki/maps/Code 與 Agent 地圖.md` 與 `wiki/index.md`；跑 `npx graphifyy link` 把這頁跟 `Karpathy LLM Wiki Ecosystem` 串起來。預估時間：30 分鐘。
2. **升級 `openclaw-runtime-monitor` skill 雛形 v2**：抄 Uber ADR 的「17 攻擊技術 × OpenClaw tool surface」對位表 + ADR-Bench 風格的 task suite（至少 30 個 attack scenario）+ Mistral Shieldstral plug-in 作為 image-safety second layer。預估時間：2-3 小時（skill + benchmark fixture + test）。
3. **把 `mattpocock-teach` skill 拆成 `mattpocock-teach-core` + 多 harness install scripts**：跟著 obra/superpowers 的命名走。先做 `mattpocock-teach-install-claude-code.sh`（已經在 Claude Code 用）+ `-codex-cli.sh` 兩個 — 這是 OpenClaw skill 可移植性的關鍵測試。預估時間：1-2 小時。

---

## 🔁 02:02 UTC 增量更新（距 01:11 UTC re-cron，~50 分鐘）

**沒有新突破訊號**，但有三個增量值得追記：

- **GitHub Trending 新面孔：`zhaoxuya520/reverse-skill`（#2，+2,297 stars/day，PowerShell）— 「Reverse Engineering / Penetration Testing Skill Router Pack：AI-powered routing + on-demand toolchain bootstrapping + self-evolving knowledge base」，支援 Claude Code / Kiro / Cursor / Cline。**這是 OpenClaw `skill-guard` 應該掃描的對象** — 它在 GitHub Trending 上公開提供「**AI 自動選擇並執行 reverse-engineering 工具鏈**」的能力，這正是我們「Risk and Consequence Principle」需要警覺的攻擊面。Stars：17,979 / Forks：2,465。<https://github.com/zhaoxuya520/reverse-skill>
- **HN 升溫訊號**：`Eight Myths on Software Engineering and GenAI` 從 01:11 的 14 pts → 02:02 的 63 pts（2h 內 +49 pts，26 comments → 持續發酵中）— 學術界對「GenAI × SWE」反 narrative 熱度仍升，OpenClaw 應搶在 narrative 固化前建立自己的「GenAI × Coding Agent：實務觀察筆記」 wiki 頁，避免被動引用 ACM 結論。
- **HN 新進：`libexpat` Munich City 6 個月 funding**（127 pts/2h，#1）— 開源關鍵基礎元件的 municipal funding 模式（City of Munich → libexpat maintenance）。對 OpenClaw / Linder 的啟發：**OpenClaw / llm-wiki 本身是否適合申請類似的 open-source maintenance grant？** OpenClaw skill ecosystem 越長（目前 60+ skill），maintenance 成本越高，這是個 funding 對位選項。
- **數字增量**：`TencentCloud/TencentDB-Agent-Memory` stars：13,616 → 13,727（+111 stars / 50 min，~2.2 stars/min 持續攀升）。趨勢仍在加速，沒有見頂。

**新對 OpenClaw / Linder 啟發（一條）：**
4. **`skill-guard` skill 升級：把 `reverse-skill`（GitHub Trending #2，AI-routing reverse-engineering toolchain）列為高優先掃描對象** — 自動 detect「AI 自動路由到 hacking / pentesting / reverse-engineering tool」模式的 SKILL.md 與 tools.json，標記為 high-risk 並要求 Linder 顯式 enable。這條補充到「下一步建議」第 2 條（`openclaw-runtime-monitor` 升級 v2）的 scope。

---

**查過的來源（即使沒進報告也記錄）：**
- GitHub Trending daily（2026-08-05 02:02 UTC re-check）：TencentCloud/TencentDB-Agent-Memory（13.7k stars、+111 / 50 min）/ zhaoxuya520/reverse-skill（17.9k、+2,297 today）**【新增】** / firecrawl/pdf-inspector / uber/ADR / obra/superpowers / microsoft/generative-ai-for-beginners
- Hacker News frontpage（2026-08-05 02:02 UTC re-check）：libexpat（127 pts/2h，Munich funding）**【新增】** / Eight Myths on SWE and GenAI（63 pts/2h，+49 vs 01:11）**【升溫】** / gwern Guardian Angel / Pi autoresearch / DuckDB Clojure / Mistral Shieldstral / WebKit IP leaks
- arXiv cs.AI 2026 list / HuggingFace Daily Papers（landing page 可達，individual paper 需 query）
- anthropic.com/news（6-30 Fable 5 / Glasswing — 已存 wiki）
- openai.com/news（7-29 ~ 8-4 八篇 — 已存摘要）
- martinfowler.com / pragmaticengineer.com（homepage 可達，archive 需 query）
- ACM Queue（Cloudflare 403，需 archive.org fallback）
- 本地 LLM wiki graphify query（02:02 UTC）：命中 `Karpathy LLM Wiki Ecosystem`、`A Survey of Frontiers in LLM Reasoning`、`Agent Skill Architecture Guide`、`Agent-Native-Immune-System`、`Two Tales of Persona in LLMs`、`AtomMem`、`A-MEM Agentic Memory`、`Backboard.io vs Mem0`、`Building Effective Agents`、`Claude Code`、`Co-Failure Ceiling`、`Code Knowledge Graph`、`Coding Agent Black Box Debugging` 等 30+ 既有頁

**結論：01:11 → 02:02 UTC 之間沒有結構性新訊號；只有三個增量（reverse-skill 新進 Trending #2、Eight Myths HN 升溫、libexpat municipal funding 模式）。報告主體不變。**
