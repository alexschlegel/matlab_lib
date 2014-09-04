function cstr  = strenum( basestr, k, delim )
%STRENUM appends sequence of numeric digits to a base string. 
% usage:
%   cstr  = strenum( basestr, k )
%   K can be a scalar in which case cstr is a vector in {basestr1,
%   basestr2, ... basestrk);
%   K can be a vector the same length as basestr in which case 
%   CSTR is a length(k) vector with the digits K applied
%   basestr can be a cellstr. 
%
% Notes. strenum is a generalization of make_key works with scalars and single element strings 
% by replicating them to the same length and then calling make_key

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
if nargin > 1
    n = size(basestr,1);
    if nargin < 2
        k = n;
    end
    if isscalar(k)
        if k ~= n && n ~= 1
            error( 'for scalar k, k must equal the length of basestr');
        end
        k = (1:k)';
    elseif length(k) ~= n && n ~= 1
         error( 'for vector k, lenght k must equal length basestr');
    end
    if n == 1
        basestr = repmat( basestr, length(k), 1 );
    end
end

if nargin < 3
    delim = '';
end

cstr = make_key( basestr, k, 'delim', delim);