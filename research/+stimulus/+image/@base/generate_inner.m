function [stim,ifo] = generate_inner(obj,ifo)
% stimulus.image.base.generate_inner
% 
% Description:	the method that actually generates the stimulus image. in most
%				cases, subclasses should not need to touch this, and should
%				override generate_mask instead. subclasses that do override this
%				method should be sure to include a 'mask' field in the info
%				struct.
% 
% Syntax: [stim,ifo] = obj.generate_inner(ifo)
% 
% In:
%	ifo	- a struct of info generated previously. includes the field 'param' that
%		  stores all the parameters the function needs to uniquely determine the
%		  stimulus.
% 
% Out:
%	stim	- the stimulus
%	ifo		- the updated info struct
% 
% Updated:	2015-09-30
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%generate the mask
	[mask,ifo]	= obj.generate_mask(ifo);
	ifo.mask	= mask;

%colorize
	[stim,ifo]		= obj.generate_image(ifo.mask,ifo);
