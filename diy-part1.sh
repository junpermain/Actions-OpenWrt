#!/bin/bash
#=============================================================
# diy-part1.sh For ImmortalWrt openwrt‑25.12 K2P
# Before Update feeds
#=============================================================

# 清理旧package，避免重复克隆
rm -rf package/luci-theme-argon
rm -rf package/luci-app-openclash

# 1. 拉取 Argon 主题（适配新版本luci）
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

# 2. 拉取 OpenClash
git clone https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 【注意】下面老源对25.12兼容性差，请勿启用
#sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
#sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default
