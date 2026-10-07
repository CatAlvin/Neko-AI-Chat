# V1.25.0 · Neko 需求基线与开发索引

版本号: V1.25.0  
目标: 建立从本地消息托管 MVP 到当前交付基线的需求、设计、开发顺序与验收约束。  
## 文档约定

本目录的版本号标识需求迭代，不替换程序包及 `/health` 中的应用版本号。每版先明确行为、数据边界与退出条件，再安排实现及验证；后续版本只覆盖明确列出的旧规则，其余约束继续有效。

这些文件记录设计与验收条件。每版的验收条目是交付条件；真实 QQ、云模型、专用 MySQL 的通过结论仍须附对应环境的运行证据。已有 V1 验收报告保留原有时间与结论，不因需求版本推进而自动更新。

开发按“确认范围 → 明确接口与边界 → 实现最小闭环 → 验证失败和竞态 → 本机验证 → 保留回退方式”的顺序进行。跨版本修复应落到所属需求，不能以局部页面显示正常代替完整消息链路通过。

## 版本路线

| 版本 | 需求文档 | 核心交付 |
| --- | --- | --- |
| V1.0.0 | [本地托管 MVP](versions/V1.0.0-core.md) | 消息、策略、模型、记忆、后台与发布门禁 |
| V1.1.0 | [QQ 官方接入](versions/V1.1.0-qq-official.md) | 回调验证、持久化收件箱与真实验收 |
| V1.2.0 | [实验连接器](versions/V1.2.0-experimental-connectors.md) | NapCat、AutoWx、入站鉴权 |
| V1.3.0 | [时段与 LIVE](versions/V1.3.0-live-controls.md) | 可配置时间门禁、北京时间与单联系人 LIVE |
| V1.4.0 | [聊天数据归档](versions/V1.4.0-message-recording.md) | 对方、本人、AI 消息持久化 |
| V1.5.0 | [媒体保存与理解](versions/V1.5.0-local-media.md) | 图片、语音、文件、视频及本机提取 |
| V1.6.0 | [账号切换与续火](versions/V1.6.0-accounts-keepalive.md) | 多配置单活、账号隔离、独立续火授权 |
| V1.7.0 | [记录导出与管理员](versions/V1.7.0-export-admin.md) | 多联系人导出、管理员身份与命令入口 |
| V1.8.0 | [文件发送与引用](versions/V1.8.0-file-reference.md) | 文件回复、引用解析、管理员指定发送 |
| V1.9.0 | [聊天管理策略](versions/V1.9.0-admin-policy.md) | 联系人开关、时段、模型与记录查询 |
| V1.10.0 | [诊断与资料管理](versions/V1.10.0-observability.md) | 未回复诊断、联系人详情、媒体库、引用预览 |
| V1.11.0 | [模型与凭据可靠性](versions/V1.11.0-model-credentials.md) | 凭据迁移、云端与本地 Qwen、失败回退 |
| V1.12.0 | [Kimi 多模态](versions/V1.12.0-kimi-media.md) | Moonshot 直连、压缩上传、实际模型可见 |
| V1.13.0 | [智能工作台](versions/V1.13.0-productivity.md) | 任务、补偿、路由、知识、记忆审核、摘要 |
| V1.14.0 | [贴图与本地语音](versions/V1.14.0-voice-stickers.md) | 缓存导入、少年男声、主动引用与 Whisper 修复 |
| V1.15.0 | [长列表体验](versions/V1.15.0-scroll-retention.md) | 独立滚动、懒加载、预览与任务保留策略 |
| V1.16.0 | [人工消息与话题委托](versions/V1.16.0-manual-topic.md) | 无接管等待的人工发送、主动找联系人聊天 |
| V1.17.0 | [完整长文档与回复风格](versions/V1.17.0-long-form.md) | 自动续写、PDF/TXT、简体中文与自然表达 |
| V1.18.0 | [可靠性与运行管理](versions/V1.18.0-reliability.md) | 降级状态、投递账本、提醒与常驻方案 |
| V1.19.0 | [导航与启动体验](versions/V1.19.0-dashboard.md) | 分组菜单、启动超时、明确故障出口 |
| V1.20.0 | [工具与管理员代答](versions/V1.20.0-tools-delegation.md) | 天气、搜索、日历、待办转交闭环 |
| V1.21.0 | [回复连续性](versions/V1.21.0-reply-continuity.md) | 正式事务记录回执、管理员对话、故障定位 |
| V1.22.0 | [记忆导入与统一语法](versions/V1.22.0-memory-import.md) | 截图批次、直接记住、自动生效、连字符命令 |
| V1.23.0 | [品牌图标](versions/V1.23.0-branding.md) | 网站标签页与桌面识别资产 |
| V1.24.0 | [恢复手动启停](versions/V1.24.0-manual-lifecycle.md) | 移除常驻、托盘、自启和崩溃拉起 |
| V1.25.0 | [NapCat 兼容升级](versions/V1.25.0-napcat-compatibility.md) | 官方包验证、配置保全、启动与登录分层验收 |

## 当前规则与图表

- [当前边界、默认值与替代关系](CURRENT_BASELINE.md)
- [数据模型、迁移与接口责任](DATA_AND_CONTRACTS.md)
- [需求到实现及验收的追踪表](TRACEABILITY.md)
- [分模块 Mermaid 运行流程](flows/README.md)

当前有效的关键决策：NapCat 多配置单活；AutoWx 仅草稿；管理员命令统一使用 `-`；安全记忆直接生效并允许后台修改；正式事务记录后回复；服务使用 PowerShell 手动启停。双 NapCat 并发接入仍属于下一阶段设计。

代码路径约定：完整路径从项目根目录起算；服务文件短名默认位于 `backend/app/services/`，`core/`、`policy/`、`llm/`、`channels/`、`api/` 相对 `backend/app/`，测试短名位于 `backend/tests/`。Mermaid 图表按模块拆分，目录内共 18 张运行流程图。

## 开发与验收纪律

1. 修改连接器之前，先定义账号身份、事件键、ACK 和平台发送回执的契约。
2. 涉及真实发送的改动必须覆盖生成期间切账号、关闭白名单、急停和响应丢失四类情况。
3. 媒体、引用、工具、记忆必须在模型调用前准备好，并保留来源；不得让模型猜测未取得的材料。
4. 数据变更走 Alembic；不通过删除用户聊天库解决迁移问题。
5. 备份与回退按当前数据版本执行；代码可回退不代表数据库可直接降级。
6. 发布说明列明代码验证、真实环境验证和仍待用户操作的步骤。

依据：[系统设计](../docs/ARCHITECTURE.md)、[V1 验收报告](../docs/ACCEPTANCE_V1.md)、[验收矩阵](../docs/ACCEPTANCE_MATRIX_V1.md)及本目录列出的实现入口。
