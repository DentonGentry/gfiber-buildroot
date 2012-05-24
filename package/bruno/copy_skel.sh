#!/bin/sh
set -x
TARGET_DIR=$1

cp -alf package/bruno/skel/. ${TARGET_DIR}/
