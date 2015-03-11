function cPathVTC = GetPathVTC(strDirRoot,strSession,kRun,varargin)
% GetPathVTC
% 
% Description:	get the path to a VTC file
% 
% Syntax:	cPathVTC = GetPathVTC(strDirRoot,strSession,kRun,<options>)
% 
% In:
% 	strDirRoot	- root study directory path
%	strSession	- session name
%	kRun		- an array of run numbers
%	<options>:
%		'vtcsuffix':	('_SCCA_3DMCT_THPGLMF2c') the VTC suffix
% 
% Out:
% 	cPathVTC	- a cell of paths to the specified VTC files
% 
% Updated:	2009-08-11
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'vtcsuffix'	, '_SCCA_3DMCT_THPGLMF2c'	  ...
		);

cDirRun		= ForceCell(GetDirRun(strDirRoot,strSession,kRun));
cPathVTC	= cellfun(@(strDir,kRun) [strDir strSession '_' StringFill(kRun,2) opt.vtcsuffix '.vtc'],cDirRun,num2cell(kRun),'UniformOutput',false);
