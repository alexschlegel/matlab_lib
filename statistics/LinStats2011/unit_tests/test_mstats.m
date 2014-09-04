function L = test_mstats
% testing variance estimation function
% A comparison by eye with results from JMP 6 were done using
% mildly-unbalanced data under a 1,2,3 way with interactions and random
% effects. The results were similar to JMP only to a few decimal places.
% The results from my own baseline are treated as gold. So if new versions
% differ, something else must be done to resolve discrepencies.
[p fname ext] = fileparts( which('test_mstats'));
pname  = [p, '\mixed_model_tests'] ;

addpath( pname );

L = table([], 'name', 'F', 'E', 'B', 'S', 'result' );

try
    %%
    load weather1
    m = Model( y, g1, 'type', 3 );
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather1' );];
    
    %% weather 2
    load weather2
    m = Model(y, g1, g2, 'type', [3 1], 'model',2 );
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather2' );];
    
    %% weather 3
    load weather3;
    m = Model(y, g1, g2, 'type', [1 3], 'model', 2 );
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather3' );];
    
    %% weather 4   
    load weather4;
    m = Model(y, g1, g2, g3, 'type', [3 1 1] );
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather4' );];

    %% weather 5
    load weather5
    m = Model( y, g1, g2, g3, 'type',  [1 3 1]);
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather5' );];

    %% weather 6
    load weather6
    m = Model( y, g1, g2, g3, 'type',  [1 1 3]);
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather6' );];
    
 
    %% weather 7
    load weather7
    m = Model( y, g1, g2, g3, 'type',  [3 3 1]);
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather7' );];
    
    %% weather 8
    load weather8
    m = Model( y, g1, g2, g3, 'type', [3 1 1], 'model', 2);
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather8' );];
    
    %% weather 9
    load weather9
    m = Model( y, g1, g2, g3, 'type', [1 3 1], 'model', 2);
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather9' );];
   
    %% weather 10
    load weather10
    m = Model( y, g1, g2, g3, 'type', [1 1 3], 'model', 2);
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather10' );];
   
   
    %% weather 11
    % jmp* [-.9375 56.1031 2.2181 -.2273 1.2061 .8269802]
    % s2{11} disagrees with JMP, and JMP gives a convergence waring   
    % The  likelihoods are much better for mine.

    load weather11
    m = Model( y, g1, g2, g3, 'type', [3 3 1], 'model', 2);
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'weather11' );];
   
    
    %% Fertilizer
    load fertilizer.mat
    m    = Model( y, block, fertilizer, 'type', [3 1] );
    m = solve(m);
    L = [L; dotests(m, F,  E, B, S, 'fertilizer' );];
   
    disp('passed: mixed tests');
catch
    disp('failed: mixed tests' );
    m = lasterror;
    disp( m.message);
end;
rmpath(pname);
end

function L = dotests( m, F,  E, B, S, name )
% F is anova F test statistics (minimum LRE from all F tests)
% E is the variance estimates (minimum LRE)
% B is the parameter estimates (minimum LRE)
% S is the std error of the parameter estimates (minimum LRE)
l = nan(1,4);
a = anova(m);
l(1) = min(lre( double(a(:,1)), F ));
l(2) = min(lre( m.stats.s2,E));

ll = nan;
b = double(m.stats.beta(:,1));
for i = 1:size(B,1)
    ll(i) = lre( b(i), B(i) );
end
l(3) = min(ll);

e = m.estimates;
b = double(e(:,2));
ll = nan;
for i = 1:size(S,1)
    ll(i) = lre( b(i), S(i) );
end
l(4) = min(ll);



res = 'passed';
if any(l<3)
    res = 'failed (lre<3)';
elseif any(l<5)
    res = 'warning (lre<5)';
end

L = table( [], name, l, res );

end
