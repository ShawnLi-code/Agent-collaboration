# Brief

## Goal

读取当前 Kokoro TTS 微调训练代码，检查超参数是否合理，并提出可落地的优化方案。

## Background

- 基于 Kokoro（hexgrad 82M）进行微调训练
- 在云算力平台运行，每小时成本约 ¥2
- 单次完整训练耗时约 10 小时，跑出来的结果多次不可用
- 上一个任务（task-2026-06-27-并发测试）处理的是开放端口，本任务聚焦训练优化
- 协作仓库：https://github.com/ShawnLi-code/Agent-collaboration

## Your Role（GPT 5.5 / Builder）

按以下顺序执行：

1. **读取项目规则** — 先读 `AGENTS.md`，再读本项目 `PROJECT.md`
2. **获取训练代码** — 在当前云系统上搜索并读取训练脚本（搜索范围：用户目录、项目目录、home 下的常见工作目录）
3. **检查超参数** — 重点检查：learning rate、batch size、warmup steps、total steps、scheduler 类型、loss 函数、音频预处理参数
4. **写优化方案** — 写入 `plan.md`

## Success Criteria

- [ ] 列出当前超参数清单（从代码中提取，不要猜测）
- [ ] 每个可疑参数给出：当前值 / 建议值 / 原因
- [ ] 提出 Smoke Test 方案（5 条样本，几分钟跑完的配置）
- [ ] 至少一个降低云算力成本的优化点

## In Scope

- 训练超参数检查
- 数据预处理流水线合理性
- Smoke Test 配置
- 成本优化（减少无效训练时长）

## Out Of Scope

- 不修改 Kokoro 模型架构
- 不处理数据集采集
- 不做推理侧优化

## Constraints

- 先读 `AGENTS.md` 和 `PROJECT.md` 再动手
- 在云系统上搜索训练代码（不要凭空假设路径）
- 超参数校验由 DeepSeek V4 并行独立完成，不共享结论
- 结论写入 `plan.md`，风险写入 `risks.md`
