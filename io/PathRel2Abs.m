function strPathAbs = PathRel2Abs(strPath,varargin)
% PathRel2Abs
% 
% Description:	convert a relative path to an absolute one
% 
% Syntax:	strPathAbs = PathRel2Abs(strPath,[strDirBase]=pwd)
% 
% In:
% 	strPath			- the relative path
% 	[strDirBase]	- the base directory (absolute or relative to the current
%					  directory)
% 
% Out:
% 	strPathAbs	- strPath as an absolute path
% 
% Updated:	2011-11-12
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strDirBase	= ParseArgs(varargin,pwd);

strSlash	= GetSlashType;


%change ~ to the home directory
	if isunix
		re		= '^[/]?~';
		strPath	= regexprep(strPath,re,getenv('HOME'));
	end

%change to absolute
	if IsPathRelative(strDirBase)
		strDirBase	= PathRel2Abs(strDirBase,pwd);
	end
	
	if IsPathRelative(strPath)
		strPathAbs	= [AddSlash(strDirBase,false) strPath];
	else
		strPathAbs	= strPath;
	end

%clean it up
	strSlashSafe	= StringForRegExp(strSlash);
	%get rid of .
		re			= {['^' strSlashSafe '\.([^\.])'] ['(' strSlashSafe ')\.' strSlashSafe] ['(.)' strSlashSafe '\.$']};
		strPathOld	= '';
		while ~isequal(strPathAbs,strPathOld)
			strPathOld	= strPathAbs;
			strPathAbs	= regexprep(strPathAbs,re,'$1');
		end
	%get rid of ..
		re	= ['(([^\.' strSlashSafe '][^' strSlashSafe ']*)|(\.[^\.' strSlashSafe '][^' strSlashSafe '*))' StringForRegExp([strSlash '..' strSlash])];
		
		strPathOld	= '';
		while ~isequal(strPathAbs,strPathOld)
			strPathOld	= strPathAbs;
			strPathAbs	= regexprep(strPathAbs,re,'');
		end
