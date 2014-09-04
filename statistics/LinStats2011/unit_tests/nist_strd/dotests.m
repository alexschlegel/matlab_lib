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
if any(l<10)
    res = 'failed';
end

L = table( [], name, l, res );

end
