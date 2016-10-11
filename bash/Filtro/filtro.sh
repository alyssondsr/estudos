#!/bin/bash
cat sombras.txt | cut -d \' -f2 | sort -u > /tmp/sombra.txt
cat sombras.txt | cut -d \' -f4 | sort -u >> /tmp/sombra.txt
rm /tmp/saida.txt > /dev/null
while read line  
do  
	echo "(name eq '""$line""')" >> /tmp/saida.txt	
done < /tmp/sombra.txt
cat /tmp/saida.txt | sed ':a;N;s/\n/ or /g;ta' >  /tmp/saida1.txt
cat /tmp/saida1.txt
