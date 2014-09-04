function [im,bConverted] = im2double(im)
% im2uint8
% 
% Description:	convert an image to double
% 
% Syntax:	[im,bConverted] = im2double(im)
% 
% In:
% 	im	- the image
% 
% Out:
% 	im			- the converted image
%	bConverted	- true if the image was converted.  only converts if the image
%				  isn't already double or if it was double but contained values
%				  greater than one
% 
% Updated:	2010-08-05
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bConverted	= true;

switch class(im)
	case 'double'
		if any(im(:)>255)
			[im,bConverted]	= im2double(uint16(im));
		elseif any(im(:)>1)
			[im,bConverted]	= im2double(uint8(im));
		else
			bConverted	= false;
		end
	case 'logical'
		im	= double(im);
	case 'uint16'
		im	= double(im);
		
		bLess	= im<=32768;
		
		im(bLess)	= im(bLess)/65536;
		im(~bLess)	= im(~bLess)/65535;
	otherwise
		im	= double(im);
		
		bLess	= im<=128;
		
		im(bLess)	= im(bLess)/256;
		im(~bLess)	= im(~bLess)/255;
end
