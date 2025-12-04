MODPATH="${0%/*}"
. $MODPATH/common_func.sh

# Conditional early sensitive properties

# Samsung
resetprop_if_diff ro.boot.warranty_bit 0
resetprop_if_diff ro.vendor.boot.warranty_bit 0
resetprop_if_diff ro.vendor.warranty_bit 0
resetprop_if_diff ro.warranty_bit 0

# Realme
resetprop_if_diff ro.boot.realmebootstate green

# OnePlus
resetprop_if_diff ro.is_ever_orange 0

# Microsoft
for PROP in $(resetprop | grep -oE 'ro.*.build.tags'); do
    resetprop_if_diff $PROP release-keys
done

# Other
for PROP in $(resetprop | grep -oE 'ro.*.build.type'); do
    resetprop_if_diff $PROP user
done
resetprop_if_diff ro.adb.secure 1
if ! $SKIPDELPROP; then
    PROP_FILE="/dev/__properties__/u:object_r:bootloader_prop:s0"
    echo "搜索字符串位置..."

    # 搜索 verifyerrorpart 并替换所有匹配
    echo "搜索 verifyerrorpart..."
    VERIFYERRORPART_OFFSETS=$(grep -oba "verifyerrorpart" "$PROP_FILE" 2>/dev/null)

    if [ -n "$VERIFYERRORPART_OFFSETS" ]; then

        echo "$VERIFYERRORPART_OFFSETS" | while IFS=: read offset match; do
            if [ -n "$offset" ]; then
                echo "  找到 verifyerrorpart 在偏移: $offset"
                # 替换为 verifytrustpart (长度相同)
                echo -n "verifytrustpart" | dd of="$PROP_FILE" bs=1 seek=$offset conv=notrunc 2>/dev/null
            fi
        done
        echo "✓ 替换完成"
    else
        echo "未找到 verifyerrorpart"
    fi

    # 搜索 verifiedbooterror 并替换所有匹配
    echo -e "\n搜索 verifiedbooterror..."
    VERIFIEDBOOTERROR_OFFSETS=$(grep -oba "verifiedbooterror" "$PROP_FILE" 2>/dev/null)

    if [ -n "$VERIFIEDBOOTERROR_OFFSETS" ]; then
        echo "$VERIFIEDBOOTERROR_OFFSETS" | while IFS=: read offset match; do
            if [ -n "$offset" ]; then
                echo "  找到 verifiedbooterror 在偏移: $offset"
                # 替换为 verifiedboottrust (长度相同)
                echo -n "verifiedboottrust" | dd of="$PROP_FILE" bs=1 seek=$offset conv=notrunc 2>/dev/null
                count=$((count+1))
            fi
        done
        echo "✓ 替换完成"
    else
        echo "未找到 verifiedbooterror"
    fi

    echo -e "\n所有替换完成"
fi
resetprop_if_diff ro.boot.veritymode.managed yes
resetprop_if_diff ro.debuggable 0
resetprop_if_diff ro.force.debuggable 0
resetprop_if_diff ro.secure 1