function test_vars
%TEST_VARS unit test for Vars class

%%
load weather
% g1 is double
% g2 and g3 are cellstr

% test var type
v = Vars(g1,g2,g3);
if ~all( v.type == [ 0 1 1] )
    error( 'Variable type is incorrect' );
end

% test that int8 get typed as categorical 
v = Vars( uint8(g1), g2, g3 );
if ~all( v.type == 1  )
    error( 'Variable type is incorrect' );
end

% test specifying type is applied homogeneously where appropriate
v = Vars( g1, g2, g3, 'type', 3 );
if ~all( v.type == 3  )
    error( 'Variable type is incorrect' );
end

% test specifying type is applied heterogeneously where appropriate
v = Vars( g1, g2, g3, 'type', [-1 3 3] );
if ~all( v.type == [-1 3 3]  )
    error( 'Variable type is incorrect' );
end

% test that specifying annotation works
Vars(g1,g2,g3, 'type', v.type, 'anno', v.anno);

% test that passing in multiple variables on a single observation works
v.x(2:end,:) = [];
Vars(v.x, 'type', 1, 'anno', v.anno);
%%

% test encoding schemes are encoded correctly
% set level hi to be 1
v = Vars( g2, 'type', 1, 'levelnames', { 'hi',  'lo'}' );
k = strcmp(g2,'hi');
iseq( v.x(k,1), ones( sum(k),1) );
iseq( g2, decode(v,1));

% set level hi to encode as 2.
v = Vars( g2, 'type', 1, 'levelnames', { 'lo',  'hi'}' );
k = strcmp(g2,'hi');
iseq( v.x(k,1), 2*ones( sum(k),1) );
iseq( g2, decode(v,1));


%%
% test creating matrix of ordinals, given particular names
[X fn] = grp2ind(g1,g2,g3);
X = int8(X);
v = Vars( X(:,1), X(:,2), X(:,3), 'levelnames', fn );
iseq( g1, str2double(decode(v,1)));
iseq( g2, decode(v,2));
iseq( g3, decode(v,3));


%% Test Data Assignment
v.x = X+1;
iseq(v.x, X+1);
% 
v.x(:,2) = X(:,2);
iseq(v.x(:,2), X(:,2));

%% Test deletion of variables

v1 = Vars( g1, g2, g3, 'type', [0 3 3] );
v2 = v1(:,2:3);
v1(:,1) = [];
iseq(v1,v2);


%% Test deletion of observations

v1 = Vars( g1, g2, g3, 'type', [0 3 3 ] );
v2 = v1(2:end,:);
v1(1,:) = [];
iseq(v1,v2);

%% Test hetrogenous datasets

%% 
load carbig
v = Vars( int8(Cylinders) );
if v.type(1) ~= 1
    error('Variable type is incorrect');
end


%% test reorder/decode/construct levels
% in this test create a collection of 
% levels a..z and then randomly reassign them
% to different ranking. test that the decoded 
% values have not changed
ln = ('A':'Z')';
d = unidrnd( 26, 100,1);
x = ln(d);
v0 = Vars(x);
n = length(unique(d));
o = randsample(n,n);
v1 = reorderLevels(v0, o ,1 );  % new random order

[o, o] = sort(v1.getLevelNames);
v2 = reorderLevels( v1, o, 1 ); % change it back
if ~isequal(v2.x, v0.x);   % check it
    error('Variable reorder is incorrect');
end

if ~isequal(v1.decode, v0.decode) || ~isequal( v2.decode, v1.decode)   % check decode
    error('Variable decode is incorrect');
end

v3 = Vars( x, 'levelnames', v1.getLevelNames);
if ~isequal(v3.decode, v1.decode) || ~isequal( v3.x, v1.x)   % check decode
    error('Variable construct is incorrect');
end

%% test matrix input 

v = Vars( randn(10,2), 'type', 0 );

v = Vars( [g2 g3] );
if ~isequal( decode(v,1), g2 ) || ~isequal( decode(v,2), g3 )
      error('matrix input of cell str failed');
end
g4 = g3;
g4(1) = {''};
v = Vars( [g2 g4] );
if ~isequal( decode(v,2), g4 )
      error('matrix input of cell str with missing values failed');
end

%% test mixed input

% combined annotation
v = Vars( randn(10,2), unidrnd( 10,10, 1 ), 'anno', {'x1', 'y1' 'g1'}', 'type', [0 1] );

anno = dataset(  {'x1', 'y1' 'g1'}' );
v = Vars( randn(10,2), unidrnd( 10,10, 1 ), 'anno',anno, 'type', [0 1] );

% matrix and vector with group annotation for matrix and another for vector
v = Vars( randn(10,2), unidrnd( 10,10, 1 ), 'anno', {{'x'} 'g1'}', 'type', [0 1] );

% matrix and vector with group annotation for matrix and another for vector
v = Vars( randn(10,2), unidrnd( 10,10, 1 ), 'anno', {anno(1:2,:) 'g1'}', 'type', [0 1] );


disp( 'Vars: passed' );

function e = iseq(a,b)
if ~isequal( a, b ) 
    error( 'variable is not encoded correctly' );
end
e = true;