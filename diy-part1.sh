#!/bin/bash
#=============================================================
# diy-part1.sh For ImmortalWrt v25.12.2 K2P
# 执行时机：./scripts/feeds update -a 之前
#=============================================================
set -e

# 说明一：ImmortalWrt 的 luci feed 里已自带 luci-theme-argon，
# 再从 jerrykuku 仓库 clone 一份会出现同名 package，构建时冲突，
# 所以这里不克隆，直接用 feeds 里的版本。

# 说明二：K2P 只有 16MB flash，OpenClash 加上内核体积会直接超，
# 第一次编译先不装。确认镜像还有余量再放开下面两行：
# rm -rf package/luci-app-openclash
# git clone --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 【注意】下面老源对 25.12 兼容性差，请勿启用
#sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
#sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default

echo "[i] diy-part1: 保持 feeds 默认，未引入外部仓库"
