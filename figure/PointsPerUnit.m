function [pW,pH] = PointsPerUnit(h)
% UnitsPerPoint
% 
% Description:	get the number of points per unit in the specified figure
%				element handle
% 
% Syntax:	[pW,pH] = PointsPerUnit(h)
% 
% Updated: 2011-03-17
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
switch(get(h,'type'))
	case 'axes'
		pUW	= range(get(h,'XLim'));
		pUH	= range(get(h,'YLim'));
	otherwise
		pU	= get(h,'Position');
		pUW	= pU(3);
		pUH	= pU(4);
end

uOld	= get(h,'Units');
set(h,'Units','points');
pP		= get(h,'Position');
set(h,'Units',uOld);

pW	= pP(3)/pUW;
pH	= pP(4)/pUH;
