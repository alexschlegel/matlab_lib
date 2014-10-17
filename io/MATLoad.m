function x = MATLoad(strPathMAT,strVar,varargin)
% MATLoad
% 
% Description:	load a variable from a .mat file
% 
% Syntax:	x = MATLoad(strPathMAT,strVar,<options>)
% 
% In:
%	strPathMAT	- the path to a .mat file
%	strVar		- the name of variable to load
%	<options>:
%		default:	([]) the default value to return if the variable doesn't
%					exist
%		error:		(false) true to raise an error if the variable doesn't
%					exist
%
% Out:
%	x	- the value of the variable strVar in the .mat file
% 
% Updated: 2014-10-01
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'default'	, []	, ...
		'error'		, false	  ...
		);

if MATVarExists(strPathMAT,strVar)
	s	= load(strPathMAT,strVar);
	x	= s.(strVar);
elseif ~opt.error
	x	= opt.default;
else
	error('The variable "%s" does not exist in %s.',strVar,strPathMAT);
end
