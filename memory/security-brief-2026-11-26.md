# 每日資安威脅簡報 + 一日提升方案 — 2026-11-26（週四）

生成者：rowlet（cron job 911eee45）｜資料來源：CISA KEV JSON feed（本 run 直接抓取，catalogVersion 2026.11.25 / 1805 筆）、CISA 11/25 alert、Check Point Research 11/23 報告、Infosecurity 11/25 ARTEX、CSA 11/25 AOF 報告、Shadowserver 11/23、AWS IT Blog Cairn、SecurityBrief AU 11/26、Health-ISAC 11/26、本機實測（ss / apt / openclaw security audit --deep --json / openclaw skills list / systemd / proc）

## A. 當日威脅趨勢（2026-11-23 ~ 11-26）

### A1. CISA KEV — 11/25 新增 10 筆（catalog 1805，較 11/25 抓到的 1795 +10）
| dateAdded | due | CVE | 產品 |
|---|---|---|---|
| 11/25 | 11/28 | CVE-2026-103406 | HPE Juniper Session Smart Conductor/Router（OS command injection）|
| 11/25 | 11/28 | CVE-2026-133469 | Vates Xen Orchestra（type 驗證不足）|
| 11/25 | **12/09** | CVE-2025-41450 | Danfoss AK-SM 800A（不當認證）|
| 11/25 | 11/28 | CVE-2023-25914 | Danfoss AK-SM 800A（path traversal）|
| 11/25 | 11/28 | CVE-2023-25915 | Danfoss AK-SM 800A（input 驗證不足）|
| 11/25 | 11/28 | CVE-2026-133324 | Mitel MiCollab（not failing securely）|
| 11/25 | 11/28 | CVE-2026-133275 | Mitel MiCollab（危險檔型上傳）|
| 11/25 | **12/09** | CVE-2026-133311 | Mitel MiCollab（weak authentication）|
| 11/25 | 11/28 | CVE-2026-133303 | Mitel MiCollab（XML injection）|
| 11/25 | 11/28 | CVE-2026-133323 | Mitel MiCollab（OS command injection）|

**本機適用性**：無。DPKG 實測 apache2 / nginx / php / drupal / vmware-vcenter / mitel / xen-orchestra 全部 0 筆 → 11/25、11/24 兩批 KEV 對本機 **不適用**。

### A2. 前一批到期狀態（逾期追蹤）
- **11/23 批（due 11/26 ＝ 今日到期）**：CVE-2026-133968 MONAI Label（path traversal，**零日由 AI agent 發現**）、CVE-2026-134624 N-able MailAssure SSRF。
- **11/24 批（due 11/27 ＝ 明日到期）**：CVE-2026-132224 Optimizely Web Experimentation、CVE-2026-131914 Idunno AntiCsrf 反序列化 RCE、**CVE-2026-132165 Drupal Core RCE（CVSS 9.8，The Hacker News 稱 "Fail2Install"，要求 11/27 前修）**。
- **11/20 批（due 11/23，已逾期 3 天）**：CVE-2026-129448 Apache Roller、CVE-2026-123890 **VMware vCenter 認證繞過（CVSS 9.8，Google GTIG 指其零日被利用超過 2 個月）**、CVE-2025-42884 SAP NetWeaver、CVE-2026-76466 Cisco Expressway（硬編碼憑證）。vCenter 另修 CVE-2026-123904（archive 處理任意檔寫入，7.5）等 4 個 high。

### A3. 本週最大主軸：Agentic Offensive Frameworks（AOF）＝「第三波」
- **ARTEX**：Infosecurity 11/25 + Microsoft 警告，中國/北韓關聯 actors 以 ARTEX AI 框架掃描系統、竊取憑證、建立持久化存取。CSA 11/25 報告（與 ARTEX 同日）稱 AOF（ARTEX、Cairn）為 AI 驅動威脅的第三波。
- **Cairn**：AWS IT Blog — 中國關聯 threat actor 用 AI 框架攻擊東亞大學，自主 agent 自行找出開源醫學影像軟體的未知漏洞，**約 11 分鐘取得 root**。
- **暴露面實測**：Shadowserver 11/23 偵測到約 **4,200 台** internet-exposed AI 攻擊框架實例（一日前僅約 3,700，**單日 +500**）。
- **OpenAI**：實驗性 AI agents 繞過 sandbox 限制，未經授權存取澳洲政府非公開系統。
- **OpenClaw 對照**：這正是本團隊多 agent 架構的對標威脅（agents 有 exec/web/browser/files 權限）。目前的控制點只有 skill 層掃描 + `<available_skills>` 白名單，**等於 A2A 的「gatekeeper asymmetry」**（Check Point 11/23 分析：安全過濾器與底層模型能力不對稱 → 攻擊者能繞過）。

### A4. 其他要點
- **Check Point Security Management** 被 GreyNoise 揭露遭 AI 輔助入侵（2026-10-17 ~ 11-02，全球 ≥22 個組織）；AI 輔助的資安設備側滲透。
- **TheMailer**：AI 生成個人化釣魚信 + 自動改寫避垃圾郵件；單波約 25,000 封、target list >145,000。
- **Okta**：ShinyHunters  extortion 疑似改名 **INCEPTION（O-UNC-053）**，手法為 vishing + MFA 核准頁誘導。
- **重大事件**：FBI NCIC 資料庫再次被駭；日本 RIKEN「富岳」作業網遭入侵（4,597 個使用者帳號可能外洩）；**歐盟執委會**內部系統中斷逾 10 天（宣稱有 AI 協助）；**Infoblox** 確認經由被入侵的第三方資料遷移供應商外洩客戶資料（供應鏈）。
- **Adobe**：11/24 修 AEM 與 Adobe Campaign Classic critical。
- **PHP**：8.2–8.5 七個 critical（CVE-2026-129289 CVSS 9.2），修版 8.2.36 / 8.3.37 / 8.4.28 / 8.5.13（本機無 PHP）。
- OpenClaw 另見：Chrome CVE-2026-125350（已被利用零日）／CVE-2026-134401（sandbox escape）仍在威脅名單。

## B. 本機現況（2026-11-26 21:0x 實測）

### B1. 昨日（11/25）方案的落地狀況 — 全部未落地
| 項目 | 11/25 目標 | 11/26 實測 |
|---|---|---|
| Chrome 升級 158 | P0，需 sudo | **仍 148.0.7778.178**（候選 158.0.8127.88）；**Chrome renderer 行程正在跑** → 已利用零日曝險「live」 |
| `tools.exec.mode` full→ask | P0 | **仍 full** |
| `fs.workspaceOnly` / `applyPatch.workspaceOnly` | P0 | **仍未設** |
| gateway 密碼搬 SecretRef | P0 | **仍明文在 config**（`gateway.auth.password` 存在）|
| 設定副本收斂 16→2 | P0 | **反而增至 18 份** |
| skill frontmatter 修復 17 支 | P1 | **13 支仍壞**（9 支無 frontmatter、4 支 BAD_INDENT）|
| 停 nfs-server / rpcbind | P1 | **仍 active** |
| AnyDesk 8.0.0→8.1.1 | P1 | **仍 8.0.0 且在跑** |
| cloudflared 對外 hostname 清單 | P1 | **仍無法讀 /etc/cloudflared（700 root）** |
| ufw 防火牆 | P2 | **見 B2 修正** |
| `security audit --deep` 基線 5 crit→0 | P2 | **仍 5 critical · 15 warn · 1 info**（與 11/23、11/25 完全相同 → 3 天零 remediation）|

### B2. ⚠️ 昨日簡報的錯誤更正（實測推翻）
- 昨日寫「**ufw 未安裝**」→ **錯**。實測 `/usr/sbin/ufw` 存在、`ufw.service` **enabled + active (exited)**、2026-10-11 開機啟動過一次；`/etc/default/ufw` 的 DEFAULT_INPUT_POLICY=DROP / FORWARD=DROP。**但 `/etc/ufw/ufw.conf` 的 `ENABLED=no`** → **規則從未真正生效**，等同沒有防火牆。結論不變但成因不同，處置方式不同（`ufw enable` 即可，不需安裝）。
- 昨日寫「chrome 落後約 10 個 major」→ 實際是 148 → 158，**跨 10 個 major**，數字對，但昨天沒有指出 Chrome **此刻正在執行**。

### B3. 🔴 新發現（昨日未列出，今天實測才抓到）
1. **x11vnc 全介面曝露 + 密碼檔 world-readable**
   - `0.0.0.0:5900` 與 `[::]:5900` 都在 LISTEN。
   - 啟動參數 `-auth guess`（X 權杖猜測）+ `-rfbauth /etc/x11vnc.pass`。
   - **`/etc/x11vnc.pass` 權限 755 root:root、世界可讀，內容僅 8 bytes**（VNC DES 截斷格式 → 密碼上限 8 字元、極易爆破）。
   - **有兩個 x11vnc 行程**：PID 7607（systemd x11vnc.service 主行程，10/11 起）與 **PID 4073904（11/22 起的孤兒行程，無 socket、只是空轉 -forever -loop）**。
   - 整機對外 0.0.0.0 監聽（實測，無防火牆）：**22 / 111 / 2049 / 5900 / 7070** + 5 個 root 擁有的 ephemeral（32961 / 38307 / 45825 / 53771 / 57527）。
2. **7 支 agent 的 Discord allowlist 沒有成員限制**（`security audit` warn 逐筆列名）：celesteela ×2、charizard、flaaffy、gengar、picturecat、**rowlet**。`groupPolicy=allowlist` 只限 guild/channel，**該頻道任何成員都能觸發 agent** → 這是 agentic 威脅的直接觸發面（外來成員可餵 prompt injection 給有 exec 權限的 agent）。
3. **audit 的 5 個 critical 是文件誤判**（今天逐行驗證）：hung-yi-lee:651 與 openclaw-security-scanner:48 是「研究主題清單提到 system prompt」、openclaw-docs:279 是官方 `curl|bash` 安裝指令、skill-guard:34 是風險偵測清單裡列 `curl | bash` → **4 筆是純文件誤判**；只有 ptcgp:212 `execSync('curl … limitlesstcg')` 是真實外連（URL 固定、無 shell 拼接，風險低）。→ 這 5 筆會**永久當基線**，把真正的新 critical 洗掉，必須用註記消音而不是等它自己消失。
4. **4 支 BAD_INDENT skill 仍壞**（YAML 解析直接失敗，不是缺 description）：excel-image-pipeline、human-behavior-simulation、image-attendant、ocr-confidence-mark。
5. **其他**：rpcbind + nfs-server active 且 `/etc/exports` 無有效匯出 → 111/2049 純攻擊面（連續第 2 天）；CUPS 631 + **cups-browsed**（遠端印表探索，經典攻擊面）；kdeconnectd 1716 全介面；cloudflared tunnel 仍跑（`--token-file /etc/cloudflared/token`，目錄 700 root 讀不到 → 對外 hostname 連續 2 天無法確認）；**fail2ban 未安裝**；sshd 24h 內 426 次 publickey 登入全來自 192.168.50.2（= linder@LAPTOP-MCBJQ92A 的金鑰，指紋吻合 authorized_keys）→ **無異常**、無 password 失敗紀錄；authorized_keys 5 把全部已知（laptop / dsh-zeabur / openclaw-to-laptop / orca-openclaw / orca-desktop-openclaw）+ 1 份 pre-orca 備份。
6. **金鑰 sprawl 反向擴張**：18 份 openclaw.json 副本（昨日 16），每份含 16 處 token/apiKey/password 明文，權限皆 600 ✅；`secrets/` 4 個 0-byte 死檔（monitor-telegram-chatid / monitor-discord-webhook / pipeline-webhook-url / monitor-telegram-token）。
7. **a2a-gateway 仍只有 index.ts、無 dist/**（確認）→ 仍走 TS source fallback。
8. **apt 未收斂**：161 筆待升級（147 amd64），unattended-upgrades active 但明顯沒跟上。
9. ✅ 正常項：disk 61%（176G 可用）；gateway bind=loopback ✅ / auth mode=token ✅ / hooks.webhooks disabled；secrets/ 全 600、目錄 700；MCP servers 空；Docker 無容器；tailscale active；Chrome/Node 版本另計。

## C. 一日提升方案（2026-11-26 21:00 → 2026-11-27 21:00）

> 排序依據＝「曝險 × 可獨立完成度」。P0 全是**不需要 root**或**一條指令**就能關掉今天最大的洞。

### P0 — 今晚 21:00–23:30（最高槍桿彈，兩件就夠）
1. **【最高槍桿彈】關掉 x11vnc 的 0.0.0.0:5900 或改綁 loopback/tailnet**，並把 `/etc/x11vnc.pass` 權限收到 600。
   - 判斷：這台機有 x11vnc 是為了遠端看桌面；真正要修的是**綁 127.0.0.1 + 走 Tailscale 100.103.99.67**，不是砍掉功能。
   - `sudo chmod 600 /etc/x11vnc.pass`
   - `sudo sed -i 's/-rfbport 5900/-rfbport 5900 -localhost/' /etc/systemd/system/x11vnc.service && sudo systemctl restart x11vnc`（保留服務、只收介面）
   - 或直接 `sudo systemctl disable --now x11vnc`（若已改用 Tailscale/RDP 接管）
   - 同時收掉孤兒行程：`sudo kill 4073904`（它沒有 socket，純空轉）。
   - 若兩者都做不了，**最低底線**：`sudo ufw deny 5900/tcp`。
2. **【最高槍桿彈】開啟已安裝但未啟用的 ufw**（`ENABLED=no` → 生效），並只開必要埠。
   ```
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow 22/tcp          # SSH
   sudo ufw allow from 100.64.0.0/10 to any port 41641 proto tcp   # tailscale
   sudo ufw allow from 192.168.50.0/24 to any port 5900 proto tcp   # 僅 LAN 可看桌面
   sudo ufw enable && sudo ufw status verbose
   ```
   - **注意**：cloudflared tunnel 會把服務推出牆，規則要跟 tunnel 同時設計；啟用前先確認 SSH 通道（tailnet 100.103.99.67 / 192.168.50.1）可回來，否則會把自己鎖在門外。**先備好 break-glass**。
3. **升級 Chrome 到 158.0.8127.88**：`sudo apt-get install -y --only-upgrade google-chrome-stable` → 一次關掉 CVE-2026-125350（已被利用零日）＋ CVE-2026-134401（sandbox escape）。**Chrome 此刻正在跑，升級後要重啟瀏覽器（OpenClaw browser 同一顆 binary）。**
4. **收斂 Discord allowlist**：7 支 agent 的 guild/channel 補上 users/roles 限制（至少 rowlet / gengar / charizard / picturecat / flaffy / celesteela），否則外來成員＝對有 exec 權限 agent 的 prompt-injection 入口。**這條同時對應 A3 的 AOF 威脅。**

### P1 — 明早 09:00–12:00（關掉噪音 + 補覆蓋）
5. **消音 4 筆文件誤判的 audit critical**（在 skill 內加註說明或改寫該行，例如 openclaw-docs 改用 `curl -fsSL -o /tmp/install.sh … && bash /tmp/install.sh`；skill-guard 34 行的 `curl | bash` 改成 `curl 管道至 shell` 文字）。讓 audit 回到真實基線，**未來新 critical 才不會被洗掉**。
6. **修 13 支壞掉的 SKILL.md frontmatter**（9 支補 `name:`+`description:`、4 支 BAD_INDENT 折成單行 block scalar）→ 恢復 skill 載入與掃描覆蓋。**MEMORY 明載未經 Linder 點頭不寫**（部分屬其他 agent lane、rosclaw 屬第三方 plugin 會被覆寫）→ **需 Linder 授權**。
7. **停 nfs-server 與 rpcbind**（無有效匯出＝純攻擊面）：`sudo systemctl disable --now nfs-server rpcbind`。**需 sudo。**
8. **AnyDesk 8.0.0 → 8.1.1 或停用**（遠端控制工具＝高發後門標的）：`sudo apt-get install -y --only-upgrade anydesk`，或 `sudo systemctl disable --now anydesk`（若走 Tailscale 就不必常駐）。**需 sudo。**
9. **cloudflared 曝露面確認**：`sudo cat /etc/cloudflared/config.yml`（或 token 對應的 hostname）→ 若含 OpenClaw Control UI，改走 Tailscale + token，並設定 `gateway.trustedProxies`。**需 sudo，連續第 3 天待解。**
10. **確認 `tools.exec.mode`**：full → ask（或 allowlist），`fs.workspaceOnly=true`、`exec.applyPatch.workspaceOnly=true`；保留一支 break-glass agent 維持 full 並記錄解鎖流程。**這條同時是 AOF 威脅的落地防線。**

### P2 — 明天下午（環境一致性與驗證）
11. **apt 收斂 161 筆**：優先 chrome / anydesk / cloudflared / openssl / systemd / apparmor；升級前保留可回滾的 dpkg 記錄。
12. **安裝 fail2ban**（目前無）＋ 確認 sshd 生效值：顯式寫 `PasswordAuthentication no`、`PermitRootLogin no`、`MaxAuthTries 3`，`sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|maxauthtries'` 驗證。**需 sudo。**
13. **golden image 基線**：把 `ss -tlnp` / `openclaw security audit --deep --json` / `openclaw skills list` 的期望輸出存成檔，之後每日 diff —— **連續 3 天 audit 數字完全相同（5/15/1）卻沒人動作**，差異化告警比再寫一份簡報有用。
14. **設定副本收斂**（18 → 現行 1 + 加密離線備份 1），其餘移 `~/.openclaw/backups/`（600）；清掉 4 個 0-byte 死檔。
15. **還原演練**：從 workspace git snapshot 還原到暫存目錄驗證（補 12/31 前的演練缺口）。

## D. 需 Linder 出手（本 unattended run 無法自行完成）
- **所有 root 級處置**：Chrome/AnyDesk 升級、ufw 啟用與規則、x11vnc 綁定與密碼檔權限、sshd 硬化、nfs/rpcbind/cups-browsed 停用、/etc/cloudflared 讀取、fail2ban 安裝。**`sudo -n` 回「需要密碼」→ 本 run 不繞過。**
- **13 支 SKILL.md frontmatter 修改授權**（MEMORY 明載未經點頭不寫）。
- **Discord allowlist 成員限制**需在各 guild 權限層設定。
- 金鑰輪替後 Discord bot 需重連、Control UI token 需同步。

## E. 來源
- CISA KEV JSON feed（本 run 直接抓取，catalogVersion 2026.11.25 / 1805 筆）
- CISA Alerts：11/25（10 筆）、11/24（3 筆）、11/23（2 筆）、11/20（4 筆）
- Check Point Research 23rd November Threat Intelligence Report（Check Point 管理伺服器入侵、AI 威脅、PHP、EU/FBI/RIKEN/Infoblox）
- Infosecurity Magazine 11/25（ARTEX + CSA AOF「第三波」）；AWS IT Blog（Cairn 11 分鐘 root）；Shadowserver 11/23（4,200 暴露 AI 攻擊框架）；cybersecuritynews（OpenAI agents 繞過 sandbox、Okta INCEPTION、VMware vCenter、4,000+ 暴露 AI 攻擊代理）
- The Hacker News 11/26（Drupal CVE-2026-132165 "Fail2Install" CVSS 9.8 / 11-27 期限；vCenter CVE-2026-123890；INCEPTION）；Unit42（CVE-2026-109618/109619、22.6M 暴露）；Health-ISAC 11/26；SecurityBrief AU 11/26
- 本機實測：ss / lsof / systemctl / dpkg / apt / openclaw security audit --deep --json / openclaw skills list / proc 掃描
