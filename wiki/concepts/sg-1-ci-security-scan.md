---
title: "SG-1: CI 資安掃描"
type: pattern
tags: [security, ci-cd, semgrep, codeql, ros2]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# SG-1: CI 資安掃描

## Summary
每個 ELLE_WS repo 的 CI 必須在 merge 前通過 Semgrep 或 CodeQL 靜態掃描，失敗即 red。

## Symptom（未實作的風險）
- 壞人在 CI 看不見的情況下 inject 惡意依賴
- package.xml 的外來 package 沒有安全審查
- CMakeLists.txt 的 shell script 沒被 scan

## Root Cause（為什麼第一天就要做）
ELLE_WS 是 5-repo 多方協作的 AMR 系統，任何一個 repo 被污染都會影响電網、電機等物理設備。

## Implementation（Semgrep 實作）

### Step 1: 安裝 Semgrep
```bash
# 本地測試
pip install semgrep
semgrep --version

# CI 配置（GitLab CI example）
```

### Step 2: `.gitlab-ci.yml` 新增 stage
```yaml
stages:
  - test
  - security

semgrep-scan:
  stage: security
  image: returntocorp/semgrep:latest
  script:
    - semgrep --config auto --target-branch main --dangerously-disable-force-quit
  rules:
    - if: $CI_MERGE_REQUEST_IID
  allow_failure: false
```

### Step 3: ROS2 特定規則（建議自訂 `rules/ros2-security.yaml`）
```yaml
rules:
  - id: ros2-unverified-dependency
    pattern: package.xml 包含非 trusted 來源的 package
    message: 外來 package 必須經過 security review
  - id: cmake-shell-injection
    pattern: execute_process() 含外部輸入
    message: Shell command injection risk
```

## Implementation（CodeQL 實作）

```yaml
codeql-scan:
  stage: security
  image: github/codeql-action:latest
  script:
    - codeql database create --language python
    - codeql database analyze
  rules:
    - if: $CI_MERGE_REQUEST_IID
```

## Detection（如何確認有在跑）
```bash
# 確認 CI pipeline 有 security stage
grep -r "semgrep\|codeql" .gitlab-ci.yml
```

## 5-Repo 對應矩陣

| Repo | 主要語言 | 建議 Scanner |
|------|---------|-------------|
| bringup | Python + YAML | Semgrep |
| functions | C++ + Python | CodeQL |
| hardware | C++ | CodeQL |
| simulations | Python + XML | Semgrep |
| tools | Python | Semgrep |

## Related
- [[sg-2-signed-tags|SG-2: Signed Tags]]
- [[sg-4-vendor-review|SG-4: Vendor Review]]
- [[security-gates-day1]]（上層索引）

## References
- Semgrep: https://semgrep.dev/docs/
- CodeQL: https://codeql.github.com/docs/
- ROS2 Security: https://docs.ros.org/en/humble/Concepts/About-Security.html
