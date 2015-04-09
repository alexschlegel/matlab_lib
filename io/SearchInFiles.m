function [cPathFound,nFound] = SearchInFiles(cPathSearch,str,varargin)
% SearchInFiles
% 
% Description:	search for a string in a set of files
% 
% Syntax:	[cPathFound,nFound] = SearchInFiles(cPathSearch,str,<options>)
% 
% In:
% 	cPathSearch	- a cell of file paths to search in
%	str			- the string to search for
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	cPathFound	- a cell of the files containing the search string
%	nFound		- the number of instances of the search string found in each
%				  file in cPathFound
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'silent'	, false	  ...
		);

cPathSearch	= ForceCell(cPathSearch);

szSearch	= size(cPathSearch);
nSearch		= numel(cPathSearch);

bKeep	= false(szSearch);
nFound	= zeros(szSearch);

progress('action','init',...
			'total'		, nSearch				, ...
			'label'		, 'searching in files'	, ...
			'silent'	, opt.silent			  ...
			);

for kS=1:nSearch
	strPathSearch	= cPathSearch{kS};
	
	if FileExists(strPathSearch)
		strData	= fget(strPathSearch);
		
		nFound(kS)	= numel(regexp(strData,str));
		bKeep(kS)	= nFound(kS)>0;
	end
	
	progress;
end

cPathFound	= cPathSearch(bKeep);
nFound		= nFound(bKeep);
