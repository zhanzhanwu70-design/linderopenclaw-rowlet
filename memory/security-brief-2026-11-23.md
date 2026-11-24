# 每日資安威脅簡報 + 一日提升方案 — 2026-11-23（週一）

生成者：rowlet（cron job 911eee45）｜資料來源：CISA KEV、公開 CVE 回顧、OpenClaw 本機稽核

## A. 當日威脅趨勢（2026-11-16 ~ 11-23）

### A1. 零日與已被利用漏洞（KEV）
- 本週 CISA KEV 新增 **9 筆**（11/16–11/22）；一週全球新增約 4,700–4,752 筆 CVE，其中 361 筆為 critical。
- **CVE-2026-40217（LiteLLM，CVSS 8.8，11/19 入 KEV）**：guardrail sandbox escape → 攻擊者把一般 Virtual Key 升級成 PROXY_ADMIN，竊取 proxy 內所有 LLM provider key（OpenAI / Anthropic / Bedrock / Vertex）並轉手 LLMjacing 牟利，同時部署挖礦。修版 **1.83.14+**，且**升級不等於修好，必須輪替金鑰**。
- **LiteLLM 1.107.0** 另有 PyPI / Docker **供應鏈投毒**（2026-10，無 CVE）：Wiz 觀察到外洩憑證在約 4.5 小時後即遭濫用。處置＝隔離、重建乾淨映像、輪替所有可觸及的憑證。
- **CVE-2026-90436（Apache Axis 1.x, 9.8, 11/18）**：已 EOL、**無官方修補**，只能隔離/替換。
- 11/18 同批加入 KEV：Synology DSM、REDCap（Vanderbilt 研究資料平台）、Apache Axis、SAP NetWeaver（code injection）。
- **11/23 到期**：Apache Roller、Cisco Expressway、SAP NetWeaver、VMware vCenter（間諜攻擊手法）。
- **CVE-2026-124194（Outlook 零日，已被利用）** — 微軟 11 月 Patch Tuesday 共 1,362 筆 CVE，此項需最優先。
- **CVE-2026-114938（Java4Shell）**：Java runtime Base64 decoder 記憶體破壞 → 未認證遠端執行。
- **CVE-2026-123158（OpenSSH 10.6p2）**：musl-based sshd 未開 PAM 且用密碼驗證時，超過 256 bytes 的密碼可登入 shadow 中含 `*` 的帳號（如 Alpine root）。
- **CVE-2026-122006（Rails Active Storage）**：未認證上傳寫入任意檔案，Disk storage 模式下可讀 `secret_key_base`；修版 8.0.5.2 / 8.1.4.1。
- WordPress Core **CVE-2026-119977**（11/4 入 KEV）、ASP.NET 遠端程式碼執行（Mandiant 11/18 公告）、Synology / Cisco / VMware 供應鏈間諜。

### A2. AI / Agent 供應鏈（本週最大主軸）
- 某大型 agent 市集約 **12% 的 skills 遭污染**；研究指出 **22% 被標記的 MCP server 含 prompt injection / tool poisoning**。
- 實例：某 skill 會**從遠端伺服器抓取指令、靜默附加進 agent 的全域設定檔**——注入會在每個未來 session 持續生效。
- 2026-01~02 單月就有 30+ 筆針對 MCP 元件的 CVE；OWASP MCP Top 10 已把這些類別正式化。
- 對策共識：**先縮小 agent 能做的事（最小權限、隔離、egress 管制、核准閘門），再談「讓模型認得攻擊」**。
- 本機對應：`openclaw security audit --deep` 報出 **17 個 skill frontmatter 損毀**（缺 description / BAD_INDENT）→ 這些 skill 對安全掃描器是**盲區**，正對應上述供應鏈風險。

### A3. 零日供應鏈與套件管理
- OpenClaw 現行版本線為 **2026.11.x**（extended-stable 2026.10.33、latest 2026.11.7、beta 2026.11.10-beta.2）。
- **OpenClaw 2026.11.x 起要求 Node 24.22.1+ 或 26.12.1+**，會拒絕使用 2026-10 Node.js 安全更新中被撤銷的簽章憑證鏈。本機 Node v24.22.3 ✅ 合規，但 **OpenClaw 本身仍是 2026.8.2，落後三個小版本**。

## B. 本機現況（實測，非推測）

| 項目 | 現況 |
|---|---|
| OpenClaw | 2026.8.2（npm latest = 2026.11.7） |
| Node | v24.22.3 ✅ |
| `openclaw security audit --deep` | **5 critical · 15 warn · 1 info** |
| Gateway bind | loopback:18789 ✅（auth mode = token） |
| 設定檔權限 | `~/.openclaw` 700、`openclaw.json` 600 ✅ |
| secrets/ 權限 | 全部 600 ✅，但留有 `openai-api-key.txt.bak-2026-06-04`（過期金鑰備份檔） |
| 設定檔內明文 | gateway 密碼、Control UI token、9+ 組 Discord bot token 皆明文落盤 |
| 防火牆 | **ufw 不存在**、nft 需 sudo 不可讀 → 目前無主機層防火牆 |
| SSH | sshd active；`PasswordAuthentication` / `PermitRootLogin` 在 sshd_config 未顯式設定（需 `sshd -T` 確認實際生效值） |
| 磁碟加密 | lsblk 未見 crypt/LUKS 裝置 → 推測未加密 |
| 對外網路 | LAN 192.168.50.1 / 192.168.1.108（無全域 IP，未見公網直連） |
| 備份 | workspace 每 08:00 自動 git snapshot（今日 3cf2bb8c），**未做還原演練** |
| skills | 64 個；17 個 frontmatter 損毀而無法稽核 |
| a2a-gateway plugin | 套件缺 compiled dist，會走 TypeScript source fallback ⚠️ |
| LiteLLM / docker | 本機未安裝 litellm，docker 無容器 → LLM proxy 供應鏈風險不適用（但金鑰存放觀念仍適用） |

### 5 筆 CRITICAL 的真實性判定
| Skill | 判定 |
|---|---|
| openclaw-docs:279 | `curl -fsSL … install.sh \| bash` → **文件敘述**，非實際執行 |
| skill-guard:34 | pipe-to-shell → 教學範例文字 |
| openclaw-security-scanner:48 | 「Block system prompt extraction」→ 描述性文字 |
| hung-yi-lee:651 | 「system prompt / tool use」→ 描述性文字 |
| ptcgp:212 | `execSync('curl -s …limitlesstcg…')` → **唯一有真實執行行為者**，把 skill 內資料送往外站 |

→ 4 筆為誤報（但噪音會淹沒真風險），1 筆為真實外連面，應優先處理。

### 15 筆 WARN 重點
1. `tools.exec.applyPatch.workspaceOnly=false` + 10 個 agent 皆 `sandbox=off` + `fs.workspaceOnly=false` → **最大風險面**：單一 prompt injection 即可在整台機器落地寫檔與執行。
2. `tools.exec.security=full` 對全部 10 個 agent 開啟（應改 ask/allowlist，保留一個 break-glass）。
3. `gateway.auth.password` 明文存在設定檔（應改用 `OPENCLAW_GATEWAY_PASSWORD` 環境變數 / SecretRef）。
4. `gateway.trustedProxies` 為空 → 若日後用 reverse proxy 曝露 Control UI，本地檢查可被偽造。
5. `gateway.nodes.commands.deny` 只做精確名稱比對，`hostname/ip/netstat/ss/curl/wget/ifconfig` 這些 deny 清單外的名稱實際無效。
6. 多使用者啟發式告警：10 個 Discord 帳號共用同一 gateway，OpenClaw 預設是「單一信任操作者」模型。

## C. 一日提升方案（2026-11-23 21:00 → 2026-11-24 21:00）

### P0（今晚 21:00–23:00，60–90 分鐘）
1. **升級 OpenClaw 2026.8.2 → 2026.11.7**（含安全修補 + Node 憑證鏈檢查）。先備份：`cp ~/.openclaw/openclaw.json ~/.openclaw/backups/openclaw.json.$(date +%F).bak`（既有備份目錄 `~/.openclaw/backups/2026-11-13-security/` 可參考）。升級後 `node -v` 需 ≥ 24.22.1（本機 24.22.3 已符合）。回滾：重裝舊版 + 還原設定檔。
2. **金鑰輪替與搬移**：把 `gateway.auth.password` 從設定檔搬到 `OPENCLAW_GATEWAY_PASSWORD` 環境變數；Discord bot token 改用 SecretRef 或至少分檔存放（現在 9+ 組 token 明文在 openclaw.json，權限 600 只能防同機其他帳號，防不了備份外流）。刪除 `~/.openclaw/secrets/openai-api-key.txt.bak-2026-06-04`（過期金鑰落地檔）。
3. **收斂 agent 權限**（對應本週 #1 趨勢）：至少把 rowlet 與其他非值班 agent 設為 `tools.exec.applyPatch.workspaceOnly=true`、`fs.workspaceOnly=true`、`tools.exec.mode=ask`；保留 1 個 break-glass agent 維持 full，並在 memory 記錄誰可解鎖。

### P1（明早 09:00–12:00，2–3 小時）
4. **修 17 個 skill frontmatter**（補 `description:`、修正 BAD_INDENT 縮排），恢復稽核覆蓋率——這是最便宜、也最對題的一步。
5. **處理 5 筆 CRITICAL**：把 ptcgp:212 的 `execSync(curl ...)` 改為受控 fetch + host allowlist；其餘 4 筆在 skill 內加註說明或改寫該行字面，降低後續稽核噪音。
6. **停用 a2a-gateway plugin**（`~/.openclaw/extensions/a2a-gateway` 缺 compiled dist，現行走 TS source fallback = 直接執行來源碼）直到上游發布編譯產物。
7. **檢查 MCP / skills 外連面**：清點已安裝 skill 與 MCP server 的網域白名單，確認沒有 skill 會讀寫 ~/.openclaw 全域設定（對應「skill 靜默改全域設定」案例）。

### P2（午後 13:00–17:00，3–4 小時）
8. **主機防火牆**：本機無 ufw。最小風險做法：`sudo apt install ufw` → 允許 SSH（確認實際 Port）→ 預設 deny incoming → 開啟 18789 僅限 loopback（gateway.bind 已 loopback，不需要對外開）。**動 firewall 前先確認自己的連線路徑（LAN / Tailscale / SSH）不被擋**。
9. **SSH 硬化**：以 `sudo sshd -T | grep -Ei 'passwordauth|permitroot|pubkey'` 取得生效值；若為 password=yes，關閉並改用 key；`PermitRootLogin no`。修改前保留可用的第二工作階段，避免把自己鎖在外面。
10. **磁碟加密**：lsblk 未見 LUKS，屬「推測未加密」。本機裝了 snap/多分割，現機無法原地加密；先做決策記錄（下次安裝時全碟 LUKS + home 加密），本輪不動。
11. **修正 nodes.commands.deny**：從 `gateway.nodes.commands.allow` 移除 deny 清單外的通用工具名（hostname/ip/netstat/ss/curl/wget/ifconfig），改用精確命令名（camera.list、location.get、device.info…）。
12. **trustedProxies**：若 Control UI 走 nginx/Tailscale 反向代理 → 設 `gateway.trustedProxies` 為 proxy IP；否則維持 loopback + 本機專用並記錄決策。

### 驗收標準（明晚 21:00 前）
- `openclaw security audit --deep` → **critical 5 → 0**、warn 15 → ≤5。
- `openclaw --version` = 2026.11.7（或更高），`node -v` ≥ 24.22.1。
- 17 個 skill 前置資料修好，稽核不再出現 "Skipping invalid skill"。
- **還原演練**：把 workspace git repo 複製到 /tmp 驗證 restore（目前只有 snapshot 從未還原過）。
- 建立每週 cron：`openclaw security audit --deep` + KEV 差異比對（建議週一 09:00）。

## D. 今日可立即套用的「一條指令版」檢查
```bash
openclaw security audit --deep | head -c 4000
npm view openclaw version            # 對照最新
lsblk -f | grep -i crypt || echo "no LUKS"
sudo sshd -T | grep -Ei 'passwordauth|permitrootlogin'
```

<!-- project: github.com/zhanzhanwu70-design/linderopenclaw-rowlet -->
