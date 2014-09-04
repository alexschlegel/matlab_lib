function b = region2b(r,s)
% region2b
% 
% Description:	converts a regionprops struct back to the binary image from
%				whence it came
% 
% Syntax:	b = region2bw(r,s)
%
% In:
%	r	- a region props struct including PixelIdxList
%	s	- the size of the original binary image
% 
% Out:
%	b	- the binary image
%
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= logical(zeros(s));

b(cat(1,r.PixelIdxList))	= 1;
