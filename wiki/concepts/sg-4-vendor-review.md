---
title: "SG-4: Vendor Review"
type: pattern
tags: [security, vendor, navigation2, cve, ros2]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# SG-4: Vendor Review

## Summary
外部 vendor 依賴（如 Navigation2）升級前必須走 Security Review 流程，防止 CVE 污染。

## ELLE_WS 的 Vendor 清單
| Vendor | 用途 | 風險等級 |
|--------|------|---------|
| navigation2 (Nav2) | 導航堆疊 | 🔴 高 |
| ros2_control | 馬達控制框架 | 🔴 高 |
| sensor_msgs | 感測器訊息定義 | 🟡 中 |
| Gazebo (sim) | 模擬器 | 🟡 中 |
| Isaac Sim (sim) | 模擬器 | 🟡 中 |

## Implementation

### Step 1: 建立 Vendor Review Checklist
每次升級前必須完成：

```markdown
## Vendor Security Review: <vendor-name> <new-version>

### CVE Check
- [ ] 查詢 https://cve.mitre.org/cve/search_cve_list.cshtml
- [ ] 查詢 https://security.google.com/welcome
- [ ] 列出所有已知 CVE

### Impact Assessment
- [ ] 此 vendor 影響 ELLE_WS 的哪些模組？
- [ ] 是否有网络-facing interface？
- [ ] 是否有 privileged access？

### ADR Decision
- [ ] Approved / Rejected / Deferred
- [ ] 理由記錄在 `wiki/concepts/adr/<vendor>-<version>.md`

### Testing
- [ ] CI full test suite passed
- [ ] 物理測試（如果涉及硬體介面）
```

### Step 2: 建立 ADR 目錄結構
```
wiki/concepts/adr/
├── nav2-humble-upgrade.md
├── ros2-control-jazzy-migration.md
└── gazebo-harmonic-adoption.md
```

### Step 3: CI 整合
```yaml
vendor-upgrade-check:
  stage: security
  script:
    - echo "Checking vendor CVEs for $UPGRADE_PACKAGE $NEW_VERSION"
    - python .gitlab/ci/vendor_review.py --package $UPGRADE_PACKAGE --version $NEW_VERSION
  rules:
    - if: $CI_COMMIT_BRANCH == "vendor-upgrade/*"
```

### `vendor_review.py` 範例（概念驗證）
```python
import requests, sys

def check_cve(package):
    url = f"https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch={package}"
    r = requests.get(url, timeout=10)
    cves = r.json().get("vulnerabilities", [])
    if cves:
        print(f"⚠️  Found {len(cves)} CVEs")
        for cve in cves[:5]:
            print(f"  {cve['cve']['id']}: {cve['cve']['descriptions'][0]['value']}")
    return len(cves) == 0

if __name__ == "__main__":
    pkg = sys.argv[1]
    if not check_cve(pkg):
        sys.exit(1)  # Fail CI
```

## 快速評估矩陣（用於日常）
| 條件 | 風險 | Action |
|------|------|--------|
| 新版本無 CVE | 低 | ✅ 可升級 |
| 有已知 CVE，但需 auth | 中 | ⚠️ 需 review |
| 未修補的 RCE CVE | 高 | 🚫 擱置 |

## Related
- [[sg-1-ci-security-scan|SG-1: CI 資安掃描]]
- [[sg-2-signed-tags|SG-2: Signed Tags]]
- [[security-gates-day1]]（上層索引）

## References
- NIST NVD API: https://nvd.nist.gov/developers/request-an-api-key
- ROS2 Security: https://docs.ros.org/en/humble/Concepts/About-Security.html
- ADR 機制：see [[elle_ws/nav2-plugin-drift]]（導航相關決策）
