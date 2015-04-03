function bit = int2bit(x,varargin)
% int2bit
% 
% Description:	convert an array of unsigned integers to bits
% 
% Syntax:	bit = int2bit(x,[bitMax]=<determine>)
% 
% In:
% 	x			- an M1 x ... x MN array of unsigned integers
%	[bitMax]	- the highest bit in the return array (0-based)
% 
% Out:
% 	bit	- an array of the bits of elements of x along its first singleton
%		  dimension 
% 
% Updated: 2015-03-19
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bitMax	= ParseArgs(varargin,[]);

if isempty(bitMax)
	bitMax	= floor(log2(max(double(x(:)))));
end

bScalar	= isscalar(x);

%get the first singleton dimension
	sz			= [size(x) 1];
	nd			= numel(sz);
	kSingleton	= find(sz==1,1,'first');
%permute to make that dimension first
	kPermute	= [kSingleton 1:kSingleton-1 kSingleton+1:nd];
	x			= permute(x,kPermute);
	sz			= sz(kPermute);
%get the comparison bits
	bitCompare	= reshape(bitshift(ones(1,1,class(x)),0:bitMax),[],1);
	bitCompare	= repmat(bitCompare,sz);
%compare the bits
	x	= repmat(x,[bitMax+1 ones(1,nd-1)]);
	
	bit	= bitand(x,bitCompare)~=0;
%unpermute
	bit	= permute(bit,[2:kSingleton 1 kSingleton+1:nd]);

if bScalar
	bit	= reshape(bit,1,[]);
end
