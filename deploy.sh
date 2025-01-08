#!/bin/bash

# 获取当前脚本的所在目录
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# 切换到 Makefile 所在的工作目录 (即脚本所在目录的父目录)
cd "$SCRIPT_DIR" || exit 1

# 检查参数
if [ $# -lt 2 ]; then
  echo "Usage: $0 <REMOTE_HOST> <REMOTE_DIR>"
  echo "Example: $0 m920x /path/to/remote/directory"
  exit 1
fi

# 从参数获取 REMOTE_HOST 和 REMOTE_DIR
REMOTE_HOST="$1"
REMOTE_DIR="$2"


# 使用第3个参数作为提交信息，如果未提供参数，则使用默认信息
COMMIT_MESSAGE=${3:-"更新页面"}

# 执行 Git 操作
git add .
git commit -m "$COMMIT_MESSAGE"
git push -u origin main

# 定义本地目录
LOCAL_DIR="public" # 脚本同级目录下的 public

# 上传文件到远程并覆盖
echo "正在上传 public 目录下的所有文件到 $REMOTE_HOST:$REMOTE_DIR..."
rsync -azqhP --delete \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude '__MACOSX' \
  "$LOCAL_DIR/" "$REMOTE_HOST:$REMOTE_DIR" | tee /dev/null

# 检查上传是否成功
if [ $? -eq 0 ]; then
  echo "文件上传成功！"
else
  echo "文件上传失败，请检查连接或权限配置。"
  exit 1
fi