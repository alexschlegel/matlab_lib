function n = FSLTractWaytotal(cDirDTI,cNameTract,varargin)
% FSLTractWaytotal
% 
% Description:	calculate the total number of samples that made it in a
%				probtrackx run
% 
% Syntax:	n = FSLTractWaytotal(cDirDTI,cNameTract,<options>)
% 
% In:
% 	cDirDTI		- the DTI data directory path or cell of paths
%	cNameTract	- the name or cell of names of the tracts (i.e. the name of the
%				  tract folder in <strDirDTI>.probtrackX/) (one for each
%				  specified DTI directory)
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	n	- an array of the total number of samples that made it, or NaN if no
%		  waytotal was found
% 
% Updated: 2011-03-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'silent'	, false	  ...
		);

[cDirDTI,cNameTract]	= ForceCell(cDirDTI,cNameTract);
[cDirDTI,cNameTract]	= FillSingletonArrays(cDirDTI,cNameTract);

sTract	= size(cDirDTI);
nTract	= numel(cDirDTI);

n	= NaN(sTract);

%which files exist?
	cPathWaytotal	= cellfun(@FSLPathTractWaytotal,cDirDTI,cNameTract,'UniformOutput',false);
	bExist			= FileExists(cPathWaytotal);
	
	if ~all(bExist)
		cDirTract	= cellfun(@PathGetDir,cPathWaytotal(~bExist),'UniformOutput',false);
		
		status(['Waytotal files do not exist for the following tracts: ' 10 join(cDirTract,10)],'warning',true,'silent',opt.silent);
	end
%get waytotals for the files that exist
	n(bExist)	= cellfunprogress(@(f) sum(str2array(fget(f))),cPathWaytotal(bExist),'label','compiling waytotals','silent',opt.silent);
