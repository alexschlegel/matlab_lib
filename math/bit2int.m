function x = bit2int(bit)
% bit2int
% 
% Description:	convert bits to an array of unsigned integers
% 
% Syntax:	x = bit2int(bit)
% 
% In:
% 	bit			- an M1 x ... x MN x nBit array of 0s and 1s (nBit must be <=32)
% 
% Out:
% 	x	- an M1 x ... x MN of the integers represented by bit 
% 
% Updated: 2011-09-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s		= size(bit);
nBit	= s(end);
s		= s(1:end-1);
nDim	= numel(s);

nShift	= repmat(reshape(0:nBit-1,[ones(1,nDim) nBit]),[s 1]);
x		= sum(uint32(bitshift(uint32(bit),nShift)),nDim+1);
