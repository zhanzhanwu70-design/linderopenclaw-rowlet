# 每日資安建議 — 2026-10-26（一日提升方案）

> 執行：cron 911eee45（無人值守）。所有本機檢查皆為唯讀，**未執行任何狀態變更**（安裝/升級/改 config/重啟 gateway 需有 sudo 或核准的人員執行）。

---

## 一、當日威脅趨勢（研究來源）

- CISA KEV JSON（catalog `2026.10.23`，released 2026-10-23T19:30Z，總計 1,756 筆）
- The Hacker News（2026-10-26 首頁清單）
- Imperva / Aikido / Brandefense（Node2Shell）
- OX Security / ZerodayObserver（Pillow）
- SOCRadar（INC / The Gentlemen「Phantom」曝露基礎設施，10/20 發布、10/23 更新）
- Cyware / 微軟 / Help Net Security 等每日簡報

### 1. Node2Shell（CVE-2026-111497，CVSS 9.2）— 本機直接命中
OpenAI 發現的 Node.js Brotli decoder 記憶體覆寫 RCE。2026-10-21 釋出修補版 **22.23.4 / 24.22.1 / 26.12.1**，10/22 公開 PoC 流出，Imperva 在**未修改的 Node 24.22.0 Linux arm64 官方映像**上以特製 Brotli 資料（HTTP 回應或 request body）示範任意程式碼執行。上游 Brotli 亦修（1.2.1 / 1.1.1 / 1.0.10），Bun、Python 同受影響。

### 2. Pillow 三個關鍵 CVE（CVSS 9.2，10/19 揭露）
- CVE-2026-112900 — EPS + Ghostscript 參數注入 → 任意指令執行
- CVE-2026-112393 / CVE-2026-112403 — TIFF / JPEG / FlashPix heap overflow
修補版為 **Pillow 13.0.0**；所有處理不可信圖片的 Python 服務皆受影響（本機的 OCR 圖片流程即在此路徑）。

### 3. KEV 本週新增（10/20、10/23）
| dateAdded | CVE | 產品 | 備註 |
|---|---|---|---|
| 10/23 | CVE-2026-114625 | Arista VeloCloud Orchestrator | SQL Injection，CVSS 9.9，**FCEB 到期 10/26（今天）** |
| 10/23 | CVE-2026-110447 | Collabora Online CODE Server | OS Command Injection，**FCEB 到期 10/26（今天）** |
| 10/20 | CVE-2026-106931 | EG Secure SiteGuard | OS Command Injection |
| 10/20 | CVE-2026-96652 / 96654 / 96655 / 96656 | Plex Media Server | SSRF ×2、URI scheme improper neutralization、檔名路徑控制 |
| 10/20 | CVE-2026-110936 | Siemens Software Center | Uncontrolled Search Path Element（ClickFix 惡意軟體鏈） |

> 核對昨日修正：114625 = Arista、110447 = Collabora，**今日 KEV JSON 再次確認，昨日更正無誤**。10 月新增的 KEV 中 `knownRansomwareCampaignUse=Known` 為 0 筆；PAN-OS CVE-2026-0257（5/29 列入）仍標記為已知遭勒索利用。

### 4. AI 代理＝攻擊執行面（延續 10/25 主軸，今日升溫）
- OpenAI 官方示範 AI agent 達成 **VM escape 與跨 sandbox 傳輸 secret**。
- 駭客以自主 AI agent 攻破 **1,200+ 網站**；惡意檔放在 Downloads 夾誘導 AI coding agent「自動安裝」。
- SOCRadar「Phantom」框架：INC / The Gentlemen 勒索 affiliate 以 AI agent 大規模利用 edge/remote-access（FortiClient EMS CVE-2026-35616、SimpleHelp、cPanel、Ivanti/Citrix/SonicWall/OpenVPN）；FortiClient EMS 側記錄 2,236 個目標、108 個管理員帳號被建立、4,140 台受管端點被觸及；46 個 INC encryptor 為 6 名受害者打包、10/1 部署。

### 5. 供應鏈與憑證外洩
- OpenCode Console 外洩：可能含 OpenAI / Anthropic / Google API key。
- LiteLLM master key 外洩 → GitHub token 被竊 → 發布流水線遭劫持。
- Gheist：以被竊 GitHub token 從 Actions log 撈 repo secret。
- M365 token replay 規模更新為 **97 個帳號 / 79 個組織**（昨日僅列 79 組織）。

### 6. 其他值得記錄
Tailscale SSH「Tailworm」橫向 root 提權（**尚無 CVE、無修補版**）／GitLab CVSS 10.0 unauth RCE（Ruby regex 引擎 bug）／PHP2Shell 兩支未修補 PHP RCE ＋第三支／Wasmtime CVE-2026-115889、115893 sandbox escape（CVSS 9.9）／Linux KSMBD 兩支 CVSS 9.0／Go 緊急封鎖 8 個 CA key ＋eMudhra 8 個 CA key 被竄／BlackX UEFI bootkit 繞過 Secure Boot（Windows 節點）／FortiSIEM 公開 PoC unauth RCE／Atlassian 10 月公告 176 筆、14 支 critical。

---

## 二、本機唯讀快照（21:03–21:10）

**基本**：Ubuntu 22.04.5 LTS；uptime 2 週 1 天；根目錄 53%（212G 可用）；`~/.openclaw` 29G；docker0 存在；**無 passwordless sudo**（下列多數動作需管理員執行）。

**防火牆**：ufw / nft / iptables / firewalld **全缺** → 連續第 3 天未處理。

**對外 0.0.0.0 監聽**：
- `22` sshd、`111` rpcbind、`2049` NFS（nfsd 執行中，但 `/etc/exports` 無任何實際匯出）、`5900` x11vnc（root 執行，`-rfbauth /etc/x11vnc.pass`）、`7070`、`57527`、`32961`、`38307`、`45825`、`53771`
- `*:1716` kdeconnectd；AnyDesk 以 root 跑且 `systemctl is-enabled` = enabled
- gateway 綁 `127.0.0.1:18789`（良好，無對外暴露）

**元件版本**：
- Node **v24.19.0（預設，受 CVE-2026-111497 影響）**，另殘留 v24.14.1、v20.19.6；nodejs.org 已提供 v24.22.1、v22.23.4
- Pillow **12.0.0（受三支 critical 影響）**；PyPI 目前最高 12.3.0，13.0.0 尚未發布
- OpenClaw **2026.8.2**，npm latest **2026.10.7**（落後 9 版）
- Tailscale 1.102.4，`RunSSH=false`、無 serve → Tailworm 目前不適用；mesh 內 5+ 節點
- opencode 1.17.11（`~/.config/opencode`、`~/.opencode`）

**openclaw security audit 重點**：`tools.elevated` enabled；`exec security=full`（9 個 agent）；`applyPatch.workspaceOnly=false`；gateway auth password 存於 config；plugin index 含未釘版 npm spec（`@openclaw/codex`、`@openclaw/llama-cpp-provider`）；Discord allowlist 頻道 broad_members；browser control enabled。

**憑證與金鑰**：`~/.openclaw/secrets/` 多數 600，但 **`site-auth.env` 仍 644（連續第 3 天）**；`openai-api-key.txt.bak-2026-06-04` 仍在；另有 `~/.local/share/opencode/auth.json`、`~/.codex/auth.json`、`github-token.txt`。本 repo 無 `.github/workflows`（Gheist Actions log 竊取面目前無）。

**其他**：apt 待更新 153 套（openssl/openssh/linux-image 類 0 套）；unattended-upgrades、apparmor 皆 active；`/etc/x11vnc.pass` 權限 **755、僅 8 bytes**（全機可讀且密碼過短）；tailscale 上 2 台 Windows 節點離線（f4-000733-nb、laptop-mcbjq92a）。

---

## 三、一天資安提升方案

### P0 — 今天必須收斂（曝險面與已知可利用漏洞）

**P0-1｜Node.js 升級至修補版（CVE-2026-111497）**
```bash
# 預估 10 分鐘；需重啟 OpenClaw gateway 才生效（由人執行）
source ~/.nvm/nvm.sh
nvm install 24.22.1 && nvm alias default 24.22.1
nvm install 22.23.4            # 舊專案用
npm i -g openclaw@2026.10.7    # 目前 2026.8.2，落後 9 版
# 驗收
node -v                         # 期望 v24.22.1
npm ls -g --depth=0 | grep openclaw   # 期望 2026.10.7
ss -tlnp | grep 18789           # gateway 重新綁 127.0.0.1
```
驗收標準：`node -v` = v24.22.1；`openclaw --version` = 2026.10.7；`openclaw doctor` 無紅燈。回退：`nvm alias default 24.19.0`。

**P0-2｜Pillow 過渡期緩解（CVE-2026-112900 / 112393 / 112403）**
13.0.0 未上 PyPI（index 最高 12.3.0），因此現在做「降風險」而非等版：
```bash
pip3 install --user --upgrade "pillow>=12.3.0"    # 先吃進已發布的修正
# 暫時停用 EPS/Ghostscript 路徑（EPS 是 CVE-2026-112900 觸發點）
python3 - <<'PY'
import os
os.environ.setdefault("PIL_DISABLE_GHOSTSCRIPT", "1")
PY
# 設定擋掉 EPS 開啟的最小 patch（套用到 OCR / photo-archive / pokemon-card-ocr 入口）
```
驗收標準：`python3 -c "import PIL; print(PIL.__version__)"` ≥ 12.3.0；OCR 流程加入「拒絕 .eps/.ps 輸入 + 限制 Ghostscript」測試。追蹤：Pillow 13.0.0 一發布即升級。

**P0-3｜對外服務收斂**
```bash
# 1) x11vnc：綁 loopback 或停用（遠端需求改走 Tailscale）
sed -i 's/-rfbport 5900/-rfbport 5900 -listen 127.0.0.1/' /etc/x11vnc.service   # 或 systemctl disable --now x11vnc
# 2) 密碼檔權限 + 長度（現在 755 / 8 bytes）
chmod 600 /etc/x11vnc.pass
# 3) NFS 與 rpcbind：/etc/exports 無實際匯出，直接收
systemctl disable --now nfs-server rpcbind
# 4) AnyDesk：改由 Tailscale 取代，或確認為必要且設密碼
# 5) 防線本體
apt install -y ufw
ufw default deny incoming && ufw default allow outgoing
ufw allow 22/tcp && ufw allow 1716/udp   # 必要時 5900/tcp（僅限 Tailscale 網段）
ufw enable && ufw status verbose
```
驗收標準：`ss -tulpn | grep -vE '127\.0\.0\.1|::1|\[::1\]'` 不再出現 2049 / 111 / 5900 / 7070；`ufw status` 為 active + deny incoming。

**P0-4｜金鑰檔權限與金鑰輪換**
```bash
chmod 600 ~/.openclaw/secrets/site-auth.env            # 現在是 644
shred -u ~/.openclaw/secrets/openai-api-key.txt.bak-2026-06-04  # 或 trash
```
驗收標準：`ls -l ~/.openclaw/secrets/` 全部 `-rw-------`；`find ~/.openclaw/secrets -type f ! -perm 600` 回傳空。

### P1 — 今天內完成（供應鏈、憑證、權限面）

**P1-1｜OpenCode / LiteLLM 供應鏈應變**
```bash
# OpenCode 升級至 >= 1.18.33（1.18.33 悄悄修補 MCP OAuth RCE，掃描器不報）
npm -g ls opencode-ai || ls ~/.opencode/node_modules | head
# 先清掉舊版殘留
rm -rf ~/.config/opencode/node_modules ~/.opencode/node_modules
# 重新安裝最新並驗證
~/.opencode/bin/opencode --version
# 輪替被 OpenCode Console 波及的 provider key（OpenAI / Anthropic / Google）
# 輪替 GitHub token（本次 GitHub token 已被 LiteLLM / Gheist 生態視為外洩）
```
驗收標準：`opencode --version` ≥ 1.18.33；`~/.local/share/opencode/auth.json` 權限 600；舊 token 經 provider 後台撤銷（撤銷紀錄留存）。

**P1-2｜GitHub Actions / 發布流水線**
本 repo 目前無 `.github/workflows`，但 9 個 agent 共用 GitHub token。建議：建立最小權限 token（唯讀 → 分開寫入）、開啟 2FA、檢查 `~/.openclaw/secrets/github-token.txt` 對應的 scope。

**P1-3｜OpenClaw 設定收斂（依 audit 逐項）**
```bash
# 依序處理（config 變更建議由 openclaw 系統專家確認後執行）
openclaw security audit
# 目標狀態：
#   tools.elevated            → false（除非有明確用途）
#   tools.exec.applyPatch.workspaceOnly → true
#   gateway.auth.mode        → token（密碼留 config 改由環境變數注入）
#   plugin index             → 釘版（codex / llama-cpp 不再使用 latest）
#   Discord allowlist        → 指定 users/roles，收斂 broad_members
#   browser control          → 保留但限制可讀 profile
```
驗收標準：`openclaw security audit` 的 warn 數量下降、Discord 頻道不再出現 broad_members。

### P2 — 本週內（信任鏈、裝置端、偵測）

1. **CA / 信任鏈**：Go 封鎖 8 個 CA key、eMudhra 8 個 CA key 被竄 → 更新 `ca-certificates`、清 `ca-certificates-java`、檢查 Node/Python 的 `certifi`（現為 2026.7.22）。
2. **Windows 節點**：BlackX UEFI bootkit 繞過 Secure Boot（需 revocation 清單）→ 對 f4-000733-nb、laptop-mcbjq92a 等離線 Windows 裝置排入 Secure Boot revocation 與韌體更新。
3. **瀏覽器沙箱**：OpenAI 示範 AI agent VM escape + 跨 sandbox 傳輸 secret → 檢視 OpenClaw 沙箱設定（sandbox: inherit/require）、限制 exec 對敏感路徑的寫入、確認 Chrome `--remote-debugging-port=18800` 僅綁 loopback（目前已是 127.0.0.1，合規）。
4. **偵測**：生成式 AI 讓行為特徵失效（Proofpoint）→ 部署以「身分 + 行為序列」而非單一告警為核心的偵測；建議在 SIEM 優先監看 mailbox rule、token replay、rogue device 與 agent tool 註冊。
5. **AI coding agent 防護**：針對 Downloads 夾帶誘騙安裝 → 將 `~/Downloads` 設為 agent 禁寫／需核准路徑，agent 不得自動執行下載檔。

---

## 四、今日驗收清單（Checklist）

- [ ] `node -v` = v24.22.1（或 ≥ 24.22.1）；`openclaw --version` = 2026.10.7
- [ ] `PIL.__version__` ≥ 12.3.0，EPS 輸入被拒絕，13.0.0 上架後再升
- [ ] `ufw status` = active / deny incoming；2049、111、5900、7070 不再對外
- [ ] `/etc/x11vnc.pass` = 600；x11vnc 不再對 0.0.0.0 監聽
- [ ] `find ~/.openclaw/secrets -type f ! -perm 600` = 空；舊 .bak 已清除
- [ ] OpenCode ≥ 1.18.33；OpenAI / Anthropic / Google / GitHub key 已輪替
- [ ] `openclaw security audit` warn 明顯下降；Discord broad_members 收斂
- [ ] GitLab / Plex / Arista VeloCloud / Collabora / Siemens 逐一確認「不存在於本機環境」或在 FCEB 到期前完成修補（今日 10/26 為兩筆 10/23 新增的最後期限）
- [ ] CA 套件更新；Windows 節點 Secure Boot revocation 排程

---

## 五、本次未做（原因）

無人值守 cron，無法取得核准，且下列操作會改變主機狀態或中斷服務：安裝/升級套件、寫入 `openclaw.json`、啟用防火牆（可能鎖死遠端）、重啟 gateway、撤銷或輪替 API key（需 provider 後台）。以上皆已轉成可逐條貼上的指令與驗收標準，交由有 sudo 或授權的人員執行。
