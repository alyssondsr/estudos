-module(kitchen).
-compile(export_all).

start(FoodList) ->
    spawn(?MODULE, fridge2, [FoodList]).
% ?MODULE é uma macro para retornar o nome do módulo atual


 % guarda e reitra alimentos de uma geladeira
fridge1() ->
	receive
		{From, {store, _Food}} -> %não salva o guarda os valores
			From ! {self(), ok},
			fridge1();
		{From, {take, _Food}} ->
			From ! {self(), not_found},
			fridge1();
		terminate ->
			ok
	end.
fridge2(FoodList) ->
    receive
        {From, {store, Food}} -> % recebe o alimento
            From ! {self(), ok},
            fridge2([Food|FoodList]); % salva os valroes na lista FoodList
        {From, {take, Food}} ->
            case lists:member(Food, FoodList) of % busca o alimento na lista
                true ->
                    From ! {self(), {ok, Food}},
                    fridge2(lists:delete(Food, FoodList)); % retira o alimento da lista
                false ->
                    From ! {self(), not_found},
                    fridge2(FoodList)
            end;
        terminate ->
            ok
    end.

store(Pid, Food) ->
    Pid ! {self(), {store, Food}}, 
    receive
        {Pid, Msg} -> Msg %Passa a msg recebida para a função do PID
    end.

take(Pid, Food) ->
    Pid ! {self(), {take, Food}},
    receive
        {Pid, Msg} -> Msg 
    end.

store2(Pid, Food) ->
    Pid ! {self(), {store, Food}},
    receive
        {Pid, Msg} -> Msg %
    after 3000 -> % adiciona timeout, pois o processo pode não responder e o programa ficará travado
        timeout
    end.

take2(Pid, Food) ->
    Pid ! {self(), {take, Food}},
    receive
        {Pid, Msg} -> Msg
    after 3000 -> % 3000 ms
        timeout
    end.



