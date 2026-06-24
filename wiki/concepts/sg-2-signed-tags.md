---
title: "SG-2: Signed Tags"
type: pattern
tags: [security, git, gpg, signed-tag, supply-chain]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# SG-2: Signed Tags

## Summary
跨-repo 依賴改用 GPG-signed git tag，而非 commit hash，防止供應鏈攻擊。

## Symptom（未實作的風險）
- attacker 可以 push 一個 malicious commit 並偽裝成已知 hash
- `package.xml` 的 `<depend>` 引用 commit sha，無法驗證來源

## Root Cause
git commit hash 只证明內容存在，不证明誰写的。GPG signed tag 用私鑰簽名綁定 identity。

## Implementation

### Step 1: 生成 GPG Key（建議用子機碼，非 master key）
```bash
# 生成 Ed25519（現代推薦）
gpg --full-generate-key --expert
# 選擇：ECC Curve 25519
# 到期：1 年（每年 rotate）
```

### Step 2: 配置 git 使用 signing key
```bash
# Repository 層級
git config commit.gpgsign true
git config tag.gpgsign true
git config user.signingkey <YOUR-FINGERPRINT>

# 或全域
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

### Step 3: 發布 Signed Tag
```bash
# 每個 repo release 時
git tag -s v1.0.0-elle_ws_<repo> -m "Release v1.0.0 for ELLE_WS
Signed by: $(git config user.name)"
git push origin v1.0.0-elle_ws_<repo>
```

### Step 4: Consumer 端驗證
```bash
# 取 tag 時自動驗證
git fetch --tags
# 手動驗證
git tag -v v1.0.0-elle_ws_functions
```

## 與 package.xml 的整合
```xml
<!-- package.xml 改用 tag 而非 commit -->
<depend>elle_ws_functions</depend>
<!-- 但這需要 CI 自動更新 version — 見下方自動化 -->
```

### 自動化：Renovate Bot + GPG Verification
```json
// renovate.json
{
  "packageRules": [{
    "matchPackagePatterns": ["elle_ws_*"],
    "commitMessageExtra": "{{{currentVersion}}} (verified tag)"
  }]
}
```

## 鑰匙管理（特別針對 5-repo）
| Repo | Signing Key Holder | Key Type |
|------|-------------------|----------|
| elle_ws_bringup | 平台團隊 | Ed25519 sub-key |
| elle_ws_functions | 導航團隊 | Ed25519 sub-key |
| elle_ws_hardware | 硬體團隊 | Ed25519 sub-key |
| ... | ... | ... |

## Known Issues
- **CI/CD runner 需要有 GPG key 的副本**（建議用 vault 存私鑰）
- **Key rotation**：每年需要重新簽署新 key，需有 KM 流程

## Related
- [[sg-1-ci-security-scan|SG-1: CI 資安掃描]]
- [[sg-4-vendor-review|SG-4: Vendor Review]]
- [[security-gates-day1]]（上層索引）

## References
- Git Tag Signing: https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work
- GPG Best Practices: https://riseup.net/en/security/message-encryption/openpgp/best-practices
