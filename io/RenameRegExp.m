function [cPathAfter,cPathBefore] = RenameRegExp(strDir,reFrom,reTo,varargin)
% RenameRegExp
% 
% Description:	rename a set of files using regular expressions
% 
% Syntax:	[cPathAfter,cPathBefore] = RenameRegExp(strDir,reFrom,reTo,<options>)
% 
% In:
% 	strDir	- a directory path or cell of directory paths
%	reFrom	- the regular expression to match in pre-extension file names in the
%			  search path, or a cell of such to match sequentially
%	reTo	- a string specifying the replacement, or a cell of such.  Use
%			  syntax from regexprep
%	<options>
%		'casei':	(false) true to perform case-insensitive matches
%		'ext':		(<all>) a cell of strings specifying the extensions of files
%					to rename
%		'extcasei':	(true) true to perform case-insensitive matches on file
%					extensions
%		'subdir':	(false)	true to rename in subdirectories as well
%		'confirm':	(true) true to display confirmation dialog boxes
% 
% Out:
% 	cPathAfter	- a cell of paths to files after renaming
%	cPathBefore	- a cell of paths to files before renaming
% 
% Updated:	2010-09-13
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin	, ...
		'casei'		, false	, ...
		'ext'		, []	, ...
		'extcasei'	, true	, ...
		'subdir'	, false	, ...
		'confirm'	, true	  ...
		);
		
%get the files to search
	cPathSearch	= FindFilesByExtension(strDir,opt.ext,'subdir',opt.subdir,'casei',opt.extcasei);
	nSearch		= numel(cPathSearch);
	
%check each file
	if opt.confirm
		progress(nSearch,'label','Searching file name');
	end
	
	if opt.casei
		cOption	= {'ignorecase'};
	else
		cOption	= {};
	end
	
	bRename		= false(nSearch,1);
	cFilePreTo	= cell(nSearch,1);
	for k=1:nSearch
		%get the pre-extension file name
			[dummy,strFilePre]	= PathSplit(cPathSearch{k});
			
		%do we have a match?
			strFilePreTo	= regexprep(strFilePre,reFrom,reTo,cOption{:});
			if ~isequal(strFilePre,strFilePreTo)
				bRename(k)		= true;
				cFilePreTo{k}	= strFilePreTo;
			end
			
		%progress
			if opt.confirm
				progress;
			end
	end
	
%prepare the replacement info
	[cPathBefore,cPathAfter]	= deal(cPathSearch(bRename));
	cFilePreTo	= cFilePreTo(bRename);
	
	nReplace	= numel(cPathBefore);

%do we have anything to do
	if nReplace==0 
		if opt.confirm
			if opt.confirm
				progress('end');
			end
			
			msgbox('No files to replace');
		end
		return;
	end

%prompt to continue
	if opt.confirm
		%get an example
			[dummy,strFilePre,strExt]	= PathSplit(cPathBefore{1});
			strFileBefore				= PathUnsplit([],strFilePre,strExt);
			strFileAfter				= PathUnsplit([],cFilePreTo{1},strExt);
			
		%prompt
			strPrompt	=	plural(nReplace,sprintf('%d file{,s} to replace. Example below:\n\nFrom: %s\nTo: %s\n\nContinue?',nReplace,strFileBefore,strFileAfter));
			
			if askyesno(strPrompt,'title',mfilename,'default',false)
				return;
			end
	end

%replace!
	if opt.confirm
		progress(nReplace,'label','Renaming file');
	end
	
	for k=1:nReplace
		[strDir,dummy,strExt]	= PathSplit(cPathBefore{k});
		cPathAfter{k}			= PathUnsplit(strDir,cFilePreTo{k},strExt);
		
		if ~movefile(cPathBefore{k},cPathAfter{k},'f')
			status(['Could not move ' cPathBefore{k} ' to ' cPathAfter{k}]);
			
			cPathAfter{k}	= cPathBefore{k};
		end
		
		if opt.confirm
			progress;
		end
	end
	