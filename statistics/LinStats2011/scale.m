function d = scale(X, V, dim)
%SCALE divides a vector from each row in a matrix 
% this function predated Matlab's bsxfun, which is a good generalization
% and this function is now a wrapper around bsxfun. 
%
% data utility to simplify dividing each row in a matrix by a vector
%
% d = scale(X, V)
% X is a m x n matrix
% V is a 1 x n vector. defaults to column sum of X
% d is a new matrix with each row of X divided by V
%
%Example
%   load carbig MPG Acceleration Weight Displacement
%   X = [MPG Acceleration Weight Displacement];
%   z = scale( center( X, mean(X )), std(X)); %columns of z are zscore
%   z = scale(X, nansum(X,2), 2); %rows of z sum to 1. 
%
%See also center

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

if nargin < 3
    dim = 1;
end;

if dim == 2
    d = bsxfun( @rdivide, X, V(:) );
elseif dim==1
   d = bsxfun( @rdivide, X, V(:)' );
else
    error( 'dim must be 1 or 2');
end