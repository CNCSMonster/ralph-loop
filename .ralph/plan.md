# 工作计划

## 需求分析

根据 PROMPT.md，需要完善 Ralph Loop 项目：
1. 制定 PROMPT.md 编写规范，指导用户编写需求文档
2. 在 examples/ 目录提供至少 2 种类型项目的 PROMPT.md 示例（CLI 工具、Web 应用）
3. README.md 需要覆盖：安装、快速开始、工作流程、常见问题
4. 验证机制能自动检测核心功能是否正常

当前项目状态：
- 核心脚本 ralph-loop 已实现 init/run/status/help 命令
- README.md 已有基础内容但不够完整
- 存在一个 bug：status 命令统计逻辑有问题（init 后还没有任务，却显示有 2 个任务）
- 缺少 examples/ 目录
- 缺少 PROMPT.md 编写规范
- 缺少自动化验证/测试机制

## 任务列表

- [x] task-001 修复 status 命令统计 bug（priority:1, passes:true）
- [x] task-002 添加自动化验证/测试机制（priority:1, passes:true）
- [x] task-003 制定 PROMPT.md 编写规范并写入 README.md（priority:2, passes:true）
- [x] task-004 创建 examples/cli-tool/PROMPT.md 示例（priority:2, passes:true）
- [x] task-005 创建 examples/web-app/PROMPT.md 示例（priority:2, passes:true）
- [ ] task-006 完善 README.md（priority:3, passes:false）

## 调整历史

- 2026-04-14: 初始计划，根据 PROMPT.md 需求分解任务
- 2026-04-14 迭代 3: task-003 完成，验证次数达到 3/3，但仍有 task-004/005/006 待完成，继续执行
- 2026-04-14 迭代 5: task-005 完成，创建了 web-app 示例，同时更新 bug_report.md 标记已修复的 bug
