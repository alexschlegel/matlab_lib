function A = blkrepmat( type, c, q )
% BLKREPMAT replicate blks of matrices
% 
% A = blkrepmat( type, c, q )
% type is either 'J', 'I', '1' or 'C' (case insensitive)
% c is a scalar or r-vector of coefficients. if c is a scalar it is
% replicated to an r-vector
% q is a r-vector of block sizes: q(i) is the blk size of the ith block
% if q is a scalar and c is a vector, then the block sizes are uniform
% 
% A = blkrepmat( 'J', c, q )
%       returns blk diagnoal matrix of c(i)*ones(q(i),q(i))
%
% A = blkrepmat( 'I', c, q )
%       returns blk diagonal matrix of c(i)*eye(q(i));
%
% A = blkrepmat( '1', c, q )
%       returns block diagonal matrix of c(i)*ones(q(i),1) );
%
% A = blkrepmat( 'C', c, q )
%       returns column vector of  c(i)*one(q(i),1)


% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%
r = length(q);

if isscalar(c)
    c = repmat( c, r, 1);
end

if isscalar(q)
    r = length(c);
    q = repmat( q, r, 1 );
end

A = cell(r,1);

type = upper(type);

if type == 'J'
    for i = 1:r
        A{i} = repmat(c(i), q(i), q(i));
    end
elseif type == 'I'
    for i = 1:r
        A{i} = diag( repmat( c(i), q(i), 1) );
    end
elseif type == '1' || type == 'C'
    for i = 1:r
        A{i} = repmat( c(i), q(i), 1);
    end
else
    error('linstats:blkrepmat:InvalidArgument', 'type must be one of J,I,1 or C');
end

if type ~= 'C'
    A = blkdiag(A{:});
else
    A = cat(1, A{:} );
end;
