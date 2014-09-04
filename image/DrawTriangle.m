function im = DrawTriangle(s1,s2,s3,varargin)
% DrawTriangle
% 
% Description:	draw a triangle, given the length of its three sides
% 
% Syntax:	im = DrawTriangle(s1,s2,s3,<options>)
% 
% In:
% 	sK	- the length of the Kth side
%	<options>
%		(see DrawPolygonFromPoints)
% 
% Out:
% 	im	- an image of the triangle
% 
% Updated:	2009-02-07
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strErrBase	= 'drawtriangle:';

%make sure the side lengths work
	sS	= sort([s1 s2 s3]);
	if sS(3)>=sS(1)+sS(2);
		error([strErrBase 'invalidsidelength'],'Each side length must be less than the sum of the other two.');
	end

%initialize the coordinate array
	p	= zeros(3,2);

%s1 will be horizontal along the x-axis
	p(2,2)	= s1;
	
%find the left angle (law of cosines)
	cosTheta	= (s1^2+s2^2-s3^2)/(2*s1*s2);
	sinTheta	= sqrt(1-cosTheta^2);
	
%get the third coordinate
	p(3,1)	= s2*sinTheta;
	p(3,2)	= s2*cosTheta;
	
%draw the triangle
	im	= DrawPolygonFromPoints(p,varargin{:});
