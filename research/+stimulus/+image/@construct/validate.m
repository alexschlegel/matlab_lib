function param = validate(obj,param)
% stimulus.image.construct.validate
% 
% Description:	validate a set of parameter values for construct stimuli
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

%check the parts
	assert(isnumeric(param.part),'part parameter must be an array of part indices');
	assert(all(isint(param.part)),'each part must be an integer');
	assert(all(param.part>0 & param.part<obj.N_PART),'invalid part index');
	
	nPart	= numel(param.part);
	assert(nPart==1 || nPart==4,'either 1 or 4 parts must be specified');
	
	param.part	= reshape(param.part,[],1);

%return style
	param.style	= CheckInput(param.style,'style',{'figure','parts'});

