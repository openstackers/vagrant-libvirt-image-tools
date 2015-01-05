if [ ! -v DIR ]; then
    echo "Internal error: DIR variable not set when sourcing lib/common.sh."
    exit 1
fi

TEMPLATES_DIR="$DIR/templates"
OUT_DIR="$DIR/output"
TMP_DIR="$DIR/tmp"

function create_box() {
    cp "$TEMPLATES_DIR/metadata.json" "$TMP_DIR/metadata.json"
    sed -i -e "s/__IMAGE_SIZE__/$IMAGE_SIZE/" "$TMP_DIR/metadata.json"

    cp "$TEMPLATES_DIR/Vagrantfile" "$TMP_DIR/Vagrantfile"

    # run the image to perform SELinux relabel
    qemu-system-x86_64 \
       -no-reboot \
       -nographic \
       -machine accel=kvm:tcg \
       -cpu host \
       -m 2048 \
       -drive file="$TMP_DIR/built.qcow2,if=virtio" \
       -serial null

    # minify the image
    qemu-img convert -O qcow2 "$TMP_DIR/built.qcow2" "$TMP_DIR/box.img"

    tar -cvzf "$OUT_DIR/$BOX_NAME.box" --directory "$TMP_DIR" metadata.json Vagrantfile box.img
}

function prepare() {
    mkdir "$OUT_DIR" || true
    mkdir "$TMP_DIR" || true
}

function cleanup() {
    rm -r "$TMP_DIR" || true
}
