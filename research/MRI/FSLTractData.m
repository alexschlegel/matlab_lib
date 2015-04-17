function d = FSLTractData(cDirDTI,cNameTract,strType,varargin)
% FSLTractData
% 
% Description:	calculate DTI data for a tract created with FSLROITractFS
% 
% Syntax:	d = FSLTractData(cDirDTI,cNameTract,strType,<options>)
% 
% In:
% 	cDirDTI		- the DTI data directory path or cell of paths. if the directory
%				  is a combined directory (see DTICombine) then data for all the
%				  constituent data sets is retrieved unless the <check_combined>
%				  option is false.
%	cNameTract	- the name or cell of names of the tracts (i.e. the name of the
%				  tract folder in <strDirDTI>.probtrackX/) (one for each
%				  specified DTI directory)
%	strType		- the type of data to calculate.  one of the following:
%					fa, md, ad, rd, faz, mdz, adz, rdz
%				  (the corresponding data must exist in the DTI data directory)
%	<options>:
%		data:			(<load>) a data array or cell of arrays returned by
%						FSLTractDataLoad from which to calculate the specified
%						value.  this should only be used if all of the specified
%						DTI directories are the same.
%		lengthcorrect:	(false) true to use length-corrected ROIs
%		check_combined:	(true) true to check whether the passed directory
%						represents combined data, and to load the data from the
%						source directories if it is
%		force:			(true) true to calculate the tract data even if
%						previously saved data exists
%		forceprep:		(false) true to recalculate required files avalues 
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	d		- an array (or a cell of arrays [one array for each DTI/tract pair]
%			  if a cell of data files were specified or any DTI directories
%			  represent combined data) of the tract data, or NaNs if the
%			  required files don't exist
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'data'				, []	, ...
		'lengthcorrect'		, false	, ...
		'check_combined'	, true	, ...
		'force'				, true	, ...
		'forceprep'			, false	, ...
		'silent'			, false	  ...
		);

[cDirDTI,cNameTract]	= ForceCell(cDirDTI,cNameTract);
[cDirDTI,cNameTract]	= FillSingletonArrays(cDirDTI,cNameTract);

sTract	= size(cDirDTI);
nTract	= numel(cDirDTI);

d	= cell(sTract);

bLoadData	= isempty(opt.data);
if ~bLoadData
	[cData,bSingleData]	= ForceCell(opt.data);
	sData				= size(cData);
	nData				= numel(cData);
else
	bSingleData	= true;
end

%get the output data files
	cDirTract	= cellfun(@FSLDirTract,cDirDTI,cNameTract,'UniformOutput',false);
	cPathD		= cellfun(@(d) PathUnsplit(d,lower(strType),'dat'),cDirTract,'UniformOutput',false);
%are we combined data?
	if opt.check_combined
		bCombined	= cellfun(@(d) isequal(lower(char(DirSplit(d,'limit',1))),'combined'),cDirDTI);
	else
		bCombined	= false(sTract);
	end
%get the data to calculate
	if opt.force
		bCalc	= true(sTract);
	else
		bCalc	= ~FileExists(cPathD);
	end
%read the previously stored data
	d(~bCalc)		= cellfunprogress(@(f) reshape(fget(f,'precision','double'),[],1),cPathD(~bCalc),'label','reading previously calculated data','silent',opt.silent,'UniformOutput',false);
	bCalc(~bCalc)	= cellfun(@(x) any(isnan(x)),d(~bCalc));
%calculate the data
	if any(bCalc)
		d(bCalc)	= cellfunprogress(@CalcData,cDirDTI(bCalc),cNameTract(bCalc),cPathD(bCalc),num2cell(bCombined(bCalc)),'label','calculating data','UniformOutput',false);
	end
%convert to an array?
	if bSingleData && ~any(bCombined(:))
		d	= cell2mat(d);
	end

%------------------------------------------------------------------------------%
function d = CalcData(strDirDTI,strNameTract,strPathD,bCombined)
	d	= NaN;
	
	if bLoadData
	%load the data
		cData	= FSLTractDataLoad(strDirDTI,strType,bCombined,'silent',opt.silent);
		sData	= size(cData);
	end
	
	%get the ROI
		[b,strPathROI]	= FSLTract2ROI(strDirDTI,strNameTract,'lengthcorrect',opt.lengthcorrect,'force',opt.forceprep);
		if ~b
			status(['Could not create the ROI file for tract ' strNameTract ' of DTI data ' strDirDTI '.'],'warning',true,'silent',opt.silent);
			return;
		end
		
		roi			= double(NIfTI.Read(strPathROI,'return','data'));
		roiTotal	= sum(roi(:));
		
		if roiTotal==0
			return;
		end
		
		roi	= roi./roiTotal;
	%get the weighted mean for each data set
		d			= NaN(sData);
		bNoNaN		= cellfun(@(x) ~isequalwithequalnans(x,NaN),cData);
		d(bNoNaN)	= cellfun(@(dt) nansum(reshape(dt.*roi,[],1)),cData(bNoNaN));
	%save the data
		fput(d,strPathD);
end
%------------------------------------------------------------------------------%

end
