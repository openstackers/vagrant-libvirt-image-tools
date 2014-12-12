#!/bin/bash
# builds a vagrant-libvirt box

set -euo pipefail
set -x  # unlock dev mode here!

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
TEMPLATES_DIR="$DIR/templates"
OUT_DIR="$DIR/output"
TMP_DIR="$DIR/tmp"

function create_builder_params() {
    BUILDER_PARAMS=(
        "$OS_VERSION"
        "--output" "$TMP_DIR/built.qcow2"
        "--format" "qcow2"
        "--size" "${IMAGE_SIZE}G"
        "--root-password" "password:vagrant"
        "--run-command" "useradd vagrant"
        "--password" "vagrant:password:vagrant"
        "--write" "/etc/sudoers.d/90-vagrant:vagrant ALL=(ALL) NOPASSWD:ALL"
        "--run-command" "sed -i -r 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config"
        "--install" "rsync"
        "--run-command" "touch /.autorelabel"
    )
}

function create_box() {
    cp "$TEMPLATES_DIR/metadata.json" "$TMP_DIR/metadata.json"
    sed -i -e "s/__IMAGE_SIZE__/$IMAGE_SIZE/" "$TMP_DIR/metadata.json"

    cp "$TEMPLATES_DIR/Vagrantfile" "$TMP_DIR/Vagrantfile"

    # minify the image
    qemu-img convert -O qcow2 "$TMP_DIR/built.qcow2" "$TMP_DIR/box.img"

    tar -cvzf "$OUT_DIR/$BOX_NAME.box" --directory "$TMP_DIR" metadata.json Vagrantfile box.img
}

function validate_variables() {
    # TODO: DRY?
    if [ ! -v BOX_NAME ]; then
        echo "Variable BOX_NAME must be set."
        exit 1
    fi
    if [ ! -v OS_VERSION ]; then
        echo "Variable OS_VERSION must be set."
        exit 1
    fi
    if [ ! -v IMAGE_SIZE ]; then
        echo "Variable IMAGE_SIZE must be set."
        exit 1
    fi
}

function prepare() {
    mkdir "$OUT_DIR" || true
    mkdir "$TMP_DIR" || true
}

function cleanup() {
    rm -r "$TMP_DIR" || true
}

function main() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 <manifest-path>"
        exit 1
    fi

    if [ ! -e "$1" ]; then
        echo "Manifest file '$1' not found."
    fi

    source "$1"
    validate_variables

    prepare
    create_builder_params
    build_image
    create_box
    cleanup
}

main "$@"
