function [X U S V r] = svdinv(A,varargin)
%PINV   Pseudoinverse using SVD. Matlab has this function (pinv), but it
%doesn't return intermediate results that are expensive to calculate.
%   X = SVDINV(A) produces a matrix X of the same dimensions
%   as A' so that A*X*A = A, X*A*X = X and A*X and X*A
%   are Hermitian. The computation is based on SVD(A,0) and any
%   singular values less than a tolerance are treated as zero.
%   The default tolerance is LENGTH(A) * NORM(A) * EPS(class(A)).
%
%   SVDINV(A,TOL) uses the tolerance TOL instead of the default.
%
%   [X U S V r] = SVDINV(...) also returns U S V and rank from SVD(A,0)
%
%   PINV( U, S, V ), with 3 arguments uses precomputed svd results to
%   calculate inverse
%
%   PINV( U, S, V, TOL ) uses precomputed svd results at given TOL

%
%
%   Class support for input A:
%      float: double, single
%
%   See also RANK.
%
% Modified by MJB to return the useful and compute intensive S V D

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/12/06 16:35:27 $

    % Copyright 2011 Mike Boedigheimer
    % Amgen Inc.
    % Department of Computational Biology
    % mboedigh@amgen.com
    %

if isempty(A)     % quick return
    X = zeros(size(A'),class(A));
    return
end

if nargin > 2
    U = A;
    [S V] = varargin{1:2};
    s = diag(S);
    if nargin == 2
        tol = varargin{3};
    else
        tol = max(length(U), length(V)) * eps(max(s));
    end
else
    [U S V] = svd(A,'econ');    
    s = diag(S);    
    if nargin == 2
        tol = varargin{1};
    else
        tol = length(A) * eps(max(s));
    end
end


r = sum(s > tol);
if (r == 0)
    X = zeros(size(A'),class(A));
else
    s = diag(ones(r,1)./s(1:r));
    X = V(:,1:r)*s*U(:,1:r)';
end


