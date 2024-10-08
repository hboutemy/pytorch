#!/bin/bash

\rm -rf whl

for d in whl whl/cu111 whl/cu118 whl/cu124 whl/cpu whl/rocm6.1
do
  mkdir -p $d/simple
  dir="$(pwd)"
  cd $d/simple
  curl -s https://download.pytorch.org/$d/ | grep -v 'TIMESTAMP 1' > index.html
  count="$(cat index.html | cut -d '>' -f 2 | cut -d '<' -f 1 | grep -cve '^\s*$')"

  echo "https://download.pytorch.org/$d/ $count => $d/simple/"
  if [ $count -lt 40 ]
  then
    echo "failing because low packages count for $d: $count (intermittent download failure?)"
    exit 1
  fi

  i=0
  for p in `cat index.html | cut -d '>' -f 2 | cut -d '<' -f 1`
  do
    mkdir $p
    cd $p
    ((i++))
    curl -s https://download.pytorch.org/$d/$p/ \
      | sed -e 's_href="/whl_href="https://download.pytorch.org/whl_' \
      | grep -v 'TIMESTAMP 1' \
      > index.html

    count="$(cat index.html | grep -c 'https://download.pytorch.org/whl/')"
    echo "$i                            $d/$p/ => $d/simple/$p/ $count"
    if [ $count -lt 1 ]
    then
      echo "failing because low packages count for $d/$p: $count (intermittent download failure?)"
      exit 1
    fi
    cd ..
  done
  echo
  cd "$dir"
done

du -sh whl/*

for d in whl/simple whl/*/simple ; do echo "$(ls $d | wc -l) $d" ; done > summary.txt
cat summary.txt
