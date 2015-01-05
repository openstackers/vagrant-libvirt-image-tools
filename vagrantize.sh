#!/bin/bash
# builds a vagrant-libvirt box

set -euo pipefail
set -x  # unlock dev mode here!

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source "$DIR/lib/common.sh"

VAGRANT_PUB_KEY="${VAGRANT_PUB_KEY:-ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key}"

function customize_image() {
    cp "$1" "$TMP_DIR/built.qcow2"
    virt-customize "${CUSTOMIZE_PARAMS[@]}"
}

function create_customize_params() {
    CUSTOMIZE_PARAMS=(
        "--add" "$TMP_DIR/built.qcow2"
        "--format" "qcow2"
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
    if [ ! -v IMAGE_SIZE ]; then
        echo "Variable IMAGE_SIZE must be set."
        exit 1
    fi

    # make sure there's a trailing newline in VAGRANT_PUB_KEY
    VAGRANT_PUB_KEY="${VAGRANT_PUB_KEY%'\n'}"$'\n'
}

function main() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 <image-path>"
        exit 1
    fi

    if [ ! -e "$1" ]; then
        echo "Image file '$1' not found."
    fi

    validate_variables

    prepare
    create_customize_params

    customize_image "$1"
    create_box
    cleanup
}

main "$@"
