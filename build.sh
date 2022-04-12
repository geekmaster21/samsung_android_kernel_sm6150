#!/usr/bin/env bash
# Copyright ©2022 XSans02
# Kernel Build Script

# Color
RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

# environtment
KERNEL_DIR="$PWD"
KERNEL_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image"
KERNEL_DTBO="$KERNEL_DIR/out/arch/arm64/boot/dtbo.img"
KERNEL_DTB="$KERNEL_DIR/out/arch/arm64/boot/dts/qcom/"
AK3_DIR="$HOME/AK3/"
BASE_DTB_NAME="sm8150-v2"
CODENAME="vayu"
DEFCONFIG="vayu_defconfig"
CORES=$(grep -c ^processor /proc/cpuinfo)
CPU=$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*) */\1/p')
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
COMMIT="$(git log --pretty=format:'%s' -1)"

# Setup Clang
export PATH="$HOME/clang/bin:$PATH"
CLANG_DIR="$HOME/clang"
PrefixDir="$CLANG_DIR/bin/"
KBUILD_COMPILER_STRING="$(${CLANG_DIR}/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

# Export
export TZ="Asia/Jakarta"
export ZIP_DATE="$(TZ=Asia/Jakarta date +'%d%m%Y')"
export ZIP_DATE2="$(TZ=Asia/Jakarta date +"%H%M")"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="XSansツ"
export KBUILD_BUILD_HOST="Wibu-Server"
export KBUILD_COMPILER_STRING

# Telegram Setup
git clone --depth=1 https://github.com/XSans02/Telegram Telegram

TELEGRAM=Telegram/telegram
send_msg() {
  "${TELEGRAM}" -c "${CHANNEL_ID}" -H -D \
      "$(
          for POST in "${@}"; do
              echo "${POST}"
          done
      )"
}

send_file() {
  "${TELEGRAM}" -f "$(echo "$AK3_DIR"/*.zip)" \
  -c "${CHANNEL_ID}" -H \
      "$1"
}

send_log() {
  "${TELEGRAM}" -f "$(echo out/log.txt)" \
  -c "${CHANNEL_ID}" -H \
      "$1"
}

# Menu
while true; do
    echo -e "$GREEN" ""
    echo -e " Menu                                                               "
    echo -e " ╔═════════════════════════════════════════════════════════════════╗"
    echo -e " ║ 1. Export defconfig to Out Dir                                  ║"
    echo -e " ║ 2. Start Compile With Clang                                     ║"
    echo -e " ║ 3. Start Compile With Clang LLVM                                ║"
    echo -e " ║ 4. Copy Image to Flashable Dir                                  ║"
    echo -e " ║ 5. Copy dtbo to Flashable Dir                                   ║"
    echo -e " ║ 6. Copy dtb to Flashable Dir                                    ║"
    echo -e " ║ 7. Make Zip                                                     ║"
    echo -e " ║ 8. Upload to Telegram                                           ║"
    echo -e " ║ 9. Upload to Gdrive                                             ║"
    echo -e " ║ e. Back Main Menu                                               ║"
    echo -e " ╚═════════════════════════════════════════════════════════════════╝"
    echo -ne "\n Enter your choice 1-9, or press 'e' for back to Main Menu : " "$ENDCOLOR"

    read -r menu

    # Export deconfig
    if [[ "$menu" == "1" ]]; then
        make O=out $DEFCONFIG
        echo -e "$GREEN" "\n (i) Success export $DEFCONFIG to Out Dir" "$ENDCOLOR"
        echo -e ""
    fi

    # Build With Clang
    if [[ "$menu" == "2" ]]; then
        echo -e ""
        START=$(date +"%s")
        CURRENTDATE=$(date +"%A, %d %b %Y, %H:%M:%S")
        echo -e "$GREEN" "\n (i) Start Compile kernel for $CODENAME, started at $CURRENTDATE using $CPU $CORES thread"
        echo -e "\n" "$ENDCOLOR"
        send_msg "<b>New Kernel On The Way</b>" \
                 "<b>==================================</b>" \
                 "<b>Device : </b>" \
                 "<code>* $CODENAME</code>" \
                 "<b>Branch : </b>" \
                 "<code>* $BRANCH</code>" \
                 "<b>Build Using : </b>" \
                 "<code>* $CPU $CORES thread</code>" \
                 "<b>Last Commit : </b>" \
                 "<code>* $COMMIT</code>" \
                 "<b>==================================</b>"

        # Run Build
        make -j"$CORES" O=out CC=clang AR=llvm-ar NM=llvm-nm LD=ld.lld OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee out/log.txt

        if ! [ -a "$KERNEL_IMG" ]; then
            echo -e "$RED" "\n (!) Compile Kernel for $CODENAME failed, See buildlog to fix errors" "$ENDCOLOR"
            send_log "<b>Build Failed, See log to fix errors</b>"
            exit
        fi

        END=$(date +"%s")
        TOTAL_TIME=$(("$END" - "$START"))
        echo -e "$GREEN" "\n (i) Compile Kernel for $CODENAME successfully, Kernel Image in $KERNEL_IMG"
        echo -e " (i) Total time elapsed: $(("$TOTAL_TIME" / 60)) Minutes, $(("$TOTAL_TIME" % 60)) Second."
        echo -e "\n" "$ENDCOLOR"

        send_msg "<b>Build Successfully</b>" \
                 "<b>==================================</b>" \
                 "<b>Build Date : </b>" \
                 "<code>* $(date +"%A, %d %b %Y, %H:%M:%S")</code>" \
                 "<b>Build Took : </b>" \
                 "<code>* $(("$TOTAL_TIME" / 60)) Minutes, $(("$TOTAL_TIME" % 60)) Second.</code>" \
                 "<b>Compiler : </b>" \
                 "<code>* $KBUILD_COMPILER_STRING</code>" \
                 "<b>==================================</b>"
    fi

        # Build With Clang LLVM
    if [[ "$menu" == "3" ]]; then
        echo -e ""
        START=$(date +"%s")
        CURRENTDATE=$(date +"%A, %d %b %Y, %H:%M:%S")
        echo -e "$GREEN" "\n (i) Start Compile kernel for $CODENAME, started at $CURRENTDATE using $CPU $CORES thread"
        echo -e "\n" "$ENDCOLOR"
        send_msg "<b>New Kernel On The Way</b>" \
                 "<b>==================================</b>" \
                 "<b>Device : </b>" \
                 "<code>* $CODENAME</code>" \
                 "<b>Branch : </b>" \
                 "<code>* $BRANCH</code>" \
                 "<b>Build Using : </b>" \
                 "<code>* $CPU $CORES thread</code>" \
                 "<b>Last Commit : </b>" \
                 "<code>* $COMMIT</code>" \
                 "<b>==================================</b>"

        # Run Build
        make -j"$CORES" O=out CC=clang LD=${PrefixDir}ld.lld AR=${PrefixDir}llvm-ar NM=${PrefixDir}llvm-nm AS=${PrefixDir}llvm-as STRIP=${PrefixDir}llvm-strip OBJCOPY=${PrefixDir}llvm-objcopy OBJDUMP=${PrefixDir}llvm-objdump READELF=${PrefixDir}llvm-readelf HOSTAR=${PrefixDir}llvm-ar HOSTAS=${PrefixDir}llvm-as HOSTLD=${PrefixDir}ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee out/log.txt

        if ! [ -a "$KERNEL_IMG" ]; then
            echo -e "$RED" "\n (!) Compile Kernel for $CODENAME failed, See buildlog to fix errors" "$ENDCOLOR"
            send_log "<b>Build Failed, See log to fix errors</b>"
            exit
        fi

        END=$(date +"%s")
        TOTAL_TIME=$(("$END" - "$START"))
        echo -e "$GREEN" "\n (i) Compile Kernel for $CODENAME successfully, Kernel Image in $KERNEL_IMG"
        echo -e " (i) Total time elapsed: $(("$TOTAL_TIME" / 60)) Minutes, $(("$TOTAL_TIME" % 60)) Second."
        echo -e "\n" "$ENDCOLOR"

        send_msg "<b>Build Successfully</b>" \
                 "<b>==================================</b>" \
                 "<b>Build Date : </b>" \
                 "<code>* $(date +"%A, %d %b %Y, %H:%M:%S")</code>" \
                 "<b>Build Took : </b>" \
                 "<code>* $(("$TOTAL_TIME" / 60)) Minutes, $(("$TOTAL_TIME" % 60)) Second.</code>" \
                 "<b>Compiler : </b>" \
                 "<code>* $KBUILD_COMPILER_STRING</code>" \
                 "<b>==================================</b>"
    fi

    # Move kernel image to flashable dir
    if [[ "$menu" == "4" ]]; then
        cp "$KERNEL_IMG" "$AK3_DIR"/

        echo -e "$GREEN" "\n (i) Done moving kernel img to $AK3_DIR" "$ENDCOLOR"
    fi

    # Move dtbo to flashable dir
    if [ "$menu" == "5" ]; then
        cd "$AK3_DIR" || exit
        cp "$KERNEL_DTBO" "$AK3_DIR"/
        cd "$KERNEL_DIR" || exit

        echo -e "$GREEN" "\n(i) Done moving dtbo to $AK3_DIR." "$ENDCOLOR"
    fi

    # Move dtb to flashable dir
    if [ "$menu" == "6" ]; then
        cd "$AK3_DIR" || exit

        if [[ -f $KERNEL_DTB/${BASE_DTB_NAME}.dtb ]]; then
		cp "$KERNEL_DTB/${BASE_DTB_NAME}.dtb" "$AK3_DIR/dtb.img"
	fi

        cd "$KERNEL_DIR" || exit

        echo -e "$GREEN" "\n(i) Done moving dtb to $AK3_DIR." "$ENDCOLOR"
    fi

    # Make Zip
    if [[ "$menu" == "7" ]]; then
        cd "$AK3_DIR" || exit
        ZIP_NAME=["$ZIP_DATE"]Weeaboo-"$ZIP_DATE2".zip
        zip -r9 "$ZIP_NAME" ./*
        cd "$KERNEL_DIR" || exit

        echo -e "$GREEN" "\n (i) Done Zipping Kernel" "$ENDCOLOR"
    fi

    # Upload Telegram
    if [[ "$menu" == "8" ]]; then
        send_log
        send_file "<b>md5 : </b><code>$(md5sum "$AK3_DIR/$ZIP_NAME" | cut -d' ' -f1)</code>"

	    echo -e "$GREEN" "\n (i) Done Upload to Telegram" "$ENDCOLOR"
    fi

    # Upload Gdrive
    if [[ "$menu" == "9" ]]; then
        if [[ -d "/usr/sbin/gdrive" ]]; then
            gdrive upload "$AK3_DIR/$ZIP_NAME"
            send_log
            send_msg "<code>$ZIP_NAME</code>" \
                     "<b>md5 : </b><code>$(md5sum "$AK3_DIR/$ZIP_NAME" | cut -d' ' -f1)</code>" \
                     "<b>Uploaded to gdrive</b>"

            echo -e "$GREEN" "\n (i) Done Upload to Gdrive" "$ENDCOLOR"
        else
            echo -e "$RED" "Please setup your gdrive first!" "$NOCOLOR"
        fi
    fi

    # Exit
    if [[ "$menu" == "e" ]]; then
        exit
    fi

done
