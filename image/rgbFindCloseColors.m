function [c,k] = rgbFindCloseColors(rgb,c,thresh)
% FINDCLOSECOLORS
% 
% Description:	find the closest colors in an image to a given color
% 
% Syntax:	[c,k] = rgbFindCloseColors(rgb,c,[thresh]=0)
%
% In:
%	rgb			- an rgb image or an Nx3 list of colors
%	c			- a three element array specifying a color
%	[thresh]	- find the thresh% of closest values.  if thresh=0 finds the closest value
% 
% Out:
%	c	- an Nx3 array of the closest colors to c
%	k	- the indices of the nearest pixels
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
bThresh	= exist('thresh','var') && ~isempty(thresh) && thresh~=0;

%make rgb a list of colors if it isn't already
	if ndims(rgb)~=2
		rgb	= reshape(rgb,[],3);
	end

%find the distance between each point and the color
	d2	= dist2(rgb,c);

%find the distance at the cutoff point
	if bThresh
		dCutoff	= prctile(d2,thresh);
	else
		dCutoff	= min(d2);
	end

%find the pixels within the cutoff
	k	= find(d2 <= dCutoff);
	
%find the color values of the cutoff pixels
	c	= rgb(k,:);
