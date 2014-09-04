function i = col2ind(order,siz)
%col2ind converts column specific 1-based indices to element based indices
%i = col2ind(A, siz)
%   return i, a set of integer indices into a m x n matrix
%   A is a p x n set of column specific indices as you'd get from the second
%   output of sort
%   size is optional. 
%        if present, P is set to SIZ(1), otherwise 
%        P is set to the size of the first dimension of ORDER, 
%
% example
%   [xsort order] = sort(x);
%   wrong = x(order);    % this isn't what you want
%   xsort = x(col2ind(order));   % this is

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
[m p] = size(order);    
if nargin < 2
    q = m;
else
    q = siz(1);
end
oset = 0:q:(q*p-1);
i = order + repmat( oset, m, 1 );
