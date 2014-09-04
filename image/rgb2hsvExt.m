function [im,h,s,v] = rgb2hsvExt(varargin)
% rgb2hsvExt
% 
% Description:	an extension to rgb2hsv.  Accepts rgb or r, g, and b components
%				separately as input, and returns hsv along with h, s, and v
%				components separately
% 
% Syntax:	[hsv,h,s,v] = rgb2hsvExt(rgb) OR
%			[hsv,h,s,v] = rgb2hsvExt(r,g,b)
%
% In:
%	rgb	- an m1 x ... x mN x 3 double
%	r	- the red "plane", or a single red value
%	g	- "
%	b	- "
% 
% Out:
% 	hsv	- the image in hsv space
% 	h	- the hue "plane"
% 	s	- "
% 	v	- "
%
% Updated:	2010-05-03
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%construct the image
	switch nargin
		case 1
			im	= varargin{1};
		case 3
			[r,g,b]	= FillSingletonArrays(varargin{1:3});
			im		= cat(ndims(r)+1,r,g,b);
		otherwise
			error('Invalid number of inputs.');
	end
%convert to hsv
	s	= size(im);
	im	= reshape(im,[],3);
	im	= rgb2hsv(im);
	im	= reshape(im,s);
%parse the output
	if nargout>1
		nd	= ndims(im);
		h	= extract(im,nd,1);
		s	= extract(im,nd,2);
		v	= extract(im,nd,3);
	end
