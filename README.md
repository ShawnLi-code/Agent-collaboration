# Agent Collaboration

多模型、多项目协作仓库。GPT 5.5、DeepSeek V4、Claude 4.8、千问 3.7 Max、智谱 GLM 5.2 通过文件交接协作，不依赖聊天上下文。

核心原则：

- 所有 Agent 进入仓库后先读 `AGENTS.md`。
- 每个项目放在 `projects/<project-slug>/`。
- 每个任务的协作记录放在该项目的 `.agent-work/task-YYYY-MM-DD-<task-slug>/`。
- Agent 之间通过文件交接，不靠聊天记录。

## 模型分工

| 模型 | 角色 | 主要职责 |
|------|------|----------|
| GPT 5.5 | Builder | 生成训练代码、config、数据预处理脚本 |
| DeepSeek V4 | Validator | 校验超参数合理性（独立于 Claude） |
| Claude 4.8 | Reviewer | 审查代码逻辑、写 risks.md（独立于 DeepSeek） |
| 千问 3.7 Max | Memory | 持有训练日志、维护 experiments.md |
| 智谱 GLM 5.2 | Docs | 整理项目文档、同步 GitHub |

## 协作流程

```
Human 写 brief.md
    ↓
GPT 5.5 生成代码和 config
    ↓
DeepSeek V4 校验超参  ←── 独立并行 ──→  Claude 4.8 审查代码逻辑
    ↓
Human 对比两份意见，写入 decisions.md
    ↓
Smoke Test（过拟合 5 条样本，几分钟出结论）── 失败 → 回 GPT 5.5 修
    ↓ 通过
完整训练
    ↓
千问 3.7 Max 更新 experiments.md
智谱 GLM 5.2 整理文档
```

## 快速开始

```powershell
# 创建项目
.\scripts\New-AgentProject.ps1 -ProjectName "my-project"

# 创建任务包
.\scripts\New-AgentTask.ps1 -Project "my-project" -TaskName "first task"
```

任意 Agent 接手时，读取顺序：

1. `AGENTS.md`
2. `projects/<project-slug>/PROJECT.md`
3. 任务包的 `brief.md` → `plan.md`

## 目录结构

```text
.
├── AGENTS.md                  ← 所有 Agent 必读，含模型分工和协作规则
├── docs/workflow.md
├── projects/
│   ├── _template/
│   └── <project-slug>/
│       ├── PROJECT.md
│       └── .agent-work/
│           └── task-YYYY-MM-DD-<slug>/
│               ├── brief.md
│               ├── plan.md
│               ├── codex-notes.md
│               ├── claude-review.md
│               ├── risks.md
│               ├── decisions.md
│               ├── done.md
│               └── experiments.md  ← 实验记录（千问维护）
├── scripts/
│   ├── New-AgentProject.ps1
│   └── New-AgentTask.ps1
└── templates/task-package/
```
