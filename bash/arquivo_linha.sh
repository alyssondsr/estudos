#!/bin/bash

declare -r BAR_SIZE="#################################################################################################################"
# Calcula o length (tamanho) da string
declare -r MAX_BAR_SIZE=${#BAR_SIZE}

max=$(wc -l < $1)

tput civis -- invisible

count=0
while read linha; do
	perc=$((($count + 1) * 100 / max))
	percBar=$((perc * MAX_BAR_SIZE / 100))
	grep -e "$linha" limpo.log >> teste/detectado.log
	grep -ve "$linha" limpo.log  >> /tmp/limpo.log
	# Exibo a porcentagem do loop corrente
	# Flag -n para manter o ponteiro na mesma linha
	# Flag -e para voltar o ponteiro no inicio da linha
	echo -ne " \033[01;36m\\r[${BAR_SIZE:0:percBar}] $perc%\033[01;37m"
	count=$((count  + 1))
done < $1
echo "Ordenando...."
# Volta cursor ao normal
tput cnorm -- normal

sort -u /tmp/limpo.log > teste/limpo.log
rm /tmp/limpo.txt
