---
title: "ELLE WS Integration Contract"
type: spec
tags: [ros2, integration, launch-composition, cross-repo]
status: active
created: 2026-06-23
updated: 2026-06-23
---

# ELLE WS Integration Contract

## Summary
5-repo 的整合契約，定義 repos 間的組合方式與依賴關係。

## Repo Roles

| Repo | Role | 职责 |
|------|------|------|
| `elle_ws_bringup` | **Orchestration** | 啟動檔 composition、根啟動檔、robot config |
| `elle_ws_functions` | **Business Logic** | SLAM、Navigation2、AMR behaviors、logging |
| `elle_ws_hardware` | **Driver** | 馬達、IMU、LiDAR、Camera、GPIO |
| `elle_ws_simulations` | **Simulation** | Gazebo world、robot model |
| `elle_ws_tools` | **Tooling** | 資料視覺化、log 分析 |

## Integration Pattern: Launch Composition

`elle_ws_bringup` 的 launch 檔 import 並 composition `elle_ws_functions` 的 launch 檔：

```python
# bringup/launch/functions/amr_behaviors.launch.py
fromament import LaunchDescription
fromament.actions import DeclareLaunchArgument, IncludeLaunchDescription
fromament.launch_wrapper.actions import PythonLaunchDescriptionSource

def generate_launch_description():
    # Include functions/层的 coordinator
    amr_coordinator = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            [FindPackageShare('amr_coordinator'), '/launch/', 'amr_coordinator.launch.py']
        )
    )
    # Include SLAM
    slam = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            [FindPackageShare('slam'), '/launch/', 'slam.launch.py']
        )
    )
```

### Config-driven Composition
每個 robot config（`configs/<robot_name>/`）指定要用哪些 functions：
```
configs/custom_1/functions/slam_cartographer_params.lua
configs/elle_robox500_1/functions/slam_cartographer_params.lua
```

## Cross-Repo Data Flow

```
hardware (drivers)
    ↓ ROS2 topics
functions (navigation/SLAM)
    ↓ ROS2 actions/services
bringup (orchestration)
    ↓ Launch composition
simulations (Gazebo)
```

## Key Interfaces

### ROS2 Topics（Hardware → Functions）
| Topic | Type | Source | Consumer |
|-------|------|--------|----------|
| `/scan` | sensor_msgs/LaserScan | lidar | slam, navigation |
| `/imu/data` | sensor_msgs/Imu | imu | slam (EKF fusion) |
| `/motor/odom` | nav_msgs/Odometry | motor | navigation |

### ROS2 Actions（Functions 內部）
| Action | Client | Server |
|--------|--------|--------|
| `/navigate_to_pose` | bt_navigator | nav2 |
| `/compute_path_to_pose` | bt_navigator | planner |

### ROS2 Services（Functions 內部）
| Service | Type | Provider |
|---------|------|----------|
| `/map_server/load_map` | nav2_msgs/srv/LoadMap | map_server |
| `/config_repost/get_params` | std_srvs/srv/Trigger | config_repost |

## Version Contract

每個 repo 版本必須满足：
1. **Backward compatible** — 舊 config 仍能啟動
2. **No breaking topic names** — 已發布的 topic 不可改名
3. **Launch file contract** — `package/launch/*.launch.py` 介面不變

## Deployment Model

```bash
# 典型啟動順序
ros2 launch elle_ws_bringup bringup.launch.py robot_config:=elle_robox500_1
# 1. 加載 robot config（定義要用哪些 hardware/functions）
# 2. Include hardware 驅動 launch（lidar, motor, imu...）
# 3. Include functions launch（slam, navigation2...）
# 4. 動態參數服務（config_repost）
```

## Related
- [[elle_ws/nav2-plugin-drift]]（Navigation2 整合問題）
- [[security-gates-day1]]（跨 repo 依賴的資安考量）
- [[sg-2-signed-tags]]（跨 repo 版本綁定）

## Evidence
- AST extraction: `graphify/elle_ws_bringup/`（197 nodes）
- Launch composition pattern: `src/bringup/launch/functions/*.launch.py`
