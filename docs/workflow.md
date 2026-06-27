# Multi-Agent Workflow

## 一次协作的完整流程

1. 创建项目：`projects/<project-slug>/`
2. 把项目资料放进项目目录。
3. 创建任务包：`projects/<project-slug>/.agent-work/task-YYYY-MM-DD-<task-slug>/`
4. 人类或主控 Agent 填写 `brief.md`。
5. Codex 读取项目和任务包，生成或更新 `plan.md`。
6. Claude Code 审查 `plan.md`，把问题写入 `claude-review.md` 和 `risks.md`。
7. Codex 或 Trae 执行计划，并分别写入 `codex-notes.md` 或 `trae-notes.md`。
8. Claude Code 做最终审查。
9. 主控 Agent 或人类把最终取舍写入 `decisions.md`。
10. 完成状态写入 `done.md`。

## 项目目录应该放什么

每个项目目录建议包含：

```text
projects/<project-slug>/
├── PROJECT.md
├── source/
├── docs/
├── outputs/
└── .agent-work/
```

- `PROJECT.md`：项目目标、资料说明、协作约束。
- `source/`：项目原始资料或代码。
- `docs/`：项目文档。
- `outputs/`：最终产物。
- `.agent-work/`：任务包和协作记录。

## 什么时候开 Git 分支

只读分析、写文档、小修改：可以不开分支。

以下情况建议开分支或 worktree：

- 多个 Agent 同时改代码。
- 任务超过一天。
- 涉及生成大量文件。
- 涉及不可逆操作、迁移、批量重命名。

