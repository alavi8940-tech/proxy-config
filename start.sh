#!/bin/bash

# ============================================================
# 🚀 GitHub Codespaces Proxy - One Shot Setup
# ============================================================

set -e
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔥 راه‌اندازی پروکسی Codespaces...${NC}"

# ۱. نصب پیش‌نیازها
echo -e "${YELLOW}[۱/۴] نصب ابزارها...${NC}"
sudo apt update -qq && sudo apt install -y -qq tmux curl git build-essential netcat-openbsd

# ۲. نصب microsocks (پروکسی SOCKS5 فوق‌سبک)
echo -e "${YELLOW}[۲/۴] نصب microsocks...${NC}"
cd /tmp
git clone --quiet https://github.com/rofl0r/microsocks
cd microsocks && make -s && sudo cp microsocks /usr/local/bin/
cd ~

# ۳. نصب cloudflared (تونل WebSocket رایگان)
echo -e "${YELLOW}[۳/۴] نصب cloudflared...${NC}"
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared && sudo mv cloudflared /usr/local/bin/

# ۴. اجرا
echo -e "${YELLOW}[۴/۴] راه‌اندازی سرویس...${NC}"
tmux new-session -d -s proxy
tmux send-keys -t proxy "microsocks -i 127.0.0.1 -p 1080" Enter
sleep 2
tmux new-window -t proxy -n tunnel
tmux send-keys -t tunnel "cloudflared tunnel --url http://127.0.0.1:1080" Enter
sleep 5

# گرفتن لینک
TUNNEL_LOG=$(tmux capture-pane -t tunnel -p -S -10)
LINK=$(echo "$TUNNEL_LOG" | grep -oP 'https://[a-zA-Z0-9-]+\.trycloudflare\.com' | head -1)

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✅ راه‌اندازی شد!${NC}"
echo -e "${GREEN}🌐 لینک اتصال: ${LINK:-'یه لحظه صبر کن...'}${NC}"
echo -e "${GREEN}📡 پورت پروکسی: 1080${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}برای دیدن لاگ: tmux attach -t proxy${NC}"
echo -e "${YELLOW}برای خروج از tmux: Ctrl+B سپس D${NC}"
echo ""
