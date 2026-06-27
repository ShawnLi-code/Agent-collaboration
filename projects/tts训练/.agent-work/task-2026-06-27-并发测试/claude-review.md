# Claude Code 实现审查记录

## 实现摘要

在云服务器真实 TTS 项目中开放了文本转音频 HTTP 接口。基于已存在的 `api_tts.py`（StyleTTS2 项目），验证配置、修复端口绑定、添加 `/health` 端点，并在 AutoDL 云平台完成端到端测试。

## 变更文件列表

| 文件 | 操作 | 说明 |
|------|------|------|
| `kokoro-deutsch/StyleTTS2/api_tts.py` | 修改（添加 6 行） | 添加 `/health` 端点 |

## 关键代码变更

### 新增：`/health` 健康检查端点（`api_tts.py:172-176`）

```python
@app.get("/health")
async def health():
    """健康检查"""
    return {"status": "ok", "device": str(DEVICE), "model": PRESET["name"]}
```

### 核心配置（`api_tts.py` 预设参数，未变更）

```python
PRESET = {
    "name": "epoch53_scale1.5_seed9999",
    "ckpt": "logs/C_diff_own_correct/epoch_2nd_00053.pth",
    "config": "logs/C_diff_own_correct/config_C_diff_own_correct.yml",
    "embedding_scale": 1.5,     # scale=1.5
    "seed": 9999,                # seed=9999
    "speed": 1.0,
    "diffusion_steps": 10,
}
```

### 关键推理管线（`api_tts.py:97-159`）

合成函数 `synthesize()`：
1. 设置 `torch.manual_seed(seed)` + `np.random.seed(seed)` + `cuda.manual_seed_all(seed)`
2. 使用 `KPipeline(lang_code="z")` 将中文文本转为音素
3. `TextCleaner` 将音素转为 token IDs
4. `model.text_encoder` + `model.bert` 编码文本
5. `DiffusionSampler(ADPM2Sampler, KarrasSchedule)` 采样 style 向量，应用 `embedding_scale`
6. 时长预测 + alignment → decoder → 音频输出

### API 端点

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/health` | 健康检查 |
| GET | `/` | Web UI 表单 |
| GET/POST | `/synthesize` | 文本转音频 |
| GET | `/preset` | 查看当前预设参数 |
| GET | `/docs` | FastAPI Swagger 文档 |

### 输入验证

- 空文本 → `400 {"detail":"文本不能为空"}`
- 文本 > 500 字 → `400 {"detail":"文本过长，限制500字"}`
- 异常捕获 → `500 {"detail":"<错误信息>"}`

## 启动命令

```bash
cd /root/autodl-tmp/kokoro-deutsch/StyleTTS2
nohup python api_tts.py > /tmp/tts_api.log 2>&1 &
```

服务运行在 **端口 8123**，绑定 `0.0.0.0`。

## 防火墙 / 安全组设置

### AutoDL 云平台（本实例环境）

服务器位于 **AutoDL** 平台（westX 区域），使用 **frp (frpc)** 做内网穿透：

- 内网 IP: `172.17.0.3`
- 容器 UUID: `60034c9a8d-5d91dc27`
- 公网入口: `https://u539523-9a8d-5d91dc27.westx.seetacloud.com:8443`

**开放端口的两种方式：**

**方式 A — AutoDL 网页控制台（推荐）：**
1. 登录 [AutoDL 控制台](https://www.autodl.com)
2. 进入"容器实例" → 选择当前实例
3. 点击"自定义服务" → 添加：
   - 服务名称：`tts-api`
   - 端口：`8123`
4. 保存后即可通过公网 URL 访问

**方式 B — SSH 隧道（临时调试用）：**
```bash
ssh -L 8123:localhost:8123 root@116.172.96.170 -p <ssh_port>
```

### 安全边界说明

- 当前无认证/鉴权机制（v1 范围外）
- 建议：仅在 AutoDL 自定义服务中暴露，利用平台内置的访问控制
- 建议：如有公网直接暴露需求，应在前置加 nginx 反向代理 + 基础认证

## 请求示例

### POST（程序调用推荐）

```bash
curl -X POST http://localhost:8123/synthesize \
  -H "Content-Type: application/json" \
  -d '{"text":"您好，欢迎致电客服中心。"}' \
  -o output.wav
```

### GET（浏览器/简单测试）

```bash
# 中文需 URL 编码
curl -o output.wav "http://localhost:8123/synthesize?text=%E6%82%A8%E5%A5%BD%EF%BC%8C%E6%AC%A2%E8%BF%8E%E8%87%B4%E7%94%B5%E5%AE%A2%E6%9C%8D%E4%B8%AD%E5%BF%83%E3%80%82"
```

### 自定义参数

```bash
curl -X POST http://localhost:8123/synthesize \
  -H "Content-Type: application/json" \
  -d '{"text":"测试自定义参数。","seed":1234,"embedding_scale":2.0}' \
  -o output.wav
```

## 响应格式

- **成功**：`audio/wav` 二进制（PCM 16-bit, mono, 24000 Hz）
- **失败**：`application/json`（HTTP 400/500）
- **响应头**：
  - `X-Preset`: `epoch53_scale1.5_seed9999`
  - `X-Seed`: 使用的种子值
  - `X-Scale`: 使用的 scale 值
  - `X-Duration-S`: 音频时长（秒）

## 测试结果

| 测试 | 结果 | 说明 |
|------|------|------|
| `GET /health` | ✅ 200 | `{"status":"ok","device":"cuda","model":"epoch53_scale1.5_seed9999"}` |
| `GET /preset` | ✅ 200 | 预设参数正确：scale=1.5, seed=9999, device=cuda |
| `POST /synthesize` 短文本 | ✅ 200 | 3.48s 音频, 166KB, 24000Hz mono PCM16 |
| `GET /synthesize` URL编码中文 | ✅ 200 | 2.72s 音频, 130KB |
| `POST /synthesize` 自定义参数 | ✅ 200 | 2.33s 音频, 111KB, seed=1234, scale=2.0 |
| `POST /synthesize` 空文本 | ✅ 400 | `{"detail":"文本不能为空"}` |
| `GET /synthesize` 空文本 | ✅ 400 | `{"detail":"文本不能为空"}` |
| 超长文本 (>500字) | ✅ 400 | `{"detail":"文本过长，限制500字"}` |
| 长文本 (200字) | ✅ 200 | 16.97s 音频, 814KB |
| `GET /docs` | ✅ 200 | Swagger UI |
| `GET /` | ✅ 200 | HTML Web 表单 |

## 未解决问题 / 风险

1. **鉴权缺失**：当前无认证机制，任何人可调用。生产部署需要添加 API Key 鉴权。
2. **输出文件累积**：`/root/autodl-tmp/api_tts_output/` 目录会累积生成的 WAV 文件，无自动清理策略。建议添加定时清理或基于 LRU 的自动删除。
3. **并发限制**：当前单进程单线程（uvicorn 默认），高并发下可能阻塞。建议后续使用 gunicorn + uvicorn workers 或异步队列。
4. **内存占用**：模型约 3.6GB GPU 显存，需确保实例有足够显存。
5. **外部访问配置**：需用户在 AutoDL 控制台手动添加自定义服务端口映射，本文档已提供详细步骤。

## 与 plan.md 的对照

| plan 要求 | 状态 | 说明 |
|-----------|------|------|
| 第53轮权重 | ✅ | `epoch_2nd_00053.pth`，路径已验证存在 |
| scale=1.5, seed=9999 | ✅ | PRESET 硬编码，可被请求参数覆盖 |
| 绑定 `0.0.0.0` | ✅ | `uvicorn.run(app, host="0.0.0.0", port=8123)` |
| 输入验证 | ✅ | 空文本拒绝 + 超500字拒绝 |
| 健康检查端点 | ✅ | `GET /health` |
| 请求/响应格式文档 | ✅ | 本文档 + Swagger `/docs` |
| 音频输出目录 | ✅ | `/root/autodl-tmp/api_tts_output/` |
| 外部访问 | ⚠️ | 需 AutoDL 控制台手动配置自定义服务 |
| 本仓库无真实代码/权重 | ✅ | 仅在 Markdown 中记录摘要 |
