function x = border(x,vBorder)
% border
% 
% Description:	surround an array with a border
% 
% Syntax:	x = border(x,vBorder)
% 
% In:
% 	x		- an array
%	vBorder	- the border value
% 
% Out:
% 	x	- the array with a border added
% 
% Updated: 2012-07-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
s	= size(x);
nd	= numel(s);

for kD=1:nd
	kOrder		= [kD 1:kD-1 kD+1:nd];
	kUnOrder	= [2:kD 1 kD+1:nd];
	x			= permute(x,kOrder);
	xBorder		= vBorder*ones([1 s(kOrder(2:end))]);
	x			= [xBorder; x; xBorder];
	x			= permute(x,kUnOrder);
	s			= size(x);
end
