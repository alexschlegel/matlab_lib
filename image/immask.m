function im = immask(im,b)
% immask
% 
% Description:	mask in image
% 
% Syntax:	im = immask(im,b)
% 
% In:
% 	im	- the image
%	b	- a binary mask with the same (h,w) dimensions
% 
% Out:
% 	im	- the masked image
% 
% Updated: 2012-01-11
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[h,w,p]	= size(im);
b		= repmat(b,[1 1 p]);
im		= im.*b;
