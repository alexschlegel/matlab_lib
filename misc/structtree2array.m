function x = structtree2array(s)
% structtree2array
% 
% Description:	convert a structtree to a numerical array
% 
% Syntax:	x = structtree2array(s)
% 
% In:
% 	s	- a struct tree containing only numerical arrays
% 
% Out:
% 	x	- the array version of s
% 
% Updated: 2014-05-07
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

if isstruct(s)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	sCell	= struct2cell(s);
	xCell	= cellfun(@structtree2array,sCell,'uni',false);
	
	szX		= cellfun(@size,xCell,'uni',false);
	szX		= max(cat(1,szX{:}),[],1);
	cSzX	= num2cell(szX);
	ndX		= numel(szX);
	subX	= repmat({':'},[1 ndX]);
	
	x		= NaN([nField szX]);
	
	for kF=1:nField
		xCur	= xCell{kF};
		szXCur	= size(xCur);
		if any(szXCur < szX)
			b			= true(szXCur);
			b(cSzX{:})	= false;
			
			xOld	= xCur;
			xCur	= NaN(szX);
			xCur(b)	= xOld;
		end
		
		x(kF,subX{:})	= xCur;
	end
elseif isnumeric(s)
	x	= s;
else
	error('Only struct trees of numerical arrays are supported.');
end
