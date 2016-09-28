-module(hhfuns).
-compile(export_all).
 % Passagem de argumentos entre funções

one() -> 1.
two() -> 2.

% hhfuns:add(fun hhfuns:one/0, fun hhfuns:two/0). passa as funções one e two como parâmetro de add
add(X,Y) -> X() + Y().

% hhfuns:increment(L).
increment([]) -> [];
increment([H|T]) -> [H+1|increment(T)].
 
decrement([]) -> [];
decrement([H|T]) -> [H-1|decrement(T)].

% hhfuns:map(fun hhfuns:incr/1, L).
map(_, []) -> [];
map(F, [H|T]) -> [F(H)|map(F,T)].
 
incr(X) -> X + 1.
decr(X) -> X - 1.



filter(Pred, L) -> lists:reverse(filter(Pred, L,[])).
 
filter(_, [], Acc) -> Acc;
	filter(Pred, [H|T], Acc) ->
	case Pred(H) of
		true  -> filter(Pred, T, [H|Acc]);
		false -> filter(Pred, T, Acc)
	end.
