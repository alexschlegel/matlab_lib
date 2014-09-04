function eq = mat_compare( x, y, tol )
% MAT_COMPARE returns true if two matrices are equivlant to specified
% tolerance
%
% nans may be present if they are present in both x and y
% in the same elements. If present they are treated as zeros

if ndims(x) ~= ndims(y) || any( size(x) ~= size(y) )
    eq = false;
    return
end

k = isnan(x);
% make sure the nans are identical
if ~isequal(k, isnan(y))
    eq = false;
    return;
end

%treat nan as zero
if any(k(:))
    x(k) = 0;
    y(k) = 0;
end

% craete default tolerance after replacing nans
if nargin < 3
    % how tol was derived. 
    % x = ones(m,n);
    % y = x + eps;
    % norm(x-y) == eps*sqrt(numel(x)); I use the maximum value in X because
    % it is conservative in the sense that norm(x-y) < eps(max(x(:)))*sqrt(numel(x))
    % for heterogenous X
    tol = eps(max(x(:)))*sqrt(numel(x));
end


eq = norm( x-y ) < tol ;
