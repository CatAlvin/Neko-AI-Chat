# V1.25.0 · 数据与接口契约

版本号: V1.25.0  
目标: 明确模块之间的数据归属、身份隔离、状态语义和数据库演进责任。  
## 数据归属

| 数据实体 | 责任与关联 |
| --- | --- |
| Account / ApiCredential | 平台实例、启用状态、登录身份及凭据引用；不在消息表复制 Token |
| Contact / ChatGroup | 平台、账号、外部 ID、白名单、AI、记忆与局部策略 |
| Conversation | 所属账号与联系人、外部会话键、人工接管和冷却状态 |
| Message | 会话、来源 ID、方向、作者、正文、模型、生成与投递状态 |
| MessageAttachment | 所属消息、媒体类型、原始来源、本地路径、哈希、保存及识别状态 |
| ConversationSummary / Memory | 会话摘要与联系人长期记忆分离，不能跨账号混用 |
| ConnectorEvent | 归一化入站信封、去重键、处理状态、尝试次数和错误 |
| OutboundDeliveryEvent | 每次出站阶段、是否开始网络发送、回执及安全重试判断 |
| AdminMemoryImportBatch / Item | 管理员截图批次、目标联系人、每张截图及提取证据 |
| BackgroundTask / RecoveryItem | 可恢复后台任务与失败补偿事项，不等价于聊天待发消息 |
| TodoItem / RelationshipReminder | 待办、正式事务、管理员代答、关系提醒及关联回执 |
| KnowledgeDocument / DailyDigest / StickerAsset | 知识条目、按日摘要、贴图资产 |
| ProviderConfig / ProviderHealth | 配置优先级与运行成功失败记录 |
| RuntimeState / PersonaProfile | 运行门禁、功能配置和人格，不放入联系人聊天原文 |
| AuditLog / Incident / AcceptanceRun | 过程证据、可处理风险项和独立验收记录 |

账号、联系人与会话必须联合约束查询。仅凭昵称、QQ 号或平台消息 ID 不能跨账号定位对象。旧数据的账号补齐通过迁移和明确归属处理，不在每次查询时随意猜一个活动账号。

## 入站契约

统一事件携带 platform、account_id、message_id、conversation_id、sender_id、content、timestamp、author、attachments、reply_to_message_id 与原始信封。平台适配层负责规范化，不在模型提示词里修补平台身份。

- QQ 官方入口：`POST /api/v1/connectors/qq/webhook`。验证请求与事件请求分别处理；HTTP 成功不代表业务完成。
- NapCat 入口：`POST /api/v1/connectors/napcat/events`。按实现验证 Bearer 或兼容签名；无效身份拒绝，非消息事件可明确忽略。
- AutoWx 入口：`POST /api/v1/connectors/autowx/events`。授权后按接收草稿能力处理。
- 合法事件先持久化 ConnectorEvent，再 ACK，由后台处理。重投命中同一事件不应再产生一条出站。
- ConnectorEvent 状态为 PENDING、PROCESSING、DONE、FAILED；处理异常最多尝试三次。DONE 表示流水线已处理，包含策略拦截，不代表已真实发送。

## 消息状态契约

| 状态 | 含义 |
| --- | --- |
| RECEIVED | 入站已记录 |
| PROCESSING | 正在处理 |
| GENERATED | 已生成内容 |
| QUEUED | 等待发送，尚需复核门禁 |
| SENT | 发送接口成功并记录平台结果；不表示对方已阅读 |
| SHADOWED | 草稿已记录，无真实发送 |
| BLOCKED | 策略拒绝，保留原因 |
| CANCELLED | 原计划已取消，不应再投递 |
| FAILED | 当前步骤失败；是否重试另看投递账本 |

MessageAuthor 的 CONTACT、AI、HUMAN、SYSTEM 与方向 INBOUND、OUTBOUND 是独立字段。SHADOW AI 草稿不能归为对方消息；本人回显不能再次触发普通 AI 回复。附件失败也应记录原因，不能把“有附件行”等同于“已下载且已识别”。

## 出站与重试契约

调用连接器前记录意图，发送期间记录 delivery_started，成功后记录 acknowledged 和外部 ID。连接器异常发生在发送开始之后时，可能是“已发出但回执丢失”，不得自动重发。当前安全重试仅限未开始投递的失败文本，并要求原因属于连接器缺失、通道禁用或活动账号变化的明确集合。

管理员显式发送、普通 AI 回复、续火、代答和人工发送均应有各自授权来源与审计证据；不能通过统一“发送成功”字段抹平它们的策略差别。

## 数据库演进

| 迁移 | 引入的能力 |
| --- | --- |
| 20260824_0001 | 初始实体 |
| 20260824_0002 | 连接器持久化收件箱 |
| 20260824_0003 | 验收运行 |
| 20260824_0004 | 消息信封 |
| 20260826_0005 | LIVE 时间窗口 |
| 20260826_0006 | 媒体附件 |
| 20260826_0007 | 媒体理解 |
| 20260826_0008 | NapCat 配置及续火 |
| 20260827_0009 | 默认聊天管理员 |
| 20260827_0010 | 账号隔离及联系人覆盖项 |
| 20260828_0011 | Kimi 云媒体 |
| 20260828_0012 | 智能工作台 |
| 20260828_0013 | 本地语音、贴图及引用 |
| 20260830_0014 | 可靠性与投递体验 |
| 20260830_0015 | 在线工具及代答待办 |
| 20260831_0016 | 管理员记忆导入 |

迁移只描述 schema 演进，不证明生产库已升级。数据库写入与文件系统保存不是一个原子事务：附件文件缺失、导出失败、进程中断必须能单独诊断。聊天、记忆、媒体原件不随普通任务保留策略自动清除。

## 接口演进约束

配置写入校验后提交；秘密字段留空表示不修改时，不能将其误写为空值。WebSocket 通知用于刷新，不承担唯一事实来源；重连后通过 API 重新读取。分页按时间与 ID 双游标，避免同一秒多消息重排或漏读。导出和聊天详情必须复用账号范围过滤，而非前端单独过滤。
