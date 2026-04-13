# Ralph Loop

极简自动化开发循环 - 只需一个 `PROMPT.md`，让 AI Agent 自动完成开发任务。

## 安装

单脚本，无需依赖，复制到 `~/.local/bin` 即可全局使用：

```bash
cp ralph-loop ~/.local/bin/ralph-loop
chmod +x ~/.local/bin/ralph-loop
```

确保 `~/.local/bin` 在你的 `PATH` 中：

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

安装后任意目录可直接运行 `ralph-loop` 命令。

## 原理

核心就是一个 `while` 循环，每次全新上下文启动 AI，通过文件系统持久化状态。

## 快速开始

### 1. 编写需求

创建 `PROMPT.md`，写入你的项目需求。

### 2. 初始化

```bash
ralph-loop init
```

自动生成 `.ralph/` 下的约束文件和状态文件模板（不会覆盖已有文件）。

### 3. 启动循环

```bash
ralph-loop run        # 默认 50 次迭代
ralph-loop run 100    # 指定 100 次
```

### 4. 配合 AI

脚本会自动启动 `qwen --yolo` 执行任务，无需人工干预。

如果需要在迭代之间暂停观察，可以在 qwen 执行完成后按 `Ctrl+C` 中断脚本。

### 5. 断点续跑

如果迭代次数用完但任务没完成，直接再次 `run` 即可，会从上次进度继续：

```bash
ralph-loop run 20     # 继续之前的进度
```

## 命令

| 命令 | 说明 |
|------|------|
| `ralph-loop init` | 初始化项目结构（幂等，不覆盖已有文件） |
| `ralph-loop run [N]` | 启动循环，N 为最大迭代次数（默认 50） |
| `ralph-loop status` | 生成状态分析 prompt，交给 qwen-code 分析 |
| `ralph-loop help` | 显示帮助 |

## 文件结构

```
.
├── PROMPT.md                     # 需求文档（唯一需要你写的）
├── ralph-loop                    # 主脚本
└── .ralph/
    ├── constraints.md            # AI 约束规则（自动生成，❌ 禁止修改）
    ├── plan.md                   # 计划与任务状态（✅ AI 更新）
    ├── progress.md               # 进度记录（✅ AI 更新）
    ├── verify.md                 # 验证记录（✅ AI 更新）
    └── docs/                     # 子任务 spec（✅ AI 可选）
```

## 工作流程

```
PROMPT.md
  ↓
ralph-loop run
  ↓
while 循环 N 次:
  1. AI 读取 constraints.md + plan.md + progress.md
  2. AI 判断是否需要调整 plan.md
  3. AI 选择下一个任务 → 实现 → 验证
  4. AI 更新 plan.md + progress.md + verify.md
  5. 脚本规则检查:
     - 验证发现问题 → 次数归零 → 继续
     - 全部通过 或 验证3次 → 结束
     - 其他 → 继续
```

## 约束机制

`.ralph/constraints.md` 定义 AI 必须遵守的规则：
- 调整计划 → 选择任务 → 实现 → 验证 → 更新状态 → 提交
- **只有此文件禁止 AI 修改**，其他状态文件 AI 自由读写
- `plan.md` 有格式约定，脚本通过正则 `passes:(true|false)` 统计任务状态

## 完成条件

循环在以下情况结束：
- ✅ `.ralph/plan.md` 中所有任务 `passes:true`
- ✅ `.ralph/verify.md` 验证次数达到 3 次
- ❌ 达到最大迭代次数
- 用户输入 `quit`

## 常见问题

**Q: 可以中断后继续吗？**
A: 可以。状态持久化在文件中，随时 `ralph-loop run N` 即可续跑。

**Q: 会覆盖我之前写的进度吗？**
A: 不会。`init` 是幂等的，已有文件不会覆盖。

**Q: 如何自定义验证命令？**
A: 在 `PROMPT.md` 中说明项目使用的测试/验证方式，AI 会按照约束规则执行。
