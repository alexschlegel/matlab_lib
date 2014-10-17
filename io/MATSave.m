function MATSave(strPathMAT,strVar,x)
% MATSave
% 
% Description:	save a variable to a .mat file
% 
% Syntax:	MATSave(strPathMAT,strVar,x)
% 
% In:
%	strPathMAT	- the path to a .mat file
%	strVar		- the name of variable to save
%	x			- the value to save to the variable
%
% Updated: 2014-10-01
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
eval(sprintf('%s=x;',strVar));

if IsMATFile(strPathMAT)
	save(strPathMAT,strVar,'-append');
else
	save(strPathMAT,strVar);
end
