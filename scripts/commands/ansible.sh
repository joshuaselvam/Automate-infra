#!/usr/bin/env bash
# Infra Automation ansible command
#
# Usage: ./infra-automation ansible ENVIRONMENT COMMAND
#

set -euo pipefail

readonly SELF_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SELF_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly ROOT_PATH="$(cd "${SELF_PATH}/../.." && pwd)"


source "${SELF_PATH}/../includes/common.sh"
source "${SELF_PATH}/../includes/ansible.sh"

usage() {
    local cmd="./infra-automation"

    local environments
    environments="$(get_ansible_remote_environments | awk '{ print "    " $1 }')"

    cat <<- EOF

Usage: ${cmd} ansible ENVIRONMENT <TARGET FROM INVENTORY> <ANSIBLE OPTIONS>

Execute a custom Ansible module on your VMs

Examples:
    ${cmd} ansible production docker --become -m apt -a "update_cache=yes upgrade=safe"
    ${cmd} ansible production docker -m shell -a "echo 'test' > /tmp/test"

To get some help, run: ansible --help

ENVIRONMENTS:
    production       Deploy to production environment

EOF
    exit 1
}

main () {
    local environment="${1:-}"

    case "${environment}" in
        "")
            usage
            ;;
        *)
            shift
            check_ansible
            source "${SELF_PATH}/../includes/remote_ansible.sh"
            remote_ansible "${environment}" "$@"
            ;;
    esac
}

main "$@"
