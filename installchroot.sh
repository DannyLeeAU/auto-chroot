#!/bin/sh

LGREEN=$(tput setaf 2; tput setaf bold)
ERRCOLOR=$(tput setaf 7; tput setaf bold; tput setab 1)
NC=$(tput sgr0)

ERRTAG="[${ERRCOLOR}ERROR${NC}]"

BASEPATH="${HOME}/Downloads"
CHROOTPATH="${BASEPATH}/chroots"
BOOTSTRAPPATH=${CHROOTPATH}/bootstraps

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "${ERRTAG} Invalid number of arguments; expected 1-2, got ${#}." >&2
    exit 1
fi
CHROOTKERNEL=$1

while getopts ":n:p:" flags; do
    case $flags in
        n)
            NFLAG=1
            NAME=$OPTARG
            ;;
        p)
            BASEPATH=$OPTARG
            CHROOTPATH="${BASEPATH}/chroots"
            if [ ! -d $BASEPATH ]; then
                echo "${ERRTAG} Invalid path: ${BASEPATH}" >&2
            fi
            ;;
        \?)
            echo "${ERRTAG} Invalid option: -${OPTARG}" >&2
            ;;
        :)
            echo "${ERRTAG} Option -${OPTARG} requires argument." >&2
            ;;
    esac
done

if [ ! -e ${CHROOTPATH}/crouton ]; then
    ERRMSG="${ERRTAG} Crouton not installed."
    ERRMSG="${ERRMSG} Run ${LGREEN}setupcrouton${NC} first."
    echo $ERRMSG >&2
    exit 1
fi

SHELLCMD="sudo sh ${CHROOTPATH}/crouton${NFLAG:+" -n ${NAME}"}"

BOOTSTRAPFILE=${BOOTSTRAPPATH}/${CHROOTKERNEL}bootstrap.tar.gz
if [ -f $BOOTSTRAPFILE ]; then
    SHELLCMD="${SHELLCMD} -f ${BOOTSTRAPFILE}"
else
    SHELLCMD="${SHELLCMD} -r ${CHROOTKERNEL}"
fi

if [ $# -eq 2 ]; then
  CHROOTTARGETS=$2
  SHELLCMD="${SHELLCMD} -t ${CHROOTTARGETS}"
fi

$SHELLCMD
