function [M,yOld,xOld] = padExtrap(M,n)
% PADEXTRAP
% 
% Description:	pad a 2D matrix, performing linear extrapolation to find
%				the padded values
% 
% Syntax:	[M,yOld,xOld] = padExtrap(M,n)
%
% In:
%	M	- a 2D matrix
%	n	- the size of the padding.  either scalar or two-elements
% 
% Out:
%	M		- M padded by n elements, with new element values extrapolated linearly
%	yOld	- the row range of the old matrix (use for eliminating the padding)
%	xOld	- the column range of the old matrix
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
n	= FixSize(n,2);

s		= size(M);
sPad	= s + 2*n;

%the padded matrix
	mPad		= padarray(ones(s),n);
	kExt		= mPad==0;
	mPad(~kExt)	= M;

%the interpolation elements in the original matrix
	[yI1,xI1,kI1]	= perimeterK(sPad,n);
	[yI2,xI2,kI2]	= perimeterK(sPad,n+1);
	nI1				= numel(yI1);
	nI2				= numel(yI2);
	
%find the offsets of the pad elements from the center of the padded matrix
	[yExt,xExt]	= ind2sub(sPad,find(kExt)');
	nExt		= numel(yExt);
	[yExt,xExt]	= ShiftByCenter(sPad,yExt,xExt);
	
%find offsets for the interpolation elements
	[yI1,xI1]	= ShiftByCenter(sPad,yI1,xI1);
	[yI2,xI2]	= ShiftByCenter(sPad,yI2,xI2);

%find the angle of the vectors formed from the elements to the center of the padded matrix
	aExt	= atan2(yExt,xExt);
	aI1		= atan2(yI1,xI1);
	aI2		= atan2(yI2,xI2);

%for each int1 element, find the int2 element with closest angle
	kA				= FindClosestAngle(aI1,aI2);
	[yI2,xI2,kI2]	= reCast(kA,yI2,xI2,kI2);

%find the slope of each interpolation point
	dInt	= dist([yI1' xI1'],[yI2' xI2'])';
	dVInt	= mPad(kI1) - mPad(kI2);
	slp		= dVInt ./ dInt;

%for each pad element, find the int element with closest angle
	kA					= FindClosestAngle(aExt,aI1);
	[yI1,xI1,slp,kI1]	= reCast(kA,yI1,xI1,slp,kI1);
	
%find the distance between each pad element and its corresponding interpolation element
	dInt	= dist([yI1' xI1'],[yExt' xExt'])';

%the new values of the extrapolation points are vInt + dInt*s
	mPad(kExt)	= mPad(kI1) + dInt .* slp;

	M			= mPad;
	yOld		= (1:s(1))+n(1);
	xOld		= (1:s(2))+n(2);
	