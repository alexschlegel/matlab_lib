function g = rgb2g(rgb,varargin)
% rgb2g
% 
% Description:	convert an RGB image to a grayscale image
% 
% Syntax:	g = rgb2g(rgb,<options>)
%
% In:
%	rgb	- an image loaded by rgbRead
%	<options>:
%		fast:		(false) true to use a faster method
%		colorplane:	([]) if specified, convert to grayscale by keeping the
%					specified plane:
%						r/g/b:	red, green ,or blue plane
%						h/s/v:	hue, saturation, value plane
%						l:		luminance plane
% 
% Out:
%	g	- a double grayscale image with values between 0 and 1
%
% Updated:	2010-04-19
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'fast'			, false	, ...
		'colorplane'	, []	  ...
		);

if size(rgb,3)==1
	g	= rgb;
	return;
end

if ~isempty(opt.colorplane)
	switch lower(opt.colorplane)
		case 'r'
			k	= 1;
		case 'g'
			k	= 2;
		case 'b'
			k	= 3;
		case 'h'
			rgb	= rgb2hsv(rgb);
			k	= 1;
		case 's'
			rgb	= rgb2hsv(rgb);
			k	= 2;
		case 'v'
			rgb	= rgb2hsv(rgb);
			k	= 3;
		case 'l'
			rgb	= rgb2hsl(rgb);
			k	= 3;
		otherwise
			error(['"' opt.colorplane '" is not a valid color plane.']);
	end
	
	g	= extract(rgb,3,k,'squeeze',false);
else
	if opt.fast
		g	= rgb2g(rgb,'colorplane','g');
	else
		g	= rgbColorContrast(rgb,[0 0 0],[1 1 1]);
	end
end
