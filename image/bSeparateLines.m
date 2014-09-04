function b = bSeparateLines(b)
% bSeparateLines
% 
% Description:	makes sure no more than three white pixels exist within any
%				3x3 neighborhood.  this will separate lines in a skeletonized
%				line image
% 
% Syntax:	b = bSeparateLines(b)
%
% In:
%	b	- a skeletonized binary image representing straight lines
% 
% Out:
%	b	- b with line intersections removed
%
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
f	= ones(3);
n	= 9;

%get rid of the intersection points
	bIntersection		= b & imfilter(double(b),f,'symmetric')>3;
	b(bIntersection)	= 0;

%now get rid of pixels that still have a neighbor in another line
	%pixels in each intersection's surround
		bSurround		= ordfilt2(bIntersection,n,f,'symmetric');
	%label each line pixel in the intersection surround
		bInSurround				= b & bSurround;
		fX						= find(bInSurround);
		bInSurroundLabel		= zeros(size(b));
		bInSurroundLabel(fX)	= fX;
	%eliminate connections between line pixels in intersection surrounds
	%we will only delete pixels that;
	%	1) are line pixels
	%	2) are in an intersection surround
	%	3) have a line pixel neighbor also in the surround
	%	4) have the smaller of the two indices
	f2	= [1 1 1; 1 0 1; 1 1 1];
	n2	= 8;
	bHighestNeighbor	= bInSurroundLabel~=0 .* ordfilt2(bInSurroundLabel,n2,f2,'symmetric');
	while any(bHighestNeighbor~=0)
		bInSurroundLabel(bInSurroundLabel < bHighestNeighbor)	= 0;
		bHighestNeighbor										= bInSurroundLabel~=0 .* ordfilt2(bInSurroundLabel,n2,f2,'symmetric');
	end
	b(bInSurround & bInSurroundLabel==0)	= 0;

%now get rid of isolated points
	b(ordfilt2(b,n,f)==0)	= 0;
