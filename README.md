# Agent Collaboration

这是一个让 Codex、Claude Code、Trae 和其他智能体围绕同一项目协作的 Git 仓库。

核心原则：

- 根目录保存全局协作规则，任何智能体进入仓库后先读根目录规则。
- 每个真实项目放在 `projects/<project-slug>/` 下。
- 每个项目的任务协作记录放在该项目自己的 `.agent-work/` 下。
- Agent 之间不靠聊天记录交接，必须把目标、计划、审查、风险、决策和完成证据写入文件。

## 快速开始

创建一个项目：

```powershell
.\scripts\New-AgentProject.ps1 -ProjectName "my reading assistant"
```

创建一个项目任务：

```powershell
.\scripts\New-AgentTask.ps1 -Project "my-reading-assistant" -TaskName "first collaboration test"
```

然后让任意智能体按这个顺序读取：

1. `AGENTS.md`
2. 自己对应的角色文件：`CLAUDE.md` 或 `TRAE.md`
3. `projects/<project-slug>/PROJECT.md`
4. `projects/<project-slug>/.agent-work/task-YYYY-MM-DD-<task-slug>/brief.md`
5. `projects/<project-slug>/.agent-work/task-YYYY-MM-DD-<task-slug>/plan.md`

## 目录结构

```text
.
├── AGENTS.md
├── CLAUDE.md
├── TRAE.md
├── docs/
│   └── workflow.md
├── projects/
│   ├── README.md
│   └── _template/
├── scripts/
│   ├── New-AgentProject.ps1
│   └── New-AgentTask.ps1
└── templates/
    └── task-package/
```

## 推荐工作流

1. 人类创建项目文件夹，并把项目资料放进去。
2. 人类或 Codex 创建任务包。
3. Codex 读取项目和任务包，写计划并执行。
4. Claude Code 只做审查、风险和替代方案。
5. Trae 可做工程实现、UI 集成、运行检查或补充审查，具体看任务包分配。
6. 最终状态写入 `done.md`，不要只留在聊天窗口。

## Git 分支建议

每个任务可以使用这些分支：

```text
agent/<project-slug>/<task-slug>/main
agent/<project-slug>/<task-slug>/codex
agent/<project-slug>/<task-slug>/claude
agent/<project-slug>/<task-slug>/trae
agent/<project-slug>/<task-slug>/review
```

分支不是强制要求。小任务可以只用任务包文件协作；涉及代码改动、多人并行时再开分支或 worktree。

