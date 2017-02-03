#!/bin/sh

BASEPATH="${HOME}/Downloads"

ERRTAG="[$(tput setab 1; tput setaf 7; tput bold)ERROR$(tput sgr0)]"

while getopts ":p:" flags; do
    case $flags in
        p)
            BASEPATH=$OPTARG
            CHROOTPATH="${BASEPATH}/chroots"
            ;;
        \?)
            echo "${ERRTAG} Invalid option: -${OPTARG}" >&2
            ;;
        :)
            echo "${ERRTAG} Pathname not specified." >&2
            ;;
    esac
done

if [ ! -d $BASEPATH ]; then
    ERRMSG="${ERRTAG} Not a valid directory name: ${BASEPATH}\n"
    ERRMSG="${ERRMSG}Use -u flag if running under sudo."
    echo $ERRMSG >&2
    exit 1
fi

CHROOTPATH="${BASEPATH}/chroots"
mkdir -p $CHROOTPATH
wget https://goo.gl/fd3zc -qO ${CHROOTPATH}/crouton

BOOTSTRAPPATH=${CHROOTPATH}/bootstraps
mkdir -p $BOOTSTRAPPATH

for kernel in $@; do
    sudo sh ${CHROOTPATH}/crouton \
      -dr $kernel \
      -f ${BOOTSTRAPPATH}/${kernel}bootstrap.tar.gz
done
