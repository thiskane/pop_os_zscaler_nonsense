#!/bin/bash
set -euo pipefail

ZSCALER_DIR="/opt/zscaler/bin"
PID_FILE="/tmp/zstray.pid"

usage() {
    echo "Usage: $0 {start|stop}"
    exit 1
}

start_zscaler() {
    echo "[+] Re-writing /etc/os-release for Ubuntu 22.04"
    sudo bash -c 'cat > /etc/os-release << EOF
PRETTY_NAME="Ubuntu 22.04.2 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.2 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
EOF'
	    
    echo "[+] Starting Zscaler services..."

    # Start zsaservice if not running
    if ! pgrep -f zsaservice >/dev/null; then
        sudo systemctl start zsaservice
        echo "  - zsaservice started"
        sleep 2
    else
        echo "  - zsaservice already running"
    fi

    # Start ZSTray if not already running
    if ! pgrep -f ZSTray >/dev/null; then
        "$ZSCALER_DIR/ZSTray" &
        ZSTRAY_PID=$!
        echo "$ZSTRAY_PID" > "$PID_FILE"
        echo "  - ZSTray launched (pid=$ZSTRAY_PID)"
    else
        echo "  - ZSTray already running"
    fi

    echo "[+] Zscaler started"
    sleep 20

    echo "[+] Re-writing /etc/os-release back to Pop_OS 22.04"
    sudo bash -c 'cat > /etc/os-release << EOF
NAME="Pop!_OS"
VERSION="22.04 LTS"
ID=pop
ID_LIKE="ubuntu debian"
PRETTY_NAME="Pop!_OS 22.04 LTS"
VERSION_ID="22.04"
HOME_URL="https://pop.system76.com"
SUPPORT_URL="https://support.system76.com"
BUG_REPORT_URL="https://github.com/pop-os/pop/issues"
PRIVACY_POLICY_URL="https://system76.com/privacy"
VERSION_CODENAME=jammy
UBUNTU_CODENAME=jammy
EOF'

}

stop_zscaler() {
    echo "[+] Stopping Zscaler services..."

    # Stop ZSTray if running
    if pgrep -f ZSTray >/dev/null; then
        pkill -f ZSTray
        echo "  - ZSTray stopped"
    else
        echo "  - ZSTray not running"
    fi

    # Stop zsaservice
    if pgrep -f zsaservice >/dev/null; then
        sudo systemctl stop zsaservice
        echo "  - zsaservice stopped"
    else
        echo "  - zsaservice not running"
    fi

    # Cleanup
    [ -f "$PID_FILE" ] && rm -f "$PID_FILE"

    echo "[+] Zscaler stopped"
}

# ─── MAIN ──────────────────────────────────────────────────────

if [ $# -ne 1 ]; then
    usage
fi

case "$1" in
    start)
        start_zscaler
        ;;
    stop)
        stop_zscaler
        ;;
    *)
        usage
        ;;
esac

