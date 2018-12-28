#!/bin/bash

declare -r BAR_SIZE="#################################################################################################################"
# Calcula o length (tamanho) da string
declare -r MAX_BAR_SIZE=${#BAR_SIZE}

path=$1
Path1="$(echo $path | cut -d. -f1 )"

rm -rf /tmp/diretorio*
cut -d: -f2 $path > /tmp/diretorio1.txt
max=$(wc -l < /tmp/diretorio1.txt)

tput civis -- invisible

count=0
while read linha; do
	perc=$((($count + 1) * 100 / max))
	percBar=$((perc * MAX_BAR_SIZE / 100))
	dir="$(echo "$linha" | awk -F '/' '{ print substr($0, 0, length($0)-length($NF)) }')" 
	echo $dir >> /tmp/diretorio2.txt
	# Exibo a porcentagem do loop corrente
	# Flag -n para manter o ponteiro na mesma linha
	# Flag -e para voltar o ponteiro no inicio da linha
	echo -ne " \033[01;36m\\r[${BAR_SIZE:0:percBar}] $perc%\033[01;37m"
	count=$((count  + 1))
done < /tmp/diretorio1.txt
echo ""
# Volta cursor ao normal
tput cnorm -- normal

sort -u /tmp/diretorio2.txt > $Path1"_diretorios.txt"
