function [kY1,kX1,kY2,kX2] = GetImageIntersection(s1,p1,s2,p2,varargin)
% GetImageIntersection
% 
% Description:	get the indices at which two images intersect
% 
% Syntax:	[kY1,kX1,kY2,kX2] = GetImageIntersection(s1,p1,s2,p2,[pType1]='tl',[pType2]=pType1)
% 
% In:
% 	s1			- the size of the first image
%	p1			- the position of the first image
%	s2			- the size of the second image
%	p2			- the position of the second image
%	[pType1]	- 'tl' if p1 refers to the top-left of the image, 'center' if it
%				  refers to the center point
%	[pType2]	- same for p2
% 
% Out:
% 	kY1	- the row indices at which the first image intersects the second
%	kX1	- the column indices at which the first image intersects the second
%	kY2	- "
%	kX2	- "
% 
% Updated:	2009-03-14
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[pType1,pType2]	= ParseArgs(varargin,'tl',[]);
if isempty(pType2)
	pType2	= pType1;
end

s1	= s1(1:2);
s2	= s2(1:2);

%get the top-left position of each image
	switch lower(pType1)
		case 'tl'
		case 'center'
			p1	= floor(p1 - (s1-1)/2);
		otherwise
			error(['"' pType1 '" is not a valid position type.']);
	end
	switch lower(pType2)
		case 'tl'
		case 'center'
			p2	= floor(p2 - (s2-1)/2);
		otherwise
			error(['"' pType2 '" is not a valid position type.']);
	end

%get the top-left positions relative to each other
	pTemp	= p1 - p2;
	p2		= p2 - p1;
	p1		= pTemp;
%get the top-left points of each in the other
	p1TLin2	= ceil(max(1,1-p1));
	p2TLin1	= ceil(max(1,1-p2));
	
	p1BRin2	= floor(min(s1,s2-p1));
	p2BRin1	= p2TLin1 + (p1BRin2 - p1TLin2);
	
	kY1	= p1TLin2(1):p1BRin2(1);
	kX1	= p1TLin2(2):p1BRin2(2);
	
	kY2	= p2TLin1(1):p2BRin1(1);
	kX2	= p2TLin1(2):p2BRin1(2);
	