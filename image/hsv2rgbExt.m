function [im,r,g,b] = hsv2rgbExt(varargin)
% hsv2rgbExt
% 
% Description:	an extension to hsv2rgb.  Accepts hsv or h, s, and v components
%				separately as input, and returns rgb along with r, g, and b
%				components separately
% 
% Syntax:	[rgb,r,g,b] = hsv2rgbExt(hsv) OR
%			[rgb,r,g,b] = hsv2rgbExt(h,s,v)
% 
% In:
%	hsv	- an m1 x ... x mN x 3 double
%	h	- the hue "plane", or a single hue value
%	s	- "
%	v	- "
% 
% Out:
% 	rgb	- the image in rgb space
% 	r	- the red "plane"
% 	g	- "
% 	b	- "
% 
% Updated:	2010-05-03
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%construct the image
	switch nargin
		case 1
			im	= varargin{1};
		case 3
			[h,s,v]	= FillSingletonArrays(varargin{1:3});
			im		= cat(ndims(h)+1,h,s,v);
		otherwise
			error('Invalid number of inputs.');
	end
%convert to rgb
	s	= size(im);
	im	= reshape(im,[],3);
	im	= hsv2rgb(im);
	im	= reshape(im,s);
%parse the output
	if nargout>1
		nd	= ndims(im);
		r	= extract(im,nd,1);
		g	= extract(im,nd,2);
		b	= extract(im,nd,3);
	end
