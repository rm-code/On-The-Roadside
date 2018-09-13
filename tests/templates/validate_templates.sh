#!/bin/bash
RED="\033[0;31m"
GRAY="\033[37m"
GREEN="\033[1;32m"
CLR="\033[0m"

STATUS=0

# Searches through all files and checks if the template is used more than once.
function searchUses {
  warnings=0

  lua ./tests/templates/dumpTemplates.lua $1 $2 > ./tests/templates/templates.out
  printf "==> Searching for unused templates in ${GRAY}%s.lua${CLR}\n" $1

  while read p; do
    count=$(grep -rw --color --exclude=CHANGELOG.md --exclude-dir=tests --exclude-dir=.git --exclude-dir=lib $p . | wc -l)

    if [ $count -eq 1 ]
    then
      printf "[${RED}WARNING${CLR}] Found unused template ${GREEN}%s${CLR}\n" $p
      warnings=$[warnings+1]
    fi
  done < ./tests/templates/templates.out

  if [ $warnings -ne 0 ]
  then
    printf "Found %d unused templates!\n\n" $warnings
    STATUS=1
  fi
}

searchUses "res.texturepacks.default.colors"
searchUses "res.texturepacks.default.sprites"
searchUses "res.text.en_EN" "strings"

exit $STATUS
