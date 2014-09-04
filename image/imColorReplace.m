function im = imColorReplace(im,colFrom,colTo)
% IMCOLORREPLACE
%
% Description:	replaces one color in an rgb image with another
%
% Syntax:	im = imColorReplace(im,colFrom,colTo)
%
% In:
%	im		- an image
%	colFrom - a three element array specifying the color to replace
%	colTo	- a three element array specifying the replacement color
%
% Out:
%	im	- the image with the color replaced
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s	= size(im);

toReplace	= im(:,:,1)==colFrom(1) & im(:,:,2)==colFrom(2) & im(:,:,3)==colFrom(3);

for k=1:3
	imP				= im(:,:,k);
	imP(toReplace)	= colTo(k);
	im(:,:,k)		= imP;
end
