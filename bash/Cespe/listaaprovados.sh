#!/bin/bash

echo "" > eliminados.lst
echo "" > aprovados.lst

while read linha; do
  #echo "$linha"
  while read nota; do
    echo "$nota"
	  grep -e "$linha" $nota >> aprovados.lst
	  grep -ve "$linha" $nota >> eliminados.lst
  done < $2
done < $1
cat aprovados.lst
