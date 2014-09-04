function n = decget(x,k)
% decget
% 
% Description:	get the specified digit of a decimal number
% 
% Syntax:	n = decget(x,k)
% 
% In:
% 	x	- an array of numbers
%	k	- get the digit at the 10^k digit
% 
% Out:
% 	n	- the digit
% 
% Updated: 2012-03-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%move the digit to the ones place
	x	= fix(x./10.^k);
%extract the ones digit
	n	= mod(x,10);
