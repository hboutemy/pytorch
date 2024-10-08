#!/bin/bash

\rm -rf whl

for d in whl whl/cu111 whl/cu118 whl/cu124 whl/cpu whl/rocm6.1
do
  mkdir -p $d/simple
  dir="$(pwd)"
  cd $d/simple
  wget -q https://download.pytorch.org/$d/

  echo "https://download.pytorch.org/$d/ $(cat index.html | cut -d '>' -f 2 | cut -d '<' -f 1 | grep -cve '^\s*$') => $d/simple/"
  i=0
  for p in `cat index.html | cut -d '>' -f 2 | cut -d '<' -f 1`
  do
    mkdir $p
    cd $p
    ((i++))
    echo "$i                             $d/$p/ => $d/simple/$p/"
    wget -q https://download.pytorch.org/$d/$p/
    sed -i 's_href="/whl_href="https://download.pytorch.org/whl_' index.html
    cd ..
  done
  cd "$dir"
done

du -sh whl/*
