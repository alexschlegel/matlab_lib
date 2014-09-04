function [d, V] = center(X, V, dim)
%CENTER subtracts a vector from each row of a matrix. 
% this function predated Matlab's bsxfun, which is a good generalization
% and this function is now a wrapper around bsxfun. 
%
%data utility to simplify subtracting each row of a matrix by a vector
%
% [D V] = center(X, V, dim)
%         X is a m x n matrix
%         V is a 1 x n vector. defaults to column sum of X
%         dim is a scalar equal to 1 or 2. 1 to subtract a row vector, 2
%         to subtract a column vector
%     RETURNS
%         D is a new matrix with each row of X divided by V
%         V is the same as input V, or equal to the mean(X,dim)
%
%Example
%   load carbig
%   X = [MPG Acceleration Weight Displacement];
%   z = center( X, nanmean(X) ); 
%   z = center(X, nanmean(X,2), 2);

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
% 

if nargin < 3
    dim = 1;
end;

if ( nargin < 2 )
    V = mean(X, dim);
end;


[m, n] = size(X);
s = n;
if dim == 2
    s = m;
end;

if ~isscalar(V) && (~isvector(V) || length(V) ~= s)
     error('linstats:scale:InvalidArgument', 'Input argument must be a vector');
end

if dim == 2
    d = bsxfun( @minus, X, V(:) );
elseif dim==1
   d = bsxfun( @minus, X, V(:)' );
else
    error( 'dim must be 1 or 2');
end