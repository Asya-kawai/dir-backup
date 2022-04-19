#!/usr/bin/env bash

# -*- coding:utf-8 -*- 

set -euo pipefail
# set -euxo pipefail

### $1 backup script.

### Static values.
cmdname=$(basename "$0")
readonly cmdname
today=$(date '+%Y%m%d%s')
readonly today

readonly NO_ERR=0
readonly ARG_ERR=255
readonly DST_DIR_NOT_FOUND=1
readonly SRC_DIR_NOT_FOUND=2
readonly FUN_ARG_ERR=3
readonly T_ERR=4
readonly VAL_ERR=5

readonly t_dir='T_DIR'
readonly t_base='T_BASE'

# Set permission 077 when craete directories and files.
umask 077

### functions.

# Show usage.
usage () {
    echo "Usage:"
    echo "$cmdname 'source-directory' 'destination-directory' [--dry-run]"
}

# Check the command status.
check_status () {
    if [ "$1" -eq 0 ]; then
        echo "...Succeeded (return $1)."
        echo "$1"
    else
        # Never go throuth.
        echo "...Failed (return $1)."
        exit "$1"
    fi
}

# Convert dot('.') to literal name.
# arg1 : src path or dst path.
# arg2 : file type of ['dir'|'base'].
dot2path () {
    if [ $# -ne 2 ]; then
        echo "dot2path : arguments error, expected 2."
        exit $FUN_ARG_ERR
    fi
    if echo "$1" | grep -q '[*]'; then
        echo "dot2path : arguments error, no accept '*'."
        exit $FUN_ARG_ERR
    fi
    case $2 in
        "$t_dir" )
            v="$(cd "$1" && dirname "$(pwd)")"
            ;;
        "$t_base" )
            v="$(cd "$1" && basename "$(pwd)")"
            ;;
        * ) exit $T_ERR ;;
    esac
    echo "$v"
}

### Check command line arguments.
debugmode=0
case $# in
    2 ) echo "--- execution mode ---" ;;
    3 ) 
        if [ "$3" = "--dry-run" ]; then
            debugmode=1
            echo "--- debug mode ---"
        else
            usage; exit $ARG_ERR
        fi ;;
    * ) usage ; exit $ARG_ERR ;;
esac

### Set command line arguments as variables.
srcdir=$1
dstdir=$2

if [ "$srcdir" = "$dstdir" ]; then
    echo "Abort error: source directory is same the destination directory."
    exit $ARG_ERR
fi

if [ "$srcdir" = '/' ]; then
    echo "Abort error: cant' set '/' to the source directory."
    exit $ARG_ERR
fi

# Check whether exists source-directory(file) or not.
if [ ! -e "$srcdir" ]; then
    echo "Abort error: \$srcdir($srcdir) is not found."
    exit $SRC_DIR_NOT_FOUND
fi
# Check whether exists destination-directory or not.
if [ ! -d "$dstdir" ]; then
    echo "Abort error: \$dstdir($dstdir) is not found."
    exit $DST_DIR_NOT_FOUND
fi

# Convert [src|dst]dir to full path if $srcdir or $dstdir are dot.
# Otherwise, get path except dir name.
srcpath=$(dot2path "$srcdir" "$t_dir")
srcname=$(dot2path "$srcdir" "$t_base")
dstpath=$(dot2path "$dstdir" "$t_dir")
dstname=$(dot2path "$dstdir" "$t_base")

# Check source and destination directories.
if [ -z "$srcpath" ] || [ -z "$srcname" ]; then
    echo "Local values \$srcpath($srcpath), \$srcpath($srcname) are invalid."
    exit $VAL_ERR  
fi
if [ -z "$dstpath" ] || [ -z "$dstname" ]; then
    echo "Local values \$dstpath($dstpath), \$dstname($dstname) are invalid."
    exit $VAL_ERR
fi

# Debug
if [ $debugmode -eq 1 ]; then
    echo "-----"
    echo "soruce path =" "$srcpath"
    echo "source basename =" "$srcname"
    echo "destination path =" "$dstpath"
    echo "destination basename =" "$dstname"
    echo "backup file name =" "$srcname"
    echo "-----"
fi

if [ "$dstpath" = '/' ]; then
    dstfullpath=${dstpath}${dstname}
else
    dstfullpath=${dstpath}/${dstname}
fi

# Debug
if [ $debugmode -eq 1 ]; then
    echo "-----"
    echo "destination full path =" "${dstfullpath}"
    echo "-----"
fi

# Create a backup file (format is tar.gz).
backupcmd="tar --exclude=mnt --exclude=Downloads --exclude=tmp* --exclude=work* --exclude=timeshift --exclude=.pyenv* --exclude=.npm* --exclude=.opam* --exclude=.rbenv* --exclude=.nvm* --exclude=.texlive* --exclude=.thumbnails --exclude=.thunderbird* --exclude=.cache* --warning=no-file-changed --warning=no-file-removed --warning=no-file-shrank -zvcf ${dstfullpath}/${srcname}-${today}.tar.gz -C ${srcpath} ./${srcname}"
echo "${backupcmd}"
if [ $debugmode -eq 0 ]; then
    ${backupcmd}
    check_status $?
fi

# Update access time (YYYYMM01 files only).
rotatecmd="find $dstdir -name ${srcname}'-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]01*.tar.gz' -exec touch '{}' \;"
echo "${rotatecmd}"
if [ $debugmode -eq 0 ]; then
    find "$dstdir" -name "${srcname}"'-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]01*.tar.gz' -exec touch '{}' \;
    check_status $?
fi

# Delete tar.gz-files which not access 5days.
rotatecmd="find $dstdir -name ${srcname}'*' -atime +5 -exec rm '{}' \;"
echo "${rotatecmd}"
if [ $debugmode -eq 0 ]; then
    find "$dstdir" -name "${srcname}"'*' -atime +5 -exec rm '{}' \;
    check_status $?
fi

# Normal end.
exit $NO_ERR
