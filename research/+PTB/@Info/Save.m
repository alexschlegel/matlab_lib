function bSuccess = Save(ifo)
% PTB.Info.Save
% 
% Description:	save the info struct to file.  the Info object must already have
%				been named using PTB.Info.SetName
% 
% Syntax:	bSuccess = ifo.Save
%
% Out:
%	bSuccess	- true if the info struct was successfully saved
% 
% Updated: 2011-12-15
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
global PTBIFO;

bSuccess	= ifo.parent.File.Write(PTBIFO,'session','overwrite',true,'variable','PTBIFO');

if ~bSuccess
	warning(['Could not save info struct to "' ifo.parent.File.Get('session') '".']);
end
