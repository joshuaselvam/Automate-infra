#!/usr/bin/env bash

readonly MIN_ANSIBLE_VERSION="2.8"

# Global Ansible config
export ANSIBLE_DEPRECATION_WARNINGS="False"

get_ansible_remote_environments () {
    ls -1 -I "localhost" -I "*.sample*" "${ROOT_PATH}/ansible/inventories"
}

check_ansible () {
    if ! command -v ansible > /dev/null; then
        echo_red "Ansible must be installed on your local machine. Please referer to README.md to see how."
        exit 1
    fi

    local current_ansible_version
    current_ansible_version="$(ansible --version | head -n1 | cut -d " " -f2)"

    if ! is_version_gte "${current_ansible_version}" "${MIN_ANSIBLE_VERSION}"; then
        echo_red "Your Ansible version (${current_ansible_version}) is not supported by Infra Automation."
        echo_red "Please upgrade it to at least version ${MIN_ANSIBLE_VERSION}"
        exit 1
    fi
}
