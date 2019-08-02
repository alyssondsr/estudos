#!/usr/bin/env python3
# modelo03.py

class Computador():
	def __init__(self, codigo, nome, aquisicao, vida, marca):
		self.codigo = codigo
		self.nome = nome
		self.aquisicao = aquisicao
		self.vida = vida
		self.marca = marca
	def alerta_manutencao(self):
		# TODO: calcular período de manutenção.
		pass

class Marca():
	def __init__(self, codigo, nome):
		self.codigo = codigo
		self.nome = nome

if __name__ == '__main__':
	# Instancias(objetos) de marca.
	dall = Marca(1, 'Dall')
	lp = Marca(2, 'LP')
	# Instancias(objetos) de computador.
	vastra = Computador(1, 'Vastra', '10/01/2015', 365, dall)
	polvilion = Computador(2, 'Polvilion', '10/01/2015', 365, lp)

	print(type(dall))
	# <class '__main__.Marca'>
	print(type(polvilion))
	# <class '__main__.Computador'>
	print(isinstance(dall, Marca))
	# True
	print(isinstance(polvilion, Marca))
	# False
	print(isinstance(polvilion, Computador))
	# True
