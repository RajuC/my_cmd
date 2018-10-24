-module(awwfun).
-export([start/0]).
-compile(export_all).




crypto:start(),
[crypto:rand_uniform(1, 10) || _ <- lists:seq(1, 1000)].


start() ->
	ok.
%% ====================== quick sort
qs([]) -> [];
qs([F|N]) ->
	qs([R||R<-N,R=<F]) ++ [F] ++ qs([R||R<-N,R>F]). 

%% ====================== transpose of a 3X3 matrix
%transpose({[1,2,3],[4,5,6],[7,8,9]},[])   =====> {[1,4,7],[2,5,8],[3,6,9]}

transpose({[],[],[]},Transpose) ->
	list_to_tuple(Transpose);
transpose({[H1|T1],[H2|T2],[H3|T3]},Transpose) ->
	transpose({T1,T2,T3},Transpose ++ [[H1,H2,H3]]).
	
	
	
	
%%======================= transpose of nXn matrix

transpose(L) ->
  tranpose(L, []).

transpose([], Res) ->
  Res;
transpose([H|T], FinalTranspose) ->
  transpose(T, H, [], [], FinalTranspose).

transpose(_tails, [], [], Tails, FinalTranspose) ->
  transpose(Tails, FinalTranspose);
transpose(_tails, [], Heads, Tails, FinalTranspose) ->
  transpose(Tails, FinalTranspose ++ [Heads]);
transpose([], [H|T1], Heads, Tails, FinalTranspose) ->
  transpose([], [], Heads ++ [H], Tails ++ [T1], FinalTranspose);
transpose([HH|TT], [H|T1], Heads, Tails, FinalTranspose) ->
  transpose(TT, HH, Heads ++ [H], Tails ++ [T1], FinalTranspose).
	
%%% ================ using list comphrehension

transpose1(L) ->
  transpose1(L, []).


transpose1(L, Res) ->
  case lists:flatten(L) == [] of
    true -> Res;
    false ->
      Transpose = [H || [H|_T] <- L ],
      Tails = [T|| [_H|T] <- L],
      transpose1(Tails, Res ++ [Transpose])
  end.

%% ======================  merging  [1,2,3] ,[4,5,6] - > [1,4,2,5,3,6]
merge(L1,L2) ->
	lists:reverse(mergeL(L1,L2,[])).

mergeL([H|T],L2,Res) ->
	mergeR(T,L2,[H]++Res);
mergeL([],[],Res) ->
	Res.

mergeR(L1,[H|T],Res) ->
	mergeL(L1,T,[H]++Res);
mergeR([],[],Res) ->
	Res.




merge_lists(L1, L2) ->
  merge(L1, L2, []).

merge([],[], Res) ->
  Res;

merge([H1|T1], [H2|T2], Res) ->
  merge(T1,T2, Res ++ [H1, H2]).


%% ====================== <<"2015-11-23T16:58:39">>

tim() -> 
	{{Y,M,D},{H,Mi,S}} =erlang:localtime(),
	{YYYY,MM,DD} =to_bin({Y,M,D}),
	{HH,Min,Sec} = to_bin({H,Mi,S}),
	<<YYYY/binary,"-",MM/binary,"-",DD/binary,"T",HH/binary,":",Min/binary,":",Sec/binary>>.


%% ==========================  <<"2015-11-23T16:58:39">>   - > {{2015,11,23},{16,58,39}}
get_prop_ts(TimeStamp)->
	[D,T]=string:tokens(binary_to_list(TimeStamp),"T"),
	Date = erlang:list_to_tuple([erlang:list_to_integer(Dd)||Dd<- string:tokens(D,"-")]),
	Time = erlang:list_to_tuple([erlang:list_to_integer(Tt)||Tt<- string:tokens(T,":")]),
	{Date,Time}.




%%=============================

%% TS = os:timestamp(). // TS format {1513,617997,240000}
diff_timestamp(TS1, TS2) ->
	DT1 = calendar:now_to_datetime(TS1),
	DT2 = calendar:now_to_datetime(TS2),
	diff_datetime(DT1, DT2).


%% calendar:local_time(). // DT format  {{2017,12,18},{11,58,10}}

diff_datetime(DT1, DT2) ->
	GregSec1 = calendar:datetime_to_gregorian_seconds(DT1),
	GregSec2 = calendar:datetime_to_gregorian_seconds(DT2),
	abs(GregSec2 - GregSec1).


%% ==================== to binary 

to_bin({A,B})  ->
	{to_bin(A),to_bin(B)};
to_bin({A,B,C}) ->
	{to_bin(A),to_bin(B),to_bin(C)};

to_bin(A) when is_list(A) ->
	list_to_binary(A);
to_bin(A) when is_integer(A) ->
	integer_to_binary(A);
to_bin(A) when is_atom(A) ->
	list_to_binary(to_list(A));
to_bin(A) when is_binary(A) ->
	A.


%% ==================== to binary 

to_list({A,B})  ->
	{to_list(A),to_list(B)};
to_list({A,B,C}) ->
	{to_list(A),to_list(B),to_list(C)};

to_list(Data) when is_list(Data) ->
	Data;
to_list(Data) when is_atom(Data) ->
	atom_to_list(Data);
to_list(Data) when is_integer(Data) ->
	integer_to_list(Data);
to_list(Data) when is_binary(Data) ->
	binary_to_list(Data).







%%==== hackney get request

get_req(SrcId, TargetId) ->
    BaseURL = application:get_env(sqor_ft_rest, lambda_base_url,
                  <<"https://lambda.sqor.com/">>),
    Path = <<"entities/dev/following/">>,
    Qs = <<"?source_entity_id=", SrcId/binary,"&target_entity_id=", TargetId/binary>>,    
    URL = <<BaseURL/binary, Path/binary,Qs/binary>>,
    lager:info("URL=~p",[URL]),
    {ok, 200, _Headers, ClientRef} = hackney:request(get, URL),
    {ok, JSONResp} = hackney:body(ClientRef),
    jsx:decode(JSONResp).



%%==== hackney post request

post_req(Req0, State) ->
    TargetId = cowboy_req:binding(id, Req0),
    SrcId = cowboy_req:header(<<"user-id">>, Req0),
    Token = cowboy_req:header(<<"access-token">>, Req0),
    BaseURL = application:get_env(sqor_ft_rest, lambda_base_url,
                  <<"https://lambda.sqor.com/">>),
    Path = <<"entities/dev/follow">>,
    URL = <<BaseURL/binary, Path/binary>>,
    Body = jsx:encode([{source_entity_id, SrcId}, {target_entity_id, TargetId}]),
    {ok, 200, _Headers, _Ref} =
        hackney:request(post, URL, [{'content-type', 'application/json'}], Body),
    spawn(sfr_entities_follow, invalidate_cache, [Token]),
    {true, Req0, State}.


%%====== reg exp


-spec matches_regex(Str, Regex) -> Matches when
    Str     :: string() | binary(),
    Regex   :: string(),
    Matches :: boolean().
matches_regex(Str, Regex) when is_binary(Str) ->
    matches_regex(binary_to_list(Str), Regex);
matches_regex(Str, Regex) ->
    {ok, CompiledRegex} = re:compile(Regex),
    io:format("CompiledRegex,:~p~n",[CompiledRegex]),
    Result = re:run(Str, CompiledRegex),
    io:format("Result,:~p~n",[Result]),
    case Result of
        {match, _} -> true;
        _          -> false
    end.


dis(A) ->
    io:format("~nArg1===> ~p~n~n", [A]).
dis(A, B) ->
    io:format("~nArg1===> ~p~nArg2===> ~p~n", [A, B]).
dis(A, B, C) ->
    io:format("~nArg1===> ~p~nArg2===> ~p~nArg3===> ~p~n", [A, B, C]).




%%%%%%%%% pmap


part(List) ->
        part(List, []).
part([], Acc) ->
        lists:reverse(Acc);
part([H], Acc) ->
        lists:reverse([[H]|Acc]);
part([H1,H2|T], Acc) ->
        part(T, [[H1,H2]|Acc]).



% 11> A = [1,3,3,4,5,6,6,7,8,4,5,6,6,7,73,3,3,3,3].
% [[1,3],[3,4],[5,6],[6,7,8],[4,5],[6,6,7],[73,3],[3,3,3]]
split_list(L) ->
    {L1, L2} = split_l(L),
    [{L3, L4}, {L5, L6}] = [split_l(X)||X<-[L1, L2]],
    [{L7, L8}, {L9, L10}, {L11, L12}, {L13, L14}] =
      [split_l(X)||X<-[L3, L4, L5, L6]],
    [L7, L8, L9, L10, L11, L12, L13, L14].


split_l(L)  ->
 lists:split(length(L) div 2, L).



% 11> A = [1,3,3,4,5,6,6,7,8,4,5,6,6,7,73,3,3,3,3].
% [1,3,3,4,5,6,6,7,8,4,5,6,6,7,73,3,3,3,3]
% 12> awwfun:test_pmap([A,A,A,A,A]).


test_pmap(L) ->
    Processor = fun(X) -> split_list(X) end,
    pmap(Processor, L).


 pmap(F, L) ->
    S = self(),
    Pids = lists:map(fun(I) -> spawn(fun() -> pmap_f(S, F, I) end) end, L),
    pmap_gather(Pids).

pmap_gather([H|T]) ->
    receive
        {H, Ret} -> [Ret|pmap_gather(T)]
    end;
pmap_gather([]) ->
    [].

pmap_f(Parent, F, I) ->
    Parent ! {self(), (catch F(I))}.



encode(Mdn) ->
	Base64EncMdn = base64:encode_to_string(Mdn),
	re:replace(Base64EncMdn,"=","!",[global, {return, list}]).

decode(Base64EncMdn) ->
	Base64EncMdnWoPad = re:replace(Base64EncMdn,"!","=",[global, {return, list}]),
	base64:decode_to_string(Base64EncMdnWoPad).


% vm.args env variables

% ## Name of the node
% -name pushysim@127.0.0.1

% ## Cookie for distributed erlang
% -setcookie pushysim

% ## Heartbeat management; auto-restarts VM if it dies or becomes unresponsive
% ## (Disabled by default..use with caution!)
% ##-heart

% ## Enable kernel poll and a few async threads
% +K true
% +A 10

% +P 262144

% ## Increase number of concurrent ports/sockets
% -env ERL_MAX_PORTS 65536

% ## Tweak GC to run more often
% -env ERL_FULLSWEEP_AFTER 10

% ## Increase logfile size to 10M
% -env RUN_ERL_LOG_MAXSIZE 10000000

