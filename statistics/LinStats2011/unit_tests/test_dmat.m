function test_dmat

load weather
v = Vars( g2,g1, g3, 'type', [ 1 0 3]);
d = Dmat( v, 3);
n = size(d,1);

%% subsref
% todo: test 1:end, : 
dtest( d(:,1) - ones(n,1));  % intercept term (is a double)
dtest( d(:,2) - mdummy(v.x(:,1),1)); %
dtest( d(:,3) - mdummy(v.x(:,2),0)); % 
dtest( d(:,4) - mdummy(v.x(:,3),3));
X = d.X;
Z = d.Z;

%% nested terms
sample =  [1 2 2 1 1 2 2 1]';
chip     =   [1 1 2 2 1 1 2 2]';
chan    =   [1 2 1 2 1 2 1 2]';
loop    =   [1 1 1 1 2 2 2 2]';

v = Vars( sample, chan, chip, loop, 'type', 1);
dmat= Dmat( v, 'model', [0 0 0 0; 1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 -1 1] );

% this should also work. It doesn't matter whether the chips are
% encoded 1..n or the labels are reused within the nesting factor
chip     =   [1 1 2 2 3 3 4 4]';

v = Vars( sample, chan, chip, loop, 'type', 1);
dtest( dmat - Dmat( v, 'model', [0 0 0 0; 1 0 0 0; 0 1 0 0; 0 0 0 1; 0 0 -1 1] ))

%% Augmenting design
load weather
d1 = Dmat(g1);
d2 = Dmat(g2,'model', 0);
d3 = Dmat(g3,'model', 0);
y(1) = nanmean(y);

s1 = Lstats( y, [d1 d2 d3] );
v = Vars(g1,g2,g3);
s2 = Lstats(y,v);
if ~isequal(s1,s2)
    error( 'failed to concatenate');
end

%% Accessing
dmat(2,:);
dmat(:,2);
dmat(1:end,2);
dmat(:, 1:4);
size(dmat);
length(dmat);
size(dmat,2);
size(dmat,1);
% accessing as vector
c = d(:,1);
c(1);
c = d(1,:);
c(2);

%% Transpose
% 
% check rnames and cnames
c = d';
if ~isequal( c.rnames, d.cnames') || ~isequal( c.cnames', d.rnames)
    error('failed Dmat: transposed names do not match');
end

%% Two continuous variables

v = Vars( randn(10,2) );
m = Dmat(v,2);

%%
load weather
m = Dmat(g1,g2,g3);
y(1) = nanmean(y);
s = Lstats(y,m);


%%
disp( 'passed: Dmat');

end

function dtest(A)

if norm(A) > eps(max(A(:)))
    error( 'failed: Dmat');
end

end