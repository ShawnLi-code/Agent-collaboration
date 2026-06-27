# Brief

## Goal

基于 Claude Code 已训练完成的 TTS 模型，开放一个云端文本转音频接口，让本地其他电脑可以通过网络调用。

已知模型条件：

- 权重：第 53 轮。
- 推理参数：`scale=1.5`、`seed=9999`。
- 输入：文本。
- 输出：音频文件或音频二进制响应。

## Background

本仓库是 Markdown 协作仓库，不保存真实 TTS 代码、训练数据、模型权重或大日志。真实接口开发由 Claude Code 在云服务器真实项目目录中完成。Codex 在本仓库中分配任务、定义验收标准，并在 Claude Code 提交代码摘要或 diff 后做代码审核。

## Success Criteria

- Claude Code 在云服务器真实 TTS 项目中开放一个可调用接口。
- 接口能根据文本生成音频，并固定使用第 53 轮权重、`scale=1.5`、`seed=9999`，除非任务记录中明确说明可配置。
- 云端端口能被本地其他电脑访问，且有最小访问控制或安全边界。
- Claude Code 在本任务包记录接口路径、启动命令、端口、防火墙/安全组设置、请求示例、响应格式和测试结果摘要。
- Codex 根据 Claude Code 提供的代码 diff、关键文件摘要、运行命令和测试结果进行审核。
- 本仓库只保存 Markdown 协作记录，不提交真实代码、权重、数据集、音频样本或大日志。

## In Scope

- 接口形式设计，例如 HTTP API。
- 云端端口开放和本地调用说明。
- 推理参数固定或显式配置策略。
- 最小并发/重复调用测试方案。
- Claude Code 实现任务分配。
- Codex 代码审核标准和审核记录。

## Out Of Scope

- 把真实 TTS 项目代码复制到本仓库。
- 上传第 53 轮权重、训练集、音频样本、checkpoint 或大日志。
- 在本协作仓库内运行推理服务。
- 设计完整产品级鉴权、计费、用户系统或前端页面。

## Constraints

- Read root `AGENTS.md` first.
- Read project `PROJECT.md`.
- Do not overwrite another agent's assigned notes.
- Record final decisions in `decisions.md`.
- This is a Markdown-only coordination task.
- Real implementation happens in the external cloud server TTS project.
- If external paths are sensitive, record only safe aliases or sanitized paths.

