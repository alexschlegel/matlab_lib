function [mask,ifo] = generate_mask(obj,ifo)
% stimulus.image.scribble.generate_mask
% 
% Description:	generate the scribble mask
% 
% Syntax: [mask,ifo] = obj.generate_mask(ifo)
% 
% In:
%	ifo	- the info struct
% 
% Out:
%	mask	- the binary scribble image
%	ifo		- the updated info struct
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

p	= [reshape(ifo.param.y,1,[]); reshape(ifo.param.x,1,[])];
v	= spcrv(p,3);
vIm	= MapValue(v',min(v(:)),max(v(:)),ifo.param.pen_size_px,ifo.param.size-ifo.param.pen_size_px);

mask	= contour2im(vIm(:,1),vIm(:,2),...
			'size'	, ifo.param.size	, ...
			'pen'	, ifo.param.pen		  ...
			);
