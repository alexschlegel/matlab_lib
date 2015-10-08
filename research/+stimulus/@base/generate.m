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

%seed the random number generator
	rSeed	= obj.param.seed;
	
	rng2(rSeed);

%update the excluded values
	sExclude	= obj.param.exclude;
	
	assert(isstruct(sExclude),'exclude parameter must be a struct');
	
	cField	= fieldnames(sExclude);
	nField	= numel(cField);
	
	for kF=1:nField
		strParam	= cField{kF};
		
		obj.param.(strParam).exclude	= sExclude.(strParam);
	end

%get a set of parameter values
	ifo.param	= fill(obj.param,'values',varargin,'store',false);
	
	ifo.param.seed		= rSeed;
	ifo.param.exclude	= sExclude;

%validate the parameter values
	ifo.param	= obj.validate(ifo.param);

%generate the stimulus
	[stim,ifo]	= obj.generate_inner(ifo);
