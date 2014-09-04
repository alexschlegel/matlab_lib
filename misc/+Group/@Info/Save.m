function bSuccess = Save(ifo,varargin)
% Group.Info.Save
% 
% Description:	save the info struct to file
% 
% Syntax:	bSuccess = ifo.Save([strPathInfo]=<auto>)
%
% In:
%	[strPathInfo]	- the path to the info struct file to save.  if unspecified,
%					  info.name must already have been set.
%
% Out:
%	bSuccess	- true if the info struct was successfully saved
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bSuccess	= ifo.parent.File.Write(ifo.Get({}),'info','overwrite',true,'variable','ifo');

if ~bSuccess
	warning(['Could not save info struct to "' ifo.File.Get('info') '".']);
end
