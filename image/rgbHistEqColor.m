function rgb = rgbHistEqColor(rgb)
% RGBHISTEQCOLOR
% 
% Description:	equalize the histogram on each color plane of an RGB image
% 
% Syntax:	rgb = rgbHistEqColor(rgb)
%
% In:
%	rgb	- an image loaded by rgbRead
% 
% Out:
%	rgb	- rgb after each color plane has undergone histogram equalization
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
for k=1:3
	rgb(:,:,k)	= histeq(rgb(:,:,k));
end
