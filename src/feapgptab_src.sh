#!/usr/bin/env bash

# Bash scrit with embeded GAWK script for extracting Gauss Points table
# from FEAP results file.

# A better class of script...
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o xtrace          # Trace the execution of the script (debug)

strain=0;
stress=0;
eigen=0;

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
     -e|--strain                Add strain to output
     -s|--stress                Add stress to output
     -g|--eigen                 Add eigenvalues to output
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
            -e|--strain)
                strain=1
                ;;
            -s|--stress)
                stress=1
                ;;
            -g|--eigen)
                eigen=1
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
cat $1 | gawk '
NF == 0 {next}
$0 ~ / *Element Stresses and Strains/  {
  FEASS = 1;
}
FEASS == 1 && $0 ~/ *Command/ { exit }
FEASS == 1 {print $0}
'   |  gawk -v printStress=$stress -v printStrain=$strain -v printEig=$eigen '
BEGIN {
 j = 0;
 oldelem=0;
}
NF == 0 {next}
$0 ~ / FEAP \* \*/ {next} 
$0 ~ / *Element Stresses and Strains/  {
  for (i=0; i<5; ++i) getline;
  next
}
{ if (NF == 4) { dim=2;
  } else { dim =  3;}
  if ($1 != oldelem) {
    oldelem=$1;
    j = 0;
  }
  j = j+1;
  printf("%s %d %s %s", $1, j, $3, $4)
  if (dim == 3) printf(" %s", $5);
  getline pv;
  getline;
  if (printStress) {
    if (dim == 2) $3="";
    printf(" %s", $0)
  }
  getline;
  if (printStrain) { 
    if (dim == 2) $3="";
    printf(" %s", $0)
  }
  if (printEig) {
    n = split(pv, v, " ");
    if (printStress) {
      for (i=1; i<=n/2; ++i) { printf(" %s", v[i]) }
    } 
    if (printStrain) {
      for (i=n/2+1; i<=n; ++i) { printf(" %d", v[i]) }
    }
  }
  printf("\n");
}'
}

# Make it rain
main "$@"

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
