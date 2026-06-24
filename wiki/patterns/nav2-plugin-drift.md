---
title: "Nav2 Plugin Drift"
type: pattern
tags: [navigation2, plugin, drift, ros2, refactor]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# Nav2 Plugin Drift

## Summary
Nav2 plugin 設計在版本演進中出現重複、未一致化的問題。charizard 研究（task_02 R4）指出 P1 等級問題。

## Symptom（觀察到的問題）
1. **Plugin 重複設計** — 多個 plugin 做類似的事（e.g. 多種 controller 或 planner 變體）
2. **API 飄移** — 新版本 Nav2 的 plugin API 與舊版不相容
3. **配置飄移** — `nav2_params` 檔案隨版本變更結構

## Root Cause
Nav2 插件生態的兩股力量拉扯：
- **Plugin 開發者自由** — 每個 plugin 可以有自己的實現細節
- **Core API 穩定性** — Nav2 core 需要向後相容

當 Nav2 升級時，plugin 作者可能：
- 選擇不更新（停在舊 API）
- Breaking change 進入 core API

## Detection（如何發現）
```bash
# 1. 檢查 Nav2 版本
ros2 pkg exec nav2_bringup --ros-args | grep nav2_version

# 2. 對比 plugin API
grep -r "nav2_core::" src/ | head -20

# 3. 檢查 params schema
param_schemes=$(find ~/. -name "*.params.yaml" -exec grep -l "controller_server\|planner_server" {} \;)
```

## Fix Pattern

### 短期：Pin 版本
```xml
<!-- package.xml -->
<depend>navigation2</depend>
<depend>nav2_bringup</depend>
<depend>nav2_controller</depend>
<!-- 不要用 >version，pin 死特定版本 -->
```

### 中期：Plugin 抽象層
```cpp
// amr_nav_plugins 封裝所有 Nav2 plugin
// 內部追蹤 API 版本，屏蔽 drift
class AMRNavPluginBridge {
public:
    virtual geometry_msgs::msg::TwistStamped computeVelocity(
        const geometry_msgs::msg::PoseStamped& pose,
        const geometry_msgs::msg::Twist& velocity) = 0;
};
```

###、長期：ADR 追蹤每次升級
每次 Nav2 升級必須：
- [ ] 記錄 ADR：`wiki/concepts/adr/nav2-<version>.md`
- [ ] 測試所有 plugin
- [ ] 更新 `amr_nav_plugins` 整合目標（見 [[amr_nav_plugins]]）

## ELLE_WS 目前受影響範圍
| Package | Plugin Count | 風險 |
|---------|-------------|------|
| `navigation2` | 6+ core plugins | 🔴 Nav2 vendor |
| `amr_main` | 6 amr_* plugins | 🟡 內部整合 |
| `ax_navigation2` | Axiomtek 包裝層 | 🟡 中間層 |

## AST Graph 觀察到的具體信號

### 1. Community 38 重疊
`nav2_costmap_2d` plugin 和 `amr_nav_plugins` 落在同一個社群（Community 38），代表這兩者有高度耦合：
- 任何一方改動都可能影響另一方
- Plugin 置換時需要同時考慮 costmap 依賴

### 2. BT Plugin 跨模組呼叫（Surprising Connection）
```
on_tick() --calls--> Config
```
BT（Behavior Tree）plugin 的 `on_tick()` 跨模組呼叫 `Config`，說明：
- Plugin 間介面不明確，沒有乾淨的封裝邊界
- Plugin 狀態管理分散，容易產生隱式依賴

### 3. 多種 Implementation 並存
| Plugin Type | 實現數量 | 風險 |
|-------------|---------|------|
| Controller | >3（DWB, Regulated Pure Pursuit, MPPI） | 配置飄移 |
| Planner | >2（NavFn, SmacPlanner2D/Hybrid） | API drift |
| Smoother | >1 | 相對穩定 |

## 進一步確認需要
- Git history：`git log --oneline --grep="plugin" --since="2024-01-01"`
- Axiomtek 內部升級記錄（有人工記錄才能定位具體版本）
- 直接問 charizard task_02 R4 的原始研究

## Related
- [[amr_nav_plugins]]（整合目標）
- [[sg-4-vendor-review]]（vendor 升級審查）
- [[navigation2-vs-move_base]]（框架選擇上下文）

## References
- charizard task_02 research findings (R4)
- Nav2 Plugin API: https://navigation.ros.org/plugin_tutorials/
