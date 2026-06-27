# Project

## Project Name

TTS训练

## Goal

用本 Git 仓库作为 TTS 训练相关工作的多 Agent 协作控制台。

本项目不要求把真实训练代码、数据集、模型权重、日志大文件上传到仓库。仓库只保存 Markdown 协作记录、测试计划、执行摘要、风险、决策和复盘。

## Source Materials

- 真实代码、数据、模型和运行环境保留在外部位置。
- 如果需要引用外部资料，只在 Markdown 中记录路径、链接、版本、命令摘要或结果摘要。
- 不提交大文件、私密数据、训练音频、模型权重或临时缓存。

## Outputs

- `.agent-work/` 中的任务包。
- 测试计划、测试结果摘要、问题列表、决策记录。
- 必要时可在 `outputs/` 放最终报告类 Markdown 文件。

## Agent Rules For This Project

- Read root `AGENTS.md` before working.
- Read this `PROJECT.md` before opening a task.
- Use `.agent-work/` for every substantial task.
- Do not rely on chat history as the only source of truth.
- Treat this repository as a coordination repository, not the TTS code repository.
- Do not add real project code unless the human owner explicitly changes this rule.
- Do not add datasets, audio samples, checkpoints, model weights, generated caches, or large logs.
- When referencing external execution, record enough context for another Agent to understand it: environment, command summary, input scale, output path, observed result, and blocker.

## Current Tasks

- `.agent-work/task-2026-06-27-并发测试/`

