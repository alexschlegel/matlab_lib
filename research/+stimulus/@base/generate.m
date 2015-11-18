function [stim,ifo] = generate(obj,varargin)
% stimulus.base.generate
% 
% Description:	generate the stimulus
% 
% Syntax: [stim,ifo] = obj.generate([param1,val1,...,paramN,valN])
% 
% In:
%	[paramK]	- the Kth parameter whose value should be overridden
%	[valK]		- the new explicit value of parameter paramK
% 
% Out:
%	stim	- the stimulus
%	ifo		- a struct of extra info about the stimulus
% 
% Updated:	2015-09-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ifo	= struct;

%get the parameter values
	ifo.param	= obj.get_parameters(varargin{:});

%generate the stimulus
	[stim,ifo]	= obj.generate_inner(ifo);
