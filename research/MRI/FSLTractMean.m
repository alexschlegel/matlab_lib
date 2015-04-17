function m = FSLTractMean(cDirDTI,cNameTract,varargin)
% FSLTractMean
% 
% Description:	calculate the mean within-ROI tract values for a set of tracts
% 
% Syntax:	m = FSLTractMean(cDirDTI,cNameTract,<options>)
% 
% In:
% 	cDirDTI		- the DTI data directory path or cell of paths
%	cNameTract	- the name or cell of names of the tracts (i.e. the name of the
%				  tract folder in <strDirDTI>.probtrackX/) (one for each
%				  specified DTI directory)
%	<options>:
%		force:		(true) true to calculate the mean even if a previously saved
%					mean exists
%		forceprep:	(false) true to recalculate ROIs
%		silent:		(false) true to suppress status messages
% 
% Out:
% 	m	- an array of tract means, or NaN if the required files don't exist
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'force'		, true	, ...
		'forceprep'	, false	, ...
		'silent'	, false	  ...
		);

[cDirDTI,cNameTract]	= ForceCell(cDirDTI,cNameTract);
[cDirDTI,cNameTract]	= FillSingletonArrays(cDirDTI,cNameTract);

sTract	= size(cDirDTI);
nTract	= numel(cDirDTI);

m	= NaN(sTract);

%get the output mean files
	cDirTract	= cellfun(@FSLDirTract,cDirDTI,cNameTract,'UniformOutput',false);
	cPathM		= cellfun(@(d) PathUnsplit(d,'mean','dat'),cDirTract,'UniformOutput',false);
%get the means to calculate
	if opt.force
		bCalc	= true(sTract);
	else
		bCalc	= ~FileExists(cPathM);
	end
%read the previously stored means
	m(~bCalc)	= cellfunprogress(@(f) fget(f,'precision','double'),cPathM(~bCalc),'label','reading previously calculated tract means','silent',opt.silent);
%calculate the means
	if any(bCalc)
	%required files
		cPathTract		= cellfun(@FSLPathTract,cDirDTI(bCalc),cNameTract(bCalc),'UniformOutput',false);
		[b,cPathROI]	= cellfun(@(d,n) FSLTract2ROI(d,n,'force',opt.forceprep),cDirDTI(bCalc),cNameTract(bCalc),'UniformOutput',false);
		
		bReady			= true(sTract);
		bReady(bCalc)	= cell2mat(b) & FileExists(cPathTract);
		
		if any(~bReady(:))
			status(['The following tract directories are not ready: ' 10 join(cDirTract(~bReady),10)],'warning',true,'silent',opt.silent);
		end
	%calculate
		bDo					= bReady(bCalc);
		m(bCalc & bReady)	= cellfunprogress(@CalcMean,cPathTract(bDo),cPathROI(bDo),cPathM(bCalc & bReady),'label','calculating tract means');
	end

%------------------------------------------------------------------------------%
function m = CalcMean(strPathTract,strPathROI,strPathM)
	%load each
		[dT,dROI]	= varfun(@(f) NIfTI.Read(f,'return','data'),strPathTract,strPathROI);
	%get the mean of ROI voxels
		b	= dROI~=0;
		m	= mean(dT(b));
	%save the output
		fput(m,strPathM);
end
%------------------------------------------------------------------------------%

end
