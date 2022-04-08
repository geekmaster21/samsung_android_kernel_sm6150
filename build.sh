#!/bin/bash

KERNEL_DEFCONFIG=a71_eur_open_defconfig

echo
echo "==> Clean Build Directory"
echo

echo
echo "==> Issue Build Commands"
echo

mkdir -p out
export HOME=/workspace/samsung_android_kernel_sm6150
export ARCH=arm64
export SUBARCH=arm64
export CLANG_PATH=$HOME/azure-clang/bin
export PATH="$CLANG_PATH:$PATH"
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
export KBUILD_BUILD_USER=MasterKernelv2
export KBUILD_BUILD_HOST=OVH
KERNEL_MAKE_ENV="DTC_EXT=$HOME/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

START=$(date +"%s")

echo
echo "==> Kernel is using the current defconfig: $KERNEL_DEFCONFIG"
echo
 
make CC=clang LD=ld.lld $KERNEL_MAKE_ENV AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out $KERNEL_DEFCONFIG

echo
echo "==> Begin compilation..."
echo 

make CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out -j$(nproc --all)

echo
echo "==> Verify Image.gz.dtb and dtbo.img..."
echo

ls $PWD/out/arch/arm64/boot/Image.gz-dtb
ls $PWD/out/arch/arm64/boot/dtbo.img

END=$(date +"%s")
DIFF=$((END - START))

echo
echo "==> Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"
echo