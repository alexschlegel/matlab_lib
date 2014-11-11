function [bSuccess,cPathOut] = NIfTIApplyMask(cPathIn,cPathMask,varargin)
% NIfTIApplyMask
% 
% Description:	apply a mask to a NIfTI data file
% 
% Syntax:	[bSuccess,cPathOut] = NIfTIApplyMask(cPathIn,cPathMask,<options>)
% 
% In:
% 	cPathIn		- the path to a NIfTI file, or a cell of paths
%	cPathMask	- the path to a NifTI mask file, or a cell of paths
%	<options>:
%		output:		(<in>-masked.nii.gz) the path/cell of paths to the output
%					file(s)
%		nthread:	(1) the number of threads to use
%		force:		(false) true to force masking if output data already exist
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array indicating which data were successfully
%				  masked
%	cPathOut	- the output path/cell of output paths
% 
% Updated: 2012-03-17
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'nthread'	, 1		, ...
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
						'nthread'		, opt.nthread				, ...
						'uniformoutput'	, true						, ...
						'silent'		, opt.silent				  ...
						);

if bNoCell
	cPathOut	= cPathOut{1};
end

%------------------------------------------------------------------------------%
function b = MaskOne(strPathIn,strPathMask,strPathOut)
	b	= false;
	
	try
		%load the data
			nii		= NIfTIRead(strPathIn);
			niiMask	= NIfTIRead(strPathMask);
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
				NIfTIWrite(nii,strPathOut);
		end
		
		b	= true;
	catch me
		
	end
end
%------------------------------------------------------------------------------%

end
