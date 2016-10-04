#!/bin/bash
# Remove as quebras de um txt.
cat quebra.txt | sed ':a;N;s/\n/ /g;ta' > /tmp/quebr.tmp
sed 's/\*\*/\n/g' /tmp/quebr.tmp > /tmp/quebr1.tmp
sed 's/\- //g' /tmp/quebr1.tmp
sed 'y/[ABCDEFGHIJKLMNOPQRSTUVWXYZ]/**[ABCDEFGHIJKLMNOPQRSTUVWXYZ]/'
