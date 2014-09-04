function col = p_GetColorFunction(drw,col,strProp)
% p_GetColorFunction
% 
% Description:	get the function associated with a color
% 
% Syntax:	f = p_GetColorFunction(drw,col,strProp)
% 
% In:
%	drw		- the PTB.Draw object
% 	col		- the color
%	strProp	- the property name in case an error occurs
% 
% Out:
%	f	- the function associated with col
% 
% Updated: 2012-11-27
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if ~isa(col,'function_handle')
	if ischar(col)
		col	= drw.parent.Color.Get(col);
	end
	
	if isnumeric(col)
		nCol	= numel(col);
		
		col	= reshape(im2uint8(col),1,[]);
		
		switch nCol
			case 3
				col	= [col 255];
			case 4
			otherwise
				error(['Invalid ' strProp '.']);
		end
		
		col	= @(tFlip,tStart) col;
	else
		error(['Invalid ' strProp '.']);
	end
end
