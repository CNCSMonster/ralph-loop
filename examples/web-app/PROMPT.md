# 在线书签管理器

## 目标
使用 Python Flask 构建一个简单的在线书签管理 Web 应用。

## 当前状态
- 空项目，只有 README.md
- 需要从零开始实现

## 具体要求

### 核心功能
1. **用户注册/登录**
   - 简单的用户名 + 密码注册
   - 登录 session 管理
   - 未登录用户只能访问登录/注册页面

2. **书签管理**
   - 添加书签：URL、标题、标签（多个，逗号分隔）
   - 查看书签列表：按添加时间倒序，支持分页（每页 20 条）
   - 搜索书签：按标题或标签模糊搜索
   - 删除书签：用户只能删除自己的书签

3. **标签云**
   - 侧边栏显示热门标签（使用最多的前 20 个）
   - 点击标签可过滤书签

### 技术约束
1. 使用 Python 3.10+ 和 Flask
2. 使用 SQLite 存储数据
3. 使用 Flask-Login 处理用户认证
4. 模板使用 Jinja2 + Bootstrap CDN
5. 不引入额外的前端框架（如 React/Vue）
6. 密码使用 werkzeug 的 generate_password_hash 加密

### 项目结构
```
bookmark-app/
├── app.py              # Flask 应用主入口
├── models.py           # 数据库模型
├── requirements.txt    # Python 依赖
├── templates/          # Jinja2 模板
│   ├── base.html       # 基础布局
│   ├── login.html      # 登录页面
│   ├── register.html   # 注册页面
│   ├── bookmarks.html  # 书签列表
│   └── add_bookmark.html  # 添加书签
└── static/
    └── css/
        └── style.css   # 自定义样式
```

## 验证方式

### 启动应用
```bash
pip install -r requirements.txt
python app.py
```
应用应在 `http://localhost:5000` 启动

### 功能验证
1. **注册/登录**
   - 访问 `/register` → 显示注册表单
   - 注册新用户 → 跳转到登录页
   - 访问 `/login` → 显示登录表单
   - 登录成功 → 跳转到书签列表

2. **书签操作**
   - 未登录访问 `/bookmarks` → 重定向到登录页
   - 登录后访问 `/bookmarks` → 显示书签列表（空或分页）
   - 访问 `/add` → 显示添加表单
   - 提交添加书签 → 返回列表页，新书签出现在顶部

3. **搜索功能**
   - 在搜索框输入关键词 → 显示匹配的书签
   - 搜索不存在的标签 → 显示空结果提示

4. **标签云**
   - 侧边栏显示标签云 → 标签按使用频率排序
   - 点击标签 → 只显示包含该标签的书签

### 数据库验证
```bash
sqlite3 bookmarks.db ".tables"        # 应显示 users, bookmarks 表
sqlite3 bookmarks.db ".schema users"  # 应包含 id, username, password_hash
```

## 提示
- 数据库初始化应在 app.py 启动时自动执行（如果不存在）
- 分页使用 Flask-SQLAlchemy 的 paginate 方法
- 标签云查询使用 GROUP BY 和 ORDER BY count
- 错误处理：所有表单验证失败应显示 flash 消息
- 样式尽量简洁，使用 Bootstrap 默认样式即可
