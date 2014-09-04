function D = dctmtx2(m,varargin)
% dctmtx2
% 
% Description:	like dctmtx, but also handles M x N discrete cosine transform
%				matrix
% 
% Syntax:	D = dctmtx2(m,[n]=m) OR
%			D = dctmtx2(kM,[kN]=kM)
%
%	m,n		- the number of rows and columns in the dct matrix
%	kM,kN	- the indices to use for the dct matrix
% 
% Updated: 2012-09-23
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
n	= ParseArgs(varargin,m);

if numel(m)==1 & numel(n)==1
	[c,r]	= meshgrid(0:n-1,0:m-1);
else
	[c,r]	= meshgrid(n,m);
	
	n	= numel(n);
end

D		= sqrt(2/n)*cos(pi*(2*c+1).*r/(2*n));
D(r==0)	= D(r==0)/sqrt(2);
