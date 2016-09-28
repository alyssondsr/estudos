-module(useless).
% Primeiro atributo de um arquivo, é o nome do módulo atual. Este é o nome usado para chamar funções de outros módulos. As chamadas são feitas com a forma M:F(A), onde M é o nome do módulo, F a função e A os argumentos.
-export([add/2, hello/0, greet_and_add_two/1]).
% Usado para definir as funções de um módulo. É preciso uma lista de funções com seu respectiva aridade. A aridade de uma função é um número inteiro representando quantos argumentos podem ser passados para a função. Isto é informação crítica, porque diferentes funções definidas dentro de um módulo podem compartilhar o mesmo nome, se e somente se eles têm aridade diferente. As funções add(X,Y) e add(X,Y,Z) seria assim considerados diferente e escrito no formulário add/2 e add/3 respectivamente.
 
add(A,B) ->
	A + B.
 
%% Shows greetings.
%% io:format/1 is the standard function used to output text.
hello() ->
	io:format("Hello, world!~n").
 
greet_and_add_two(X) ->
	hello(),
	add(X,2).
