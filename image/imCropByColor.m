function im = imCropByColor(im,c)
% imCropByColor
% 
% Description:	remove extra padding around an image
% 
% Syntax:	im = imCropByColor(im,c)
% 
% In:
% 	im	- an image
%	c	- the color that pads the region of interest (1x3 or scalar for
%		  grayscale)
% 
% Out:
% 	im	- the cropped image
% 
% Updated: 2011-11-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[h,w,p]	= size(im);

c	= repmat(reshape(c,1,1,[]),[h w 1]);
b	= all(im==c,3);

bH	= all(b,1);
bV	= all(b,2);

clear b c;

kHFirst	= find(~bH,1,'first');
kHLast	= find(~bH,1,'last');
kVFirst	= find(~bV,1,'first');
kVLast	= find(~bV,1,'last');

im	= im(kVFirst:kVLast,kHFirst:kHLast,:);
