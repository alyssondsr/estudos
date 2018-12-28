#!/bin/bash

Path=$1

Path1="$(echo $Path | cut -d. -f1 )"
filename="$(basename "$Path")"
File="$(echo $filename | cut -d. -f1)"
extensao="$(echo "$filename" | awk -F '.' '{ if (NF==2) {print $NF} else if (NF>2) { print $(NF-1)"."$NF } }')"
dir="$(echo "$Path" | awk -F '/' '{ print substr($0, 0, length($0)-length($NF)) }')"    


echo -e "Diretório\tArquivo\t\tExtensão"
echo -e "$dir""\t\t""$filename""\t""$extensao"
echo -e "\n"


grep "\.mkv\|\.webm\|\.flv\|\.vob\|\.ogg\|\.ogv\|\.drc\|\.gifv\|\.mng\|\.avi$\|\.mov\|\.qt\|\.wmv\|\.yuv\|\.rm\|\.rmvb\|\.asf\|\.amv\|\.mp4$\|\.m4v\|\.mp\|\.m?v\|\.svi\|\.3gp\|\.flv\|\.f4v" $Path > $Path1"_videos.txt" 
echo "Videos gravados no arquivo: $(pwd $Path1"_videos.txt")/"$Path1"_videos.txt"
echo -e "\n"

grep "\.jpg\|\.jpeg\|\.png\|\.tif\|\.bmp\|\.gif\|\.xpm\|\.nef\|\.cr2\|\.arw" $Path > $Path1"_imagens.txt" 
echo "Imagens gravadas no arquivo: $(pwd $Path1"_imagens.txt")/"$Path1"_imagens.txt"
echo -e "\n"
