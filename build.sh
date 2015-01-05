#!/bin/bash
# builds a vagrant-libvirt box

set -euo pipefail
set -x  # unlock dev mode here!

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source "$DIR/lib/common.sh"

function create_builder_params() {
    BUILDER_PARAMS=(
        "$OS_VERSION"
        "--output" "$TMP_DIR/built.qcow2"
        "--format" "qcow2"
        "--size" "${IMAGE_SIZE}G"
        "--root-password" "password:vagrant"
        "--password" "vagrant:password:vagrant"
        "--write" "/root/vagrant_pub_key:${VAGRANT_PUB_KEY}"
        "--install" "rsync,nfs-utils"  # for Vagrant file transfer
        "--run" "files/prepare_vm.sh"
        "--run-command" "touch /.autorelabel"
    )
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
    if [ ! -v VAGRANT_PUB_KEY ]; then
        echo "Variable VAGRANT_PUB_KEY must be set."
        exit 1
    fi

    # make sure there's a trailing newline in VAGRANT_PUB_KEY
    VAGRANT_PUB_KEY="${VAGRANT_PUB_KEY%'\n'}"$'\n'
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
