#!/bin/bash

function die () {
  echo "${1}" && exit 1
}

BASE=$(cd $(dirname $0) && pwd)

POM=${BASE}/pom.xml
if [ -n "${1}" ] ; then
  POM="${1}"
fi

collecting=0
in_comment=0
cat ${POM} | while read line ; do

  if [ -z "${line}" ] ; then continue; fi

  if [[ "${line}" =~ "<!--" ]] ; then
    if [ ${in_comment} -ne 0 ] ; then die "Cannot nest XML comments" ; fi
    in_comment=1
  fi

  if [ ${in_comment} -eq 1 ] ; then
    if [[ "${line}" =~ "-->" ]] ; then
      in_comment=0
      continue
    fi
  fi

  if [ $(echo "${line}" | tr -d '[:blank:]') = "<properties>" ] ; then
    collecting=1
    continue
  fi

  if [ ${collecting} -eq 1 ] ; then
    if [ $(echo "${line}" | tr -d '[:blank:]') = "</properties>" ] ; then
      break
    fi
    echo ${line} | tr '<>' '  ' | awk '{print " -D"$1"="$2}' | tr -d '\n'
  fi
done
