function [d, D] = mdummy(x, method, nlevels)
% MDUMMY enodes integer index (grouping) variables into a design matrix
%
% [d, D] = mdummy(x, method)
% X is a vector of integer grouping variables in 1:p, p is assumed to be max(x)  
% METHOD specifies an encoding method
%   for full rank methods p-1 variables are created
%   for overdetermiend p variables are created. 
%   method = 1:   0/-1/1 coding, full rank  (aka nominal)
%   method = 2:   0/1 coding, full rank     (aka ordinal)
%   method = 3:   0/1 coding, overdetermined, and stored with contraints
%   matrix
%   method = 4:   0/1 conding, full rank (aka reference cell). 
%                 level 1 is the reference and is effectively droped
%                 the p-1 variables correspond to the remaining levels
%  method = 5;    0/1 coding & random
%
% d is encoded design matrix
% D is the unique listing of the design matrix. Each row represents the
% encoding of the corresponding integer index
% 
% [d, D] = mdummy(x, method, p)
% X is a vector of integer grouping variables in 1:p.  
%
%
% Example:
%   load carbig
%   [gi, gn] = grp2ind(Cylinders);
%   [d, D]   = mdummy( gi );

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
% 
% Version 2.0. Added support for reference cell encoded for logistic
% regression


if (nargin < 2)
    method = 1;
end

if method <= 0      % continuous
    D = 1;
    d = x;
    if method <= -1
        mu = nanmean(d);
        d = d - mu;
        if method <= -2
            d = scale( d, range(d)/2 );
        end
    end
 return;
end

n = length(x);
if nargin < 3
    g = max(x);
else
    g = nlevels;
end;
ncols = g - double( (method ~= 3 & method ~=5) );

if ( g*ncols < 1000000 )
    if method == 1
        D = eye( [g ncols] );
        D(end,:) = -1;
    elseif method == 2
        D = tril(ones([g ncols]), -1);
    elseif method ==3 || method==5
        D = eye( [g ncols] );
    else
        D = [zeros(1,g-1);eye(g-1)];
    end
    
    d = D(x,:);

else
    if method == 1
        D = speye( [g ncols] );
        D(end,:) = -1;
%         error('linstats:mdummy:notSupported', 'sparse encoding using method 1 is not supported');
    elseif method == 2
        D = tril(spones([g ncols]), -1);
%         error('linstats:mdummy:notSupported', 'sparse encoding using method 2 is not supported');
    else
        d = sparse( 1:n, x, 1);
    end

end