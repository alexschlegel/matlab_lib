function nii = TemporalZScore(nii,varargin)
% NIfTI.TemporalZScore
% 
% Description:	temporally z-score each voxel of a 4D NIfTI data set 
% 
% Syntax:	nii = NIfTI.TemporalZScore(nii,[strPathOut]=<none>)
% 
% In:
% 	nii				- the path to a NIfTI file, a NIfTI struct loaded with
%					  NIfTI.Read, or a 3d or 4d array
%	[strPathOut]	- the output file path
% 
% Out:
% 	nii	- the z-score data
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
strPathOut	= ParseArgs(varargin,[]);

bStruct	= true;
switch class(nii)
	case 'char'
		nii	= NIfTI.Read(nii);
	case 'struct'
	otherwise
		bStruct	= false;
		
		nii	= struct('data',nii);
end

nii.data	= double(nii.data);

m	= nanmean(nii.data,4);
sd	= nanstd(nii.data,0,4);

nii.data	= nii.data - repmat(m,[1 1 1 size(nii.data,4)]);
nii.data	= nii.data./repmat(sd,[1 1 1 size(nii.data,4)]);

if ~bStruct
	nii	= nii.data;
elseif ~isempty(strPathOut)
	NIfTI.Write(nii,strPathOut);
end
