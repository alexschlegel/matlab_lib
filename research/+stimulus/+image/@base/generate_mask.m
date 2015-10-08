function [mask,ifo] = generate_mask(obj,ifo)
% stimulus.image.base.generate_mask
% 
% Description:	generate the stimulus mask. subclasses should override this.
% 
% Syntax: [mask,ifo] = obj.generate_mask(ifo)
% 
% In:
%	ifo	- the info struct
% 
% Out:
%	mask	- the binary mask image
%	ifo		- the updated info struct
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
mask	= false(ifo.param.size);
