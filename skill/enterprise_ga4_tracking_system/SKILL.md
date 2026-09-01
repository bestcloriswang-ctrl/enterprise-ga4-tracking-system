---
name: enterprise_ga4_tracking_system
description: Build enterprise-grade GA4 app analytics standards and reusable end-to-end user journey tracking plans, including journey reconstruction, KPI convergence, event requirements, parameter enum and canonical dictionaries, page dictionaries, journey prioritization, single-parameter or GA4 multi-parameter modes, Feishu/Base synchronization, review checks, governance, and backward-compatible iterations. Use when users ask for an “XXX 链路用户分析埋点方案”, tracking-plan optimization, journey funnel decomposition, or linked 00–05 analytics artifacts.
---

# App Analytics Standard (GA4)

## Purpose

Use this skill to create, review, or iterate enterprise-grade GA4 tracking specifications for app journeys.

The standard defines analytics specification, not business implementation. Prefer updating existing requirement, parameter, and KPI tables instead of recreating them.

## Standard Outputs

For each journey produce or maintain six linked artifacts in this exact order:

1. `00-KPI`
2. `01-埋点需求`
3. `02-参数枚举字典`
4. `03-参数字典`
5. `04-页面字典`
6. `05-链路优先级`

Treat these artifacts as one governed system, not independent tables:

- `00-KPI.分子事件` and `00-KPI.分母事件` reference `01-埋点需求.埋点事件`.
- `00-KPI.链路名称（引用）` references `05-链路优先级.链路名称`.
- `00-KPI.关键维度` references `03-参数字典.参数名`.
- `01-埋点需求.必传参数` references `03-参数字典.参数名`.
- `01-埋点需求.页面标识` references `04-页面字典.页面标识`.
- `01-埋点需求.链路名称（引用）` references `05-链路优先级.链路名称`.
- `02-参数枚举字典.参数名` references `03-参数字典.参数名`.
- `02-参数枚举字典.使用事件` references `01-埋点需求.埋点事件`.
- Every `page_name` enum in `02` must match one `04-页面字典.页面标识`, and every governed page identifier in `04` must have a corresponding `page_name` enum unless it is explicitly reserved.
- `05-链路优先级` defines the ordered business journeys that determine which KPI, pages, and events are P0/P1/P2; use the same chain names as the source business-journey document.
- When creating a new KPI or event, infer its journey from the user's named journey, source requirement, business outcome, and surrounding flow, then automatically populate `链路名称（引用）` with the matching current `05.链路名称`. Never default new rows to a previously used journey merely because it is already common in the table.

Artifact responsibilities:

- `00-KPI`: converged result and direct diagnostic metrics, with numerator, denominator, key dimensions, filters in the analysis purpose, metric level/type, and journey reference.
- `01-埋点需求`: canonical event implementation requirements and journey ownership. In `单参数版`, each event has at most one required business parameter; common parameters stay centralized.
- `02-参数枚举字典`: one row per `参数名 + 参数值`, business explanation, importance, and linked usage events.
- `03-参数字典`: one canonical row per parameter name, with type, one of the five fixed categories, purpose, description, and GA4 usage classification when the table supports it.
- `04-页面字典`: unique page identifier, business-readable page name, and page purpose; it is the source of truth for `page_name`.
- `05-链路优先级`: unique chain name, priority, ordered scope or node summary, business goal, and analysis focus.

When working in Feishu/Lark Base, use the real field names and record IDs from the table. Do not rely on remembered column positions after fields have been added or reordered.

For a request named `XXX 链路用户分析埋点方案`, also produce or update a linked journey document. Before acting, read [references/journey-analysis-plan.md](references/journey-analysis-plan.md) completely and follow its workflow.

Before creating, restructuring, or comprehensively auditing the six tables, read [references/six-table-schema.md](references/six-table-schema.md) completely and use its field contracts, uniqueness keys, and dependency order.

## Task Routing

- Use the core rules in this file for event, parameter, KPI, privacy, compatibility, and output-mode decisions.
- Use `references/journey-analysis-plan.md` when the task requires reconstructing a journey, splitting business or shipment types, creating analysis funnels, synchronizing the six standard artifacts, or writing the final journey document.
- Use `references/kpi-driven-funnel.md` when creating, filling, reviewing, or reconciling `05-链路优先级.漏斗`; read it completely before writing a funnel back to a document or Base.
- Use `references/six-table-schema.md` when creating, restructuring, or validating table fields and cross-table references.
- Do not create a separate journey-specific skill for Pickup, Delivery, POD, payment, address, or another business flow unless it contains stable domain rules that cannot be represented by the generic journey workflow and parameters.

## Output Modes

Before producing or updating a tracking spec, identify the output mode:

- `单参数版`: one event supports at most one required business parameter. Use this when the user's system or downstream governance requires strict event-to-primary-parameter mapping.
- `GA4多参数版`: this is this skill's output-mode name, not an official GA4 product term. It follows the official GA4 event model where one event name may be sent with multiple event parameters.
- `双版本`: produce both versions side by side. Keep event names and KPI definitions aligned whenever possible, and only vary the parameter model.

If the user does not specify a mode, default to `单参数版` for backward compatibility. If the user explicitly asks for two versions, produce `单参数版` and `GA4多参数版`.

## Core Principles

1. Reuse the standard, not another app's business model.
2. One event represents one user action or one page arrival.
3. Choose a parameter output mode before designing or editing `01`, `02`, and `03`.
4. Common parameters are managed centrally.
5. Parameters must be reused before new parameters are created.
6. Every KPI must map to existing events.
7. KPI definitions must be converged, not exhaustive.
8. All changes must be backward compatible unless the user explicitly approves a breaking change.
9. Treat tracking as a problem-discovery system, not an event inventory.
10. Design events and KPI around the end-to-end core user journey, not isolated pages or features.

## Problem-Oriented Journey Design

Start every tracking design by defining the user's core task and complete journey. Experience optimization must preserve continuity across the journey rather than optimize one page in isolation.

For each journey:

1. Write the ordered key nodes from entry to business completion.
2. Define one result metric for the final outcome.
3. Define a measurable arrival, attempt, success, failure, or exit indicator for every key node that can block the result.
4. Add diagnostic events and dimensions that explain why a node underperforms, such as `fail_reason`, `exit_stage`, source, task type, network, app version, or device.
5. Remove events that cannot support a journey KPI, diagnose a known risk, or verify an optimization.

The tracking plan must answer:

- Where do users fail or abandon the journey?
- Why does the failure, delay, or abandonment occur?
- Which users, scenarios, versions, or environments are most affected?
- Did the optimization improve the intended node metric and final result metric?

Use this closed loop for optimization work:

`发现异常指标 -> 定位异常节点 -> 按维度识别原因 -> 制定优化方案 -> 明确目标指标 -> 上线后验证提升`

For every proposed optimization, document:

- the observed problem and affected journey node;
- the evidence-backed cause or hypothesis;
- the key experience factors and relevant benchmark or best practice;
- the design logic and planned change;
- the target KPI, expected direction, and measurable improvement goal.

## Event Rules

- Use `snake_case`.
- Treat `snake_case` as this specification's stricter naming style. GA4 allows event names made of letters, numbers, and underscores, but names must start with a letter and should not use reserved prefixes or reserved event names.
- Keep business-action event names unique. For `page_view`, multiple Base requirement rows are allowed only when each row has a distinct page identifier; use `埋点事件 + 页面标识` as the uniqueness key for page views and `埋点事件` for other events.
- Use GA4 recommended events and recommended parameters when the business meaning matches. Use custom events for app-specific logistics actions that do not match recommended events.
- Do not rename existing events unless the user explicitly asks.
- Use one canonical `page_view` event for successful page arrival and require `page_name` to identify the page, such as `page_view + page_name=sender_list`.
- Do not add a separate click event when the click has no standalone analysis value and the next page view already represents successful arrival.
- If click-but-not-arrived analysis is required, add a separate entry click event and document why.
- In `双版本`, keep the same event name for the same user action or page arrival across both versions unless the platform requires a different event grain.

## Parameter Rules

Parameter categories are fixed to exactly five values:

- `公共参数`
- `页面参数`
- `事件参数`
- `结果参数`
- `实验参数`

Do not create synonymous categories such as `公共事件参数`. Merge shared SDK/context fields into `公共参数`; classify experiment assignment, grouping, version, and variant identifiers as `实验参数`.

Common parameter layer:

`user_id,session_id,trace_id,platform,app_version,os_version,language,country,network_type,login_status,event_time`

Classify `page_name` as `页面参数`. Typical experiment parameters include `experiment_id,experiment_version,group_id,variant_id`; classify them as `实验参数`. A placement field such as `component_position` remains a `页面参数` when it describes where an exposure occurred.

This is a specification-governance layer, not an official GA4 parameter category. Map it carefully to GA4 mechanisms:

- Use GA4 automatically collected parameters where GA4 already provides the value.
- Use GA4 user properties for stable user-level attributes.
- Use default event parameters or shared SDK wrappers for values that should be attached to many events.
- Do not register GA4 reserved names as custom dimensions or custom metrics. For example, treat `user_id`, session identifiers, and timestamps as GA4/platform fields where available rather than ordinary custom event parameters.

Rules:

- Dynamic values use `dynamic`.
- Enum values use one row per value.
- Required parameters in `01-埋点需求` must exist in `03-参数字典`, except `无`.
- Enum parameters in `03-参数字典` must have their allowed values in `02-参数枚举字典`.
- Enum parameter rows must explain what each value means in plain business language.
- Reserved enum values may have empty `使用事件`, but their description must clearly say they are reserved and not used by current `01` requirements.
- Do not collect raw PII or sensitive free text such as name, phone, full address, email, ID number, payment credential, or user remark content. Use IDs, state flags, enum values, counts, or ranges.

## Single-Parameter Version

Use `单参数版` when an event supports at most one required business parameter.

Rules:

- In `01-埋点需求`, populate one primary required parameter per event, or `无` when no business parameter is needed.
- The primary parameter should be the minimum parameter needed to explain the event's business state, such as `submit_result`, `address_type`, `goods_type`, or `payment_method`.
- Put supporting dimensions that are useful but not required into notes, derived analysis guidance, or the `GA4多参数版`.
- Do not split one user action into many artificial events only to carry extra parameters.
- `02-参数枚举字典` still keeps one row per parameter value for enum parameters, while `03-参数字典` keeps one canonical row per parameter name.

Recommended `01` fields for this mode:

- `埋点事件`
- `触发时机`
- `页面/模块`
- `事件类型`
- `必传参数`
- `参数说明`
- `备注/口径`

## GA4 Multi-Parameter Version

Use `GA4多参数版` when one event can carry multiple event parameters.

Rules:

- Model each event as `event name + event parameters`. In GA4 implementation examples this is commonly sent as an event name plus a key-value parameter object; in BigQuery export, event parameters appear under `event_params`.
- Remember that `GA4多参数版` is this skill's version name. The official GA4 terms are `event`, `event parameter`, `user property`, `custom dimension`, and `custom metric`.
- Keep common parameters centralized; do not repeat them in every event row unless the target table requires explicit listing.
- In `01-埋点需求`, use a parameter-list field such as `事件参数清单` to list all required and optional event parameters.
- In `03-参数字典`, define every parameter once. In `02-参数枚举字典`, define every enum value and link it to all `使用事件`.
- Separate parameter level using only: `公共参数`, `页面参数`, `事件参数`, `结果参数`, or `实验参数`.
- Mark whether each parameter is required, optional, enum, dynamic, boolean, numeric, or range.
- Prefer enum/range parameters over high-cardinality raw values when analysis only needs grouping.
- Keep event parameters focused on diagnosis of the journey or KPI. Do not add all available business fields just because multi-parameter reporting is possible.
- Respect GA4 collection and configuration limits, including the practical limit of 25 event parameters per event for standard event collection. Keep event and parameter names concise.
- If a custom event parameter must be used in GA4 standard reports or Explorations, document that it should be registered as a custom dimension or custom metric. If the analysis is only in BigQuery, document the BigQuery query path instead.
- Do not use item-scoped ecommerce parameters unless the event is intentionally modeled as GA4 ecommerce/item data.

Recommended `01` fields for this mode:

- `埋点事件`
- `触发时机`
- `页面/模块`
- `事件类型`
- `事件参数清单`
- `必传参数清单`
- `可选参数清单`
- `备注/口径`

Recommended `02-参数枚举字典` fields:

- `参数名`
- `参数值`
- `中文说明`
- `使用事件`
- `重要程度`
- `备注`

Recommended `03-参数字典` fields:

- `参数名`
- `参数分类`
- `参数类型`
- `参数说明`
- `主要作用`
- `GA4参数用途`

`GA4参数用途` should clearly state one of:

- `GA4自动采集/平台字段`
- `用户属性`
- `默认事件参数/公共参数层`
- `事件参数-需注册自定义维度`
- `事件参数-需注册自定义指标`
- `事件参数-BigQuery明细分析`
- `不建议上报`

## Dual-Version Workflow

When producing `双版本`:

1. Define canonical events once, based on user actions and page arrivals.
2. Define KPI once, based on the business outcome and direct diagnostic path.
3. Build `单参数版` by choosing one primary required business parameter per event.
4. Build `GA4多参数版` by assigning all useful required and optional parameters to the same canonical events.
5. Reuse the same parameter names across both versions whenever semantics match.
6. Explain any event or parameter difference between versions in `备注/口径`.

KPI names, numerator events, denominator events, and KPI level should stay the same across both versions unless the output mode changes the available event grain.

## KPI Convergence

KPI tables should explain the target outcome, not list every measurable feature.

Build KPI as a diagnostic tree:

1. Pick one north-star result metric for the journey.
2. Keep only process metrics that directly explain why that result metric moved.
3. Remove feature usage, retention, convenience, or post-success metrics unless they directly diagnose the result metric.
4. Do not keep two KPIs for the same operation and success meaning.

For shipment/order creation journeys, if business semantics say "submit success equals order success", use this core result metric:

`下单成功率 = shipment_submit_result / shipment_submit_click`

Use `submit_result=success` or equivalent result filtering in GA4/BigQuery analysis. Do not also keep a separate `下单提交成功率` with the same numerator and denominator.

Do not define `下单成功率` as `page_view(page_name=shipment_success) / page_view(page_name=shipment_home)` when the business definition is submit success. That alternate ratio is a broader journey completion or success-page arrival metric and should be renamed or omitted.

## KPI Fields

Recommended `00-KPI` fields:

- `KPI名称`
- `指标层级`
- `指标类型`
- `关键维度`
- `分子事件`
- `分母事件`
- `分析目的`
- `GA4建议`

`指标层级` should be:

- `结果指标`: final business outcome.
- `过程指标`: diagnostic metric that explains the result.

`指标类型` should describe the calculation, not the business hierarchy:

- `核心转化率`: the main journey result when it uses a broad journey denominator.
- `成功率`: request/action success after the user has taken the action.
- `到达率`: successful arrival at a key step or page.
- `完成率`: completion of a sub-flow after entering that sub-flow.
- `流失率`: exits or failures before completion.
- Use `行为率`, `使用率`, `效率指标`, or `留存/复用` only when the user explicitly wants those secondary analyses.

Keep `KPI名称` clean. Do not prefix names with `结果指标｜` or `过程指标｜`; store that in `指标层级`.

## Shipment KPI Pattern

For a shipment creation flow focused on order success, prefer this compact KPI set:

Result metric:

- `下单成功率`: `shipment_submit_result / shipment_submit_click`

Process metrics:

- `地址信息填写到达率`: address step arrival from the shipment form.
- `寄件人地址完成率`: `sender_save_result(submit_result=success) / page_view(page_name=sender_edit)`
- `收件人地址完成率`: `receiver_save_result(submit_result=success) / page_view(page_name=receiver_edit)`
- `物品信息填写到达率`: `page_view(page_name=goods_edit) / page_view(page_name=shipment_form)`
- `物品信息完成率`: `goods_save_result(submit_result=success) / page_view(page_name=goods_edit)`
- `寄件链路退出率`: `shipment_flow_exit / page_view(page_name=shipment_home)`

Only add more KPI rows if they directly diagnose `下单成功率`. For example, add quotation success only if quoting is a required blocker before submission.

For `GA4多参数版`, use multi-parameter event context to support KPI drilldown without adding extra KPI rows. Examples:

- `shipment_submit_result`: `submit_result`, `result_code`, `receiver_count`, `payment_method`, `goods_type`, `goods_weight_range`, `service_type`.
- `goods_save_result`: `submit_result`, `result_code`, `goods_type`, `goods_weight_range`, `goods_value_range`.
- `sender_select` / `receiver_select`: `address_type`, `address_source`, `is_default_address`, `city_id`.

For `单参数版`, choose only the primary required parameter for each event, such as `submit_result` for result events or `address_type` for address selection events.

## Review Checklist

Before finishing, validate:

- `00`: no blank KPI fields, no duplicate KPI meaning, clean `KPI名称`, populated `指标层级`.
- `01`: no blank required governance fields, event names are `snake_case`; repeated `page_view` rows are allowed only when their page identifiers differ.
- `00` and `01`: every active row has a valid `链路名称（引用）` resolving to exactly one current `05.链路名称`, unless the row is explicitly governed as shared across journeys.
- Newly created `00`/`01` rows use the journey relevant to that requirement; verify that rows added for another journey did not inherit the last-used or majority journey value.
- `02`: no blank required enum fields, no duplicate `参数名 + 参数值`, enum values have clear business explanations.
- `03`: exactly one canonical row per parameter name; parameter categories use only the five fixed values.
- `04`: page identifiers are unique and match all governed `page_name` values in `02`.
- `05`: chain names match the source business-journey document and priorities are explicit.
- `05`: each populated funnel is derived from `00-KPI`, uses only events and pages that exist in `01` and `04`, separates the main result path from diagnostic sub-funnels and conditional branches, and states filters plus deduplication grain.
- Every `00` numerator and denominator event exists in `01`.
- Every `00` key dimension and every required business parameter in `01` exists in `03`.
- Every enum parameter/value in `02` maps to a parameter in `03`; every non-reserved `使用事件` exists in `01`.
- Old terms or superseded KPI names are removed from notes and descriptions.
- For shipment/order flows, no duplicate pair of `下单成功率` and `下单提交成功率` with the same meaning.
- In `单参数版`, no event has more than one required business parameter.
- In `GA4多参数版`, every listed event parameter is defined in `03`; enum values are defined in `02`; GA4 usage is clear; naming and parameter-count limits are respected; raw PII and sensitive free text are excluded.
- In `双版本`, KPI definitions remain aligned across versions unless a documented event-grain difference makes alignment impossible.
- The core user journey is explicitly ordered from entry to business completion.
- Every blocking journey node has a measurable indicator and a direct diagnostic path.
- Every event supports a journey KPI, diagnoses a known risk, or verifies an optimization; remove orphan events.
- Result, node, and diagnostic metrics form a traceable tree rather than a flat KPI list.
- Optional edit/save flows are not presented as mandatory main-funnel steps when users can select existing data or otherwise bypass them; conditional and batch flows have explicit entry conditions.
- Each optimization states the problem, cause or hypothesis, target KPI, expected direction, and post-release validation method.

## Completion Contract

Do not declare a six-table task complete until all of the following are true:

1. Read back every affected table after writes; do not rely only on write responses.
2. Report the final record count for each affected table and the number of intentional reserved or unresolved rows.
3. Confirm all six cross-table references resolve and list any unresolved names explicitly. This includes the `00`/`01` journey references to `05`.
4. Confirm the selected output mode. In `单参数版`, each event has at most one event-specific required parameter; centrally managed `公共参数` do not count toward this limit.
5. Confirm every KPI can be calculated from existing events, required filters are written in `分析目的` or a dedicated formula field, and the deduplication grain is stated.
6. Preserve unrelated user data and compatible existing records. Update by stable name or record ID; do not recreate tables or duplicate rows on reruns.
7. If source documents and tables disagree, treat the user's latest explicit instruction as authoritative, update both surfaces when authorized, and report the resolved terminology.

Use these completion labels in the final handoff:

- `已完成`: all checks pass.
- `部分完成`: safe updates are complete but named unresolved references or source decisions remain.
- `仅审查`: the user requested diagnosis without authorizing changes.

## Iteration Guidance

When the user says to optimize or review KPI:

1. Read the current KPI table.
2. Identify the business outcome and current duplicate or secondary metrics.
3. Converge the KPI table to result metrics plus direct process diagnostics.
4. Update names, `指标层级`, `指标类型`, numerator, denominator, purpose, and GA4 guidance together.
5. Re-run the review checklist and report counts plus any intentional exceptions.

When the user asks for single-parameter, multi-parameter, or two-version output:

1. Select the output mode from `Output Modes`.
2. Keep KPI convergence independent from parameter richness.
3. Update `01`, `02`, and `03` according to the selected mode.
4. Keep `00-KPI` focused on result and process metrics that affect order success.
5. Re-run the mode-specific review checklist.
