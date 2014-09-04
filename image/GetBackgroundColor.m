function col = GetBackgroundColor(im)
% GetBackgroundColor
% 
% Description:	determine the background color of an image
% 
% Syntax:	col = GetBackgroundColor(im)
% 
% In:
% 	im	- the image
% 
% Out:
% 	col	- an estimate of the background color
% 
% Updated: 2014-02-05
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[h,w,p]	= size(im);

%get the mean border color
	bBorder	= imborder([h,w],'c',true,'b',false);
	col		= cast(immean(im,bBorder),class(im));
