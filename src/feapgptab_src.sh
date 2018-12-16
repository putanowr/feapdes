#!/usr/bin/env bash

# Bash scrit with embeded GAWK script for extracting Gauss Points table
# from FEAP results file.

# A better class of script...
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

# DESC: Usage help
# ARGS: None
# OUTS: None
script_usage() {
    cat << EOF
Usage:
     -h|--help                  Displays this help
     -v|--verbose               Displays verbose output
    -nc|--no-colour             Disables colour output
    -cr|--cron                  Run silently unless we encounter an error
EOF
}


# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
parse_params() {
    local param
    while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
            -h|--help)
                script_usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                ;;
            -nc|--no-colour)
                no_colour=true
                ;;
            -cr|--cron)
                cron=true
                ;;
            *)
              datafile=$param
              ;;  
        esac
    done
}


# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
main() {
    # shellcheck source=source.sh
    source "$(dirname "${BASH_SOURCE[0]}")/source.sh"

    trap script_trap_err ERR
    trap script_trap_exit EXIT

    script_init "$@"
    parse_params "$@"
    cron_init
    colour_init
    parse_gp_table $datafile
}

# DESC: Parser input file
# ARGS: $1 : name of file to parse
# OUTS: None
parse_gp_table() {
  echo "Parsing file: $1" 
}

# Make it rain
main "$@"

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
