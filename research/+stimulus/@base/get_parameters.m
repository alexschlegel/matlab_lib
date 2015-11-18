function param = get_parameters(obj,varargin)
% stimulus.base.get_parameters
% 
% Description:	get the stimulus parameters
% 
% Syntax: param = obj.get_parameters([param1,val1,...,paramN,valN])
% 
% In:
%	[paramK]	- the Kth parameter whose value should be overridden
%	[valK]		- the new explicit value of parameter paramK
% 
% Out:
%	param	- a struct of parameter values
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

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
	param	= fill(obj.param,'values',varargin,'store',false);
	
	param.seed		= rSeed;
	param.exclude	= sExclude;

%validate the parameter values
	param	= obj.validate(param);
