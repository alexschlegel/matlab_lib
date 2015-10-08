function param = validate(obj,param)
% stimulus.image.mentalrotation.chimp
% 
% Description:	validate a set of parameter values for mr chimp stimuli
% 
% Syntax: param = obj.validate(param)
% 
% In:
%	param	- a struct of parameter values
%
% Out:
%	param	- the validated parameter struct
% 
% Updated:	2015-10-06
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%validate superclass stuff
	param	= validate@stimulus.image.base(obj,param);

%get the figure number
	assert(isscalar(param.figure) && isint(param.figure) && param.figure>0 && param.figure<=obj.N_FIGURE,'figure must be an integer between 1 and %d',obj.N_FIGURE);

%parse the transformations
	param.txParsed	= split(param.tx,' ');
	param.txParsed	= cellfun(@(tx) regexp(tx,'(?<op>(R|F[HV]))(?<param>[-]?\d*\.?\d*)','names'),param.txParsed,'uni',false);
	
	assert(~any(cellfun(@isempty,param.txParsed)),'malformed transform string');
