# V1.25.0 · 需求实现追踪

版本号: V1.25.0  
目标: 将各版交付项关联到代码责任区、验证入口及真实环境补充条件。  
## 阅读方法

下表中的 Python 服务名位于 `backend/app/services/`，测试名位于 `backend/tests/`。测试文件是可执行验证入口，不表示本次文档整理重新运行或已通过所有真实环境验收。具体测试应在隔离库运行，不向真实联系人批量发消息。

| 版本 | 代码责任区 | 验证入口 |
| --- | --- | --- |
| 1.0 | pipeline.py；policy/engine.py；llm/gateway.py | test_policy_invariants.py；test_pipeline_stability.py；test_memory_isolation.py |
| 1.1 | api/connectors.py；channels/qq_webhook.py；channels/qq.py | test_qq_webhook.py；test_qq_acceptance.py；test_failure_recovery.py |
| 1.2 | channels/experimental.py；api/connectors.py | test_experimental_connectors.py；test_channel_shutdown.py |
| 1.3 | core/clock.py；runtime.py；policy/engine.py | test_live_time_window.py；test_beijing_time.py；test_release_gates.py |
| 1.4 | models/entities.py；pipeline.py | test_mode_semantics.py；test_experimental_connectors.py |
| 1.5 | media.py；media_understanding.py | test_media_messages.py；test_media_understanding.py |
| 1.6 | account_selection.py；keepalive.py | test_keepalive_and_napcat_profiles.py；test_observability_and_account_isolation.py |
| 1.7 | chat_export.py；admin_commands.py | test_chat_export.py；test_admin_commands.py |
| 1.8 | reference_context.py；admin_delivery.py | test_reference_context.py；test_admin_commands.py |
| 1.9 | admin_commands.py；runtime.py | test_admin_commands.py；test_control_visibility.py |
| 1.10 | observability.py；system_health.py | test_observability_and_account_isolation.py；test_system_health.py |
| 1.11 | core/security.py；llm/providers.py；provider_health.py | test_credentials.py；test_provider_protocols.py；test_llm_failure.py |
| 1.12 | cloud_media.py；provider_ordering.py | test_kimi_media.py；test_ai_configuration.py |
| 1.13 | task_center.py；knowledge.py；model_router.py；daily_digest.py | test_productivity_center.py；test_reliability_center.py |
| 1.14 | local_tts.py；stickers.py；media_understanding.py | test_local_voice_and_sticker_cache.py；test_media_understanding.py |
| 1.15 | frontend/app/page.tsx；frontend/app/globals.css；task_center.py | test_productivity_center.py；浏览器滚动、切换、历史加载检查 |
| 1.16 | proactive_topic.py；pipeline.py | test_admin_commands.py；test_mode_semantics.py |
| 1.17 | long_form.py；text_overflow.py；provider_style.py | test_long_form.py；test_provider_style.py；test_reference_context.py |
| 1.18 | configuration_diagnostics.py；provider_health.py；outbox.py；relationship_assistant.py | test_reliability_center.py；test_service_control.py |
| 1.19 | frontend/app/page.tsx；frontend/app/globals.css | 初始连接超时、重连、窄屏导航与独立滚动检查 |
| 1.20 | online_tools.py；delegated_todo.py | test_online_tools_and_delegated_todos.py |
| 1.21 | formal_matter.py；pipeline.py | test_mode_semantics.py；test_admin_commands.py |
| 1.22 | admin_memory_import.py；admin_syntax.py；memory.py | test_admin_commands.py；test_memory_isolation.py |
| 1.23 | frontend/public；frontend/app/layout.tsx | 浏览器图标、缩放、小尺寸辨识检查 |
| 1.24 | scripts/start.ps1；stop.ps1；restart.ps1；service_control.py | test_powershell_compatibility.py；test_service_control.py |
| 1.25 | NapCat 外部安装；channels/experimental.py；system_health.py | 下载哈希、配置一致性、登录后 API 与授权收发分项检查 |

## 每次真实链路验收应保留的证据

- 环境：北京时间、代码版本、数据库迁移 head、账号及通道，不包含 Token 明文。
- 入站：外部消息 ID、account_id、事件去重与入库结果。
- 上下文：媒体识别状态、引用来源、实际进入模型的材料范围。
- 模型：候选顺序、每次失败、实际成功 provider/model、耗时及终止原因。
- 出站：授权来源、发送前复核、平台返回 ID、投递账本；不能把生成内容作为发送证据。
- 异常：急停、切账号、开关变化、网络中断、回执丢失，分别检查不重复、不串号。
- 结果：通过、未通过、待用户登录或待真实测试分开标注。

## 回归组合

1. 消息主链：普通文本、纯语音、图片加问题、视频、文件、显式引用、最近材料引用。
2. 策略变化：生成中急停、关闭白名单、禁用 AI、切换账号、进入时段外、人工接管。
3. 模型退化：主模型鉴权失败、连接失败、空结果、输出截断、媒体不支持、本地服务未启动。
4. 管理员：普通聊天、控制命令、正文含连字符、截图批次、代答引用、文件与主动话题。
5. 界面：切联系人时旧请求延迟返回、加载历史时收到新消息、任务超出 50 条、后端不可用后恢复。
6. 运维：普通用户启动、进程记录缺失、端口被占用、已有进程权限不足、手动停止后不被守护重启。

## 仍需区别的验收范围

历史 V1 报告与当前扩展功能是两组证据。原始官方 QQ 200 条唯一真实入站、MySQL 空库迁移与断线重连、DeepSeek/OpenAI/Ollama 真实连接聊天及失败处理，不因后来新增 Kimi 或 NapCat 而免除。这里只建立追踪关系，不覆写旧验收结论。
