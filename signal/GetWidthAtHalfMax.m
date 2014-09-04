function [w,kLeft,kRight] = GetWidthAtHalfMax(x,kPeak)
% GetWidthAtHalfMax
% 
% Description:	calculate the width at half max of a peak in data
% 
% Syntax:	[w,kLeft,kRight] = GetWidthAtHalfMax(x,kPeak)
% 
% In:
% 	x		- the data
%	kPeak	- the index of the peak
% 
% Out:
% 	w		- the width at half-max of the peak at k in x, in index units
%	kLeft	- the index of the left minimum of the peak
%	kRight	- the index of the right minimum of the peak
% 
% Updated:	2008-04-23
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the sign of the slope
	s	= sign(x(2:end) - x(1:end-1));
%fill in the zero areas
	kZ		= find(s(2:end)==0)+1;
	sOld	= s;
	while numel(kZ)
		s(kZ)	= s(kZ-1);
		if isequal(sOld,s)
			break;
		else
			kZ		= find(s(2:end)==0)+1;
			sOld	= s;
		end
	end
	kZ		= find(s==0);
	while numel(kZ)
		s(kZ)	= s(kZ+1);
		kZ	= find(s==0);
	end
%get the minima
	kMin	= find([s(1) s(1:end-1)]<s);
%add the end points
	kMin	= [1 kMin numel(x)];

%get the last minimum before the peak
	kLeft	= max(kMin(kMin<kPeak));
%get the first minimum after the peak
	kRight	= min(kMin(kMin>kPeak));

	
%we'll call the peak base the average value of the two bounding minima
	xPeakBase	= (x(kLeft)+x(kRight))/2;
%find the values at which the peak reaches the half max
	xHalfMax	= (xPeakBase + x(kPeak))/2;
	[dummy,kHMLeft]		= min(abs(x(kLeft:kPeak)-xHalfMax));
	kHMLeft				= kHMLeft + kLeft - 1;
	[dummy,kHMRight]	= min(abs(x(kPeak:kRight)-xHalfMax));
	kHMRight			= kHMRight + kPeak - 1;
%width at half max
	kHMLeft
	kHMRight
	w	= kHMRight - kHMLeft;
	