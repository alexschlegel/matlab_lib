function [cData,bCombined] = FSLTractDataLoad(strDirDTI,strType,varargin)
% FSLTractDataLoad
% 
% Description:	load data for a FSLTractData calculation
% 
% Syntax:	[cData,bCombined] = FSLTractDataLoad(strDirDTI,strType,[bCombined]=<check>)
% 
% In:
% 	strDirDTI	- the DTI data directory path or cell of paths
%	strType		- the type of data to calculate.  one of the following:
%					fa, md, ad, rd, faz, mdz, adz, rdz
%	[bCombined]	- true if the DTI directory represents combined data.  if true
%				  then all the data from the source directories will be loaded
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	cData		- a data array or cell of data arrays if bCombined==true
%	bCombined	- true if the DTI directory represents combined data
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent typeMap;

[bCombined,opt]	= ParseArgs(varargin,[],...
					'silent'	, false	  ...
					);

if isempty(bCombined)
	bCombined	= isequal(lower(char(DirSplit(strDirDTI,'limit',1))),'combined');
end

if bCombined
	cDirData	= FSLDirCombinedSource(strDirDTI);
else
	cDirData	= {strDirDTI};
end

cData	= repmat({NaN},size(cDirData));

if isempty(typeMap)
	typeMap	= mapping(...
				{'fa','md','ad','rd','faz','mdz','adz','rdz'}	, ...
				{'fa','md','l1','rd','faz','mdz','l1z','rdz'}	  ...
				);
end

switch lower(strType)
	case typeMap.domain
		strTypeMap	= typeMap(lower(strType));
		
		if bCombined
			cPathData	= cellfun(@(d) PathUnsplit(d,['dti_' upper(strTypeMap) '-tocombined'],'nii.gz'),cDirData,'UniformOutput',false);
		else
			cPathData	= cellfun(@(d) PathUnsplit(d,['dti_' upper(strTypeMap)],'nii.gz'),cDirData,'UniformOutput',false);
		end
		
		bLoad	= FileExists(cPathData);
		
		if ~all(bLoad)
			status(['The following files do not exist: ' 10 join(cPathData(~bLoad),10)],'warning',true,'silent',opt.silent);
		end
		
		cData(bLoad)	= cellfun(@(f) NIfTI.Read(f,'return','data'),cPathData(bLoad),'UniformOutput',false);
	otherwise
		error(['"' tostring(strType) '" is not a recognized data type.']);
end
