function s = array2structtree(x,s)
% array2structtree
% 
% Description:	convert an array to a struct tree
% 
% Syntax:	s = array2structtree(x,s)
% 
% In:
% 	x	- an array, probably constructed with structtree2array
%	s	- the struct tree from which x was constructed
% 
% Out:
% 	s	- the struct tree
% 
% Updated: 2014-02-09
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isstruct(s)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	if size(x,1)==1 && nField>1
		x	= x';
	end
	
	ndX		= numel(size(x));
	subX	= repmat({':'},[ndX-1 1]);
	
	for kF=1:nField
		s.(cField{kF})	= array2structtree(squeeze(x(kF,subX{:})),s.(cField{kF}));
	end
else
	s	= x;
end
