# KPI-Driven Funnel Design

Read this reference before creating, filling, reviewing, or reconciling a journey funnel in `05-链路优先级`.

## Goal

Turn the KPI diagnostic tree in `00-KPI` into an executable funnel specification using only governed events, pages, parameters, and enums from `01`–`04`.

A funnel is not a transcription of every event marked as a funnel node. It is a layered analysis model that distinguishes the business result path from optional task flows, conditional branches, and diagnostic exits.

## Required Inputs

Read the current records and real field names for:

- `00-KPI`: KPI name, numerator, denominator, filters, key dimensions, and deduplication grain.
- `01-埋点需求`: event name, page identifier, trigger condition, required parameters, funnel/critical flags, and notes.
- `02-参数枚举字典`: result values, page values, branch types, exit stages, and reserved values.
- `03-参数字典`: parameter semantics, type, category, and analysis usage.
- `04-页面字典`: valid page identifiers and business meaning.
- `05-链路优先级`: target chain, priority, scope, status, and existing funnel text.

Do not infer a funnel from the UI alone or from the `是否漏斗节点` flag alone. Treat that flag as implementation metadata to reconcile, not the source of truth for business sequence.

## Construction Method

### 1. Start from KPI, not from the event inventory

Choose the journey result KPI first. Its denominator is the result funnel's attempt node; its filtered numerator is the result node. If a success page exists, place it after the result as an arrival-validation node unless the business definition explicitly uses page arrival as success.

Example pattern:

`entry page -> task form -> submit click -> submit result(success) -> success page arrival check`

Do not replace an action-success KPI with a broader page-to-page conversion ratio. Keep the alternate ratio only when it has a distinct name and decision purpose.

### 2. Separate four layers

Every funnel should make these layers explicit when applicable:

1. `主结果漏斗`: the shortest ordered path from journey entry to the KPI-defined business result.
2. `诊断子漏斗`: entry-to-completion flows that explain a blocking area, such as edit page -> save result(success).
3. `条件分支`: paths entered only by a defined scenario, such as multi-recipient mode; state which users skip the branch.
4. `并列业务分支`: a distinct operating mode such as batch processing; give it its own attempt/result events and KPI rather than inserting it into the single-item path.

Add `流失诊断` separately. Exit and interruption events diagnose where a journey stopped; they are not forward conversion steps.

### 3. Distinguish mandatory steps from optional edits

Before placing a node in the main result funnel, ask whether every successful journey must trigger it.

- If users can select an existing object, an edit-page view or save-result event is not a mandatory main-funnel node.
- Keep edit completion as a diagnostic sub-funnel with its own entry denominator and success filter.
- A branch-specific confirmation belongs only to that branch; users outside the branch must not be counted as drop-offs.
- Disabled, reserved, future-version, or non-triggering events must not appear as active funnel steps.

### 4. State executable metric semantics

For every funnel or sub-funnel, specify as applicable:

- exact event name;
- `page_view` filter such as `page_name=...`;
- result filter such as `submit_result=success`;
- analysis unit and deduplication grain, normally `trace_id`, `session_id`, business ID, or one unified submission;
- branch entry condition;
- ordering expectation;
- success semantics for partial or batch results;
- mutual-exclusion rule for competing exit events.

For a unified multi-item submission, define whether success requires all items to succeed, any item to succeed, or uses item-level calculation. Do not leave this implicit.

### 5. Validate all references before writing

Check that:

- every event in the funnel exists in `01`;
- every `page_name` exists in both `02` and `04`;
- every filter/dimension parameter exists in `03` and required enum values exist in `02`;
- each KPI numerator and denominator matches the event/filter pair used in the funnel;
- diagnostic sub-funnels do not silently change the result KPI denominator;
- success-page arrival is not confused with request success or payment success;
- exits and interruptions are mutually exclusive or have an explicit precedence/deduplication rule;
- reserved or disabled enum values are not described as currently active.

If the tables disagree, list the conflict instead of silently choosing a meaning. The user's latest explicit decision is authoritative when they authorize synchronization.

## Recommended `05.漏斗` Structure

Use compact, business-readable sections. Omit sections that do not apply:

```text
【主结果漏斗】
<ordered event/page sequence and result filter>

【诊断子漏斗】
<sub-flow entry -> filtered completion; explain optionality>

【条件分支】
<entry condition and ordered branch sequence; identify who skips it>

【并列业务分支】
<separate sequence and KPI semantics>

【流失诊断】
<exit/interruption events, stage parameter, precedence and deduplication>

【KPI口径】
<numerator / denominator, filters, analysis unit and deduplication grain>
```

Keep product-specific event names in the target artifact, not as universal defaults in this reference.

## Write and Verification Contract

When authorized to update a Base or document:

1. Locate the unique target journey by stable chain name or record ID.
2. Update only the intended funnel field unless the user also authorizes other corrections.
3. Read the target record back after writing.
4. Recheck every referenced event, page, parameter, enum, KPI filter, and deduplication rule against `00`–`04`.
5. Report whether the funnel is fully matched, partially matched with named conflicts, or only reviewed.
