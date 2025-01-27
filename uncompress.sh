#!/bin/bash

function zip_align() {
    TEMP="${1}"
    DEST="${2}"

    if [ ! -f "${TEMP}" ]; then
        echo "${TEMP} is NOT a file"
        return
    fi

    if [ -f "${DEST}" ]; then
        rm -f "${DEST}"
    fi

    zipalign -f 4 "${TEMP}" "${DEST}"
}

function compress_without_compression() {
    DIR="${1}"
    FILE="${2}"

    if [ -f "${FILE}" ]; then
        rm -f "${FILE}"
    fi

    pushd "${DIR}" >/dev/null
    zip -r "../${FILE}" . -x "*.DS_Store" -0 >/dev/null
    popd >/dev/null
}

function unzip_apk() {
    FILE="${1}"
    DIR="${2}"

    if [ -d "${DIR}" ]; then
        rm -rf "${DIR}"
    fi

    unzip -q "${FILE}" -d "${DIR}"
}

function repack() {
    SOURCE="${1}"
    TEMP_FILE="${2}"
    TEMP_DIR="${3}"

    echo "BEFORE: $(ls -lh "${SOURCE}")"

    unzip_apk "${SOURCE}" "${TEMP_DIR}"

    compress_without_compression "${TEMP_DIR}" "${TEMP_FILE}"

    zip_align "${TEMP_FILE}" "${SOURCE}"

    echo "AFTER: $(ls -lh "${SOURCE}")"

    clear_temp "${TEMP_FILE}" "${TEMP_DIR}"
}

function prepare() {
    FILE_PATH="${1}"

    if [ ! -f "${FILE_PATH}" ]; then
        echo "NOT FILE"
        echo "Please input a valid file"
        exit
    fi

    FILE_NAME=$(basename "${FILE_PATH}" .apk)
    TEMP_DIR="temp_dir_${FILE_NAME}"
    TEMP_PATH="temp_dir_${FILE_NAME}.apk"
    rm -rf "${TEMP_DIR}"
}

function clear_temp() {
    TEMP_FILE="${1}"
    TEMP_DIR="${2}"

    if [ -f "${TEMP_FILE}" ]; then
        rm -f "${TEMP_FILE}"
    fi

    if [ -d "${TEMP_DIR}" ]; then
        rm -rf "${TEMP_DIR}"
    fi
}

prepare "${1}"
repack "${FILE_PATH}" "${TEMP_PATH}" "${TEMP_DIR}"

