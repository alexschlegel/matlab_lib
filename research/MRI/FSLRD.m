function [bSuccess,cPathRD] = FSLRD(cDirDTI,varargin)
% FSLRD
% 
% Description:	calculate radial diffusivity from an FSL DTI directory
% 
% Syntax:	[bSuccess,cPathRD] = FSLRD(cDirDTI,<options>)
% 
% In:
% 	cDirDTI	- the path or cell of paths to DTI directories with the results of
%			  dtifit
% 
% Out:
% 	bSuccess	- a logical array indicating which RDs could be calculated
%	cPathRD		- the RD path or cell array of RD paths
%	<options>:
%		output:		(<auto>) the output file path(s)
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force calculation of RD even if the output
%					already exists
%		silent:		(false) true to suppress status messages
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'cores'		, 1		, ...
		'force'		, true	, ...
		'silent'	, false	  ...
		);

[cDirDTI,cPathRD,bToChar,b]	= ForceCell(cDirDTI,opt.output);
[cDirDTI,cPathRD]				= FillSingletonArrays(cDirDTI,cPathRD);

cPathRD	= cellfun(@(d,f) unless(f,PathUnsplit(d,'dti_RD','nii.gz')),cDirDTI,cPathRD,'UniformOutput',false);

bSuccess	= MultiTask(@CalcRD,{cDirDTI cPathRD},...
				'description'	, 'Calculating radial diffusivities'	, ...
				'cores'			, opt.cores								, ...
				'uniformoutput'	, true									, ...
				'silent'		, opt.silent							  ...
				);

%------------------------------------------------------------------------------%
function b = CalcRD(strDirDTI,strPathOut)
	b	= false;
	
	strPathL2	= PathUnsplit(strDirDTI,'dti_L2','nii.gz');
	strPathL3	= PathUnsplit(strDirDTI,'dti_L3','nii.gz');
	
	if ~FileExists(strPathL2) | ~FileExists(strPathL3)
		return;
	end
	
	try
		niiL2	= NIfTI.Read(strPathL2);
		niiL3	= NIfTI.Read(strPathL3);
		
		niiL2.data	= (niiL2.data + niiL3.data)/2;
		
		NIfTI.Write(niiL2,strPathOut);
	catch me
		return;
	end
	
	b	= true;
%------------------------------------------------------------------------------%
