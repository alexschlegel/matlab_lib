function cPath = path2(varargin)
% path2
% 
% Description:	a variation of MATLAB's path function
% 
% Syntax: cPath = path2([cPath]=<keep>,<options>)
% 
% In:
%	[cPath]	- a cell of paths that define the new MATLAB path
%	<options>:
%		include:	(<all>) a cell of regular expression patterns. a path must
%					match at least one pattern in order to be included in the
%					output.
%		exclude:	(<nothing>) like <include> but for patterns that specify
%					paths to exclude from the output
% 
% Out:
%	cPath	- a cell of paths on the MATLAB path that match the specified
%			  options
% 
% Updated:	2016-01-13
% Copyright 2016 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	[cPath,opt]	= ParseArgs(varargin,{},...
					'include'	, 	{}	, ...
					'exclude'	, 	{}	  ...
	);
	
	cPath		= reshape(ForceCell(cPath),[],1);
	opt.include	= ForceCell(opt.include);
	opt.exclude	= ForceCell(opt.exclude);

%get the current path
	bSetPath	= ~isempty(cPath);
	
	if ~bSetPath
		cPath	= split(path,':');
	end

%include only the specified paths
	if ~isempty(opt.include)
		bInclude	= cellfun(@(re) ~cellfun(@isempty,regexp(cPath,re)),opt.include,'uni',false);
		bInclude	= any(cat(2,bInclude{:}),2);
		
		cPath	= cPath(bInclude);
	end

%exclude paths
	if ~isempty(opt.exclude)
		bExclude	= cellfun(@(re) ~cellfun(@isempty,regexp(cPath,re)),opt.exclude,'uni',false);
		bExclude	= any(cat(2,bExclude{:}),2);
		
		cPath(bExclude)	= [];
	end

%set the new path
	if bSetPath
		path(join(cPath,':'));
	end
