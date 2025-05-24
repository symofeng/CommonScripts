#!/usr/bin/env bash

KNOWN_HOSTS="/Users/symofeng/.ssh/known_hosts"
SCRIPT_PATH="$0"

function run_expect {
expect <<EOF
set timeout 10
set host "localhost"
set port "2222"
set user "root"
set password "alpine"

spawn ssh -p \$port \$user@\$host

expect {
    -re "Are you sure you want to continue connecting.*" {
        send "yes\r"
        exp_continue
    }
    -re "assword:" {
        send "\$password\r"
        exp_continue
    }
    -re "Permission denied" {
        send_user "❌ 密码错误或权限被拒绝，请检查密码。\n"
        exit 1
    }
    -re "Host key verification failed." {
        send_user "⚠️ Host key verification failed. 正在尝试清除 known_hosts...\n"
        exit 2
    }
    -re "\\\$ $" {
        send_user "✅ 登录成功。\n"
        interact
    }
    timeout {
        send_user "⏰ 连接超时，请检查设备连接与 iproxy 状态。\n"
        exit 3
    }
    eof {
        send_user "⚠️ ssh 连接已意外结束。\n"
        exit 4
    }
}
EOF
}

# 第一次尝试
run_expect
status=$?

# 如果是 Host key 问题，执行 rm 并重试一次
if [ "$status" -eq 2 ]; then
  echo "🧹 正在删除 $KNOWN_HOSTS..."
  rm -f "$KNOWN_HOSTS"

  echo "🔁 正在重新连接..."
  run_expect
fi
