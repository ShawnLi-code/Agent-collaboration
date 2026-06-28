# Global Agent Rules

所有 Agent 进入仓库后必须先读本文件。

---

## 模型分工

| 角色 | 模型 | 主要职责 | 能力上限说明 |
|------|------|----------|-------------|
| **Reviewer** | Claude 4.8 | 审查训练代码逻辑正确性、review plan.md 漏洞、写 `risks.md` 和 `claude-review.md` | 负责判断，不负责数值推导 |
| **Builder** | GPT 5.5 | 生成训练代码、config、数据预处理脚本、MiniMax API 调用 | 负责实现，不做最终代码审查 |
| **Parameter Validator** | DeepSeek V4 | 校验超参数合理性（batch size / lr / steps / 数据量的数量级关系）、发现数值层面的明显错误 | 只校验数值逻辑，不做代码风格判断 |
| **Context Holder** | 千问 3.7 Max | 持有完整训练日志、历史 checkpoint 对比、多次实验记录，回答"上次 X 参数跑出了什么结果" | 负责记忆和检索，不做决策 |
| **Doc Sync** | 智谱 GLM 5.2 | 整理 `done.md` / 实验记录为项目知识文档，同步 GitHub wiki | 负责整理，不做代码相关判断 |

---

## 协作流程

```
Human 写 brief.md
    ↓
GPT 5.5：生成训练代码 + config
    ↓
DeepSeek V4：独立校验超参数合理性（不共享 GPT 输出，独立判断）
    ↓
Claude 4.8：独立审查代码逻辑，写 claude-review.md + risks.md
    ↓
Smoke Test 门禁（过拟合 5 条样本，几分钟内出结论）
    ↓  失败 → 回 GPT 5.5 修复
    ↓  通过
完整训练（上云算力）
    ↓
千问 3.7 Max：持有训练日志，更新实验记录
智谱 GLM 5.2：整理进项目文档，同步 GitHub
```

**Smoke Test 说明**：取 1~5 条音频，训 200~500 步（几分钟），确认 loss 能下降且能复现这几条样本。失败 = 训练代码有根本性错误，不进入完整训练。

---

## 反点头规则

DeepSeek 和 Claude 做审查时，**独立运行，不共享彼此输出**。最后由 Human 对比两份意见。若先让 Claude review 再把结论喂给 DeepSeek，后者大概率附和，审查失效。

---

## 仓库结构

- 每个项目：`projects/<project-slug>/`
- 每个任务：`projects/<project-slug>/.agent-work/task-YYYY-MM-DD-<task-slug>/`
- 协作状态必须写入文件，不能只留在聊天上下文

## 必读顺序

开始任何任务前：

1. `AGENTS.md`（本文件）
2. `projects/<project-slug>/PROJECT.md`
3. 当前任务包的 `brief.md`
4. 当前任务包的 `plan.md`

## 任务包文件

每个任务包必须包含：

| 文件 | 负责 Agent | 内容 |
|------|-----------|------|
| `brief.md` | Human | 目标、背景、成功标准、范围 |
| `plan.md` | GPT 5.5 | 当前被接受的计划 |
| `codex-notes.md` | GPT 5.5 / Codex | 执行记录、命令、验证结果 |
| `claude-review.md` | Claude 4.8 | 审查、反例、替代方案 |
| `risks.md` | Claude 4.8 | 风险、未验证假设、失败模式 |
| `decisions.md` | Human 决策 | 最终决策和不采纳理由 |
| `done.md` | 执行 Agent | 完成状态、验收证据、剩余问题 |
| `experiments.md` | 千问 3.7 Max | 实验记录（见格式规范） |

## 实验记录格式（experiments.md）

```markdown
| 日期 | config 摘要 | Smoke Test | 训练时长 | loss 趋势 | 结论 | 可用 |
|------|------------|-----------|---------|----------|------|------|
| 2026-06-28 | lr=1e-4, bs=8, steps=5000 | ✅ | 10h | 下降后震荡 | lr 偏高 | ❌ |
```

每次训练结束必须填一行，不论成败。此文件由千问 3.7 Max 持有和维护。

---

## 角色边界

- **Human / Owner**：定义目标、决定最终取舍、批准高风险变更
- **GPT 5.5 / Builder**：写代码、生成 config、跑数据流水线
- **DeepSeek V4 / Validator**：校验超参数值，独立于 Claude
- **Claude 4.8 / Reviewer**：审查逻辑，独立于 DeepSeek
- **千问 3.7 Max / Memory**：持有历史，不做决策
- **智谱 GLM 5.2 / Docs**：整理文档，不做代码判断

任何 Agent 不能静默覆盖其他 Agent 的记录文件。需要修改别人结论时，在 `decisions.md` 记录原因。

---

## 审查格式

```text
Issue:
Impact:
Evidence:
Recommended action:
```

## Git 规则

- 默认分支用于稳定状态
- 不在未读取任务包的情况下改项目文件
- 不把临时实验直接合并到稳定分支
- 不用 `git reset --hard`、强推、删除分支解决冲突，除非 Human 明确要求
