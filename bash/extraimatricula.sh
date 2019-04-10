#!/bin/bash
####################################################
## Gera uma lista com as matriculas.

sed ':a;N;s/\n/ /;ta' $1 > temp1
sed -i 's/\ \/\ /\n/g' temp1 
cut -d, -f1 temp1 > mat.lst
rm -rf temp1
