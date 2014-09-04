function Load(ifo,varargin)
% Group.Info.Load
% 
% Description:	load the info struct from file
% 
% Syntax:	ifo.Load([strPathInfo]=<auto>)
%
% In:
%	[strPathInfo]	- the path to the info struct file to load.  if unspecified,
%					  info.name must already have been set.
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
ifo.Set({},unless(ifo.parent.File.Read('info'),struct));
