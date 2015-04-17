function [cPathReplace,nReplace] = ReplaceInFiles(cPathSearch,strSearch,strReplace,varargin)
% ReplaceInFiles
% 
% Description:	replace text in a set of files
% 
% Syntax:	[cPathReplace,nReplace] = ReplaceInFiles(cPathSearch,strSearch,strReplace,<options>) 
% 
% In:
% 	cPathSearch	- a cell of file paths to search in
%	strSearch	- the search string
%	strReplace	- the replacement string
%	<options>:
%		prompt:	(true) true to prompt before replacing
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	cPathReplace	- a cell of the files containing the search string
%	nReplace		- the number of instances of the search string replaced in
%					  each file in cPathReplace
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'prompt'	, true	, ...
		'silent'	, false	  ...
		);

%get the files that match
	[cPathReplace,nReplace]	= SearchInFiles(cPathSearch,strSearch,...
								'silent'	, opt.silent	  ...
								);
	
	nPath	= numel(cPathReplace);

%return if we didn't find anything
	if nPath==0
		status('no files found.','silent',opt.silent);
	end

%prompt if specified
	if opt.prompt
		cResult	= cellfun(@(f,n) sprintf('%s: (%d found)',f,n),cPathReplace,num2cell(nReplace),'uni',false);
		
		strPrompt	= sprintf('replace "%s" with "%s" in the following files?\n%s',strSearch,strReplace,join(cResult,10));
		
		if ~askyesno(strPrompt)
			status('aborted.','silent',opt.silent);
			
			cPathReplace	= {};
			nReplace		= [];
			return;
		end
	end

%replace!
	progress('action','init','total',nPath,'label','replacing in files','silent',opt.silent);
	for kP=1:nPath
		strPathReplace	= cPathReplace{kP};
		
		strData	= fget(strPathReplace);
		strData	= regxprep(str,strSearch,strReplace);
		
		fput(strData,strPathReplace);
		
		progress;
	end
