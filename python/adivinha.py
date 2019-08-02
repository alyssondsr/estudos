#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import random

palpite, tentativas = "", 0
frutas = ["Pera", "Laranja", "Melancia", "Ameixa"]
minha_preferida = random.choice(frutas).upper()
while palpite != minha_preferida:
	print(frutas)
	palpite = input("Adivinhe minha fruta favorita: ")
	palpite = palpite.upper()
	tentativas += 1
	if palpite != minha_preferida:
		print("Não é essa não, tente novamente.")
print("Muito bem, você acertou. "
	"Número de tentativas = {}".format(tentativas))
