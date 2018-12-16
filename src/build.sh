#!/usr/bin/env bash

# Assembles the all-in-one script by combining source.sh $1
# The assembled scritp is write to $2 

# A better class of script...
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

# Main control flow
function main() {
    # shellcheck source=source.sh
    script_init "$@"
    build_template $1 $2
}


# This is quite brittle, but it does work. I appreciate the irony given it's
# assembling a template meant to consist of good Bash scripting practices. I'll
# make it more durable once I have some spare time. Likely some arcane sed...
function build_template() {
    local tmp_file
    local shebang header
    local source_file script_file
    local script_options source_data script_data

    shebang="#!/usr/bin/env bash"
    header="
# A best practices Bash script template with many useful functions. This file
# combines the source.sh & script.sh files into a single script. If you want
# your script to be entirely self-contained then this should be what you want!"

    source_file="$script_dir/source.sh"
    script_file="$script_dir/$1"
    out_file=$2

    script_options="$(head -n 15 "$script_file" | tail -n 6)"
    source_data="$(tail -n +10 "$source_file" | head -n -1)"
    script_data="$(tail -n +16 "$script_file")"

    {
        printf '%s\n' "$shebang"
        printf '%s\n\n' "$header"
        printf '%s\n\n' "$script_options"
        printf '%s\n\n' "$source_data"
        printf '%s\n' "$script_data"
    } > ${out_file}

    tmp_file="$(mktemp /tmp/template.XXXXXX)"
    sed -e '/# shellcheck source=source\.sh/{N;N;d;}' \
        -e 's/BASH_SOURCE\[1\]/BASH_SOURCE[0]/' \
        ${out_file} > "$tmp_file"
    mv "$tmp_file" ${out_file}
    chmod +x ${out_file} 
}

# Template, assemble!
source "$(dirname "${BASH_SOURCE[0]}")/source.sh"

trap "script_trap_err" ERR
trap "script_trap_exit" EXIT

if [ $# -ne 2 ]; then
    script_exit "Expected two arguments" 77
    fi
main $1 $2

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
