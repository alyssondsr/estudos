-module (dolphins).
-compile (export_all).
 
dolphin1() ->
	receive %case que analisa a string recebida.
		do_a_flip ->
			io:format ("How about no?~n");
		fish ->
			io:format ("So long and thanks for all the fish!~n");
		_ ->
			io:format ("Heh, we're smarter than you humans.~n")
end.

dolphin2() ->
	receive
		{From, do_a_flip} -> % "Endereço de Origem", msg
			From ! "How about no?";
		{From, fish} ->
			From ! "So long and thanks for all the fish!";
		_ ->
			io:format ("Heh, we're smarter than you humans.~n")
end.

dolphin3() ->
	receive
		{From, do_a_flip} -> %Chama a função navamente.
			From ! "How about no?",
			dolphin3();
		{From, fish} -> %Recebe apenas a string fish
			From ! "So long and thanks for all the fish!";
		_ ->
			io:format ("Heh, we're smarter than you humans.~n"),
			dolphin3()
end.



