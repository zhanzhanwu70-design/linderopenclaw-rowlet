#!/usr/bin/env bash
# Guarded gateway restart: apply Node v24.22.3 (2026-11-11 security release) + move
# gateway.auth.password out of the config file into the 600-perm env file.
# Rolls back automatically if the gateway does not come back healthy.
set -uo pipefail
LOG=/home/amr/.openclaw/logs/gw-upgrade-guard.log
mkdir -p "$(dirname "$LOG")"
log(){ printf '%s %s\n' "$(date -Is)" "$*" >>"$LOG"; }

CFG=/home/amr/.openclaw/openclaw.json
UNIT=/home/amr/.config/systemd/user/openclaw-gateway.service
ENVF=/home/amr/.openclaw/secrets/site-auth.env
STAMP=$(date +%Y%m%d%H%M%S)
CFGBAK="$CFG.bak-$STAMP"
UNITBAK="$UNIT.bak-$STAMP"

cp -a "$CFG" "$CFGBAK"
cp -a "$UNIT" "$UNITBAK"
log "backup cfg=$CFGBAK unit=$UNITBAK"

# 1) move gateway.auth.password -> OPENCLAW_GATEWAY_PASSWORD in 600 env file (value never printed)
python3 - "$CFG" "$ENVF" <<'PY'
import json,sys,os,re
cfg,envf=sys.argv[1],sys.argv[2]
d=json.load(open(cfg))
pw=(d.get('gateway',{}).get('auth') or {}).get('password')
if not pw:
    print('no password in config; skip'); sys.exit(0)
existing=open(envf).read() if os.path.exists(envf) else ''
if 'OPENCLAW_GATEWAY_PASSWORD=' not in existing:
    with open(envf,'a') as f:
        if existing and not existing.endswith('\n'): f.write('\n')
        f.write('OPENCLAW_GATEWAY_PASSWORD=%s\n' % pw)
os.chmod(envf,0o600)
(d.get('gateway',{}).get('auth') or {}).pop('password',None)
json.dump(d,open(cfg,'w'),indent=2,ensure_ascii=False)
os.chmod(cfg,0o600)
print('moved password to env; config password removed')
PY

systemctl --user daemon-reload
systemctl --user restart openclaw-gateway
sleep 12
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1:18789/health || echo 000)
if [ "$code" = "200" ] && systemctl --user is-active --quiet openclaw-gateway; then
  log "OK health=$code pid=$(systemctl --user show openclaw-gateway -p MainPID --value) node=$(systemctl --user show openclaw-gateway -p ExecStart --value | grep -oE 'node/v[0-9.]+')"
else
  log "FAIL health=$code -> rollback"
  cp -a "$CFGBAK" "$CFG"; cp -a "$UNITBAK" "$UNIT"
  systemctl --user daemon-reload; systemctl --user restart openclaw-gateway
  sleep 10
  log "rollback done health=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 http://127.0.0.1:18789/health || echo 000)"
fi
