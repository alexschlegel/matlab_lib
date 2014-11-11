function cVar = MATVariables(strPathMAT)
% MATVariables
% 
% Description:	get a cell of variables in a .mat file
% 
% Syntax:	cVar = MATVariables(strPathMAT)
% 
% Updated: 2014-10-01
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if IsMATFile(strPathMAT)
	sVar	= whos('-file',strPathMAT);
	cVar	= reshape({sVar.name},[],1);
else
	cVar	= {};
end
