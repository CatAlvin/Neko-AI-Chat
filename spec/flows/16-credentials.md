# V1.25.0 · 凭据与连接诊断

版本号: V1.25.0  
目标: 将解密失败、鉴权失败和网络失败分开定位。  
```mermaid
flowchart TD
    UI["后台保存或修改凭据"] --> INPUT{"有新明文输入"}
    INPUT -->|否且已有凭据| KEEP["保留原加密内容"]
    INPUT -->|是| ENC["按当前本机方案加密"]
    ENC --> DB[("ApiCredential")]
    KEEP --> DB
    CALL["Provider 或连接器请求"] --> LOAD["按 credential_id 加载"]
    DB --> LOAD
    LOAD --> DEC{"可以解密"}
    DEC -->|否| REPAIR["标记需修复，不把坏值发送到外部"]
    DEC -->|是| CLIENT["构建相应协议客户端"]
    CLIENT --> RES{"调用结果"}
    RES -->|鉴权失败| AUTH["检查密钥与 API 地址及提供商"]
    RES -->|连接或超时失败| NET["检查网络、代理、超时与服务健康"]
    RES -->|协议或模型失败| MODEL["检查模型 ID 与响应格式"]
    RES -->|成功| OK["更新最近成功与实际模型"]
    AUTH --> HEALTH["脱敏错误进入诊断中心"]
    NET --> HEALTH
    MODEL --> HEALTH
    REPAIR --> HEALTH
```

## 运行边界与实现入口

不需要反复重新填写同一 Token 来掩盖缓存、权限、网络或协议故障。错误输出脱敏，修复模式不自动放开 LIVE。修改加密方案需兼容已有数据，保留可恢复的迁移路径。

实现：`backend/app/core/security.py`、`backend/app/services/factory.py`、`provider_health.py`、`configuration_diagnostics.py`。
