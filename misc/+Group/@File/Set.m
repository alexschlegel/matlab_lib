function Set(f,strName,strDir,strFile,varargin)
% Group.File.Set
% 
% Description:	set the path to a named file
% 
% Syntax:	f.Set(strName,strDir,strFile,...)
% 
% In:
% 	strName	- the name of the file (e.g. 'log'), must be field name compatible
%	strDir	- a named directory or the path to a directory in which the file
%			  should be stored
%	strFile	- the actual path to the file name (e.g. '81oct11as.log')
%	...: (see Group.Info.Set)
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
f.Info.Set({'file','directory',strName},strDir,varargin{:});
f.Info.Set({'file','file',strName},strFile,varargin{:});
