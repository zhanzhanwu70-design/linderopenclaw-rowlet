---
title: "Nav2 Plugin Contracts"
type: spec
tags: [ros2, navigation2, plugin, contract, open-spec]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# Nav2 Plugin Contracts

## Summary
Navigation2 的插件化架構契約。定義 planner/controller/smoother 的標準介面，確保不同實現可置換。

## Core Plugin Types

### 1. Planner Plugin（路徑規劃器）
```cpp
// nav2_core::Planner
virtual nav_msgs::msg::Path createPlan(
    geometry_msgs::msg::PoseStamped start,
    geometry_msgs::msg::PoseStamped goal,
    std::string &error_msg) = 0;
```

**內建實現：**
| Plugin | Library | 用途 |
|--------|---------|------|
| `nav2_navfn_planner/NavFnPlanner` | navfn | 傳統梯度法 |
| `smac_planner/SmacPlanner2D` | smac_planner | A* 2D |
| `smac_planner/SmacPlannerHybrid` | smac_planner | Hybrid A*（車型） |

### 2. Controller Plugin（軌跡追蹤器）
```cpp
// nav2_core::Controller
virtual geometry_msgs::msg::TwistStamped computeVelocityCommands(
    geometry_msgs::msg::PoseStamped pose,
    geometry_msgs::msg::Twist velocity,
    std::nav2_util::LifecycleBuddy &parent,
    std::string &error_msg) = 0;
```

**內建實現：**
| Plugin | Library | 用途 |
|--------|---------|------|
| `dwb_core/DWBController` | dwb_controller | ROS1 移植，成熟穩定 |
| `nav2_regulated_pure_pursuit_controller` | regulated_pure_pursuit | 簡單、平滑 |
| `nav2_mppi_controller` | mppi_controller | 學習-based |

### 3. Smoother Plugin（路徑平滑器）
```cpp
// nav2_core::Smoother
virtual bool smooth(
    nav_msgs::msg::Path &path,
    std::string &error_msg) = 0;
```

**內建實現：**
| Plugin | Library |
|--------|---------|
| `nav2_smoother::CampedSmoother` | nav2_smoother |
| `nav2_smoother::SavitzkyGolaySmoother` | nav2_smoother |

## Lifecycle State Machine

Nav2 使用 ROS2 Lifecycle 管理節點狀態：

```
CONFIGURE → ACTIVE → DEACTIVATE → INACTIVE → ACTIVE
                ↓         ↓
             _cleanup   shutdown
```

**各狀態含義：**
| State | Planner | Controller | Costmap |
|-------|---------|------------|---------|
| CONFIGURED | 載入參數 | 載入參數 | 緩衝區初始化 |
| ACTIVE | 接受請求 | 發送 cmd_vel | 更新傳感器數據 |
| INACTIVE | 不接受請求 | 輸出 zero velocity | 停止更新 |

## Costmap2D Plugin Contract

Costmap 是格點地圖，Nav2 用插件擴展感知層：

```cpp
// nav2_costmap_2d::Layer
virtual void updateBounds(
    double robot_x, double robot_y, double robot_yaw,
    std::vector<std::geometry_msgs::msg::Point> &footprint,
    double &min_x, double &min_y, double &max_x, double &max_y) = 0;

virtual void updateCosts(
    nav2_costmap_2d::Costmap2D &master_grid,
    int min_x, int min_y, int max_x, int max_y) = 0;
```

**Standard Layers：**
| Layer | 用途 |
|-------|------|
| `nav2_costmap_2d::StaticLayer` | 地圖 |
| `nav2_costmap_2d::ObstacleLayer` | 障礙物（雷射/深度相機） |
| `nav2_costmap_2d::InflationLayer` | 膨脹障礙物 |
| `nav2_costmap_2d::VoxelLayer` | 3D 體素（Kinect之類） |

## Plugin Selection Matrix（ELLE_WS 目前配置）

| Component | Plugin | 選擇原因 |
|-----------|--------|---------|
| Planner | SmacPlannerHybrid | 車型支援、障礙物環境 |
| Controller | RegulatedPurePursuit | 簡單、SMC 機器人適用 |
| Smoother | SavitzkyGolaySmoother | 保持幾何特性 |
| Obstacle Layer | ObstacleLayer + VoxelLayer | lidar + depth 相機 |

## API Stability Contract

插件更換時：
1. **不可破壞** `nav2_msgs/action/NavigateToPose.action`
2. **不可破壞** `nav2_msgs/action/ComputePathToPose.action`
3. **不可破壞** `nav2_msgs/srv/GetCostmap.srv`

## Known Issues

### Plugin Drift（charizard 研究發現）
Nav2 plugin API 在版本升級時有破壞性變更的歷史。避免方式：
- Pin Nav2 version in `package.xml`
- 參考 [[nav2-plugin-drift]] 頁面（執行經驗）

## Related
- [[ax_navigation2]]（Axiomtek Nav2 封裝）
- [[nav2-plugin-drift]]（實際發生的 drift 案例）
- [[sg-4-vendor-review]]（vendor 升級審查）

## Evidence
- 78 Nav2-related nodes in AST graph
- Primary community: 367
- Source: `functions/navigation2/`, `functions/ax_navigation2/`
