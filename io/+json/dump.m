function dump(x, strPathJSON)
% json.dump
% 
% Description:	dump a MATLAB variable to a JSON file
% 
% Syntax:	json.dump(x, strPathJSON)
% 
% In:
% 	x			- a JSON-compatible MATLAB variable (see json.to)
%	strPathJSON	- the output path
% 
% Updated: 2014-02-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
fput(json.to(x),strPathJSON);
