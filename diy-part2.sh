#!/bin/bash
#============================================================
# diy-part2 for K2P phicomm_k2p
# 执行时机：feeds 已安装、.config 已放入之后
# Target: ImmortalWrt v25.12.2
#============================================================
set -e

device_name='K2P'
wifi_name='K2P'
lan_ip='192.168.2.1'
utc_name='Asia/Shanghai'
default_theme='argon'

# ---------- 1. 首次启动自动配置（uci-defaults 在 network 启动前执行，IP 能生效） ----------
mkdir -p package/base-files/files/etc/uci-defaults
cat > package/base-files/files/etc/uci-defaults/99-custom-k2p <<EOF
#!/bin/sh
uci set system.@system[0].hostname="${device_name}"
uci set network.lan.ipaddr="${lan_ip}"
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='${utc_name}'
uci set luci.main.mediaurlbase="/luci-static/${default_theme}"
uci commit system
uci commit network
uci commit luci
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-custom-k2p
echo "[+] uci-defaults: hostname=${device_name} lan=${lan_ip} tz=${utc_name} theme=${default_theme}"

# ---------- 2. 默认 WiFi SSID（25.12 路径是 wifi-scripts 的 .uc 文件） ----------
wifi_ok=0
for f in \
  package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc \
  package/kernel/mac80211/files/lib/wifi/mac80211.sh ; do
  [ -f "$f" ] || continue
  # 25.12 源码里是双引号：${defaults?.ssid || "ImmortalWrt"}，两种引号都处理
  sed -i "s/|| \"ImmortalWrt\"/|| \"${wifi_name}\"/g" "$f"
  sed -i "s/|| \"OpenWrt\"/|| \"${wifi_name}\"/g" "$f"
  sed -i "s/|| 'ImmortalWrt'/|| '${wifi_name}'/g" "$f"
  sed -i "s/|| 'OpenWrt'/|| '${wifi_name}'/g" "$f"
  if grep -qE "\|\| [\"']${wifi_name}[\"']" "$f"; then
    echo "[+] 默认 SSID 已改为 ${wifi_name}  (${f})"
    wifi_ok=1
    break
  fi
done
[ "$wifi_ok" -eq 1 ] || echo "[!] 未找到默认 SSID 定义文件，跳过（不影响编译）"

# ---------- 3. 默认主题依赖（25.12 在 luci-light 集合里） ----------
if [ -f feeds/luci/collections/luci-light/Makefile ]; then
  theme_mk='feeds/luci/collections/luci-light/Makefile'
else
  theme_mk='feeds/luci/collections/luci/Makefile'
fi
sed -i "s/+luci-theme-bootstrap/+luci-theme-${default_theme}/g" "$theme_mk"
echo "[+] 默认主题依赖已改为 ${default_theme}  (${theme_mk})"

# ---------- 4. cmake 4.x 兼容 ----------
# v25.12.2 会自己编一个 host cmake 4.2.0，而 lucihttp 等旧包写的是
# cmake_minimum_required(VERSION 2.6)，cmake 4 直接报错退出：
#   Compatibility with CMake < 3.5 has been removed from CMake
CMAKE_MK='include/cmake.mk'
if [ -f "$CMAKE_MK" ] && ! grep -q 'CMAKE_POLICY_VERSION_MINIMUM' "$CMAKE_MK"; then
  printf '\n# cmake 4.x: 放行 cmake_minimum_required < 3.5 的旧项目\nCMAKE_OPTIONS += -DCMAKE_POLICY_VERSION_MINIMUM=3.5\nCMAKE_HOST_OPTIONS += -DCMAKE_POLICY_VERSION_MINIMUM=3.5\n' >> "$CMAKE_MK"
  echo "[+] cmake 4 兼容参数已写入 ${CMAKE_MK}"
fi

# ---------- 5. 校验 ----------
fail=0
check() { grep -q "$2" "$1" 2>/dev/null && echo "  [OK]   $3" || { echo "  [FAIL] $3"; fail=1; }; }
check package/base-files/files/etc/uci-defaults/99-custom-k2p "hostname=\"${device_name}\"" "主机名"
check package/base-files/files/etc/uci-defaults/99-custom-k2p "${lan_ip}"                 "LAN IP"
check package/base-files/files/etc/uci-defaults/99-custom-k2p "CST-8"                     "时区"
check "$theme_mk" "luci-theme-${default_theme}"                                            "主题依赖"
check "$CMAKE_MK" "CMAKE_POLICY_VERSION_MINIMUM"                                           "cmake 4 兼容参数"
[ "$fail" -eq 0 ] || { echo "[x] 有定制项未生效，检查源码结构"; exit 1; }

echo "[✓] diy-part2.sh finished"
