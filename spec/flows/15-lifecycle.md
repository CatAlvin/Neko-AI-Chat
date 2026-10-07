# V1.25.0 · 手动生命周期与兼容维护

版本号: V1.25.0  
目标: 使用同一用户显式启停，不保留自启或崩溃守护。  
```mermaid
flowchart TD
    USER["普通 Windows 用户执行 PowerShell"] --> ACTION{"操作"}
    ACTION -->|启动| CHECK["检查环境、端口、凭据与迁移"]
    CHECK --> BLOCK{"存在阻断项"}
    BLOCK -->|是| ERROR["清楚报告原因与修复步骤"]
    BLOCK -->|否| START["启动 Neko 后端与前端并记录进程"]
    START --> HEALTH["检查服务可用性"]
    ACTION -->|停止| PID["读取并核实 Neko 进程身份"]
    PID --> OWN{"进程归属可靠"}
    OWN -->|是| STOP["只停止本项目记录的 Neko 进程"]
    OWN -->|否| REPORT["报告未知归属或权限不足"]
    ACTION -->|重启| PID
    STOP --> RESTART{"本次为重启"}
    RESTART -->|是| CHECK
    RESTART -->|否| OFF["保持停止，无自动拉起"]
    QQ["QQ 更新或 NapCat 启动失败"] --> VERSION["核对实际版本及官方兼容包"]
    VERSION --> BACKUP["备份安装目录与账号配置"]
    BACKUP --> UPDATE["校验下载包并升级程序"]
    UPDATE --> LOGIN["启动检查后由用户登录"]
    LOGIN --> VERIFY["登录后验证适配器与授权收发"]
```

## 运行边界与实现入口

不以管理员账户反复重启解决普通用户的归属问题；不误杀 QQ、NapCat、Ollama、MySQL。卸载历史托管仅作用于项目创建的目标，不删除系统通用任务。二维码阶段不能证明 NapCat 登录后的 Packet 和消息收发正常。

实现：`scripts/start.ps1`、`scripts/stop.ps1`、`scripts/restart.ps1`、`scripts/uninstall-startup.ps1`、`backend/app/services/service_control.py`。
