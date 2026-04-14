# Ralph Loop 项目需求

## 目标

完善 Ralph Loop —— 一个极简自动化开发循环工具。
通过一个 `PROMPT.md` + shell 脚本，让 AI Agent 自动完成开发任务。

## 当前状态

项目已有基础代码，请先分析当前实现，识别已完成和待完善的部分，再制定计划。

## 最终产物

- `ralph-loop` 脚本功能完整且稳定
- `README.md` 包含完整的使用指南和最佳实践
- `.ralph/` 目录结构和约束文件经过充分验证
- 有可运行的验证/测试机制
- `examples/` 目录包含不同类型项目的 PROMPT.md 编写示例

## 具体要求

1. 制定 PROMPT.md 编写规范，让用户知道如何高效编写需求文档
2. 在 `examples/` 目录提供至少 2 种类型项目的 PROMPT.md 示例（如 CLI 工具、Web 应用）
3. README.md 需要覆盖：安装、快速开始、工作流程、常见问题
4. 验证机制能自动检测核心功能是否正常

## 验证方式

- `ralph-loop init` → 正确生成 .ralph/ 目录结构，幂等不覆盖已有文件
- `ralph-loop help` → 输出完整帮助信息
- `ralph-loop run N` → 能正常启动循环并调用 qwen
- `ralph-loop status` → 能生成状态分析 prompt
- 所有核心命令返回值正确，无报错

## 约束

- 保持极简，不引入外部依赖
- Shell 脚本兼容 bash
- 新增功能必须有对应文档说明
- 所有验证和测试必须在隔离目录（如临时目录或 `.test/`）中进行，不得影响项目本身文件
