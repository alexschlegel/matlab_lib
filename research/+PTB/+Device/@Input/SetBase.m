function SetBase(inp,b)
% PTB.Device.Input.SetBase
% 
% Description:	set the base state of the device.  anything in the base state
%				will never be counted as activated.
% 
% Syntax:	inp.SetBase(b)
% 
% In:
%	b	- a logical array the same size as the return from
%		  PTB.Device.Input.State indicating the base state
%
% Updated: 2011-12-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
inp.parent.Info.Set('input',{inp.type,'basestate'},b);
