function strDirSub = DirSub(strDir,kLeft,kRight)
% DirSub
% 
% Description:	extract a sub path from a directory path
% 
% Syntax:	strDirSub = DirSub(strDir,kLeft,kRight)
% 
% In:
% 	strDir	- a directory path
%	kLeft	- the index of the first directory of the sub path.  zero or negative
%			  values indicate a directory counting left from the end (e.g. -1
%			  means one directory to the left of the last)
%	kRight	- the last directory of the sub path.  zero or negative values
%			  indicate the same as for kLeft
% 
% Out:
% 	strDirSub	- the sub directory path
% 
% Updated: 2012-03-12
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cDir	= DirSplit(strDir);
nDir	= numel(cDir);

if kLeft<=0
	kLeft	= nDir+kLeft;
end

if kRight<=0
	kRight	= nDir+kRight;
end

strDirSub	= DirUnsplit(cDir(kLeft:kRight));
