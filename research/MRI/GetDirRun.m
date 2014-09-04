function [strDirRun,kRun] = GetDirRun(strDirRoot,strSession,varargin)
% GetDirFunctional
% 
% Description:	get a session's run directory, given the functional directory
%				and run number or the root experimental path, session code, and
%				run number
% 
% Syntax:	[strDirRun,kRun] = GetDirRun(strDirRoot,strSession,[kRun]=<all>,<options>)
%
% In:
%	strDirRoot			- root study directory
%	strSession			- the session code
%	[kRun]				- an array of runs.  leave blank to search for all runs
%	<options>:
%		'cell_output':	(false): true to force cell output.  if this option is
%						false and only one run is found, a char array is output
% 
% Out:
%	strDirRun	- a path or cell of paths to the run directory/ies
%	kRun		- an array of the run numbers for which directories were
%				  returned
% 
% Updated:	2009-07-29
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
[kRun,opt]	= ParseArgsOpt(varargin,[],...
				'cell_output'	, false	  ...
				);

strDirFunctional	= GetDirFunctional(strDirRoot,strSession);

%get the run paths
	if isempty(kRun)
		strDirRun	= FindDirectories(strDirFunctional,'^[0-9][0-9]$');
		kRun		= cellfun(@GetRunFromDir,strDirRun);
	else
		strDirRun	= cellfun(@(x) AddSlash([strDirFunctional StringFill(x,2)]),num2cell(kRun),'UniformOutput',false);
	end
%cell or string?
	if ~opt.cell_output && numel(kRun)==1
		strDirRun	= strDirRun{1};
	end


%------------------------------------------------------------------------------%
function kRun = GetRunFromDir(strDirRun)
	cDir	= DirSplit(strDirRun);
	kRun	= str2num(cDir{end});
%------------------------------------------------------------------------------%
