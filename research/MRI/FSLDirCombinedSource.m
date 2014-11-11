function cDirSource = FSLDirCombinedSource(strDirCombined,varargin)
% FSLDirCombinedSource
% 
% Description:	return a cell of source directories for a combined DTI data set
% 
% Syntax:	cDirSource = FSLDirCombinedSource(strDirCombined,<options>)
% 
% In:
% 	strDirCombined	- the path to the combined DTI directory (combined with
%					  DTICombine)
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	cDirSource	- a cell of the source directory paths
% 
% Updated: 2011-03-21
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
cDirSource	= [];

opt	= ParseArgs(varargin,...
		'silent'	, false	  ...
		);

strPathSource	= PathUnsplit(strDirCombined,'sourcepath','txt');

if ~FileExists(strPathSource)
	status(['The source paths text file for ' strDirCombined ' does not exist.'],'warning',true,'silent',opt.silent);
	return;
end

strSource		= StringTrim(fget(strPathSource));

cPathSourceData	= split(strSource,10);
cDirSource		= cellfun(@(f) PathRel2Abs(PathGetDir(f),strDirCombined),cPathSourceData,'UniformOutput',false);
