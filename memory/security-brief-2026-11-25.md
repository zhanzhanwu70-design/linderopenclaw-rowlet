# 每日資安威脅簡報 + 一日提升方案 — 2026-11-25（週三）

生成者：rowlet（cron job 911eee45）｜資料來源：CISA KEV JSON feed（實抓）、CISA 11/24 alert、Check Point Research 11/23 報告、OX Security「Plug and Pray」11/23、ThreatDefence、Microsoft/Google 官方 advisory、本機實測（openclaw security audit / ss / apt / config）

## A. 當日威脅趨勢（2026-11-18 ~ 11-25）

### A1. CISA KEV（本週 6 批）— 實抓 KEV JSON（catalog 共 1795 筆）
- **11/24（3 筆，due 11/27）**：CVE-2026-132224 Optimizely Web Experimentation（外部可控關鍵狀態）、CVE-2026-131914 Idunno AntiCsrf 反序列化 RCE（ASP.NET）、CVE-2026-132165 Drupal Core RCE。
- **11/23（2 筆，due 11/26 — BOD 26-04 三天期限）**：CVE-2026-133968 MONAI Label（路徑穿越，**零日由 AI agent 發現**）、CVE-2026-134624 N-able MailAssure（SSRF）。→ **這批明天 11/26 到期。**
- **11/20（4 筆，due 11/23 — 已逾期 2 天）**：CVE-2026-129448 Apache Roller（反序列化）、CVE-2026-123890 VMware vCenter（認證繞過）、CVE-2025-42884 SAP NetWeaver、CVE-2026-76466 Cisco Expressway（**硬編碼憑證**，俄方被指利用）。
- **11/18（4 筆）**：CVE-2024-10441 Synology DSM、CVE-2026-40217 BerriAI LiteLLM（due 12/02）、CVE-2026-90817 REDCap、CVE-2026-90436 Apache Axis（後兩者 due 11/21 已逾期）。
- **11/17**：CVE-2026-115731 Perforce Puppet Enterprise（due 12/01）。
- 上週統計：4,737 筆 CVE 發佈、378 critical、10 筆入 KEV、60 筆出現公開 exploit。

### A2. 瀏覽器：Chrome 兩個要命的洞
- **CVE-2026-125350**（XSLT use-after-free，**已被利用**，CISA KEV，期限 11/24 **已過**）：修版 157.0.8103.50+。2026 年 Chrome 被利用零日已達 **8 個＝2025 全年**。
- **CVE-2026-134401**（Improper Input Validation → **sandbox escape**，修版 158.0.8127.88，GitHub 已有 PoC；截至 11/24 尚無確認利用）。
- 佐證：微軟 11 月 PT 唯一被利用的是 Outlook NTLM hash 外洩；1,093~1,362 筆 MS CVE、63 critical。

### A3. AI / Agent 供應鏈（本週最大主軸，OX Security 11/23）
- **22% 被標記的 MCP server 含 prompt injection / tool poisoning**；**83% 的已部署程式碼無法獨立驗證**；**82% 確認惡意的元件在第一版就是惡意的**。
- 對應本機：17 支 SKILL.md 前置 metadata 損毀 → 對安全掃描器與 skill 載入器是**盲區**（功能上「不存在」，非只是噪音）。
- TheMailer：AI 生成個人化釣魚信 + 自動改寫避過垃圾郵件filter；單波約 25,000 封、target list >145,000 收件人。
- Claude Code CVE-2026-88968（macOS Edit tool symlink race，已修 2.1.251）；fastapi-code-generator 三個 OpenAPI→Python RCE（CVE-2026-63469/70/71，11/9）。
- LiteLLM 供應鏈投毒（PyPI/Docker，無 CVE）：外洩憑證約 **4.5 小時內**即遭濫用。

### A4. 其他本週要點
- Java4Shell CVE-2026-114938：**僅 Java 17/21/25/27 受影響**（x86-64 + AVX-512 VBMI），**Java 8/11 不含該程式碼**；11/17 修。
- PHP 8.2–8.5 七個 critical（CVE-2026-129289 CVSS 9.2）；NGINX RCE CVE-2026-123007 / 123633。
- 供應鏈／實體：冷鏈與冷藏監控系統被入侵（CISA/FBI 11/5）；Black Friday「GTA VI」相關惡意內容已偵測 27,000+ 次攻擊。

## B. 本機現況（實測，非推測，2026-11-25 21:0x）

- **OpenClaw 2026.8.2**（npm latest 2026.11.10 / extended-stable 2026.10.33）。`openclaw update --dry-run` 可用；2026.11.10 的 engines = `>=24.16.0 <25 || >=26.1.0`，本機 Node **v24.22.3 合規**。安裝根在 node v24.22.1 的 lib/node_modules，agent-cli shim 用 v24.22.3 的 node 跑它。
- **Chrome 148.0.7778.178（2026-05 的二進位，落後約 10 個 major）**，apt 候選 **158.0.8127.88** 已可升 → 升級同時關掉 CVE-2026-125350（被利用）與 CVE-2026-134401。**OpenClaw 自己的 browser profile（Last Version 148.0.7778.178）也吃同一顆 binary**，所以自動化瀏覽器同樣暴露在已被利用的零日下。
- `openclaw security audit --deep`：**5 critical · 15 warn · 1 info**（與 11/23 完全相同 → 兩天內無任何 remediation 落地）。設定實測：gateway.bind=loopback ✅、auth mode=token ✅ 但 **`gateway.auth.password` 仍明文在設定檔**、`trustedProxies` 空、`tools.exec.mode=full`、`exec.applyPatch.workspaceOnly=false`、`fs.workspaceOnly` 未設、`tools.elevated` enabled、hooks.webhooks disabled。
- **金鑰 sprawl**：`~/.openclaw/` 下 **16 份 openclaw.json 副本**（含 .bak/.bak.1~4/.last-good/.pre-*，合計 363 KB），每份都含明文 Discord token 與 gateway 密碼；`secrets/` 另有 `openai-api-key.txt.bak-2026-06-04T01-06-33-280Z`（**與現行金鑰內容不同＝另一組舊金鑰**）與 `openclaw-bridge.env.pre-token-sync-20260908T173307Z`，另有 3 個 0 byte 的死 webhook 檔。secrets/ 權限皆 600 ✅。
- **無主機防火牆**：ufw 未安裝、iptables/nft 需 root。**`sudo -n` 失敗（要密碼）→ 本 unattended run 無法執行任何 root 級處置**，防火牆/SSH/sshd 硬化/rpcbind 關閉全部要 Linder 親自跑。
- **sshd active，0.0.0.0:22**；sshd_config 未顯式設定 PasswordAuthentication / PermitRootLogin（Ubuntu 22.04 預設 = 密碼允許、root 禁密碼登入；`sshd -T` 需 root，**生效值未驗證**）。
- **rpcbind + nfs-server active，且 /etc/exports 無任何有效匯出** → 111（NFS 放大器）與 2049 是純粹的攻擊面。
- **cloudflared tunnel 在跑**（`--token-file /etc/cloudflared/token`），但 /etc/cloudflared 權限不足讀不到 → **無法確認哪些 hostname 對外公開**（若含 Control UI 就是公網曝露）。
- **AnyDesk 8.0.0** 自 10/11 持續運行、listen 0.0.0.0:7070（AnyDesk 自身 listener）；apt 已有 8.1.1。遠端控制工具 = 歷史高發 RCE/後門類標的。
- tailscale active；docker 無容器；本機**未**安裝 PHP / nginx / LiteLLM / litellm python 套件 → A4 的 PHP/NGINX/LiteLLM 條目對本機**不適用**。
- OpenJDK 11.0.33.1 → **不受 Java4Shell 影響**（僅 17/21/25/27）。
- a2a-gateway plugin 仍**只有 index.ts、無 dist/**（走 TS source fallback）；ptcgp SKILL.md:212 `execSync(curl …limitlesstcg…)` 仍在（唯一真實外連面）。
- apt 可升級 162 個套件；chrome 158.0.8127.88-1 / anydesk 8.1.1 / cloudflared 2026.11.2 可用。
- 磁碟 61% 使用（176G 可用）✅；workspace 每日 08:00 git snapshot 正常（今日 a51729d4），**仍未做還原演練**。

## C. 一日提升方案（2026-11-25 21:00 → 2026-11-26 21:00）

### P0 — 今晚 21:00–23:00（不需 root，可獨立完成）
1. **升級 Chrome 到 158.0.8127.88**：`sudo apt-get install -y --only-upgrade google-chrome-stable` → 一次關掉 CVE-2026-125350（已被利用零日）＋ CVE-2026-134401（sandbox escape）。**需 sudo 密碼 → Linder 執行**；升級後需重啟 Chrome（OpenClaw browser 亦同）。
2. **輪替並清理金鑰 sprawl**（對應 A3／本週 #1 威脅）：
   - 從 `gateway.auth.password` 明文搬到 `OPENCLAW_GATEWAY_PASSWORD` 環境變數 / SecretRef；Discord bot token 改 SecretRef。
   - 刪除 `secrets/openai-api-key.txt.bak-2026-06-04T01-06-33-280Z`（內容與現行金鑰不同的舊金鑰落地檔）與 `openclaw-bridge.env.pre-token-sync-20260908T173307Z`；用 `trash` 不用 `rm`。
   - 把 16 份 openclaw.json 副本收斂成「現行 1 份 + 1 份加密/離線備份」，其餘移到 `~/.openclaw/backups/`（同權限 600）。
3. **收斂 agent 權限**（對應 OX Security 22%／本週最大主軸）：`tools.exec.mode` 由 full → ask 或 allowlist；`exec.applyPatch.workspaceOnly=true`、`fs.workspaceOnly=true`；保留 1 個 break-glass agent 維持 full 並在 memory 記錄解鎖流程。
4. **停用 a2a-gateway plugin**（無 compiled dist，現行走 TS source fallback＝直接執行來源碼）直到上游發布編譯產物；停用前先確認誰在依賴。

### P1 — 明早 09:00–12:00（2–3 小時）
5. **修 17 支 SKILL.md 前置 metadata**（13 支缺 `description:`＋4 支 BAD_INDENT）→ 恢復稽核覆蓋率與 skill 載入。**注意：MEMORY 記載「未經 Linder 點頭不寫」**（部分屬其他 agent lane、rosclaw 4 支屬第三方 plugin 會被更新覆寫）→ **需 Linder 授權**。
6. **改寫 ptcgp SKILL.md:212** 的 `execSync('curl -s …')` 為受控 fetch + host allowlist（唯一真實外連面）；其餘 4 筆 critical 屬誤判，加註說明即可。
7. **關掉不必要對外服務**：停 nfs-server 與 rpcbind（無匯出＝純浪費）；AnyDesk 若非必要則停用並升到 8.1.1，否則檢查 unattended access 設定。**皆需 sudo → Linder。**
8. **cloudflared 曝露面確認**：讀 /etc/cloudflared 設定，列出對外 hostname；若含 OpenClaw Control UI，改走 Tailscale + 密碼/token，並設定 `gateway.trustedProxies`。
9. **apt 一致性更新**（162 筆）：優先 chrome / anydesk / cloudflared / openssl / systemd / apparmor；升級前保留可回滾的 dpkg 記錄。

### P2 — 明天下午（加固與驗證）
10. **主機防火牆**：安裝 ufw，default deny incoming、allow 22/41641/loopback，允許 tailnet；本機無全域 IP 但 cloudflared 會把服務推出牆 → 規則要跟 tunnel 一起設計。**需 sudo。**
11. **SSH 硬化**：顯式寫 `PasswordAuthentication no`（若無替代金鑰通道則先開 key-only 保留 break-glass）、`PermitRootLogin no`、`MaxAuthTries 3`；`sshd -T` 驗證生效值。**需 sudo。**
12. **還原演練**：從 workspace git snapshot（a51729d4）還原到暫存目錄驗證，補上 12/31 前的備份演練缺口。
13. **稽核基線重跑**：`openclaw security audit --deep` 目標 5 critical → 0、15 warn → ≤8；並把「金鑰 sprawl＝16 份設定檔副本」列為每日巡檢項目。

## D. 授權與阻擋（需 Linder 出手，本 run 無法自行完成）
- 所有 root 級處置：Chrome 升級、ufw/iptables、sshd 設定、rpcbind/NFS 停用、AnyDesk 停用、/etc/cloudflared 讀取。**`sudo -n` 回「需要密碼」→ unattended run 不會繞過。**
- 17 支 SKILL.md 前置 metadata 的修改授權（MEMORY 明載未經點頭不寫）。
- 金鑰輪替後 Discord bot 需重連、Control UI token 需同步。

## E. 來源
- CISA KEV JSON feed（本 run 直接抓取）+ CISA 11/24 alert（3 筆新增）
- Check Point Research 23rd November Threat Intelligence Report
- OX Security「Plug and Pray」11/23；Threatlinqs TL-2026-6776
- ThreatDefence CVE-2026-125350 / CVE-2026-114938；UpTyCs CVE-2026-134401；ChromeGeek 158 stable note
- cyber-defence.io this-week-in-CVEs；senserva Patch Tuesday 11/2026
