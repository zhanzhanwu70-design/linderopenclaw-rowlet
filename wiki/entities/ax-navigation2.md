---
title: ax_navigation2
type: entity
tags: [elle_ws, ros2, navigation, slam]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# ax_navigation2

## Summary
基於 ROS2 Navigation2 的自走車導航堆疊封包，提供路徑規劃、定位與障礙物避障能力。

## Responsibility Boundaries
- SLAM（即時定位與地圖建構）
- 全域路徑規劃（Nav2 Planner）
-區域路徑規劃（Nav2 Controller）
- 代價地圖管理（Costmap2D）

## Inputs / Outputs
| Topic / Service | Type | Description |
|-----------------|------|-------------|
| `/scan` | `sensor_msgs/LaserScan` | 雷射雷達數據 |
| `/map` | `nav_msgs/OccupancyGrid` | 占用柵格地圖 |
| `/goal_pose` | `geometry_msgs/PoseStamped` | 導航目標 |
| `/plan` | `nav_msgs/Path` | 計算出的路徑 |

## Dependencies
- [[elle_ws_hardware/lidar]] — 障礙物感測
- [[elle_ws_hardware/imu]] — 姿態估算
- [[elle_ws_hardware/gps]] — 室外定位（可選）

## Related Decisions
- [[elle_ws/navigation-stack-choice]]

## References
- Source: `repos/elle_ws_functions/src/functions/ax_navigation2/`
