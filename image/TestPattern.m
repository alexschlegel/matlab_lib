function im = TestPattern(h,w,pal,varargin)
% TestPattern
% 
% Description:	construct a test pattern showing relationships between each
%				color in a palette
% 
% Syntax:	im = TestPattern(h,w,pal,[rStep]=1:n)
% 
% In:
% 	h		- the height of the test pattern image
%	w		- the width of the test pattern image
%	pal		- an Nx3 RGB palette array
%	[rStep]	- the color progression through radius steps
% 
% Out:
% 	im	- the test pattern
% 
% Updated:	2009-04-01
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%number of colors in the palette
	n	= size(pal,1);
	
%radius step function
	rStep	= ParseArgs(varargin,1:n);
	
%construct the polar coordinate matrices for the image
	%get the indices for each wedge
		nWedge	= n;
		
		%angles from -pi to pi
			kWedge	= Coordinates([h w],'angle');
		%convert to 0 to 2pi
			kWedge	= mod(kWedge,2*pi);
		%convert to 1 to n
			kWedge	= mod(ceil(nWedge*kWedge/(2*pi)),nWedge)+1;
			
	%get the indices for each ring
		nRing	= numel(rStep);
		
		%radius from 0 to 1
			kRing	= Coordinates([h w],'radius');
			kRing	= kRing/max(kRing(:));
		%convert to 1 to n
			kRing	= round((nRing-1)*kRing+1);
	
%get the color index for each coordinate
	rStep(rStep==0)	= NaN;
	
	kC		= zeros(nRing,nWedge);
	kOff	= cumsum(1:nWedge);
	for kW=1:nWedge;
		%kC(:,kW)	= mod(rStep+kW,n)+1;
		kC(:,kW)	= mod(rStep+kOff(kW),n)+1;
	end
	
%construct the indexed image
	k	= sub2ind(size(kC),kRing,kWedge);
	im	= kC(k);
		
%now convert to rgb
	im	= ind2rgb(im,[pal; 0 0 0]);
	