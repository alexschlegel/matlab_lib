function [bSuccess,cPathOut] = ApplyMask(cPathIn,cPathMask,varargin)
% NIfTI.ApplyMask
% 
% Description:	apply a mask to a NIfTI data file
% 
% Syntax:	[bSuccess,cPathOut] = NIfTI.ApplyMask(cPathIn,cPathMask,<options>)
% 
% In:
% 	cPathIn		- the path to a NIfTI file, or a cell of paths
%	cPathMask	- the path to a NIfTI mask file, or a cell of paths
%	<options>:
%		output:	(<in>-masked.nii.gz) the path/cell of paths to the output
%				file(s)
%		cores:	(1) the number of processor cores to use
%		force:	(false) true to force masking if output data already exist
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which data were successfully
%				  masked
%	cPathOut	- the output path/cell of output paths
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'cores'		, 1		, ...
		'force'		, false	, ...
		'silent'	, false	  ...
		);

[cPathIn,cPathMask,bNoCell,bNoCell]	= ForceCell(cPathIn,cPathMask);

if isempty(opt.output)
	cPathOut	= cellfun(@(f) PathAddSuffix(f,'-masked','favor','nii.gz'),cPathIn,'UniformOutput',false);
else
	cPathOut	= opt.output;
end

[cPathIn,cPathMask,cPathOut]	= FillSingletonArrays(cPathIn,cPathMask,cPathOut);
sPath							= size(cPathIn);

if isempty(cPathIn)
	bSuccess	= false(0);
	
	return;
end

if opt.force
	bProcess	= true(sPath);
else
	bProcess	= ~FileExists(cPathOut);
end

bSuccess			= true(sPath);
bSuccess(bProcess)	= MultiTask(@MaskOne,{cPathIn(bProcess) cPathMask(bProcess) cPathOut(bProcess)},...
						'description'	, 'Masking NIfTI Files'	, ...
						'cores'			, opt.cores				, ...
						'uniformoutput'	, true					, ...
						'silent'		, opt.silent			  ...
						);

if bNoCell
	cPathOut	= cPathOut{1};
end

%------------------------------------------------------------------------------%
function b = MaskOne(strPathIn,strPathMask,strPathOut)
	b	= false;
	
	try
		%load the data
			nii		= NIfTI.Read(strPathIn);
			niiMask	= NIfTI.Read(strPathMask);
		%get size info
			sNII		= size(nii.data);
			sNIIMask	= size(niiMask.data);
			
			ndNII		= numel(sNII);
			ndNIIMask	= numel(sNIIMask);
		
		if ndNIIMask<=ndNII && all(sNII(1:ndNIIMask)==sNIIMask)
		%mask is well-formatted
			%apply the mask
				m	= repmat(logical(niiMask.data),[ones(1,ndNIIMask) sNII(ndNIIMask+1:end)]);
				
				nii.data(~m)	= NaN;
			%save the masked data
				NIfTI.Write(nii,strPathOut);
		end
		
		b	= true;
	catch me
		
	end
end
%------------------------------------------------------------------------------%

end
