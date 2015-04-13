function strType = IdentifyScanType(strPathData)
% NIfTI.IdentifyScanType
% 
% Description:	attempt to identify the scan type of a NIfTI (Analyze) formatted
%				data file
% 
% Syntax:	strType = NIfTI.IdentifyScanType(strPathData)
% 
% In:
% 	strPathData	- path to the data file to identify
% Out:
% 	strType	- one of the following strings, identifying the scan type:
%				OTHER, COPLANAR, T1, EPI, DTI, LOCALIZER
%			  if the function can't determine the type, it returns 'OTHER'
% 
% Notes:	Requires SPM8 to be in the MATLAB path.
%
%			looks for identifying information in the .descrip element of the
%			file's nifti object, the number of slices per volume, and in the
%			file path
%
%			DTI file recognition is not implemented
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%make sure the file is valid
	if ~exist(strPathData,'file')
		error(['File "' strPathData '" not found']);
	end

%type codes
				%1			%2			%3		%4		%5		%6
	cType	= {	'OTHER',	'COPLANAR',	'T1',	'EPI',	'DTI',	'LOCALIZER'};
%likelihood of a scan occurring, everything else being equal (greater value =>
%more likely)
	kLikely	= [	0			3			4		5		1		2];

%regexp patterns to identify type by file name
	[reFileName,pFileName]	= deal({});
	
	%localizer
		reFileName	= [reFileName	{'localizer'}];
		pFileName	= [pFileName	{[false false false false false true]}];
	
	%coplanar
		reFileName	= [reFileName	{'fastspgr', 'coplanar'}];
		pFileName	= [pFileName	repmat({[false true false false false false]},[1 2])];
	
	%T1
		reFileName	= [reFileName	{'mprage', RegExpWord('t1')}];
		pFileName	= [pFileName	repmat({[false false true false false false]},[1 2])];
	
	%DTI
		%not implemented
		
%regexp patterns to identify type by NIfTI description
	[reDesc,pDesc]	= deal({});
	
	%2D GR, but not 2D GR\EP, for COPLANAR and LOCALIZER
		reDesc	= [reDesc	{'2D GR(([^\\])|(\\[^E])|(\\E[^P]))'}];
		pDesc	= [pDesc	{[NaN true false false false true]}];
		
	%EP, for EPI
		reDesc	= [reDesc	{'(^EP$)|(^EP\W+)|(\W+EP\W+)|(\W+EP$)'}];
		pDesc	= [pDesc	{[false false false true false false]}];
		
	%3D GR, for T1
		reDesc	= [reDesc	{'3D GR'}];
		pDesc	= [pDesc	{[NaN false true false NaN false]}];
		
	nREDesc	= numel(reDesc);
		
%slice count limits for each type
	sliceMin	= [0	5	30	5	1	3	];
	sliceMax	= [inf	70	300	70	inf	3	];
		
	nREFileName	= numel(reFileName);
	
%keep track of which types are possibilities.  true signifies possible, false
%not possible, NaN not sure
	nPossible	= numel(cType);
	bPossible	= NaN(nPossible,1);
	
%load the file
	nii	= nifti(strPathData);
		
%check the descriptions
	strDesc	= nii.descrip;
	for k=1:nREDesc
		if regexpi(strDesc,reDesc{k})
			bPossible	= ProcessPossibilities(bPossible,pDesc{k});
		end
	end
	
	%do we have a match?
		kMatch	= TestMatch(bPossible);
			

%check the slice count
	if isempty(kMatch)
		nSlice		= size(nii.dat,3);
		pSliceCount	= nSlice >= sliceMin & nSlice <= sliceMax;
		bPossible	= ProcessPossibilities(bPossible,pSliceCount);
		
		kMatch	= TestMatch(bPossible);
	end

%look for identifying strings in the file name
	if isempty(kMatch)
		[dummy,strFilePre,dummy]	= PathSplit(strPathData);
		
		for k=1:nREFileName
			if regexpi(strFilePre,reFileName{k})
				bPossible	= ProcessPossibilities(bPossible,pFileName{k});
			end
		end
		
		kMatch	= TestMatch(bPossible);
	end
		
%choose the most likely of the remaining possibilities
	kPossible		= find(bPossible);
	[dummy,kType]	= max(kLikely(kPossible));
	strType			= cType{kPossible(kType(1))};
	
%------------------------------------------------------------------------------%
function bPossible = ProcessPossibilities(bPossible,bNewInfo)
	bConsider	= reshape(~isnan(bNewInfo),[],1);
	
	bPossible(isnan(bPossible) & bConsider)	= true;
	
	bPossible(bConsider)	= bPossible(bConsider) & reshape(bNewInfo(bConsider),[],1);
%------------------------------------------------------------------------------%
function kMatch = TestMatch(bPossible)
	if ~any(isnan(bPossible)) && sum(bPossible)==1
		kMatch	= find(bPossible);
	else
		kMatch	= [];
	end
%------------------------------------------------------------------------------%
