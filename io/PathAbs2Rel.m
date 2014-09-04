function strPathRel = PathAbs2Rel(strPath,strDirBase)
% PathAbs2Rel
% 
% Description:	convert an absolute path to a relative one
% 
% Syntax:	strPathRel = PathAbs2Rel(strPath,strDirBase)
% 
% In:
% 	strPath		- the absolute path
% 	strDirBase	- the base directory (absolute or relative to the current
%				  directory)
% 
% Out:
% 	strPathRel	- strPath as a relative path from strDirBase
% 
% Updated:	2010-03-25
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strSlash	= GetSlashType;

%windows is case-insensitive
	if ispc
		strPath		= lower(strPath);
		strDirBase	= lower(strDirBase);
	end
%check some stuff
	if isempty(strPath) || isempty(strDirBase)
		strPathRel	= '';
		return;
	end
	if IsPathRelative(strDirBase)
		strDirBase	= PathRel2Abs(strDirBase,pwd);
	end

%get the common portion of the path
	%last common part of the string
		nMin		= min(numel(strPath),numel(strDirBase));
		kEndCommon	= find(strPath(1:nMin)~=strDirBase(1:nMin),1,'first')-1;
		if isempty(kEndCommon)
			kEndCommon	= nMin;
		end
	%last common directory
		kEndCommon	= find(strPath(1:kEndCommon)==strSlash,1,'last');
	%is there anything in common?
		if isempty(kEndCommon)
			strPathRel	= strPath;
			return;
		end
	strDirCommon	= strPath(1:kEndCommon);
	
%get the relative path from the base to the common base
	cDirBase	= DirSplit(strDirBase);
	nDirBase	= numel(cDirBase);
	cDirCommon	= DirSplit(strDirCommon);
	nDirCommon	= numel(cDirCommon);
	strDir2Common	= repmat(['..' strSlash],[1 nDirBase-nDirCommon]);

strPathRel	= [strDir2Common strPath(kEndCommon+1:end)];
