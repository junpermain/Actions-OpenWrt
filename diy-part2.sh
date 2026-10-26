#!/bin/bash
#============================================================
# diy-part2 for K2P phicomm_k2p
# After Update feeds | For ImmortalWrt openwrt‑25.12
#============================================================

device_name='K2P'
wifi_name='K2P'
lan_ip='192.168.2.1'
utc_name='Asia/Shanghai'
default_theme='argon'

# 创建开机自动执行的uci-defaults脚本，首次启动自动配置
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-custom-k2p <<EOF
#!/bin/sh
# 设置主机名
uci set system.@system[0].hostname="${device_name}"
# 设置LAN IP
uci set network.lan.ipaddr="${lan_ip}"
# 设置时区
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='${utc_name}'
# 设置LuCI默认主题
uci set luci.main.mediaurlbase="/luci-static/${default_theme}"
uci commit system
uci commit network
uci commit luci
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-custom-k2p
echo "[+] 写入uci‑defaults系统配置(主机名/IP/时区/主题)"

# 尝试修改mac80211默认wifi名称（兼容旧版本，新版可能无效）
wifi_file="package/kernel/mac80211/files/lib/wifi/mac80211.sh"
if [ -f "${wifi_file}" ]; then
  echo "[+] 修改mac80211默认WiFi SSID: ${wifi_name}"
  sed -i "s/OpenWrt/${wifi_name}/g" "${wifi_file}"
fi

echo "[✓] diy-part2.sh finished"
