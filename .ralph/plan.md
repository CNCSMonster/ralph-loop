# 工作计划

## 需求分析

根据 PROMPT.md 分析，项目需要：
1. `ralph-loop` 脚本功能完整且稳定
2. `README.md` 包含完整的使用指南和最佳实践
3. `.ralph/` 目录结构和约束文件经过充分验证
4. 有可运行的验证/测试机制
5. `examples/` 目录包含不同类型项目的 PROMPT.md 编写示例

当前状态评估：
- ✅ 基础脚本已实现（init, run, status, help）
- ✅ README.md 已有较完整文档
- ✅ examples/ 目录有 CLI 和 Web 两个示例
- ✅ 测试脚本已通过 11 项测试
- ✅ bug_report.md 中的 init 异常 bug 已在迭代 1 修复

待完善部分：
1. README.md 需要补充"最佳实践"章节
2. 需要补充更多测试用例覆盖边界情况
3. 验证 init 后 status 命令的统计逻辑（bug_report.md 提到的问题）

## 任务列表

- [x] task-001 补充 README.md 最佳实践章节 (priority:1, passes:true)
- [x] task-002 增强测试用例覆盖边界情况 (priority:2, passes:true)
- [x] task-003 验证并修复 init 后 status 统计逻辑 (priority:3, passes:true)
- [x] task-004 最终全量测试验证 (priority:4, passes:true)

## 调整历史

- 迭代 1: 初始计划，基于当前代码分析制定
