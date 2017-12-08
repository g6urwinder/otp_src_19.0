%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2001-2016. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%
-module(andor_SUITE).

-export([all/0, suite/0,groups/0,init_per_suite/1, end_per_suite/1, 
	 init_per_group/2,end_per_group/2,
	 t_case/1,t_and_or/1,t_andalso/1,t_orelse/1,inside/1,overlap/1,
	 combined/1,in_case/1,slow_compilation/1]).
	 
-include_lib("common_test/include/ct.hrl").

suite() -> [{ct_hooks,[ts_install_cth]}].

all() -> 
    test_lib:recompile(?MODULE),
    [{group,p}].

groups() -> 
    [{p,[parallel],
      [t_case,t_and_or,t_andalso,t_orelse,inside,overlap,
       combined,in_case,slow_compilation]}].

init_per_suite(Config) ->
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_GroupName, Config) ->
	Config.

end_per_group(_GroupName, Config) ->
	Config.


t_case(Config) when is_list(Config) ->
    %% We test boolean cases almost but not quite like cases
    %% generated by andalso/orelse.
    less = t_case_a(1, 2),
    not_less = t_case_a(2, 2),
    {'EXIT',{{case_clause,false},_}} = (catch t_case_b({x,y,z}, 2)),
    {'EXIT',{{case_clause,true},_}} = (catch t_case_b(a, a)),
    eq = t_case_c(a, a),
    ne = t_case_c(42, []),
    t = t_case_d(x, x, true),
    f = t_case_d(x, x, false),
    f = t_case_d(x, y, true),
    {'EXIT',{badarg,_}} = (catch t_case_d(x, y, blurf)),
    true = (catch t_case_e({a,b}, {a,b})),
    false = (catch t_case_e({a,b}, 42)),

    true = t_case_xy(42, 100, 700),
    true = t_case_xy(42, 100, whatever),
    false = t_case_xy(42, wrong, 700),
    false = t_case_xy(42, wrong, whatever),

    true = t_case_xy(0, whatever, 700),
    true = t_case_xy(0, 100, 700),
    false = t_case_xy(0, whatever, wrong),
    false = t_case_xy(0, 100, wrong),

    ok.

t_case_a(A, B) ->
    case A < B of
	[_|_] -> ok;
	true -> less;
	false -> not_less;
	{a,b,c} -> ok;
	_Var -> ok
    end.

t_case_b(A, B) ->
    case A =:= B of
	blurf -> ok
    end.

t_case_c(A, B) ->
    case not(A =:= B) of
	true -> ne;
	false -> eq
    end.

t_case_d(A, B, X) ->
    case (A =:= B) and X of
	true -> t;
	false -> f
    end.

t_case_e(A, B) ->
    case A =:= B of
	Bool when is_tuple(A) -> id(Bool)
    end.

t_case_xy(X, Y, Z) ->
    Res = t_case_x(X, Y, Z),
    Res = t_case_y(X, Y, Z).

t_case_x(X, Y, Z) ->
    case abs(X) =:= 42 of
	true ->
	    Y =:= 100;
	false ->
	    Z =:= 700
    end.

t_case_y(X, Y, Z) ->
    case abs(X) =:= 42 of
	false ->
	    Z =:= 700;
	true ->
	    Y =:= 100
    end.

-define(GUARD(E), if E -> true;
             true -> false
          end).

t_and_or(Config) when is_list(Config) ->
    true = true and true,
    false = true and false,
    false = false and true,
    false = false and false,

    true = id(true) and true,
    false = id(true) and false,
    false = id(false) and true,
    false = id(false) and false,

    true = true and id(true),
    false = true and id(false),
    false = false and id(true),
    false = false and id(false),

    true = true or true,
    true = true or false,
    true = false or true,
    false = false or false,

    true = id(true) or true,
    true = id(true) or false,
    true = id(false) or true,
    false = id(false) or false,

    true = true or id(true),
    true = true or id(false),
    true = false or id(true),
    false = false or id(false),

    True = id(true),

    false = ?GUARD(erlang:'and'(bar, True)),
    false = ?GUARD(erlang:'or'(bar, True)),
    false = ?GUARD(erlang:'not'(erlang:'and'(bar, True))),
    false = ?GUARD(erlang:'not'(erlang:'not'(erlang:'and'(bar, True)))),

    true = (fun (X = true) when X or true or X -> true end)(True),

    Tuple = id({a,b}),
    case Tuple of
	{_,_} ->
	    {'EXIT',{badarg,_}} = (catch true and Tuple)
    end,

    ok.

t_andalso(Config) when is_list(Config) ->
    Bs = [true,false],
    Ps = [{X,Y} || X <- Bs, Y <- Bs],
    lists:foreach(fun (P) -> t_andalso_1(P) end, Ps),

    true = true andalso true,
    false = true andalso false,
    false = false andalso true,
    false = false andalso false,

    true = ?GUARD(true andalso true),
    false = ?GUARD(true andalso false),
    false = ?GUARD(false andalso true),
    false = ?GUARD(false andalso false),

    false = false andalso glurf,
    false = false andalso exit(exit_now),

    true = not id(false) andalso not id(false),
    false = not id(false) andalso not id(true),
    false = not id(true) andalso not id(false),
    false = not id(true) andalso not id(true),

    {'EXIT',{badarg,_}} = (catch not id(glurf) andalso id(true)),
    {'EXIT',{badarg,_}} = (catch not id(false) andalso not id(glurf)),
    false = id(false) andalso not id(glurf),
    false = false andalso not id(glurf),

    true = begin (X1 = true) andalso X1, X1 end,
    false = false = begin (X2 = false) andalso X2, X2 end,

    ok.

t_orelse(Config) when is_list(Config) ->
    Bs = [true,false],
    Ps = [{X,Y} || X <- Bs, Y <- Bs],
    lists:foreach(fun (P) -> t_orelse_1(P) end, Ps),
    
    true = true orelse true,
    true = true orelse false,
    true = false orelse true,
    false = false orelse false,

    true = ?GUARD(true orelse true),
    true = ?GUARD(true orelse false),
    true = ?GUARD(false orelse true),
    false = ?GUARD(false orelse false),

    true = true orelse glurf,
    true = true orelse exit(exit_now),

    true = not id(false) orelse not id(false),
    true = not id(false) orelse not id(true),
    true = not id(true) orelse not id(false),
    false = not id(true) orelse not id(true),

    {'EXIT',{badarg,_}} = (catch not id(glurf) orelse id(true)),
    {'EXIT',{badarg,_}} = (catch not id(true) orelse not id(glurf)),
    true = id(true) orelse not id(glurf),
    true = true orelse not id(glurf),

    true = begin (X1 = true) orelse X1, X1 end,
    false = begin (X2 = false) orelse X2, X2 end,

    ok.

t_andalso_1({X,Y}) ->
    io:fwrite("~w andalso ~w: ",[X,Y]),
    V1 = echo(X) andalso echo(Y),
    V1 = if
	     X andalso Y -> true;
	     true -> false
	 end,
    V1 = id(X and Y).

t_orelse_1({X,Y}) ->
    io:fwrite("~w orelse ~w: ",[X,Y]),
    V1 = echo(X) orelse echo(Y),
    V1 = if
	     X orelse Y -> true;
	     true -> false
	 end,
    V1 = id(X or Y).

inside(Config) when is_list(Config) ->
    true = inside(-8, 1),
    false = inside(-53.5, -879798),
    false = inside(1.0, -879),
    false = inside(59, -879),
    false = inside(-11, 1.0),
    false = inside(100, 0.2),
    false = inside(100, 1.2),
    false = inside(-53.5, 4),
    false = inside(1.0, 5.3),
    false = inside(59, 879),
    ok.

inside(Xm, Ym) ->
    X = -10.0,
    Y = -2.0,
    W = 20.0,
    H = 4.0,
    Res = inside(Xm, Ym, X, Y, W, H),
    Res = if
	      X =< Xm andalso Xm < X+W andalso Y =< Ym andalso Ym < Y+H -> true;
	      true -> false
	  end,
    case not id(Res) of
	Outside ->
	    Outside = if
			  not(X =< Xm andalso Xm < X+W andalso Y =< Ym andalso Ym < Y+H) -> true;
			  true -> false
		      end
    end,
    {Res,Xm,Ym,X,Y,W,H} = inside_guard(Xm, Ym, X, Y, W, H),
    io:format("~p =< ~p andalso ~p < ~p andalso ~p =< ~p andalso ~p < ~p ==> ~p",
	      [X,Xm,Xm,X+W,Y,Ym,Ym,Y+H,Res]),
    Res.

inside(Xm, Ym, X, Y, W, H) ->
    X =< Xm andalso Xm < X+W andalso Y =< Ym andalso Ym < Y+H.

inside_guard(Xm, Ym, X, Y, W, H) when X =< Xm andalso Xm < X+W
				      andalso Y =< Ym andalso Ym < Y+H ->
    {true,Xm,Ym,X,Y,W,H};
inside_guard(Xm, Ym, X, Y, W, H) ->
    {false,Xm,Ym,X,Y,W,H}.

overlap(Config) when is_list(Config) ->
    true = overlap(7.0, 2.0, 8.0, 0.5),
    true = overlap(7.0, 2.0, 8.0, 2.5),
    true = overlap(7.0, 2.0, 5.3, 2),
    true = overlap(7.0, 2.0, 0.0, 100.0),

    false = overlap(-1, 2, -35, 0.5),
    false = overlap(-1, 2, 777, 0.5),
    false = overlap(-1, 2, 2, 10),
    false = overlap(2, 10, 12, 55.3),
    ok.

overlap(Pos1, Len1, Pos2, Len2) ->
    Res = case Pos1 of
	      Pos1 when (Pos2 =< Pos1 andalso Pos1 < Pos2+Len2)
			orelse (Pos1 =< Pos2 andalso Pos2 < Pos1+Len1) ->
		  true;
	      Pos1 -> false
	  end,
    Res = (Pos2 =< Pos1 andalso Pos1 < Pos2+Len2)
	orelse (Pos1 =< Pos2 andalso Pos2 < Pos1+Len1),
    Res = case Pos1 of
	      Pos1 when (Pos2 =< Pos1 andalso Pos1 < Pos2+Len2)
			orelse (Pos1 =< Pos2 andalso Pos2 < Pos1+Len1) ->
		  true;
	      Pos1 -> false
	  end,
    id(Res).


-define(COMB(A,B,C), (A andalso B orelse C)).

combined(Config) when is_list(Config) ->
    false = comb(false, false, false),
    true = comb(false, false, true),
    false = comb(false, true, false),
    true = comb(false, true, true),

    false = comb(true, false, false),
    true = comb(true, true, false),
    true = comb(true, false, true),
    true = comb(true, true, true),

    false = comb(false, blurf, false),
    true = comb(false, blurf, true),
    true = comb(true, true, blurf),

    false = ?COMB(false, false, false),
    true = ?COMB(false, false, true),
    false = ?COMB(false, true, false),
    true = ?COMB(false, true, true),

    false = ?COMB(true, false, false),
    true = ?COMB(true, true, false),
    true = ?COMB(true, false, true),
    true = ?COMB(true, true, true),

    false = ?COMB(false, blurf, false),
    true = ?COMB(false, blurf, true),
    true = ?COMB(true, true, blurf),

    false = simple_comb(false, false),
    false = simple_comb(false, true),
    false = simple_comb(true, false),
    true = simple_comb(true, true),

    ok.
-undef(COMB).

comb(A, B, C) ->
    Res = A andalso B orelse C,
    Res = if
	      A andalso B orelse C -> true;
	      true -> false
	  end,
    NotRes = if
		 not(A andalso B orelse C) -> true;
		 true -> false
	     end,
    NotRes = id(not Res),
    Res = A andalso B orelse C,
    Res = if
	      A andalso B orelse C -> true;
	      true -> false
	  end,
    NotRes = id(not Res),
    Res = if
	      A andalso B orelse C -> true;
	      true -> false
	  end,
    id(Res).

simple_comb(A, B) ->
    %% Use Res twice, to ensure that a careless optimization of 'not'
    %% doesn't leave Res as a free variable.
    Res = A andalso B,
    _ = id(not Res),
    Res.

%% Test that a boolean expression in a case expression is properly
%% optimized (in particular, that the error behaviour is correct).
in_case(Config) when is_list(Config) ->
    edge_rings = in_case_1(1, 1, 1, 1, 1),
    not_loop = in_case_1(0.5, 1, 1, 1, 1),
    loop = in_case_1(0.5, 0.9, 1.1, 1, 4),
    {'EXIT',{badarith,_}} = (catch in_case_1(1, 1, 1, 1, 0)),
    {'EXIT',{badarith,_}} = (catch in_case_1(1, 1, 1, 1, nan)),
    {'EXIT',{badarg,_}} = (catch in_case_1(1, 1, 1, blurf, 1)),
    {'EXIT',{badarith,_}} = (catch in_case_1([nan], 1, 1, 1, 1)),
    ok.

in_case_1(LenUp, LenDw, LenN, Rotation, Count) ->
    Res = in_case_1_body(LenUp, LenDw, LenN, Rotation, Count),
    Res = in_case_1_guard(LenUp, LenDw, LenN, Rotation, Count),
    Res.

in_case_1_body(LenUp, LenDw, LenN, Rotation, Count) ->
    case (LenUp/Count > 0.707) and (LenN/Count > 0.707) and
	(abs(Rotation) > 0.707) of
	true ->
	    edge_rings;
	false ->
	    case (LenUp >= 1) or (LenDw >= 1) or
		(LenN =< 1) or (Count < 4) of
		true ->
		    not_loop;
		false -> 
		    loop
	    end
    end.

in_case_1_guard(LenUp, LenDw, LenN, Rotation, Count) ->
    case (LenUp/Count > 0.707) andalso (LenN/Count > 0.707) andalso
	(abs(Rotation) > 0.707) of
	true -> edge_rings;
	false when LenUp >= 1 orelse LenDw >= 1 orelse
	LenN =< 1 orelse Count < 4 -> not_loop;
	false -> loop
    end.

-record(state, {stack = []}).

slow_compilation(_) ->
    %% The function slow_compilation_1 used to compile very slowly.
    ok = slow_compilation_1({a}, #state{}).

slow_compilation_1(T1, #state{stack = [T2|_]})
    when element(1, T2) == a, element(1, T1) == b, element(1, T1) == c ->
    ok;
slow_compilation_1(T, _)
    when element(1, T) == a1; element(1, T) == b1; element(1, T) == c1 ->
    ok;
slow_compilation_1(T, _)
    when element(1, T) == a2; element(1, T) == b2; element(1, T) == c2 ->
    ok;
slow_compilation_1(T, _) when element(1, T) == a ->
    ok;
slow_compilation_1(T, _)
    when
        element(1, T) == a,
        (element(1, T) == b) and (element(1, T) == c) ->
    ok;
slow_compilation_1(_, T) when element(1, T) == a ->
    ok;
slow_compilation_1(_, T) when element(1, T) == b ->
    ok;
slow_compilation_1(T, _) when element(1, T) == a ->
    ok.

%% Utilities.

echo(X) ->	    
    io:fwrite("eval(~w); ",[X]),
    X.

id(I) -> I.
