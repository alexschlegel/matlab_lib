function eqn = coeff2eqn( coeffs, var_names, skipzeros, parens )
%COEFF2EQN text representation of a set of equations
%       coeffs is an an m x n matrix of parameters
%       var_names is a n x 1 cell array of strings
%       skipzeros is scalar resolving to a boolean indicating whether terms
%       with a 0 coefficient should be excluded
%       parens is a flag to use a 'parens' rather than '*' for
%       multiplication
% Example
% load carbig Acceleration, Cylinders;
%m = Model( Acceleration, int32(Cylinders));
% e   =coeff2eqn(double(m.stats.beta)', m.W.cnames',0,1)

% See also model2eqn, tests2eqn


% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

if ( nargin < 2 )
    error('linstats:coeff2eqn:InvalidArgument', 'usage: s = coeff2eqn( model, coeff_names )' );
end;

[m, n] = size(coeffs);
[p, q] = size(var_names);

if (p ~= n)
    error('linstats:coeff2eqn:InvalidArgument', 'inner matrix dimensions must agress');
end

if q ~= 1
    error('linstats:coeff2eqn:InvalidArgument',  'var_names must be a vector' );
end;

if nargin < 3 || isempty(skipzeros)
    skipzeros = true;
end

if nargin < 4 || isempty(parens)
    parens = 1;
end

fmt = '%.3f';
eqn = cell(m,1);
tmp_eqn = cell(m,n);

for i = 1:m
    beta = coeffs(i,:);
    beta(abs(beta)<10*eps) = 0;
    first = 1;    
    for j = 1:n
        v = beta(j);
        if ( skipzeros ~= 0 && v == 0 )
            continue;
        end;
        if v < 0
            if ~first
                delim = ' - ';
            else
                delim = '-';
            end;
            v = -v;
        elseif ~first
            delim = ' + ';
        else
            delim = '';
        end;

        if abs(v-round(v)) < 10*eps
            if abs(v - 1) < 10*eps 
                dfmt = '%s';
                v = '';
            else
                dfmt = '%d';
            end
        else
            dfmt = fmt;
        end

        if ~isempty(var_names{j}) && ~isempty(v)
            if parens
                sfmt = '(%s)';
            else
                sfmt = '*%s';
            end
        else
            sfmt = '%s';
        end

        tmp_eqn{i,j} = sprintf( ['%s'  dfmt sfmt], delim, v, var_names{j} );
        first = 0;
    end
    eqn{i} = cat(2,tmp_eqn{i,:});
end;