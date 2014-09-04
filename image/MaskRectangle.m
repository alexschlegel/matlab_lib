function b = MaskRectangle(w,varargin)
% MaskRectangle
% 
% Description:	create a binary rectangle mask
% 
% Syntax:	b = MaskRectangle(w,[h]=w)
% 
% In:
% 	w			- the width of the rectangle
%	[h]			- the height of the rectangle
% 
% Out:
% 	b	- a binary mask set to true inside the rectangle mask
% 
% Updated:	2009-03-15
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[h]	= ParseArgs(varargin,w);

b	= true(h,w);
	