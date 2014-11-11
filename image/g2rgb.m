function rgb = g2rgb(g,varargin)
% g2rgb
% 
% Description:	convert a grayscale image to an rgb image
% 
% Syntax:	rgb = g2rgb(g,<options>)
% 
% In:
% 	g	- the grayscale image
%	<options>:
%		c:		([1 1 1]) a color to use for the hue and saturation of the
%				converted image
%		pal:	([]) a palette to use as a map
% 
% Out:
% 	rgb	- the rgb image
% 
% Updated: 2010-05-03
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'c'		, [1 1 1]	, ...
		'pal'	, []		  ...
		);

g	= im2double(g);

s	= size(g);
nd	= numel(s);

if isempty(opt.pal)
	[hsvC,hC,sC]	= rgb2hsvExt(opt.c);
	[h,s,g]			= FillSingletonArrays(hC,sC,g);
	rgb				= hsv2rgbExt(h,s,g);
else
	nPal	= size(opt.pal,1);
	x		= GetInterval(0,1,nPal);
	rgb		= reshape(interp1nd(x,opt.pal,g(:)),[size(g) 3]);
end
