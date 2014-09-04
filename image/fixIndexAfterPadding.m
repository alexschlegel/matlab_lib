function k = fixIndexAfterPadding(k,sOrig,sPad)
% FIXINDEXAFTERPADDING
% 
% Description:	fixes indices that refer to elements of a matrix before
%				it was padded
% 
% Syntax:	k = fixIndexAfterPadding(k,sOrig,sPad)
%
% In:
%	k		- an array of indices that refer to elements in a pre-padded
%			  array
%	sOrig	- the size of the original array
%	sPad	- a scalar specifying uniform padding radius, or an array
%			  specifying the size of padding in each direction (so direction
%			  k should be 2*sPad(k) longer after padding)
% 
% Out:
%	k	- the new indices
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
nd		= numel(sOrig);
sPad	= FixSize(sPad,nd);

kK		= cell(1,nd);
[kK{:}]	= ind2sub(sOrig,k);

for k=1:nd
	kK{k}	= kK{k} + sPad(k);
end

k	= sub2ind(sOrig + 2*sPad,kK{:});
