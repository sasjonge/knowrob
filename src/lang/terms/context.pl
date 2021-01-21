:- module(lang_context, []).

:- use_module(library('db/mongo/compiler')).
:- use_module(library('db/mongo/query')).

%% register query commands
:- add_query_command(context).

%%
% context(-Option) and context(-Option, +Default) are used to read
% options from compile context to make them accessible in rules.
% The main usecase is that some temporal predicates need to access
% the query scope.
%
query_compiler:step_compile(
		context(Option),
		Context,
		[]) :-
	option(Option, Context).

query_compiler:step_compile(
		context(Option, Default),
		Context,
		[]) :-
	option(Option, Context, Default).