function m = bls(n)
% bls
% 
% Description:	create a balanced latin square of size n (n must be even but i
%				don't understand why)
% 
% Syntax:	m = bls(n)
% 
% Updated: 2012-02-06
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
k	= 1:n;

m		= repmat(k',[1 n]);
offset	= round((k-1)/2).*(-1).^(k);
mo		= repmat(offset,[n 1]);
m		= mod(m + mo - 1,n)+1;
