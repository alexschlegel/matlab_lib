function g = rgbColorContrast(rgb,c1,c2)
% rgbColorContrast
% 
% Description:	creates an intensity map with c1->black, c2->white, and scaling
%				between the two based on distance of pixels from those colors
% 
% Syntax:	g = rgbColorContrast(rgb,c1,c2)
%
% In:
%	rgb	- an rgb image
%	c1	- the first color as a 3 element array
%	c2	- the second color
% 
% Out:
%	b	- a measure of the degree of similarity between color in rgb and the two
%		  contrast colors
%
% Notes:	I think this will only work for combinations of red/cyan,
%			green/magenta, blue/yellow, and black/white
% 
% Updated:	2010-04-19
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the distance between the contrast colors
	dC1C2	= dist(c1,c2);
%permute so the color plane is at the end
	nd	= ndims2(rgb);
	rgb	= permute(rgb,[1 2 4:nd 3]);
%get the distances
	dC1	= dist(rgb,c1);
	dC2	= dist(rgb,c2);
%get the contrast image
	g	= ((dC1 - dC2)./dC1C2 + 1)/2;
%make sure the third-dimension is for color
	g	= permute(g,[1 2 nd 3:nd-1]);
	