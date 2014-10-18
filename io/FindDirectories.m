function [cDir,nDirTotal] = FindDirectories(strDir,varargin)
% FindDirectories
% 
% Description:	find subdirectories within a directory path that match a regular
%				expression
% 
% Syntax:	cDir = FindDirectories(strDir,[re]='.*',<options>)
%
% In:
%	strDir		- a directory or cell of directories
%	[re]		- a regular expression pattern for subdirectories to match
%	<options>:
%		subdir:		(false) true to also search for subdirectories of
%					subdirectories, etc.
%		maxdepth:	(<none>) the maximum search depth
%		casei:		(false) true to use case-insensitive matches
%		negate:		(false) true to return subdirectories that don't match re
%		usequick:	(false) true to use DirQuick (faster for directories with
%					lots of files, slower for directories with few files)
%		progress:	(false) true to show a progress bar
% 
% Out:
%	cDir		- a cell of the matching subdirectory paths in strDir.
%	nDirTotal	- the total number of directories searched
% 
% Updated:	2014-10-18
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[re,opt]	= ParseArgs(varargin, '.*', ...
				'subdir'		, false	, ...
				'maxdepth'		, -1	, ...
				'casei'			, false	, ...
				'negate'		, false	, ...
				'usequick'		, false	, ...
				'progress'		, false	, ...
				'first'			, true	, ...
				'name_progress'	, []	, ...
				'dirtotal'		, 0		  ...
				);

%get the regexp function to use
	refunc	= conditional(opt.casei,...
				conditional(opt.negate,@priv_REIN,@priv_REIP)	, ...
				conditional(opt.negate,@priv_RECN,@priv_REIP)	  ...
				);

%fix the search directories
	cDirSearch		= reshape(ForceCell(strDir),[],1);
	nDirSearch		= numel(cDirSearch);
	opt.dirtotal	= opt.dirtotal+nDirSearch;
	
	%add trailing slashes
		for kDir=1:nDirSearch
			cDirSearch{kDir}	= AddSlash(cDirSearch{kDir});
		end

%search each directory
	cDir	= {};
	
	if opt.first && opt.progress
		strNameProgress	= progress(nDirSearch,'label','Finding Directories');
	else
		strNameProgress	= opt.name_progress;
	end
	
	for kDirS=1:nDirSearch
		%get the names of the subdirectories of the current directory
			if opt.usequick
				cDirCur	= DirQuick(cDirSearch{kDirS},'getfiles',false,'getdirs',true,'fullpath',false);
			else
				d		= dir(cDirSearch{kDirS});
				cDirCur	= reshape({d.name},[],1);
				cDirCur	= cDirCur([d.isdir]);
				cDirCur	= reshape(setdiff(cDirCur,{'.','..'}),[],1);
			end
			nDirCur	= numel(cDirCur);
			
		%filter out the ones that don't match the regexp
			bKeep	= false(nDirCur,1);
			for kDirC=1:nDirCur
				bKeep(kDirC)	= refunc(cDirCur{kDirC},re);
			end
		
		%add the matching directory paths
			cDirKeep	= cellfun(@(x) AddSlash([cDirSearch{kDirS} x]),cDirCur(bKeep),'UniformOutput',false);
			cDir		= [cDir; cDirKeep];
		
		%optionally search subdirectories
			if opt.subdir && opt.maxdepth~=0
				for kDirC=1:nDirCur
					strDirCur	= [cDirSearch{kDirS} cDirCur{kDirC}];
					
					cOpt				= opt2cell(optreplace(opt,'maxdepth',opt.maxdepth-1,'dirtotal',opt.dirtotal,'first',false,'name_progress',strNameProgress));
					[cDirNew,nDirTotal]	= FindDirectories(strDirCur,re,cOpt{:});
					cDir				= [cDir; cDirNew];
					
					opt.dirtotal	= nDirTotal;
				end
			end
			
		%progress!
			if opt.progress
				progress('name',strNameProgress,'n',opt.dirtotal);
			end
	end
	
	if opt.first && opt.progress
		progress('end');
	end
	
	nDirTotal	= opt.dirtotal;

	
%------------------------------------------------------------------------------%
function b = priv_REIN(str,re)
	b	= isempty(regexpi(str,re));
%------------------------------------------------------------------------------%
function b = priv_REIP(str,re)
	b	= ~isempty(regexpi(str,re));
%------------------------------------------------------------------------------%
function b = priv_RECN(str,re)
	b	= isempty(regexp(str,re));
%------------------------------------------------------------------------------%
function b = priv_RECP(str,re)
	b	= ~isempty(regexp(str,re));
%------------------------------------------------------------------------------%
