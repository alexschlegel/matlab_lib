function rgb = hsl2rgb(hsl)
% rgb2hsl
% 
% Description:	convert hsl (0->1) values to rgb values
% 
% Syntax:	rgb = hsl2rgb(hsl)
% 
% In:
% 	hsl	- an M1 x ... x Mn x 3 array of hsl values
% 
% Out:
% 	rgb - an M1 x ... x Mn x 3 array of rgb values
% 
% Updated:	2010-12-09
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the colors along columns
	sz	= size(hsl);
	hsl	= reshape(hsl,[],3);
	n	= size(hsl,1);
	kN	= reshape(1:n,n,1);
%make sure we have 0->1 data
	[hsl,bConverted]	= im2double(hsl);

%calculate chroma and 2nd largest component
	c	= (1-abs(2.*hsl(:,3)-1)).*hsl(:,2);
	
	h	= 6*hsl(:,1);
	x	= c.*(1-abs(mod(h,2)-1));
%get rgb with the same hue and chroma
	%initialize rgb
		rgb	= zeros(n,3);
	
	%fill x
		kX			= floor(mod(5-h,3)+1);
		kRGB		= sub2ind([n 3],kN,kX);
		rgb(kRGB)	= x;
	%fill c
		kC					= mod(floor((h+1)/2),3)+1;
		bBad				= kC==kX;
		kC(bBad)			= mod(kC(bBad)-2,3)+1;
		kRGB				= sub2ind([n 3],kN,kC);
		rgb(kRGB)			= c;
%add the brightness term
	m	= hsl(:,3) - c/2;
	rgb	= rgb + repmat(m,[1 3]);

%make sure we're within the 0->1 bounds
	rgb	= max(0,min(1,rgb));

%unreshape
	rgb	= reshape(rgb,sz);
%convert back to uint8
	if bConverted
		rgb	= im2uint8(rgb);
	end
	