#!/usr/bin/env bash
# Infra Automation. ansible-playbook command
#
# Usage: ./infra-automation ansible-playbook ENVIRONMENT PLAYBOOK [ANSIBLE OPTIONS]
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

Usage: ${cmd} ansible-playbook ENVIRONMENT PLAYBOOK [ANSIBLE OPTIONS]

Use Ansible to execute a playbook on your VMs.

ANSIBLE OPTIONS:
    -C, --check      Don't make any changes; instead,
                     try to predict some of the changes that may occur
    -l SUBSET, --limit=SUBSET
                     Further limit selected hosts to an additional pattern
    --list-hosts     Outputs a list of matching hosts; does not execute
    --list-tags      List all available tags
    --list-tasks     List all tasks that would be executed
    --skip-tags=SKIP_TAGS
                     Only run plays and tasks whose tags do not match these values
    --step           One-step-at-a-time: confirm each task before running
    --syntax-check   Perform a syntax check on the playbook, but do not execute it
    -t TAGS, --tags=TAGS
                     Only run plays and tasks tagged with these values

To list other Ansible options, run: ansible-playbook --help

PLAYBOOKS:
    provision        Provision your VMs: configure hosts, install Docker, set up Docker Swarm
    deploy           Deploy your applicative stacks on the Swarm
    all              Provision and deploy in a single command

ENVIRONMENTS:
    production       Deploy to production environment
EOF
    exit 1
}

install_ansible_roles () {
    ansible-galaxy role install -r "${ROOT_PATH}/ansible/requirements.yml"
}

main () {
    local environment="${1:-}"
    local playbook="${2:-}"

    if [[ -z "${playbook}" ]]; then
        usage
    fi

    case "${environment}" in
        "")
            usage
            ;;
        *)
            shift 2
            check_ansible
            install_ansible_roles
            source "${SELF_PATH}/../includes/remote_ansible.sh"
            remote_ansible_playbook "${environment}" "${ROOT_PATH}/ansible/${playbook}.yml" "$@"
            ;;
    esac
}

main "$@"
