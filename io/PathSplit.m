function [strDir,strFile,strExt] = PathSplit(strPath,varargin)
% PathSplit
% 
% Description:	parse a file path into directory, pre-extension file name, and
%				extension
% 
% Syntax:	[strDir,strFile,strExt] = PathSplit(strPath,<options>)
%
% In:
%	strPath	- a file path
%	<options>:
%		maxext:	(false) true to treat the first period as the start of the
%				extension
%		favor:	(<none>) a cell of extensions to favor when trying to determine
%				the extension of multi-dot file names (e.g. a.b.c.txt)
% 
% Out:
%	strDir	- the directory containing the file
%	strFile	- the pre-extension file name
%	strExt	- the file's extension
%
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent optDefault cOptDefault;

if isempty(optDefault)
	optDefault		= struct(...
						'maxext'	, false	, ...
						'favor'		, {{}}	  ...
						);
	cOptDefault		= opt2cell(optDefault);
end

if numel(varargin)>0
	opt	= ParseArgs(varargin,cOptDefault{:});
else
	opt	= optDefault;
end

opt.favor	= ForceCell(opt.favor);
nFavor		= numel(opt.favor);

strSlash	= GetSlashType(strPath);

if ~ischar(strPath)
	[strDir,strFile,strExt]	= deal('');
	return;
end

%fix . or .. paths
	if ismember(strPath,{'.','..'})
		strPath	= [strPath strSlash];
	end
%position of the last slash
	kLastSlash	= find(strPath==strSlash,1,'last');
%directory
	if isempty(kLastSlash)
		strDir	= '';
	else
		strDir	= strPath(1:kLastSlash);
		strPath	= strPath(kLastSlash+1:end);
	end
%file pre and ext
	if numel(strPath)>0
		%look for favored extensions
			bFound	= false;
			if nFavor>0
				%order the extensions from longest to shortest
					[lExt,kSort]	= sort(cellfun(@numel,opt.favor),'descend');
					opt.favor		= opt.favor(kSort);
				%search for each extension
					opt.favor	= cellfun(@(e) [StringForRegExp(e) '$'],opt.favor,'UniformOutput',false);
					cMatch		= regexp(strPath,opt.favor);
					bMatch		= ~cellfun(@isempty,cMatch);
					kMatch		= find(bMatch,1);
					
					if ~isempty(kMatch)
						kDot	= cMatch{kMatch}(1)-1;
						bFound	= true;
					end
			end
		
		if ~bFound
			if opt.maxext
				kDot	= find(strPath=='.',1,'first');
			else
				kDot	= find(strPath=='.',1,'last');
			end
			if isempty(kDot)
				kDot	= numel(strPath)+1;
			end
		end
		
		strFile	= strPath(1:kDot-1);
		strExt	= strPath(kDot+1:end);
	else
		[strFile,strExt]	= deal('');
	end
	
