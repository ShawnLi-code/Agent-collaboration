# Global Agent Rules

本文件是所有智能体的入口规则。Codex、Claude Code、Trae 或其他 Agent 进入仓库后，必须先读取本文件。

## 协作目标

这个仓库不是单一项目代码库，而是多项目、多智能体协作仓库：

- 每个项目放在 `projects/<project-slug>/`。
- 每个任务放在项目内的 `.agent-work/task-YYYY-MM-DD-<task-slug>/`。
- 协作状态必须写入文件，不能只留在聊天上下文。

## 必读顺序

开始任何任务前，按顺序读取：

1. `AGENTS.md`
2. 当前智能体自己的角色规则文件，例如 `CLAUDE.md`、`TRAE.md`
3. `projects/<project-slug>/PROJECT.md`
4. 当前任务包的 `brief.md`
5. 当前任务包的 `plan.md`

如果缺少项目或任务包，先创建它们，不要直接开始改项目文件。

## 任务包文件

每个任务包必须包含：

- `brief.md`：目标、背景、成功标准、范围、约束。
- `plan.md`：当前被接受的计划。
- `codex-notes.md`：Codex 的执行记录、命令、验证结果。
- `claude-review.md`：Claude Code 的审查、反例、替代方案。
- `trae-notes.md`：Trae 的工程记录、UI/运行检查、补充实现说明。
- `risks.md`：风险、未验证假设、失败模式。
- `decisions.md`：最终决策和不采纳理由。
- `done.md`：完成状态、验收证据、剩余问题。

## 角色边界

- Human / Owner：定义目标、决定最终取舍、批准高风险变更。
- Codex / Builder：读代码、改代码、跑命令、写验证证据。
- Claude Code / Reviewer：审查计划和实现，指出漏洞、风险、过度设计。
- Trae / Engineer：按任务包分配做工程实现、界面集成、运行验证或补充审查。

任何 Agent 都不能静默覆盖其他 Agent 的记录文件。需要修改别人结论时，在 `decisions.md` 记录原因。

## Git 规则

默认分支用于稳定状态。多人并行时使用任务分支：

```text
agent/<project-slug>/<task-slug>/codex
agent/<project-slug>/<task-slug>/claude
agent/<project-slug>/<task-slug>/trae
agent/<project-slug>/<task-slug>/review
```

规则：

- 不在未读取任务包的情况下改项目文件。
- 不把临时实验直接合并到稳定分支。
- 不用 `git reset --hard`、强推、删除分支来解决协作冲突，除非人类明确要求。
- 如果发现未提交改动，先判断是否属于自己；不确定就记录并询问。

## 输出标准

任何审查意见都使用：

```text
Issue:
Impact:
Evidence:
Recommended action:
```

任何完成声明都必须说明：

- 改了什么。
- 如何验证。
- 哪些风险仍然存在。
- 哪些事情没有做。

