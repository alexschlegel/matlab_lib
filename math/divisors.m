function d = divisors(n)
% divisors
% 
% Description:	determine the divisors of an integer
% 
% Syntax:	d = divisors(n)
% 
% Updated: 2014-10-19
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%factors of n
	f		= factor(n);
	nFactor	= numel(f);

%all combinations of the factors
	combo	= arrayfun(@(k) nchoosek(f,k),(1:nFactor)','uni',false);

%product of each combo
	d	= cellfun(@(cmb) prod(cmb,2),combo,'uni',false);
	d	= cat(1,d{:});

%unique products
	d	= unique(d);
