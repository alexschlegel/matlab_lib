function L = test_lstats

[p fname ext] = fileparts( which('test_lstats'));
pname  = [p, '\nist_strd'] ;
addpath( pname );


load popcorn;
S       = Vars( cols, rows, 'type', [1 1] );
glm     =  Model(y,S , 2 );
ls      = Lstats(glm.ya,glm.Xa);
%% Ls estimates
try
    L = glm.getlsestimator;
    stats = test( ls, L );

    load anova_test_results_new glm_est;
    mat_compare( stats(:,1), glm_est.stats.beta );
    mat_compare( stats(:,2), glm_est.stats.se );
    disp('passed: lsestimates');
catch E
    disp('failed: lsestimates');
    disp(E );
end;

% TODO: test contrasts
% TODO: test least-squares parameter estimates with different encoding
% (i.e. ordinal and nominal) and include a crossed continuous term with
% each encoding type including overdetermined.

ws1 = warning('off','Model:NoIntercept');
ws2 = warning('off','Lstats:RemovingLeadingConstants');

L = table([], 'name', 'F', 'SSR', 'SSE', 'E', 'B', 'S', 'result' );
%% NISTS tests

load SiRstv.mat
m = Model( Resistance, Instrument, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SiRstv' );];

%%
load SmLs01
m = Model( Response, Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs01' );];

%%
load SmLs02
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs02' );];

%%
load SmLs03
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs03' );];

%%
load AtmWtAG
m = Model( ds.AgWt, ds.Instrument, 'type', 1);
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'AtmWtAG' );];

%%
load SmLs04
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs04' );];

%%
load SmLs05
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs05' );];

%%
load SmLs06
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs06' );];

%% TODO: use SmLs07 with a variety of randomly added large constants
load SmLs07
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs07' );];

%%
load SmLs08
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs08' );];

%%
load SmLs09
m = Model( ds.Response, ds.Treatment, 'type', 1 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, [], [], 'SmLs09' );];

%%
load Norris
m = Model( ds.y, ds.x );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Norris' );];

%%
load NoInt1
m = Model( ds.y, ds.x, 'model', 0);
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'NoInt1' );];

%%
load NoInt2
m = Model( ds.y, ds.x, 'model', 0 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'NoInt2' );];

%%
% to get the F value right these polynomials need to be centered.
% Thus the parameter estimates are differ from the certified values
load Filip
m = Model( ds.y, ds.x, 'model', (0:10)' );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Filip' );];


%%
% to get the F value right these polynomials need to be centered.
% Thus the parameter estimates are differ from the certified values
load Longley
m = Model( ds.y, ds.x1, ds.x2, ds.x3, ds.x4, ds.x5, ds.x6 );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Longley' );];



%%
load Wampler1
m = Model( ds.y, ds.x, 'model', (0:5)' );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Wampler1' );];


%% Wampler 2
load Wampler2
m = Model( ds.y, ds.x, 'model', (0:5)' );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Wampler2' );];

%% Wampler 3
load Wampler3
m = Model( ds.y, ds.x, 'model', (0:5)' );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Wampler3' );];

%% Wampler 4
load Wampler4
m = Model( ds.y, ds.x, 'model', (0:5)' );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Wampler4' );];

%% Wampler 5
load Wampler5
m = Model( ds.y, ds.x, 'model', (0:5)' );
m = solve(m);
L = [L; dotests(m, F, SSR, SSE, E, B, S, 'Wampler5' );];


%% one tailed
test( ls,[], 'alpha', .01, 'tail', 1 );

ws1 = warning(ws1.state,'Model:NoIntercept');
ws2 = warning(ws2.state,'Lstats:RemovingLeadingConstants');

rmpath( pname );


end

function L = dotests( m, F, SSR, SSE, E, B, S, name )
l = nan(1,6);
a = fit(m);
l(1) = lre( a(1,1), F );
l(2) = lre( m.stats.ssr, SSR );
l(3) = lre( m.stats.sse, SSE );
l(4) = lre( sqrt(m.stats.s2),E);

ll = nan;
b = double(m.stats.beta(:,1));
for i = 1:size(B,1)
    ll(i) = lre( b(i), B(i) );
end
l(5) = min(ll);

e = m.estimates;
b = double(e(:,2));
ll = nan;
for i = 1:size(S,1)
    ll(i) = lre( b(i), S(i) );
end
l(6) = min(ll);



res = 'passed';
if any(l<5)
    res = 'failed (lre<5)';
elseif any(l<10)
    res = 'warning (lre<10)';
end

L = table( [], name, l, res );

end
