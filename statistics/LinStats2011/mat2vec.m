function varargout = mat2vec( A )
%MAT2VEC  splits a m x n matrix or cell array into an n-vectors
%
% data manipulation routine to separate columns of a matrix into vectors
%
%   [a1 a2 ... ai] = mat2vec( A )  returns columns of A in vectors
%   if there are more columns of a than output arguments then the 
%   last columns of A are not returned
%   A is an m x n matrix
%       a1 = A(:,1), a2 = A(:,2), ... ai = A(:,i)
%
%Example
%   load fertilizer
%   [x y] = mat2vec(Y);
%   plot( x, y, '+' );
%
%See also vec2mat, mat2cell

% Copyright 2011 Mike Boedigheimer
% Amgen Inc.
% Department of Computational Biology
% mboedigh@amgen.com
%

if nargout == 0
    return;
end

n = size(A,2);

i = nargout;
if i > n
    error( 'too many output arguments');
end

for j = 1:i
    if iscell(A)
        varargout(j) = A(:,j); %! ok
    else
        varargout{j} = A(:,j);          % supports tables
    end
end

% if n > i || i == 1;
%     j = i-1;
%     q = n - j;
%     c = cell( 1, q);
%     for i = 1:q
%         c{i} = A(:,i+j);
%     end;
%     varargout{nargout} = c;
%     % different approach, but I want both to work
%     %         varargout{nargout} = cat(2,A(:,(j+1):end));
% end



        


    


