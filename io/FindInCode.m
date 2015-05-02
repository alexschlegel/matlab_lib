function [cPathFound,cPathSearch,cDirSearch] = FindInCode(str,varargin)
% FindInCode
% 
% Description:	find instances of str in files in the code directories
%				(excluding the "_old" directories)
% 
% Syntax:	[cPathFound,cPathSearch,cDirSearch] = FindInCode(str,<options>)
%
% In:
%	str	- the string to search for
%	<options>:
%		dir:	(<find>) a cell of directories to search
%		path:	(<find>) a cell of files to search (overrides <dir>)
%
% Out:
%	cPathFound	- a cell of code paths in which the search string was found
% 
% Updated: 2015-04-28
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'dir'	, []	, ...
		'path'	, []	  ...
		);

%get the files to search
	if isempty(opt.path)
		if isempty(opt.dir)
		%get the directories to search
			%base code directories
				strDirUser	= GetDirUser;
				cDirBase	=	{
									{'code','MATLAB','lib'}
									{'studies'}
									{'projects','Art','work'}
									{'projects','Graphics'}
								};
				cDirBase	= cellfun(@(c) DirAppend(strDirUser,c{:}),cDirBase,'uni',false);
			%find all code directories
				cDirSearch		= GetDirectories(cDirBase);
		else
			cDirSearch	= reshape(ForceCell(opt.dir),[],1);
		end
		
		%get the .m files to search
			cPathSearch	= FindFilesByExtension(cDirSearch,'m','progress',true);
	else
		cDirSearch	= opt.dir;
		cPathSearch	= reshape(ForceCell(opt.path),[],1);
	end
	
%search in the .m files
	cPathFound	= SearchInFiles(cPathSearch,str);

%------------------------------------------------------------------------------%
function cDir = GetDirectories(cDir)
	nDir	= numel(cDir);
	
	progress('action','init','total',nDir,'label','finding directories');
	
	kD	= 1;
	while kD<=nDir
		strDir	= cDir{kD};
		
		%get the non-old subdirectories
			d	= dir(strDir);
			d	= d([d.isdir]);
			d	= reshape({d.name},[],1);
			
			cExclude	= {'_old';'.';'..';'data'};
			bKeep		= cellfun(@(d) ~any(strcmpi(d,cExclude)),d);
			d			= d(bKeep);
			
			cDirSub	= cellfun(@(d) DirAppend(strDir,d),d,'uni',false);
		
		%append them
			cDir	= [cDir; cDirSub];
			nDir	= numel(cDir);
		
		progress('total',nDir);
		
		kD	= kD+1;
	end
end
%------------------------------------------------------------------------------%

end
