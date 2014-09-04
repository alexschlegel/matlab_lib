function l = lre( q, c )
% Log Relative Error. Returns the number of leading digits two numbers have in common 
% 
% usage
%   l = lre( q, c)
%   q is the estimated value
%   c is the correct correct value
%

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
% special case where c == 0 or is missing, just report then number of
% digits different from 1
if nargin < 2 || (isscalar(c) && c == 0)
    l = -log10(abs(q));
    return;
end

q = double(q);
c = double(c);
aq = abs(double(q));
ac = abs(double(c));

l = zeros(size(q));

k = c == q;
l(k) = inf;

i = c == 0;
l(i) = -log10(aq(i));

j = aq > ac*2 | aq < ac/2;
l(j) = 0;

h = ~j & ~i & ~k;
[i j] = find(h);
if ~isempty(i)
    l(i,j) = -log10( abs(q(i,j)-c(i,j))./ac(i,j));
end