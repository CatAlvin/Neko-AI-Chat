# V1.25.0 · 后台启动、实时会话与诊断

版本号: V1.25.0  
目标: 避免无尽加载、跨联系人串页和新消息撑长整页。  
```mermaid
flowchart TD
    OPEN["打开后台"] --> HEALTH["有超时的本机状态检查"]
    HEALTH --> ONLINE{"后端可访问"}
    ONLINE -->|否| ERROR["显示故障原因与重新连接"]
    ERROR --> HEALTH
    ONLINE -->|是| AUTH["认证与加载工作区"]
    AUTH --> API["API 快照和 WebSocket 更新"]
    API --> CHAT["选择联系人并加载最新消息页"]
    CHAT --> SCROLL["独立滚动容器，默认底部"]
    SCROLL --> TOP{"接近顶部"}
    TOP -->|是| OLDER["双游标加载历史并保持位置"]
    OLDER --> SCROLL
    API --> NEW["收到新消息"]
    NEW --> STICKY{"原本靠近底部"}
    STICKY -->|是| BOTTOM["跟随最新消息"]
    STICKY -->|否| PRESERVE["保留阅读位置与新消息提示"]
    CHAT --> SWITCH["切换会话后忽略旧请求响应"]
    API --> DIAG["按消息查看完整诊断链"]
    DIAG --> DETAIL["入库 / 策略 / 模型 / 媒体 / 投递原因"]
    AUTH --> NAV["分组导航、明确展开层级、独立滚动"]
```

## 运行边界与实现入口

WebSocket 不是唯一数据源，断线恢复后重新查询。聊天滚动与页面滚动分开；历史加载按 ID 去重。同一模式要覆盖任务、日志、媒体等可持续增长区域。诊断应解释未回复原因，不能用一个 ONLINE 替代全链路结果。

实现：`frontend/app/page.tsx`、`frontend/app/globals.css`、`backend/app/services/observability.py`。
