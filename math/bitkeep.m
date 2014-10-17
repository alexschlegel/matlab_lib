function x = bitkeep(x,kBit,varargin)
% bitkeep
% 
% Description:	keep the specified bits from numbers in array x
% 
% Syntax:	x = bitkeep(x,kBit,<options>)
% 
% In:
% 	x		- a numeric array
%	kBit	- the indices of the bit to keep (1==low bit)
%	<options>:
%		'compress':	(false) true to compress the remaining bits into the lowest
%					unoccupied bit positions
% 
% Out:
% 	x	- the transformed x
% 
% Updated: 2010-07-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'compress'	, false	  ...
		);

k	= sum(bitset(0,kBit));
x	= bitand(x,k);
	
if opt.compress
	nBit	= numel(kBit);
	
	y	= zeros(size(x),class(x));
	for kB=1:nBit
		y	= y + bitshift(bitget(x,kBit(kB)),kB-1);
	end
	x	= y;
end
