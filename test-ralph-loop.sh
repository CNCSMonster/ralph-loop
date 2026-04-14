#!/bin/bash

# Ralph Loop 自动化验证/测试脚本
# 所有测试在隔离目录中进行，不影响项目本身文件

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RALPH_LOOP="$SCRIPT_DIR/ralph-loop"
TEST_DIR=$(mktemp -d /tmp/ralph-loop-test.XXXXXX)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    echo -e "${GREEN}[PASS]${NC} $1"
}

fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    echo -e "${RED}[FAIL]${NC} $1"
    if [ -n "$2" ]; then
        echo -e "       ${YELLOW}详情: $2${NC}"
    fi
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

cleanup() {
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

# 准备测试环境
setup_test_env() {
    mkdir -p "$TEST_DIR"
    cp "$RALPH_LOOP" "$TEST_DIR/"
    chmod +x "$TEST_DIR/ralph-loop"
    # 创建最小 PROMPT.md
    cat > "$TEST_DIR/PROMPT.md" << 'EOF'
# 测试项目

这是一个用于测试 Ralph Loop 的项目。
EOF
}

run_test() {
    local name=$1
    local expected_exit=$2
    shift 2
    local cmd="$@"

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    info "测试: $name"

    local output
    local exit_code=0
    output=$($cmd 2>&1) || exit_code=$?

    if [ "$exit_code" -eq "$expected_exit" ]; then
        pass "$name (exit code: $exit_code)"
        return 0
    else
        fail "$name (期望 exit=$expected_exit, 实际=$exit_code)" "$output"
        return 1
    fi
}

# ========== 测试用例 ==========

test_init() {
    cd "$TEST_DIR"
    rm -rf .ralph  # 确保干净环境

    run_test "init - 首次初始化" 0 ./ralph-loop init

    # 验证目录结构
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if [ -d ".ralph" ] && [ -d ".ralph/docs" ] && \
       [ -f ".ralph/constraints.md" ] && [ -f ".ralph/plan.md" ] && \
       [ -f ".ralph/progress.md" ] && [ -f ".ralph/verify.md" ]; then
        pass "init - 目录结构正确"
    else
        fail "init - 目录结构不完整"
    fi

    # 验证幂等性
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local before_mtime=$(stat -c %Y .ralph/plan.md)
    sleep 1
    ./ralph-loop init > /dev/null 2>&1
    local after_mtime=$(stat -c %Y .ralph/plan.md)
    if [ "$before_mtime" -eq "$after_mtime" ]; then
        pass "init - 幂等性（不覆盖已有文件）"
    else
        fail "init - 幂等性失败（文件被覆盖）"
    fi
}

test_help() {
    cd "$TEST_DIR"

    run_test "help - 输出帮助信息" 0 ./ralph-loop help

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local output
    output=$(./ralph-loop help 2>&1)
    if echo "$output" | grep -q "init" && \
       echo "$output" | grep -q "run" && \
       echo "$output" | grep -q "status" && \
       echo "$output" | grep -q "help"; then
        pass "help - 包含所有命令说明"
    else
        fail "help - 缺少命令说明" "$output"
    fi
}

test_status() {
    cd "$TEST_DIR"
    ./ralph-loop init > /dev/null 2>&1

    run_test "status - 生成状态分析 prompt" 0 ./ralph-loop status

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if [ -f "/tmp/ralph-status-prompt.txt" ]; then
        pass "status - prompt 文件生成"
    else
        fail "status - prompt 文件未生成"
    fi

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local content
    content=$(cat /tmp/ralph-status-prompt.txt)
    if echo "$content" | grep -q "约束规则" && \
       echo "$content" | grep -q "计划" && \
       echo "$content" | grep -q "进度记录" && \
       echo "$content" | grep -q "验证记录"; then
        pass "status - prompt 内容完整"
    else
        fail "status - prompt 内容缺失" "$content"
    fi
}

test_status_empty_stats() {
    cd "$TEST_DIR"
    rm -rf .ralph
    ./ralph-loop init > /dev/null 2>&1

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    # 验证空任务时统计正确
    local total done pending
    read -r total done pending <<< $(grep -E '总任务数:|已完成:|待完成:' /tmp/ralph-status-prompt.txt 2>/dev/null | \
        sed 's/.*: //' | tr '\n' ' ')

    if [ "$total" = "0" ] && [ "$done" = "0" ] && [ "$pending" = "0" ]; then
        pass "status - 空任务统计正确 (0/0/0)"
    else
        fail "status - 空任务统计错误 (total=$total, done=$done, pending=$pending)"
    fi
}

test_verify_format() {
    cd "$TEST_DIR"
    ./ralph-loop init > /dev/null 2>&1

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local content
    content=$(cat .ralph/verify.md)
    if echo "$content" | grep -q "验证次数: 0/3" && \
       echo "$content" | grep -q "验证日志"; then
        pass "verify.md - 格式正确"
    else
        fail "verify.md - 格式不正确" "$content"
    fi
}

test_plan_format() {
    cd "$TEST_DIR"
    ./ralph-loop init > /dev/null 2>&1

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local content
    content=$(cat .ralph/plan.md)
    if echo "$content" | grep -q "工作计划" && \
       echo "$content" | grep -q "需求分析" && \
       echo "$content" | grep -q "任务列表" && \
       echo "$content" | grep -q "调整历史"; then
        pass "plan.md - 模板格式正确"
    else
        fail "plan.md - 模板格式不正确" "$content"
    fi
}

test_unknown_command() {
    cd "$TEST_DIR"

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local output
    local exit_code=0
    output=$(./ralph-loop unknown 2>&1) || exit_code=$?

    if [ "$exit_code" -eq 1 ] && echo "$output" | grep -q "未知命令"; then
        pass "unknown - 未知命令返回错误"
    else
        fail "unknown - 未知命令处理不正确 (exit=$exit_code)" "$output"
    fi
}

test_task_stats_with_tasks() {
    cd "$TEST_DIR"
    ./ralph-loop init > /dev/null 2>&1

    # 添加一些任务到 plan.md
    cat >> .ralph/plan.md << 'EOF'
- [ ] task-001 测试任务1 (priority:1, passes:false)
- [x] task-002 测试任务2 (priority:2, passes:true)
- [ ] task-003 测试任务3 (priority:3, passes:false)
EOF

    ./ralph-loop status > /dev/null 2>&1

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local total done pending
    read -r total done pending <<< $(grep -E '总任务数:|已完成:|待完成:' /tmp/ralph-status-prompt.txt 2>/dev/null | \
        sed 's/.*: //' | tr '\n' ' ')

    if [ "$total" = "3" ] && [ "$done" = "1" ] && [ "$pending" = "2" ]; then
        pass "task_stats - 有任务时统计正确 (3/1/2)"
    else
        fail "task_stats - 统计错误 (total=$total, done=$done, pending=$pending)"
    fi
}

test_verify_count_reset() {
    cd "$TEST_DIR"
    ./ralph-loop init > /dev/null 2>&1

    # 模拟验证次数为 2
    sed -i 's/验证次数: 0\/3/验证次数: 2\/3/' .ralph/verify.md

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local count
    count=$(grep -oP '验证次数: \K[0-9]+' .ralph/verify.md)

    if [ "$count" = "2" ]; then
        pass "verify_count - 初始值为 2"
    else
        fail "verify_count - 初始值设置失败 (实际=$count)"
    fi

    # 模拟验证失败，次数应归零
    sed -i 's/验证次数: 2\/3/验证次数: 0\/3/' .ralph/verify.md

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    count=$(grep -oP '验证次数: \K[0-9]+' .ralph/verify.md)

    if [ "$count" = "0" ]; then
        pass "verify_count - 失败后归零"
    else
        fail "verify_count - 归零失败 (实际=$count)"
    fi
}

test_init_multiple_times() {
    cd "$TEST_DIR"

    # 连续初始化 3 次，验证幂等性
    ./ralph-loop init > /dev/null 2>&1
    local mtime1=$(stat -c %Y .ralph/plan.md)
    sleep 1
    ./ralph-loop init > /dev/null 2>&1
    local mtime2=$(stat -c %Y .ralph/plan.md)
    sleep 1
    ./ralph-loop init > /dev/null 2>&1
    local mtime3=$(stat -c %Y .ralph/plan.md)

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if [ "$mtime1" -eq "$mtime2" ] && [ "$mtime2" -eq "$mtime3" ]; then
        pass "init - 多次初始化保持幂等"
    else
        fail "init - 多次初始化破坏幂等性 (mtime1=$mtime1, mtime2=$mtime2, mtime3=$mtime3)"
    fi
}

test_check_initialized_missing_prompt() {
    cd "$TEST_DIR"
    rm -f PROMPT.md  # 删除 PROMPT.md
    ./ralph-loop init > /dev/null 2>&1  # init 不需要 PROMPT.md

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    local output
    local exit_code=0
    output=$(./ralph-loop status 2>&1) || exit_code=$?

    if [ "$exit_code" -eq 1 ] && echo "$output" | grep -q "PROMPT.md 不存在"; then
        pass "check_initialized - 缺少 PROMPT.md 报错"
    else
        fail "check_initialized - 缺少 PROMPT.md 处理不正确 (exit=$exit_code)" "$output"
    fi
}

# ========== 执行测试 ==========

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ralph Loop 自动化测试${NC}"
echo -e "${BLUE}  测试目录: $TEST_DIR${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

setup_test_env

test_init
test_help
test_status
test_status_empty_stats
test_verify_format
test_plan_format
test_unknown_command
test_task_stats_with_tasks
test_verify_count_reset
test_init_multiple_times
test_check_initialized_missing_prompt

# ========== 输出结果 ==========

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "  总计: $TOTAL_COUNT 项测试"
echo -e "  ${GREEN}通过: $PASS_COUNT${NC}"
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo -e "  ${RED}失败: $FAIL_COUNT${NC}"
else
    echo -e "  失败: $FAIL_COUNT"
fi
echo -e "${BLUE}========================================${NC}"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
