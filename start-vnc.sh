#!/bin/bash
set -euo pipefail

# 0) X ソケット置き場の権限（非rootならビルド時に作っておく）
if [ ! -d /tmp/.X11-unix ]; then
  echo "/tmp/.X11-unix がありません。Dockerfileで root で作成して 1777 にしてください。"
  exit 1
fi

# 1) DISPLAY 固定
export DISPLAY=:1

# 2) Xvfb 起動（UNIX ソケットは有効のまま、TCP は閉じる）
Xvfb :1 -screen 0 1280x1024x24 -ac -nolisten tcp >/tmp/xvfb.log 2>&1 &
XVFB_PID=$!

# 3) DISPLAY 準備待ち
for i in $(seq 1 50); do
  if xdpyinfo >/dev/null 2>&1; then break; fi
  sleep 0.2
done

# 4) Fluxbox 起動
fluxbox >/tmp/fluxbox.log 2>&1 &
FLUX_PID=$!

# 5) Playwright（GUIで表示したいもの）
playwright launch-server --browser chromium --config playwright-server-config.json >/tmp/playwright.log 2>&1 &
PW_PID=$!

# 6) x11vnc（既存 :1 に接続。-create は付けない）
x11vnc -display :1 -nopw -localhost -xkb -ncache 10 -ncache_cr -forever >/tmp/x11vnc.log 2>&1 &
VNC_PID=$!

# 7) noVNC
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 >/tmp/novnc.log 2>&1 &
NOVNC_PID=$!

# 8) どれかが落ちたら終了（必要なら監視/再起動を追加）
wait -n "$XVFB_PID" "$FLUX_PID" "$PW_PID" "$VNC_PID" "$NOVNC_PID" &
tail -f /tmp/*.log
