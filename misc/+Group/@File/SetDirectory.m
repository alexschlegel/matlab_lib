function SetDirectory(f,strName,strDir,varargin)
% Group.File.SetDirectory
% 
% Description:	set the path to a named directory
% 
% Syntax:	f.SetDirectory(strName,strDir,...)
% 
% In:
% 	strName	- the directory name (e.g. 'base'), must be field name compatible
%	strDir	- the path to the directory
%	...: (see Group.Info.Set)
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
f.Info.Set({'directory',strName},strDir,varargin{:});
