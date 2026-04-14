# Ralph Loop 项目需求

## 目标

开发一个 CLI 工具 `file-finder`，用于在指定目录中快速查找文件。
支持按文件名、扩展名、大小等条件过滤，并输出匹配结果。

## 当前状态

从零开始，尚未创建任何文件。

## 最终产物

- `file-finder.sh`：主脚本，支持多种查找模式
- `README.md`：使用说明
- 所有功能在隔离测试目录中验证通过

## 具体要求

1. 支持三种查找模式：
   - `--name PATTERN`：按文件名模糊匹配（使用 `find -iname`）
   - `--ext EXTENSION`：按扩展名查找（如 `--ext py` 找所有 `.py` 文件）
   - `--size SIZE`：按文件大小过滤（如 `--size +1M` 找大于 1MB 的文件）
2. 支持输出格式：
   - 默认：每行一个完整路径
   - `--count`：只输出匹配数量
   - `--json`：输出 JSON 数组（使用纯 shell 实现，不调用外部工具）
3. 必须有 `--help` 选项，输出清晰的帮助信息
4. 错误处理：
   - 目录不存在时给出明确错误提示
   - 无匹配结果时返回退出码 1 并提示 "No files found"
   - 无效参数时返回退出码 2 并显示用法

## 验证方式

- `./file-finder.sh --help` → 输出完整帮助，包含所有选项说明
- `./file-finder.sh /tmp --name "*.txt"` → 返回匹配的文件列表
- `./file-finder.sh /tmp --ext sh --count` → 返回数字
- `./file-finder.sh /nonexistent --name "x"` → 退出码非零，有错误提示
- `./file-finder.sh /tmp --invalid` → 退出码 2，有帮助信息

## 约束

- 纯 bash 实现，不依赖 Python、jq 等外部工具
- 兼容 bash 4.0+
- 保持脚本简洁，单文件不超过 200 行
- 测试在临时目录中进行，不修改系统文件
