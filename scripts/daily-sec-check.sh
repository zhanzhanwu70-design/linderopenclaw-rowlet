#!/usr/bin/env bash
# daily-sec-check.sh — 一鍵主機資安曝險快篩（唯讀、不需 root、可在每台主機跑）
# 對應 2026-11-20 威脅：nginx2root / Java4Shell / Starlette smuggling / LiteLLM RCE / 曝露面
# 用法: bash ~/.openclaw/workspace-rowlet/scripts/daily-sec-check.sh
set -u
say(){ printf '%s\n' "$*"; }
flag(){ printf '  [%s] %s\n' "$1" "$2"; }
HIT=0
mark(){ HIT=$((HIT+1)); }

say "=== 主機資安快篩 $(date '+%F %T %Z') ==="
say "主機: $(hostname) | 核心: $(uname -r) | 發行版: $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME")"

# ---------- 1. NGINX2Root (CVE-2026-123007 / 123633 / 123634 / 121810 / 113425) ----------
say ""; say "[1] NGINX2Root"
if ! command -v nginx >/dev/null 2>&1; then
  say "  [OK] 未安裝 nginx → 不受影響"
else
  NV=$(nginx -v 2>&1 | sed 's/.*nginx version: nginx\///')
  say "  版本: ${NV:-unknown}"
  if nginx -V 2>&1 | grep -q -- '--with-http_v2_module'; then H2=present; else H2=absent; fi
  say "  HTTP2_MODULE=$H2"
  if nginx -T 2>&1 | sed 's/#.*//' | grep -qE 'listen[[:space:]].*http2|^[[:space:]]*http2[[:space:]]+on'; then
    say "  [!!] 設定中已啟用 HTTP/2 → CVE-2026-123007/123633 攻擊面"; mark
  fi
  case "$NV" in
    1.9.5*|1.1[0-9]*|1.2[0-9]*|1.30.[0-8]|1.31.[0-8]) say "  [!!] 版本落在 1.9.5–1.31.8 受影響區間 → 升 1.30.7 / 1.31.9"; mark;;
    1.30.7|1.31.9|1.3[2-9].*) say "  [OK] 版本已達修補版";;
  esac
  say "  處置: 升級 1.30.7(stable)/1.31.9(mainline) 且必須 restart（reload 無效）；無法立即升級則關閉對外 listener 的 http2"
fi

# ---------- 2. Java4Shell (CVE-2026-114938) ----------
say ""; say "[2] Java4Shell"
if ! command -v java >/dev/null 2>&1; then say "  [OK] 未安裝 Java"; else
  JV=$(java -version 2>&1 | head -1)
  say "  $JV"
  if grep -qo 'avx512_vbmi' /proc/cpuinfo 2>/dev/null; then VBMI=yes; else VBMI=no; fi
  say "  CPU AVX-512 VBMI=$VBMI"
  if [ "$VBMI" = yes ]; then
    case "$JV" in
      *'17.0.'*|*'21.0.'*|*'25.0.'*|*'27.0.'*) say "  [!!] 受影響版本線 → 換 Oracle 11 月版 (17.0.21.1/21.0.13.1/25.0.5.1/27.0.1.1)，或以 -XX:-UseBASE64Intrinsics 啟動"; mark;;
      *) say "  [OK] 不在 17/21/25/27 受影響版本線";;
    esac
  else
    say "  [OK] CPU 不支援 AVX-512 VBMI → 硬體加速 Base64 解碼器未啟用 → 不觸發"
  fi
fi

# ---------- 3. Starlette Host header smuggling (CVE-2026-48710, <1.0.1) ----------
say ""; say "[3] Starlette / FastAPI (CVE-2026-48710)"
SL=$(python3 -c "
import importlib.metadata as m
for p in ('starlette','fastapi'):
    try:
        print(p, m.version(p))
    except Exception:
        pass
" 2>/dev/null)
if [ -z "${SL:-}" ]; then say "  [OK] 未偵測到 starlette/fastapi"; else
  say "  $SL"
  if echo "$SL" | grep -qE 'starlette (0\.|1\.0\.0)'; then say "  [!!] starlette <1.0.1 → 升 1.0.1+"; mark
elif echo "$SL" | grep -q 'starlette '; then say "  [OK] starlette 已 ≥1.0.1"; fi
  if echo "$SL" | grep -qE 'fastapi '; then say "  [i] fastapi 可能間接帶入舊 starlette，一併檢查"; fi
fi

# ---------- 4. LiteLLM RCE (CVE-2026-40217) ----------
say ""; say "[4] LiteLLM (CVE-2026-40217)"
if command -v litellm >/dev/null 2>&1; then say "  [!!] 發現 litellm 指令 → 升官方修補版（KEV 期限 2026-12-02）"; mark
else pip3 show litellm 2>/dev/null | grep -m1 '^Version' || say "  [OK] 未安裝 LiteLLM"; fi

# ---------- 5. 對外曝露連接埠 ----------
say ""; say "[5] 對外曝露連接埠"
ss -ltn 2>/dev/null | awk 'NR>1 && $4 ~ /^(0\.0\.0\.0|\*|\[::\]):/ {print $4}' | sort -u | head -25 | while read -r p; do
  case "$p" in
    :22|:111|:2049|:5900|:7070) flag "!!" "$p  ← 需檢查（ssh/rpcbind/nfs/vnc/unknown-root-svc）";;
    *) flag "i" "$p";;
  esac
done

# ---------- 6. VNC 密碼檔 / 遠端桌面 ----------
say ""; say "[6] 遠端桌面"
if [ -e /etc/x11vnc.pass ]; then
  P=$(stat -c '%a %U:%G' /etc/x11vnc.pass)
  say "  /etc/x11vnc.pass 權限: $P"
  case "$P" in
    600*|400*) say "  [OK] 權限已收斂";;
    *) say "  [!!] 密碼檔權限過寬（應為 600）→ sudo chmod 600 /etc/x11vnc.pass"; mark;;
  esac
fi
pgrep -a x11vnc >/dev/null 2>&1 && { say "  [!!] x11vnc 執行中（5900 對外）"; mark; }
pgrep -a anydesk >/dev/null 2>&1 && say "  [i] anydesk 執行中"

# ---------- 7. SSH 驗證策略 ----------
say ""; say "[7] SSH"
if command -v sshd >/dev/null 2>&1 || [ -f /etc/ssh/sshd_config ]; then
  grep -E '^\s*#?\s*(PasswordAuthentication|PermitRootLogin)' /etc/ssh/sshd_config 2>/dev/null | sed 's/^/  /' | head -4
  if grep -qE '^\s*PasswordAuthentication\s+yes' /etc/ssh/sshd_config 2>/dev/null; then
    say "  [!!] PasswordAuthentication yes（預設值）→ 建議 no"; mark
  else say "  [OK] 未見明文 PasswordAuthentication yes"; fi
  FAILED=$(grep -c 'Failed password' /var/log/auth.log 2>/dev/null || echo 0)
  say "  /var/log/auth.log 密碼失敗次數: $FAILED"
  grep 'Failed password' /var/log/auth.log 2>/dev/null | tail -3 | sed 's/^/    /' | cut -c1-140
fi

# ---------- 8. 防火牆 / 暴力破解防護 ----------
say ""; say "[8] 防火牆與 IDS"
for c in ufw fail2ban nftables iptables; do
  if command -v $c >/dev/null 2>&1 || [ -x "/usr/sbin/$c" ] || [ -x "/sbin/$c" ]; then
    say "  [OK] $c 存在"
  else
    say "  [!!] $c 不存在（預設無過濾；需 root 確認 /usr/sbin 路徑）"; mark
  fi
done

# ---------- 9. 核心版本 / 開機選項 ----------
say ""; say "[9] Kernel"
RUN=$(uname -r)
GRUB=$(grep '^GRUB_DEFAULT' /etc/default/grub 2>/dev/null | cut -d'"' -f2)
say "  執行中: $RUN | GRUB_DEFAULT: ${GRUB:-未設定}"
if echo "$GRUB" | grep -q "$(echo "$RUN" | cut -d- -f1)"; then :; fi
if [ -n "$GRUB" ] && ! echo "$RUN" | grep -q "$(echo "$GRUB" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+-[0-9]+' | head -1)"; then
  say "  [!!] 開機核心與目前執行中不同 → sudo update-grub + 調整 GRUB_DEFAULT"; mark
fi

# ---------- 10. Docker / 容器逃逸面 ----------
say ""; say "[10] 容器"
ss -ltn 2>/dev/null | grep -qE ':(2375|2376)' && { say "  [!!] Docker TCP API 對外（CounterCraft 案例路徑）"; mark; } || say "  [OK] 無 Docker TCP API 曝露"
[ -S /var/run/docker.sock ] && { say "  [i] docker.sock 存在 → 使用者若在 docker 群組等同 root"; }
ls -d /opt/parasite 2>/dev/null && { say "  [!!] 發現 /opt/parasite"; mark; }

# ---------- 11. OpenClaw / Node 版本 ----------
say ""; say "[11] OpenClaw 與 Node"
command -v openclaw >/dev/null 2>&1 && say "  openclaw: $(openclaw --version 2>/dev/null | head -1)"
say "  node: $(node -v 2>/dev/null)"
for u in ~/.config/systemd/user/openclaw-gateway.service ~/.config/systemd/user/jormungandr-openclaw-bridge.service; do
  [ -f "$u" ] && { E=$(grep -m1 ExecStart "$u"); echo "$E" | grep -q 'node/v24\.22\.1/bin/node' && { say "  [!!] $(basename "$u") 仍釘在 v24.22.1（http2/tls High CVE）"; mark; } || say "  [OK] $(basename "$u") 使用新版 node"; }
done

say ""; say "=== 需要處理: $HIT 項 ==="
