#!/bin/bash

BOX_NAME=centos-7.0
OS_VERSION=centos-7.0
IMAGE_SIZE=30

function build_image() {
    virt-builder "${BUILDER_PARAMS[@]}"
}
