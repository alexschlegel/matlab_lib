function b = IsSubDir(strDir1,strDir2)
% IsSubDir
% 
% Description:	determine if one directory is a subdirectory of another
% 
% Syntax:	b = IsSubDir(strDir1,strDir2)
% 
% In:
% 	strDir1	- a directory path or cell of paths that might be subdirectories
%	strDir2	- a directory path or cell of paths of which the directories in
%			  strDir1 might be subdirectories
% 
% Out:
% 	b	- an array indicating which of the directories in strDir1 are
%		  subdirectories of directories in strDir2
% 
% Updated:	2009-07-16
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%make each input a cell
	[strDir1,strDir2]	= ForceCell(strDir1,strDir2);
	nDir1				= numel(strDir1);
	nDir2				= numel(strDir2);
%add a slash to each directory
	strDir1	= cellfun(@AddSlash,strDir1,'UniformOutput',false);
	strDir2	= cellfun(@AddSlash,strDir2,'UniformOutput',false);
%get the directory paths one level up from strDir1
	for k1=1:nDir1
		cDir		= DirSplit(strDir1{k1});
		strDir1{k1}	= DirUnsplit(cDir(1:end-1));
	end
%get the length of each directory string
	nLength1	= cellfun(@numel,strDir1);
	nLength2	= cellfun(@numel,strDir2);
%Windows doesn't care about case
	if ispc
		strDir1	= cellfun(@lower,strDir1,'UniformOutput',false);
		strDir2	= cellfun(@lower,strDir2,'UniformOutput',false);
	end
%check to see if directories from strDir2 are contained in strDir1
	b	= false(nDir1,1);
	for k1=1:nDir1
		for k2=1:nDir2
			if nLength1(k1)>=nLength2(k2) && isequal(strDir1{k1}(1:nLength2(k2)),strDir2{k2})
				b(k1)	= true;
				break;
			end
		end
	end