function [im,ifo] = generate_image(obj,mask,ifo)
% stimulus.image.base.generate_image
% 
% Description:	generate the final image stimulus, given a mask
% 
% Syntax: [im,ifo] = obj.generate_image(mask,ifo)
% 
% In:
%	mask	- a binary mask image
%	ifo		- the info struct
% 
% Out:
%	im	- the final image stimulus
%	ifo	- the updated info struct
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
map	=	[
			ifo.param.background
			ifo.param.foreground
		];

im	= ind2im(double(mask)+1,map);
