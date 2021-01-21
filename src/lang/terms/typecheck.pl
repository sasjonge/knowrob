:- module(lang_typecheck, []).

:- use_module(library('db/mongo/compiler')).
:- use_module(library('db/mongo/query')).

%% register query commands
:- add_query_command(ground).
:- add_query_command(var).
:- add_query_command(number).
:- add_query_command(atom).
:- add_query_command(is_list).

%%
query_compiler:step_var(ground(X),  [V,X]) :- query_compiler:var_key(X, V).
query_compiler:step_var(var(X),     [V,X]) :- query_compiler:var_key(X, V).
query_compiler:step_var(number(X),  [V,X]) :- query_compiler:var_key(X, V).
query_compiler:step_var(atom(X),    [V,X]) :- query_compiler:var_key(X, V).
query_compiler:step_var(is_list(X), [V,X]) :- query_compiler:var_key(X, V).

%%
% ground(X) holds iff a previous step has assigned
% a value to the variable key.
%
query_compiler:step_compile(
		ground(A0), _Context, []) :-
	% is grounded already compile-time
	ground(A0),
	!.

query_compiler:step_compile(
		ground(A0), _Context,
		[['$match', [
			[A, ['$exists', bool(true)]]
		]]]) :-
	query_compiler:var_key(A0, A).

%%
% var(X) holds iff no previous step has assigned
% a value to the variable key.
%
query_compiler:step_compile(
		var(A0), _Context, []) :-
	% is grounded already compile-time
	ground(A0),
	!,
	fail.

query_compiler:step_compile(
		var(A0), _Context,
		[['$match', [
			[A, ['$exists', bool(false)]]
		]]]) :-
	query_compiler:var_key(A0, A).

%%
%
%
query_compiler:step_compile(number(A0), _Context, []) :-
	% is grounded already compile-time
	ground(A0),
	!,
	% TODO: is it even ok to yield false here to skip a step?
	%           could be that this causes an exception being thrown.
	number(A0).
	
query_compiler:step_compile(
		number(A0), _Context,
		[['$match', ['$isNumber', A]]]) :-
	query_compiler:var_key(A0, A).

%%
%
%
query_compiler:step_compile(
		atom(A0), _Context, Pipeline) :-
	match_type_(A0, atom, string, Pipeline).

%%
%
%
query_compiler:step_compile(
		is_list(A0), _Context, Pipeline) :-
	match_type_(A0, is_list, array, Pipeline).


%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% helper
%%%%%%%%%%%%%%%%%%%%%%%

%%
match_type_(Arg, Goal, _Type, []) :-
	% argument is grounded already compile-time
	ground(Arg),
	!,
	call(Goal, [Arg]).

match_type_(Arg, _Goal, Type, 
		[['$match',
			[Key, ['$type', string(Type)]]
		]]) :-
	query_compiler:var_key(Arg, Key).