function [x,p] = depoly(x,n)
% depoly
% 
% Description:	remove a best-fit polynomial from a vector
% 
% Syntax:	[x,p] = depoly(x,n)
% 
% In:
% 	x	- a vector
%	n	- the degree of polynomial to remove
% 
% Out:
% 	x	- the depolyed vector
%	p	- the coefficients of the polynomial that was removed
% 
% Updated: 2012-11-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%make Nx1
	s	= size(x);
	x	= reshape(x,[],1);

%fit the polynomial
	bGood	= ~isnan(x);
	k		= (1:numel(x))';
	p		= polyfit(k(bGood),x(bGood),n);

%remove it
	x(bGood)	= x(bGood) - polyval(p,k(bGood));

%reshape
	x	= reshape(x,s);
