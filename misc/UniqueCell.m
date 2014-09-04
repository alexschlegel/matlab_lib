function [cU,kTo,kFrom] = UniqueCell(c)
% UniqueCell
% 
% Description:	unique for cells
% 
% Syntax:	[cU,i,j] = UniqueCell(c)
% 
% Updated: 2010-08-27
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= numel(c);

cU			= {};
kTo			= [];
bCounted	= false(n,1);
kFrom		= zeros(size(c));

for k=1:n
	if ~bCounted(k)
		cU		= [cU; c{k}];
		kTo		= [kTo; k];
		
		kDupe	= FindCell(c,c{k});
		
		kFrom(kDupe)	= numel(kTo);
		bCounted(kDupe)	= true;
	end
end
