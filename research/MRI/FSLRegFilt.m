function [bSuccess,cPathOut] = FSLRegFilt(cPathData,cPathD,kF,varargin)
% FSLRegFilt
% 
% Description:	call fsl_regfilt to regress timecourses out of fMRI data
% 
% Syntax:	[bSuccess,cPathOut] = FSLRegFilt(cPathData,cPathD,kF,<options>)
% 
% In:
% 	cPathData	- the path or cell of paths to fMRI data
%	cPathD		- the path or cell of paths to design files (i.e. files
%				  containing matrices of data)
%	kF			- an array or cell of arrays of the indices of the regressors to
%				  remove
%	<options>:
%		output:		(<in>-rf) the output path or cell of paths
%		cores:		(1) the number of processor cores to use
%		force:		(true) true to process even if the output data exist
%		silent:		(false) true to suppress status messages
%	
% 
% Out:
% 	bSuccess	- an array indicating which calls completed successfully
%	cPathOut	- the output path or cell of output paths
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

[cPathData,cPathD,kF,cPathOut,bNoCell1,bNoCell2,bNoCell3,bNoCell4]	= ForceCell(cPathData,cPathD,kF,opt.output);
bNoCell																	= bNoCell1 && bNoCell2 && bNoCell3 && bNoCell4;
[cPathData,cPathD,kF,cPathOut]											= FillSingletonArrays(cPathData,cPathD,kF,cPathOut);

cPathOut	= cellfun(@(fi,fo) unless(fo,PathAddSuffix(fi,'-rf','favor','nii.gz')),cPathData,cPathOut,'UniformOutput',false);

if opt.force
	bProcess	= true(size(cPathData));
else
	bProcess	= ~FileExists(cPathOut);
end

bSuccess	= true(size(bProcess));
if any(bProcess)
	bSuccess(bProcess)	= MultiTask(@DoRegFilt,{cPathData(bProcess) cPathD(bProcess) kF(bProcess) cPathOut(bProcess)},...
							'description'	, 'regressing out timecourses'	, ...
							'cores'			, opt.cores						, ...
							'uniformoutput'	, true							, ...
							'silent'		, opt.silent					  ...
							);
end

if bNoCell
	cPathOut	= cPathOut{1};
end


%------------------------------------------------------------------------------%
function b = DoRegFilt(strPathData,strPathD,kF,strPathOut)
	strF	= ['"' join(kF,',') '"'];
	
	b	= ~CallProcess('fsl_regfilt',{'-i' strPathData '-o' strPathOut '-d' strPathD '-f' strF},'silent',opt.silent);
	
	%save the removed components
		strPathLog	= PathAddSuffix(strPathOut,'','log','favor','nii.gz');
		
		fput(['removed: ' join(kF,',')],strPathLog);
end
%------------------------------------------------------------------------------%

end
