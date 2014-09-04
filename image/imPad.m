function imp = imPad(im,c,h,w)
% imPad
% 
% Description:	pad an image with a color
% 
% Syntax:	imp = imPad(im,c,h,w)
% 
% In:
% 	im	- an image
%	c	- a color, either 1x3 or scalar for grayscale images
%	h	- the new height of the image
%	w	- the new width of the image
% 
% Out:
% 	imp	- the padded image
% 
% Updated: 2011-11-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
imp	= cast(repmat(reshape(c,1,1,[]),[h w 1]),class(im));
imp	= InsertImage(imp,im,[0 0],'center','center');
