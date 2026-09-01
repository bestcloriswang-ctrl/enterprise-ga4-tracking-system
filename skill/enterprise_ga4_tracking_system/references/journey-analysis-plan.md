# End-to-End Journey Analysis Tracking Plan

Use this workflow for requests such as `XXX 链路用户分析埋点方案`, especially when the user provides screenshots, a reference document, or an existing Feishu Base.

## Required Inputs

Collect or discover:

- the core user task and final business success state;
- every known entry point and terminal state;
- screenshots or product documents that reveal actual steps;
- business, shipment, order, user, or operational types whose steps differ;
- existing event, parameter, page, and KPI dictionaries;
- the requested output mode; default to `单参数版` when unspecified.

Do not block on missing implementation details when screenshots and existing artifacts support a safe draft. Mark genuine unknowns as `待确认` and avoid inventing business semantics.

## Workflow

### 1. Reconstruct the real journey

Read the reference material and order screens by user intent, not by screenshot filename. Record:

`entry -> arrival -> selection/input -> validation -> submit -> backend result -> post-success state`

Treat search, scan, deep link, notification, task card, quick action, and history as different entry paths when they can change conversion or user context.

### 2. Split branches before designing events

Create separate sub-journeys when a type changes mandatory steps, validation, evidence, payment, signature, handoff, or completion state. Prefer a shared canonical event plus a type parameter when the action semantics are identical. Create a separate event when the user action, success condition, or failure surface is materially different.

Typical branch axes include:

- task/order/shipment type;
- standard, reverse, batch, scan, exception, or return flow;
- source or entry path;
- required verification, photo, signature, quantity, payment, or packaging steps;
- online/offline or synchronous/asynchronous completion.

Never hide materially different branches inside one undocumented “main funnel”.

### 3. Build a blocking-node matrix

For every key node define:

| Field | Requirement |
|---|---|
| Node | Business-readable step name |
| Entry indicator | Page arrival or action attempt |
| Success indicator | Completed action or backend-confirmed result |
| Failure indicator | Standard failure event or result value |
| Exit indicator | Exit event with stage |
| Diagnostic dimension | Type, source, reason, version, network, geography, or device |
| KPI dependency | Result or process metric directly supported by the node |

Do not add an event when the next page arrival already proves success and click-to-arrival loss is not an analysis requirement. Add an attempt event when arrival can fail or the current page contains several mandatory steps.

### 4. Define canonical events and parameters

Apply the main SKILL.md rules. Additionally:

- represent page arrival with a page-view event and `page_name`;
- represent backend outcomes with explicit success/failure events or a result event whose value is defined in the parameter dictionary;
- use one canonical event across business types when semantics match, and filter with a standardized type parameter;
- in `单参数版`, select the one parameter that best explains the event; keep supporting dimensions in centrally attached common context or notes;
- do not overload generic `action`, `type`, or `result` when a stable, reusable semantic parameter already exists;
- never collect raw query text, names, phone numbers, full addresses, IDs exposed to users, OTP values, signatures, images, or free-text reasons.

### 5. Design the diagnostic KPI tree

Define:

1. one final result metric for the complete journey;
2. direct process metrics for mandatory blocking nodes;
3. branch-specific metrics only where the branch introduces a distinct blocker;
4. an exit or failure metric that identifies incomplete journeys.

Each KPI must specify numerator, denominator, filters, deduplication grain, key dimensions, purpose, and expected diagnostic interpretation. A same-event KPI is valid when numerator uses a result filter, for example `otp_result(result=success) / otp_result`.

Avoid KPI inventory growth. Do not promote browsing preferences, convenience actions, or post-success behavior to KPI unless they directly diagnose the final result.

### 6. Synchronize artifacts in dependency order

Use this order:

1. inspect actual Base/table fields, options, records, views, and IDs;
2. define or update `05-链路优先级` from the source business journeys;
3. update `04-页面字典` and establish governed page identifiers;
4. update `03-参数字典` with one canonical row per parameter and one of the five fixed categories;
5. update or create `01-埋点需求` event records, automatically filling `链路名称（引用）` with the journey matched from the current requirement and `05.链路名称`, plus page and primary parameter references; do not reuse the previous row's journey as a default;
6. update `02-参数枚举字典`, including every enum value and `使用事件` relationship after the target events exist;
7. update `00-KPI` only after numerator and denominator events exist, and automatically fill each KPI's `链路名称（引用）` with the same governed journey as the KPI's business outcome;
8. write or update the journey document from the final table state;
9. read back all affected artifacts and validate every cross-table reference.

Prefer updating existing compatible rows. Preserve existing event names unless the user explicitly approves renaming. Do not create duplicate events or KPI records on reruns; search by stable name and update by record ID.

### 7. Write the journey document

Use the reference document’s structure and style when one exists. Otherwise use:

1. analysis objective overview;
2. ordered core journey;
3. business/type branch table;
4. funnels by analysis objective;
5. event groups mapped to user stages;
6. parameter summary and privacy constraints;
7. KPI alignment;
8. implementation and validation notes.

The document is a readable analysis guide, not a duplicate export of every Base row. Event names, parameters, filters, formulas, and branch names must match the linked tables exactly.

## Final Validation

In addition to the main checklist, confirm:

- every screenshot-visible mandatory step is represented by arrival, attempt, result, or exit measurement;
- every materially different business type has a documented branch or an explicit shared-event filter;
- every document event exists in `01`;
- every `01` required parameter exists in `03`, and every enum parameter in `03` has its allowed values in `02`;
- every `02.使用事件` exists in `01`, except explicitly reserved values;
- every `02` `page_name` value aligns with `04`, and every governed page in `04` is covered;
- every `00-KPI` numerator and denominator exists in `01`, and every key dimension exists in `03`;
- every active `00-KPI` and `01-埋点需求` row has a resolvable `链路名称（引用）` from `05`, with no locally duplicated static chain dictionary;
- new rows for a non-current journey use that journey's exact `05` name and have not inherited a stale journey value from earlier writes;
- every `05` chain name matches the source business-journey document;
- formulas include required filters and deduplication grain;
- no event or KPI exists only in the document;
- rerunning the workflow would update, not duplicate, existing rows;
- the final report states counts, intentional exceptions, and unresolved `待确认` items.
