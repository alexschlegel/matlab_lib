function b = Open(f,strName,varargin)
% Group.File.Open
% 
% Description:	open a text file for fast writing
% 
% Syntax:	b = f.Open(strName,<options>)
% 
% In:
% 	strName	- the name of the file (previously assigned using f.Set)
%	<options>:
%		overwrite:	(false) true to overwrite existing data
% 
% Out:
%	b	- true if the file was successfully opened
% 
% Updated: 2011-12-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'overwrite'	, false	  ...
		);

b	= false;

strPath	= f.Get(strName);

if opt.overwrite || ~f.Exists(strName)
	delete(strPath);
end

if FileExists(strPath)
	fid	= fopen(strPath,'a');
else
	fid	= fopen(strPath,'w');
end

if fid~=-1
	b	= true;
	f.Info.Set({'fid',strName},fid);
end
