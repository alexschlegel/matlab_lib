function [M,sOld] = padArrayExt(M,varargin)
% PADARRAYEXT
% 
% Description:	an extension to the padarray function.
%				adds a 'zeros' option and linear extrapolation (for 2D
%				matrices only).
% 
% Syntax:	[M,sOld] = padArrayExt(M,[sP]=[1 1],[pMethod]='zeros')
%
% In:
%	M			- the matrix to pad
%	[sP]		- the size of the padding.  may be scalar or two-element
%	[pMethod]	- the padding method.  may be one of the methods specified
%				  by padarray, or 'zeros' or 'linear'
% 
% Out:
%	M		- the padded matrix
%	sOld	- a cell of the indices in each dimension of the unpadded matrix.
%			  retrieve the original matrix using M(sOld{:})
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[sP,pMethod]	= ParseArgs(varargin,[1 1],'zeros');
nd				= ndims(M);
sP				= FixSize(sP,nd);
s				= size(M);

switch pMethod
	case 'zeros'
		M	= padarray(M,sP);
	case 'linear'
		if numel(sP)~=2
			error('''linear'' method is for 2D matrices only.');
		end
		M	= padExtrap(M,sP);
	otherwise %assume it's a valid padarray method
		M	= padarray(M,sP,pMethod);
end

sOld	= cell(1,nd);
for k=1:nd
	sOld{k}	= (1:s(k)) + sP(k);
end
