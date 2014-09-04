function x = load(strPathJSON)
% json.load
% 
% Description:	load a JSON-encoded file into a variable
% 
% Syntax:	x = json.load(strPathJSON)
% 
% In:
% 	strPathJSON	- the path to the JSON-encoded file
% 
% Out:
% 	x	- the MATLAB variable form of the file
% 
% Updated: 2014-02-14
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= json.from(fget(strPathJSON));
