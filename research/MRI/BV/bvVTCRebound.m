function bvVTCRebound(vtc,xyzBound)
% bvVTCRebound
% 
% Description:	recast the bounds of a VTC object
% 
% Syntax:	bvVTCRebound(vtc,xyzBound)
% 
% In:
% 	vtc			- a VTC object created with BVQXfile
%	xyzBound	- the new bounds of the VTC space, in BV system coordinates, as:
%					[xStart yStart zStart;
%					 xEnd   yEnd   zEnd]
% 
% Updated:	2009-08-17
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.

%get new bounds in the old VTC space
	%get the actual xyzBounds (because of rounding, not all xyz positions are
	%valid)
		kBound		= bvCoordConvert('vmr','vtc',xyzBound,'vtc',vtc);
		xyzBound	= bvCoordConvert('vtc','vmr',kBound,'vtc',vtc);
	%the <XYZ>End elements of the VTC object seem to refer to one index element
	%past the end of the data.  so the actual kBound end should be one less than
	%what the xyzBound end is
		kBound(2,:)	= kBound(2,:) - 1;
%set the new bounds in internal space
	vtc.XStart	= xyzBound(1,2);
	vtc.XEnd	= xyzBound(2,2);
	vtc.YStart	= xyzBound(1,3);
	vtc.YEnd	= xyzBound(2,3);
	vtc.ZStart	= xyzBound(1,1);
	vtc.ZEnd	= xyzBound(2,1);
	
%get a copy of the data
	vtcData	= vtc.VTCData;
	szOld	= size(vtcData);
%initialize the new data array
	szNew		= kBound(2,:) - kBound(1,:)+1;
	vtc.VTCData	= zeros([szOld(1) szNew],'single');
%copy the data back
	%kBound
	%size(vtcData)
	%size(vtc.VTCData)
	
	xOS	= max(1,kBound(1,1));
	xOE	= min(szOld(2),kBound(2,1));
	yOS	= max(1,kBound(1,2));
	yOE	= min(szOld(3),kBound(2,2));
	zOS	= max(1,kBound(1,3));
	zOE	= min(szOld(4),kBound(2,3));
	
	xNS	= max(1,-kBound(1,1)+2);
	xNE	= xNS + xOE - xOS;
	yNS	= max(1,-kBound(1,2)+2);
	yNE	= yNS + yOE - yOS;
	zNS	= max(1,-kBound(1,3)+2);
	zNE	= zNS + zOE - zOS;
	
	%[xOS,xOE,yOS,yOE,zOS,zOE]
	%[xNS,xNE,yNS,yNE,zNS,zNE]
	vtc.VTCData(:,xNS:xNE,yNS:yNE,zNS:zNE)	= vtcData(:,xOS:xOE,yOS:yOE,zOS:zOE);