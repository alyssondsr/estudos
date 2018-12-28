#!/bin/bash
#clear
nomeacao=$1
resultado=$2

while read linha; do
#	echo -e "$linha"
	grep -e "$linha" $resultado
	# Exibo a porcentagem do loop corrente
	# Flag -n para manter o ponteiro na mesma linha
	# Flag -e para voltar o ponteiro no inicio da linha
done < $nomeacao
