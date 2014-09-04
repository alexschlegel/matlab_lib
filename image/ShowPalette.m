function [hF,im] = ShowPalette(pal,varargin)
% ShowPalette
% 
% Description:	display a palette
% 
% Syntax:	[hF,im] = ShowPalette(pal,[w]=500,[h]=500,[n]=1)
% 
% In:
% 	pal	- an Nx3 color palette
%	[w]	- the width of the display image
%	[h]	- the height of the display image
%	[n]	- repeat the palette n times
% 
% Out:
% 	hF	- the handle to the figure containing the displayed palette image
%	im	- an image of the palette
% 
% Updated:	2012-10-29
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[w,h,n]	= ParseArgs(varargin,500,500,1);

im	= imresize(pal,[h 3],'bicubic');
im	= reshape(im,[],1,3);
im	= repmat(im,[n w 1]);

hF	= figure;
imshow(im);
