# Six-Table Schema Contract

## Contents

- Dependency order
- 00-KPI
- 01-埋点需求
- 02-参数枚举字典
- 03-参数字典
- 04-页面字典
- 05-链路优先级
- Readback audit

Use this reference when creating, restructuring, or comprehensively auditing the standard GA4 tracking Base. Preserve compatible existing field names when possible; map them to these semantic roles instead of recreating the table.

## Dependency order

Write and validate in this order:

`05-链路优先级 -> 04-页面字典 -> 03-参数字典 -> 01-埋点需求 -> 02-参数枚举字典 -> 00-KPI`

This order prevents unresolved links: pages and parameters exist before event requirements; events exist before enum usage links and KPI event links.

## 00-KPI

Purpose: define the final result metric and only the process metrics that directly diagnose it.

Required semantic fields:

- `KPI名称`: unique business-readable metric name.
- `指标层级`: `结果指标` or `过程指标`.
- `指标类型`: success, arrival, completion, loss, or explicitly requested secondary type.
- `分子事件`: link to one or more `01.埋点事件`.
- `分母事件`: link to one or more `01.埋点事件`.
- `关键维度`: multi-link to `03.参数名`.
- `分析目的`: include numerator/denominator filters, deduplication grain, and diagnostic purpose.
- `GA4建议`: optional when the existing table supports it.
- `链路名称（引用）`: dynamic single-select sourced from `05-链路优先级.链路名称`; required for active KPI rows.

Uniqueness key: `KPI名称`. Do not keep two names for the same formula and business meaning.

## 01-埋点需求

Purpose: define canonical event implementation requirements.

Required semantic fields:

- `埋点事件`
- `触发时机`
- `页面/模块`
- `事件类型`
- `页面标识`: link to `04.页面标识` for page-bound events.
- `必传参数`: link to `03.参数名`; in `单参数版`, allow at most one event-specific value or `无`.
- `参数说明`
- `备注/口径`
- `链路名称（引用）`: dynamic single-select sourced from `05-链路优先级.链路名称`; required for active event rows. Preserve an equivalent existing field name only when restructuring a compatible legacy Base.

Common parameters are centrally managed and do not count toward the single event-specific required parameter. For page arrival, use `page_view` with required `page_name`.

Despite the suffix `（引用）`, this field is normally a writable dynamic `select`, not a formula or record-link field. Configure `dynamic_options_source` with the real `05` table ID and its `链路名称` field ID. Do not duplicate chain options as a static select.

Assign each KPI/event to one journey by default, but do not use a fixed default journey. For every new row, derive the value from the current request or source requirement and automatically write the exact matching `05.链路名称`. A row created for 查件追踪、订单履约、异常售后、客服服务, or another governed journey must receive that journey rather than inheriting 寄件下单链路 or the most recently written value.

Journey assignment precedence:

1. the journey explicitly named by the user for the current request;
2. an explicit journey field in the source requirement;
3. the unique `05` journey whose scope and business outcome contain the event/KPI;
4. a governed shared/platform journey for genuinely cross-journey infrastructure events.

If these signals produce multiple plausible journeys, do not guess or silently reuse a previous value. List the affected rows and ask the user to confirm the journey before writing them. If the required journey does not yet exist in `05`, create or propose the `05` row first according to the user's authorization, then populate `00`/`01`.

Uniqueness key: `埋点事件 + 页面标识` for `page_view`; otherwise `埋点事件`.

## 02-参数枚举字典

Purpose: define allowed enum values and their event usage.

Required semantic fields:

- `参数名`: link/reference to `03.参数名`.
- `参数值`
- `中文说明`
- `使用事件`: multi-link/reference to `01.埋点事件`.
- `重要程度`
- `备注`: mark reserved values explicitly.

Uniqueness key: `参数名 + 参数值`. Dynamic non-enum values may use one `dynamic` row. Reserved values may have empty `使用事件` only when the description says they are not currently used.

## 03-参数字典

Purpose: provide one source-of-truth row per parameter.

Required semantic fields:

- `参数名`
- `参数分类`
- `参数类型`
- `参数说明`
- `主要作用`
- `GA4参数用途` when the existing table supports it.

Uniqueness key: `参数名`.

Allow exactly five parameter categories:

- `公共参数`
- `页面参数`
- `事件参数`
- `结果参数`
- `实验参数`

Do not create `公共事件参数` or another synonym. Put shared SDK/context values in `公共参数`; put experiment assignment, version, group, and variant identifiers in `实验参数`.

## 04-页面字典

Purpose: provide the source of truth for page identity.

Required semantic fields:

- `页面名称` or `所属页面`
- `页面标识`
- `说明`
- `所属链路` or priority when the existing table supports it.

Uniqueness key: `页面标识`. Use `snake_case`. Every governed identifier must have one matching `02` row where `参数名=page_name`; every non-reserved `page_name` value must exist here.

## 05-链路优先级

Purpose: define which end-to-end business journeys are measured first.

Required semantic fields:

- `链路名称`
- `优先级`: normally `P0`, `P1`, or `P2`.
- `业务目标`
- `起点`
- `终点`
- `关键节点` or ordered scope summary.
- `分析重点`

Uniqueness key: `链路名称`. Chain names must match the source business-journey document exactly. Do not invent a parallel naming system.

## Readback audit

After writes:

1. verify every table has no unexpected blank required fields;
2. verify every uniqueness key has no duplicate;
3. verify all links resolve in both directions required by the standard;
4. verify every active `00` and `01` row has a journey reference resolving to `05.链路名称`, and both fields use a dynamic source rather than independently maintained static options;
5. verify newly created rows use the journey of the current requirement and did not inherit a stale, last-used, or majority-chain value;
6. verify every KPI is calculable from existing events and stated filters;
7. verify `单参数版` events have at most one event-specific required parameter;
8. report counts, reserved rows, intentional exceptions, and unresolved items.
