function [cMFile,varargout] = GetDependencies(cMFile,varargin)
% GetDependencies
% 
% Description:	determine the M-files on which strMFile is dependent
% 
% Syntax:	[cPathDependent,cPathEval] = GetDependencies(strMFile/cMFile,<options>)
% 
% In:
% 	strMFile/cMFile	- the command or the path to the MATLAB file for which to
%					  find dependencies, or a cell of commands and paths
%	<options>:
%		dir_exclude:	(<none>) a directory or cell of directories to exclude
%						from the dependency list
%		exclude_matlab:	(true) true to exclude M files in the MATLAB program
%						path
% 
% Out:
% 	cPathDependent	- a cell of paths to M-files on which strMFile is dependent.
%					  this function excludes files that are in the MATLAB
%					  program directory and the file itself
%	cPathEval		- a cell of paths to M-files that may call an eval function.
%					  This function may miss dependencies that come from these
%					  calls.
%
% Note: At this point to fill cPathEval I only search for files that contain the
%		string "eval".  This could return a lot of false alarms.
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'dir_exclude'		, {}	, ...
		'exclude_matlab'	, true	  ...
		);
opt.dir_exclude	= reshape(ForceCell(opt.dir_exclude),[],1);
cMFile			= ForceCell(cMFile);
nMFileOrig		= numel(cMFile);

if opt.exclude_matlab
	opt.dir_exclude	= [opt.dir_exclude; {GetDirMATLAB}];
end
cExcludeSplit	= cellfun(@DirSplit,opt.dir_exclude,'UniformOutput',false);
nDirExclude		= cellfun(@numel,cExcludeSplit);
nExclude		= numel(opt.dir_exclude);

%find nested dependencies for each specified M file
	kM	= 0;
	progress('action','init','total',nMFileOrig,'label','Finding Dependencies');
	while kM<numel(cMFile)
		kM	= kM+1;
		
		if ~ismember(PathGetExt(cMFile{kM}),{'m','mexw32','mexw64'}) || ~FileExists(cMFile{kM})
			strPathMFile	= which(cMFile{kM});
		else
			strPathMFile	= PathRel2Abs(cMFile{kM});
		end
		
		%get the dependencies
			%cd(PathGetDir(strPathMFile));
			cMFileCur	= depfun(cMFile{kM},'-quiet','-expand','-toponly');
		%remove M files in the exclusion directories 
			cDirSplit	= cellfun(@DirSplit,cMFileCur,'UniformOutput',false);
			for kE=1:nExclude
				bKeep	= cellfun(@(x) numel(x)<nDirExclude(kE) || ~isequal(x(1:nDirExclude(kE)),cExcludeSplit{kE}),cDirSplit);
				
				cMFileCur	= cMFileCur(bKeep);
				cDirSplit	= cDirSplit(bKeep);
			end
		%the first entry should be the file itself
			if numel(cMFileCur)>0 && isequal(cMFileCur{1},strPathMFile)
				cMFileCur	= cMFileCur(2:end);
			end
		%add the new dependencies
			cMFile	= [cMFile; setdiff(cMFileCur,cMFile)];
			
		progress('total',numel(cMFile));
	end
%remove the input m files
	cMFile	= cMFile(nMFileOrig+1:end);
%optionally find the subset of these m-files that contain 'eval'
	if nargout>1
		varargout{1}	= SearchInFiles(cMFile,'eval');
	end
