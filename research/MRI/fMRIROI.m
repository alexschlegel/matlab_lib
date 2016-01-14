function cPathOut = fMRIROI(varargin)
% fMRIROI
% 
% Description:	extract ROIs from functional data 
% 
% Syntax:	cPathOut = fMRIROI(<options>)
% 
% In:
%		<+ options for MRIParseDataPaths>
%		output:		(<auto>) an nSubject-length cell of nMask-length cells of
%					output file paths
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to force ROI extraction, even if the output
%					data already exist
%		silent:		(false) true to suppress status messages
% Out:
% 	cPathOut	- the path(s) to the extracted ROI data
% 
% Updated: 2016-01-14
% Copyright 2016 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input arguments
	opt		= ParseArgs(varargin,...
				'output'	, []	, ...
				'cores'		, 1		, ...
				'force'		, true	, ...
				'silent'	, false	  ...
				);
	
	opt_path	= optreplace(opt.opt_extra,...
					'require'	, {'functional','mask'}	  ...
					);
	cOptPath	= opt2cell(opt_path);
	sPath		= ParseMRIDataPaths(cOptPath{:});
	
	cPathOut	= repto(ForceCell(opt.output),size(sPath.functional));
	cPathOut	= cellfun(@ParseOutputPath,cPathOut,sPath.functional,sPath.mask,'uni',false);

%extract the ROIs
	if opt.force
		bDo	= true(size(cPathOut));
	else
		bDo	= cellfun(@(co) ~all(FileExists(co)),cPathOut);
	end
	
	if any(bDo)
		b	= MultiTask(@ExtractOne,{sPath.functional(bDo) sPath.mask(bDo) cPathOut(bDo)},...
				'description'	, 'extracting ROIs'	, ...
				'cores'			, opt.cores			, ...
				'uniformoutput'	, true				, ...
				'silent'		, opt.silent		  ...
				);
		
		cPathOut(~b)	= {[]};
	end
	
%format the output
	if ~sPath.cell_input.mask_inner
		cPathOut	= cellnestflatten(cPathOut);
	end
		
	if ~sPath.cell_input.functional
		cPathOut	= cPathOut{1};
	end

%------------------------------------------------------------------------------%
function cPathOut = ParseOutputPath(cPathOut,strPathFunctional,cPathMask)
	[strDirData,strNameData]	= PathSplit(strPathFunctional,'favor','nii.gz');
	
	if iscell(cPathMask)
		cPathOut	= repto(ForceCell(cPathOut),size(cPathMask));
		strMaskBase	= PathGetBase(cPathMask);
		cNameMask	= cellfun(@(m) PathGetFilePre(strrep(m(numel(strMaskBase)+1:end),filesep,'_'),'favor','nii.gz'),cPathMask,'uni',false);
		cNameOut	= cellfun(@(m) sprintf('%s-%s',strNameData,m),cNameMask,'uni',false);
		cPathOut	= cellfun(@(o,n) unless(o,PathUnsplit(strDirData,n,'nii.gz')),cPathOut,cNameOut,'uni',false);
	else
		if isempty(cPathOut)
			strNameMask	= PathGetFilePre(cPathMask,'favor','nii.gz');
			strNameOut	= sprintf('%s-%s',strNameData,strNameMask);
			cPathOut	= PathUnsplit(strDirData,strNameOut,'nii.gz');
		end
	end
end
%------------------------------------------------------------------------------%
function b = ExtractOne(strPathData,cPathMask,cPathOut)
	b	= false;
	
	[cPathMask,cPathOut]	= ForceCell(cPathMask,cPathOut);
	
	%load the data
		assert(FileExists(strPathData),'%s does not exist.',strPathData);
		
		nii	= NIfTI.Read(strPathData);
		
		sData		= size(nii.data);
		nT			= sData(end);
		nii.data	= reshape(nii.data,[],nT);
	
	%extract each mask
		nMask	= numel(cPathMask);
		
		progress('action','init','total',nMask,'label','extracting ROIs for one dataset');
		for kM=1:nMask
			strPathMask	= cPathMask{kM};
			strPathOut	= cPathOut{kM};
			
			if ~opt.force && FileExists(strPathOut)
				continue;
			end
			
			assert(FileExists(strPathMask),'%s does not exist.',strPathMask);
			
			msk		= NIfTI.Read(strPathMask);
			sMask	= size(msk.data);
			
			nSpaceData	= prod(sData(1:end-1));
			nSpaceMask	= prod(sMask);
			
			assert(isequal(nSpaceData,nSpaceMask),'data (%s) and mask (%s) are not the same size.',strPathData,strPathMask);
			
			%keep only data from the mask
				msk	= logical(reshape(msk.data,[],1));
				
				roi			= nii;
				roi.data	= reshape(roi.data(msk,:),[],1,1,nT);
			
			%save the output
				NIfTI.Write(roi,strPathOut);
			
			progress;
		end
	
	b	= true;
end
%------------------------------------------------------------------------------%

end
