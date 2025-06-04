#!/usr/bin/env bash

KNOWN_HOSTS="$HOME/.ssh/known_hosts"
PORT="2222"
HOST="localhost"
USER="root"
PASSWORD="alpine"

COMMON_SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"

# 检查 ssh 是否连通
sshpass -p "$PASSWORD" ssh $COMMON_SSH_OPTS -p "$PORT" "$USER@$HOST" "echo ✅ 登录成功"
if [ $? -eq 0 ]; then
  echo "🔁 切换为交互会话..."
  exec sshpass -p "$PASSWORD" ssh $COMMON_SSH_OPTS -p "$PORT" "$USER@$HOST"
else
  echo "❌ 登录失败，请检查 iproxy 状态与密码"
fi
