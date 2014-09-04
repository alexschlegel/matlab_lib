function test_argParser
%TEST_VARS unit test for Vars class

%%
% v is a collection of input arguments to a function (e.g. varargin)
% input list is case insensitive search for switches and options
v = {'x1', 'x2', 'S1', 's2', '~S3', '~s4', 'O1', 'v1'};
% x1, x2 are first and second arugment
% x3 is unspecified (default) third argument
% s1, s2 turn switches 1 and 2 on (default 1,0, respectively)
% s3 and s4 turn switches 3 and 4 off (default 1,0, respectively)
% s5, s6 are unspecified (use defaults of 1,0 respectively)
% o1 is option with value v1
% o3 is option with unspecified value (use default)

p = ArgParser( v{:} );
try
% test first parsing included case insensitive matches
test( p.isSet('s1', nan), 1 );  %test that provided switch is used and correct
test( p.isSet('S2', nan), 1 );
test( p.isSet('s3', nan), 0 );
test( p.isSet('s4', nan), 0 );
test( p.isSet('s5', 1), 1 );  % test that defaults are set/used correctly
test( p.isSet('s6', 0), 0 );  % test that defaults are set/used correctly
test( p.value('O1', 'default'), 'v1');  % test provided input values are used
test( p.value('o3', 'v3'), 'v3');  % test defaults

% typically process input arguments after switches and options
test( p.value(1), 'x1');    % first arg
test( p.value(2), 'x2');    % second arg
% test value of optional arguments after all others have been removed
test( p.value(3, 'x3'), 'x3' ); % third arg, test defaults used correctly


%% test cached parsing 
% - careful to use the exact same names as above
test( p.isSet('s1', nan), 1 );  %test that provided switch is used and correct
test( p.isSet('S2', nan), 1 );
test( p.isSet('s3', nan), 0 );
test( p.isSet('s4', nan), 0 );
test( p.isSet('s5', 1), 1 );  % test that defaults are set/used correctly
test( p.isSet('s6', 0), 0 );  % test that defaults are set/used correctly
test( p.value('O1', 'default'), 'v1');  % test provided input values are used
test( p.value('o3', 'v3'), 'v3');  % test defaults


%% test structured input
% - careful to use the exact same names as above
o.s1 = true;
o.S2 = true;
o.s3 = false;
o.s4 = false;
o.s5 = true;
o.s6 = false;
o.O1 = 'v1';
o.o3 = 'v3';
p = ArgParser();
p.parseStruct(o);
test( p.isSet('s1', nan), 1 );  %test that provided switch is used and correct
test( p.isSet('S2', nan), 1 );
test( p.isSet('s3', nan), 0 );
test( p.isSet('s4', nan), 0 );
test( p.isSet('s5', 1), 1 );  % test that defaults are set/used correctly
test( p.isSet('s6', 0), 0 );  % test that defaults are set/used correctly
test( p.value('O1', 'default'), 'v1');  % test provided input values are used
test( p.value('o3', 'v3'), 'v3');  % test defaults


disp('passed: ArgParser');
catch
    disp('failed: ArgParser');
end



function test(a,b)
if ~isequal(a,b)
    error
end
