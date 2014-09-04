function [im,bConverted] = im2uint8(im)
% im2uint8
% 
% Description:	convert an image to uint8
% 
% Syntax:	[im,bConverted] = im2uint8(im)
% 
% In:
% 	im	- the image
% 
% Out:
% 	im			- the converted image
%	bConverted	- true if the image was converted.  only converts if the image
%				  isn't already uint8
% 
% Assumptions:	assumes the image is either uint8 or double
% 
% Updated:	2011-12-07
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

bConverted	= true;
switch class(im)
	case 'double'
		if any(im(:)>1)
			im	= uint8(im);
		else
			im	= uint8(255*im);
		end
	case 'logical'
		im	= uint8(255*double(im));
	case 'uint8'
		bConverted	= false;
	otherwise
		error(['"' class(im) '" is not a supported image class.']);
end
