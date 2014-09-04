function [cPathPackage,cPathEval] = PackageMFile(cMFile,strPathZip,varargin)
% PackageMFile
% 
% Description:	zip a set of M files along with their dependencies
% 
% Syntax:	[cPathPackage,cPathEval] = PackageMFile(cMFile,strPathZip,<options>)
% 
% In:
% 	cMFile		- the command or the path to the MATLAB file for which to find
%				  dependencies, or a cell of commands and paths
%	strPathZip	- the path to the package zip file
%	<options>:	see GetDependencies
% 
% Out:
%	cPathPackage	- a cell of paths to M-files that were included in the zip
%					  file package.
%	cPathEval		- a cell of paths to M-files that may call an eval function.
%					  This function may miss dependencies that come from these
%					  calls.
% 
% Updated: 2012-04-10
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cDependencies,cPathEval]	= GetDependencies(cMFile,varargin{:});

cMFile	= reshape(cellfun(@which,ForceCell(cMFile),'UniformOutput',false),[],1);

cPathPackage	= [cMFile; cDependencies];

zip(strPathZip,cPathPackage);
