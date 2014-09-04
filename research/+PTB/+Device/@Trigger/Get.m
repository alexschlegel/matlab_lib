function vTrigger = Get(tr,strName)
% PTB.Trigger.Get
% 
% Description:	get the value of a named trigger code
% 
% Syntax:	vTrigger = tr.Get(strName)
% 
% In:
%       strName	- the name of the trigger code
%
% Out:
%       vTrigger - the trigger bits ([] if strName has not been set)
%
% Updated: 2012-03-28
% Copyright 2012 Scottie Alexander (scottiealexander11@gmail.com).  This 
% work is licensed under a Creative Commons Attribution-NonCommercial-
% ShareAlike 3.0 Unported License.
global PTBIFO

try
    vTrigger = PTBIFO.(tr.type).code.(strName);
catch
    vTrigger = [];
end
