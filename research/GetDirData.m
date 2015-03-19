function strDir = GetDirData(strDirData,strDataType,varargin)
% GetDirData
% 
% Description:	get the directory of a particular data tye
% 
% Syntax:	strDir = GetDirData(strDirData,strDataType,<options>)
% 
% In:
% 	strDirData	- the root data directory
%	strDataType	- the type of data (e.g. 'functional')
%	<options>:
%		session_code:	([]) the session code of the subject. if this is
%						omitted, the base data type directory path is returned.
%		session:		([]) for longitudinal data, the session number 
% 
% Out:
% 	strDir	- the path to the directory that contains the specified data
% 
% Updated: 2015-03-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'session_code'	, []	, ...
		'session'		, []	  ...
		);

cDir	= {strDataType};

if ~isempty(opt.session)
	cDir{end+1}	= num2str(opt.session);
end

if ~isempty(opt.session_code)
	cDir{end+1}	= opt.session_code;
end

strDir	= DirAppend(strDirData,cDir{:});
