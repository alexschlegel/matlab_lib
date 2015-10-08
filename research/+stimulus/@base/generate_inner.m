function [stim,ifo] = generate_inner(obj,ifo)
% stimulus.base.generate_inner
% 
% Description:	the method that actually generates the stimulus. this should be
%				overridden by each subclass.
% 
% Syntax: [stim,ifo] = obj.generate_inner(ifo)
% 
% In:
%	ifo	- a struct of info generated previously. includes the field 'param' that
%		  stores all the parameters the function needs to uniquely determine the
%		  stimulus
% 
% Out:
%	stim	- the stimulus
%	ifo		- the updated info struct
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
stim	= [];
