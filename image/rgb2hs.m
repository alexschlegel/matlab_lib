function [h,s] = rgb2hs(rgb)
% RGB2HS
% 
% Description:	converts an rgb image to its hue and saturation images.
% 
% Syntax:	[h,s] = rgb2hs(rgb)
%
% In:
%	rgb	- an rgb image
% 
% Out:
%	h	- the hue component of the image
%	s	- the saturation component of the image
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
hsv	= rgb2hsv(rgb);
h	= hsv(:,:,1);
s	= hsv(:,:,2);
