function g = hsvColorContrast(hsv,cType)
% hsvColorContrast
% 
% Description:	creates an intensity image showing differences between
%				for color opposites.
% 
% Syntax:	g = hsvColorContrast(hsv,cType)
%
% In:
%	hsv		- an image in hsv space
%	cType	- the type of contrast, either 'rc' (red-cyan), 'gm'
%			  (green-magenta), or 'by' (blue-yellow)
% 
% Out:
%	g	- the contrast image
%
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
switch lower(cType)
	case 'rc',	c1	= 0;
	case 'gm',	c1	= 1/3;
	case 'by',	c1	= 2/3;
	otherwise,	error('Invalid contrast type');
end

h	= hsv(:,:,1);
s	= hsv(:,:,2);
v	= hsv(:,:,3);
clear hsv

%shift the map so c1 is at 0
h		= h - c1;
hInd	= h < 0;
h(hInd)	= h(hInd) + 1;

%find the distance from the hue to c1
hInd	= h > 1/2;
h(hInd)	= 1 - h(hInd);

%scale to between -1/4 and 1/4
	g	= h - 0.25;
%make values approach 0 as s and v approach 0
	g	= s .* v .* g;
%scale to between 0 and 1
	g	= 2.*(g+0.25);
	