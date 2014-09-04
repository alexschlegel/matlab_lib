function shp = p_GetShapeFunction(drw,shp,strProp)
% p_GetShapeFunction
% 
% Description:	get a function associated with the specified shape
% 
% Syntax:	f = p_GetShapeFunction(drw,shp,strProp)
% 
% In:
%	drw		- the PTB.Draw object
% 	shp		- the shape
%	strProp	- the property name in case an error occurs
% 
% Out:
%	f	- the function associated with shp
% 
% Updated: 2012-11-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~isa(shp,'function_handle')
	if isnumeric(shp) || islogical(shp)
		if isscalar(shp)
			shp		= round(shp);
			c		= 2*((0:shp-1) - (shp-1)/2)/shp;
			[x,y]	= meshgrid(c,c);
			shp		= x.^2 + y.^2 <= 1;
		else
			shp	= logical(shp);
		end
		
		shp	= @(tFlip,tStart) shp;
	else
		error(['Invalid ' strProp '.']);
	end
end
