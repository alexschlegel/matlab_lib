function x = bit2int(bit,varargin)
% bit2int
% 
% Description:	convert bits to an array of unsigned integers
% 
% Syntax:	x = bit2int(bit,[type]='uint32')
% 
% In:
% 	bit		- an M1 x ... x MN x nBit array of 0s and 1s (nBit must be <=32)
%	[type]	- the output datatype
% 
% Out:
% 	x	- an M1 x ... x MN of the integers represented by bit 
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
typeOut	= ParseArgs(varargin,'uint32');

s		= size(bit);
nBit	= s(end);
s		= s(1:end-1);
nDim	= numel(s);

nShift	= repmat(reshape(0:nBit-1,[ones(1,nDim) nBit]),[s 1]);
x		= sum(cast(bitshift(cast(bit,typeOut),nShift),typeOut),nDim+1);
