function rgb = rgbResize(rgb,maxHeight,maxWidth)
% RGBRESIZE
% 
% Description:	resizes an image so that it is no longer than a given bounding box
% 
% Syntax:	rgb = rgbResize(rgb,[maxHeight],[maxWidth])
%
% In:
%	rgb			- an rgb image
%	[maxHeight]	- optional, the maximum height of the output image
%	[maxWidth]	- optional, the maximum width of the output image
% 
% Out:
%	rgb	- the resized image
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s	= size(rgb);

if exist('maxHeight','var') && ~isempty(maxHeight) && s(1)>maxHeight
	s(2)	= s(2) * maxHeight / s(1);
	s(1)	= maxHeight;
end

if exist('maxWidth','var') && ~isempty(maxWidth) && s(2)>maxWidth
	s(1)	= s(1) * maxWidth / s(2);
	s(2)	= maxWidth;
end

if ~isequal(size(rgb),s)
	s	= round(s);
	rgb	= imresize(rgb,s(1:2));
end
