%%********************************************************************
%% @title Módulo helloworld_service
%% @version 1.0.0
%% @doc Módulo de serviço para o famoso hello world!!!
%% @author Everton de Vargas Agilar <evertonagilar@gmail.com>
%% @copyright ErlangMS Team
%%********************************************************************
-module(authorization).

-export([execute/1]).
%-record(rec, {	valor1,
%				valor2}).
execute(Request) -> 
	R = element(16,Request),
	%rec = R,
	io:format("~p", [R]),
	
	%io:format("Requisição ~p",[Request]),
	<<"{\"message\": \"AUTORIZACAO\"}">>.
