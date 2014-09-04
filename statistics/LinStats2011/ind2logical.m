function [b order] = ind2logical( i, d )
% IND2LOGICAL converts integer index into logical of size d
% 
% Example
%       b = ind2logical( i, d)
%           returns b, a d x n vector where elements b(j,k) = true where j in i and
%           b(j) = false where j not in i
%           d is optional. If absent d is taken to be the max of i(:);
%
%   [b order] = ind2logical(i,d)
%           if i is unsorted, then order is the sort order of i
%
%
% V1.1 generalized to support matrix input of i

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
if isnumeric(i) && all(ismember(i(:), [0 1] ))
    i = logical(i);
end

if islogical(i)
    b = i;
    i = find(i);
    order = 1:length(i);
    if nargin >= 2 && d > size(i,1)
        b(end+1:d,:) = false;
    end
    m = size(i,1);
    if nargin >= 2
    if m > d
        error( 'linstats:ind2logical:indexoutofbounds', 'length of boolean index (%d) exceeds max dimension (%d)', m, d);
    end    
    end
    return
end

m = max( i(:) );
n = size(i,2);

if nargin >= 2
    if m > d
        error( 'linstats:ind2logical:indexoutofbounds', 'index (%d) exceeds max dimension (%d)', m, d);
    end
else
    d = m;
end

b = false( d, n );
b( col2ind( i, d ) ) = true;
        
if nargout > 1 
    if isnumeric(i)
        [isort order] = sort(i);
    else
        order = 1:d;
    end
end;


if isvector(b)
    b = b(:);
end

