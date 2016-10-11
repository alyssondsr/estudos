#!/bin/bash
cat 1551.xml | grep \<ip\-netmask\> > /tmp/address.txt
cat /tmp/address.txt | sort | uniq -c > n_address.csv   #conta as repetições
