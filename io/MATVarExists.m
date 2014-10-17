function b = MATVarExists(strPathMAT,strVar)
% MATVarExists
% 
% Description:	check whether a variable exists in a .mat file
% 
% Syntax:	b = MATVarExists(strPathMAT,strVar)
% 
% Updated: 2014-10-01
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
b	= ismember(strVar,MATVariables(strPathMAT));
