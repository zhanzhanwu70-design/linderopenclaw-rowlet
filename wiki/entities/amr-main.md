---
title: amr_main
type: entity
tags: [elle_ws, ros2, functions, navigation]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# amr_main

## Summary
ELLE WS 的主控制節點，整合導航、感測器驅動與運動控制的核心軟體封包。

## Responsibility Boundaries
- 負責 AMR（自動移動機器人）的整體狀態管理
- 協調導航堆疊（navigation2）與硬體驅動程式
- 發布 robot_pose、odom、cmd_vel 等關鍵主題

## Inputs / Outputs
| Topic / Service | Type | Description |
|-----------------|------|-------------|
| `/amr_status` | `DeviceMsg` | AMR 狀態發布 |
| `/cmd_vel` | `geometry_msgs/Twist` | 運動控制命令 |
| `/robot_pose` | `geometry_msgs/Pose` | 當前位置估測 |

## Dependencies
- [[elle_ws_functions/ax_navigation2]] — 導航堆疊
- [[elle_ws_hardware/motor]] — 馬達驅動
- [[elle_ws_hardware/imu]] — IMU 慣性測量
- [[elle_ws_hardware/lidar]] — 雷射雷達

## Related Decisions
- [[elle_ws/navigation-stack-choice]] — 為何選 navigation2 而非 move_base

## References
- Source: `repos/elle_ws_functions/src/functions/amr_main/`
- Spec: `spec/amr_main/SPEC.md`
