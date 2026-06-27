# Brief

## Goal

为 TTS 训练项目设计并记录一次“并发测试”的多 Agent 协作流程。

本任务的产出是 Markdown 协作文档，不是代码提交。

## Background

用户希望 Codex、Claude Code、Trae 基于这个 Git 仓库协作，但不把真实 TTS 训练代码上传到仓库。这个仓库只作为协作底座，记录计划、测试设计、执行摘要、风险和决策。

## Success Criteria

- Codex、Claude Code、Trae 都能根据本任务包知道自己的职责。
- 并发测试的目标、测试维度、记录格式和验收标准写清楚。
- 仓库中只产生 Markdown 协作记录，不提交真实训练代码、数据集、模型权重或大日志。
- 后续某个 Agent 即使没有聊天上下文，也能只读项目文件和任务包接上工作。

## In Scope

- 并发测试方案设计。
- 多 Agent 分工。
- 运行记录模板。
- 风险和决策记录。
- 外部代码/环境的引用方式。

## Out Of Scope

- 上传或维护真实 TTS 训练代码。
- 上传音频数据、训练集、模型 checkpoint、权重文件。
- 在本仓库执行训练或压力测试。
- 保存大体积原始日志；只保存摘要和关键结论。

## Constraints

- Read root `AGENTS.md` first.
- Read project `PROJECT.md`.
- Do not overwrite another agent's assigned notes.
- Record final decisions in `decisions.md`.
- This is a Markdown-only coordination task.
- Any real execution must happen outside this repository unless the human owner explicitly changes the rule.
- If an Agent needs to reference external files, record paths or links only when safe; do not copy sensitive or large assets into this repo.

