function Load(ifo)
% PTB.Info.Load
% 
% Description:	load the info struct from file.  the Info object must already
%				have been named using PTB.Info.SetName
% 
% Syntax:	ifo.Load
% 
% Updated: 2011-12-11
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

PTBIFO	= ifo.parent.File.Read('session');

if isempty(PTBIFO)
	error(['Info struct could not be loaded from "' ifo.parent.File.Get('session') '".']);
end
