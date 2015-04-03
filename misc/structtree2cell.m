function x = structtree2cell(s)
% structtree2cell
% 
% Description:	convert a structtree to a cell array
% 
% Syntax:	x = structtree2cell(s)
% 
% In:
% 	s	- a struct tree with homogeneous levels
% 
% Out:
% 	x	- the cell version of s
% 
% Updated: 2014-03-02
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if isstruct(s)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	sCell	= struct2cell(s);
	xCell	= cellfun(@structtree2cell,sCell,'uni',false);
	xCell	= cellfun(@(x) permute(x,[ndims2(x)+1 1:ndims2(x)]),xCell,'uni',false);
	x		= cat(1,xCell{:});
else
	x	= {s};
end
