function ifo = DICOMCheck(strPath,varargin)
% DICOMCheck
% 
% Description:	check a DICOM file to make sure everything is happy and to
%				extract some useful information
% 
% Syntax:	ifo = DICOMCheck(strPath,<options>)
% 
% In:
% 	strPath			- path to a DICOM file or to a directory containing DICOM
%					  files from one scan
%	<options>:
%		'display':	(true) display the info on screen
%		'log':		(<none>) path to the log file to save
% 
% Out:
% 	ifo	- a struct of information about the scan/file
% 
% Assumptions:	assumes all DICOM files in the directory are from the same scan
% 
% Updated:	2009-09-17
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'display'	, true	, ...
		'log'		, []	  ...
		);
		
%get the files to consider
	bDirectory	= isdir(strPath);
	if bDirectory
		cPath	= DirQuick(strPath,'wildcard','*.dcm');
	else
		cPath	= {strPath};
	end
	nDICOM		= numel(cPath);
	if nDICOM==0
			error('No files');
	end

%get info about the scans
	ifo.etc	= dicominfo(cPath{1});
	ifo		= GetScanDate(ifo);
	ifo		= GetSeriesNumber(ifo);
	ifo		= GetSession(ifo);
	ifo		= GetScanType(ifo);
	ifo		= GetSlicePlane(ifo);
	ifo		= GetGradientDirection(ifo);
	ifo		= GetScanDirection(ifo,cPath);
	ifo		= GetVolumeDimensions(ifo);
	ifo		= GetTiming(ifo);
	ifo		= GetScanOrder(ifo,cPath,bDirectory);
%error check
	ifo.warning	= {};
	
	ifo	= CheckGradient(ifo);
	ifo	= CheckUnknown(ifo);
	
%display/save a log
	bSaveLog	= ~isempty(opt.log);
	
	if opt.display || bSaveLog
		strLog	= ConstructLog(ifo);
		
		if opt.display
			disp(strLog);
		end
		if bSaveLog
			fput(strLog,opt.log);
		end
	end

%------------------------------------------------------------------------------%
function ifo = GetScanDate(ifo)
	d	= ifo.etc.AcquisitionDate;
	t	= ifo.etc.AcquisitionTime;
	
	ifo.ScanDate	= [d(1:4) '-' d(5:6) '-' d(7:8) ', ' t(1:2) ':' t(3:4) ':' t(5:6)];
%------------------------------------------------------------------------------%
function ifo = GetSeriesNumber(ifo)
	ifo.SeriesNumber	= ifo.etc.SeriesNumber;
%------------------------------------------------------------------------------%
function ifo = GetSession(ifo)
	ifo.Session	= ifo.etc.PatientID;
%------------------------------------------------------------------------------%
function ifo = GetScanType(ifo)
	cScanType	= {	'localizer'						; 
					'3d high resolution anatomical' ;
					'2d high resolution anatomical (coplanar)' ;
					'functional (epi)'
					};
	cSearch{1}	= {'localizer'};
	cSearch{2}	= {'mprage','3d spgr','3d,spgr','efgre3d'};
	cSearch{3}	= {'fastspgr','coplanar'};
	cSearch{4}	= {'epi','ep\gr'};
	nType		= numel(cScanType);
	nString		= max(cellfun('length',cSearch));
	
	cFieldSearch	= {'SeriesDescription','ImageType','Private_0019_109e'};
	nFieldSearch	= numel(cFieldSearch);
	
	for kS=1:nString
		for kFS=1:nFieldSearch
			for kT=1:nType
				if numel(cSearch{kT})>=kS
					if strfind(lower(ifo.etc.(cFieldSearch{kFS})),cSearch{kT}{kS})
						ifo.ScanType	= cScanType{kT};
						return;
					end
				end
			end
		end
	end
	
	ifo.ScanType	= 'unknown';
%------------------------------------------------------------------------------%
function ifo = GetSlicePlane(ifo)
%the ImageOrientationPatient field stores the (x,y,z) direction cosines of row
%and column directions of the image.  e.g. [1 0 0] for the first three values
%means that the row top->bottom is x neg->pos (i.e. patient right to left)
	iop	= abs(ifo.etc.ImageOrientationPatient)';
	
	if IsMemberCell({iop},{[1 0 0 0 0 1],[0 0 1 1 0 0]})
		ifo.SlicePlane	= 'coronal';
	elseif IsMemberCell({iop},{[1 0 0 0 1 0],[0 1 0 1 0 0]})
		ifo.SlicePlane	= 'transverse';
	elseif IsMemberCell({iop},{[0 1 0 0 0 1],[0 0 1 0 1 0]})
		ifo.SlicePlane	= 'saggital';
	else
		ifo.SlicePlane	= 'unknown';
	end
%------------------------------------------------------------------------------%
function ifo = GetGradientDirection(ifo)
%InPlanePhaseEncodingDirection stores the direction along which the phase
%gradient travels.  'ROW' means the gradient travels along the row direction,
%'COL' is equivalent.
	strPhaseDirection	= lower(ifo.etc.InPlanePhaseEncodingDirection);
	
	dcRow	= ifo.etc.ImageOrientationPatient(1:3);
	dcCol	= ifo.etc.ImageOrientationPatient(4:6);
	sgnRow	= sum(dcRow);
	sgnCol	= sum(dcCol);
	xyzRow	= find(dcRow~=0);
	xyzCol	= find(dcCol~=0);
	
	cDirString	= {StringRL,StringAP,StringIS};
	
	strRow	= GetDirection(cDirString{xyzRow}{:},sgnRow);
	strCol	= GetDirection(cDirString{xyzCol}{:},sgnCol);
	
	switch ifo.SlicePlane
		case {'coronal','transverse','saggital'}
			if isequal(strPhaseDirection,'col')
				ifo.PhaseEncodingDirection		= strCol;
				ifo.FrequencyEncodingDirection	= strRow;
			else
				ifo.PhaseEncodingDirection		= strRow;
				ifo.FrequencyEncodingDirection	= strCol;
			end
		otherwise
			ifo.PhaseEncodingDirection	= strPhaseDirection;
			if isequal(strPhaseDirection,'col')
				ifo.FrequencyEncodingDirection	= 'ROW';
			else
				ifo.FrequencyEncodingDirection	= 'COL';
			end
	end
%------------------------------------------------------------------------------%
	function strDirection = GetDirection(strLoc1,strLoc2,sgn)
		if sgn>0
			strDirection	= [strLoc1 ' to ' strLoc2];
		else
			strDirection	= [strLoc2 ' to ' strLoc1];
		end
%------------------------------------------------------------------------------%
	function cStr = StringRL()
		cStr	= {'right','left'};
	function cStr = StringAP()
		cStr	= {'anterior','posterior'};
	function cStr = StringIS()
		cStr	= {'inferior','superior'};
%------------------------------------------------------------------------------%
function ifo = GetScanDirection(ifo,cPath)
	if numel(cPath)<2
		ifo.ScanDirection	= 'unknown';
		return;
	end
	
	ifoLast	= dicominfo(cPath{end});
	
	pFirst	= ifo.etc.ImagePositionPatient;
	pLast	= ifoLast.ImagePositionPatient;
	
	sgn		= sign(pLast - pFirst);
	
	strIS	= StringIS;
	strAP	= StringAP;
	strRL	= StringRL;
	
	switch ifo.SlicePlane
		case 'coronal'
			ifo.ScanDirection	= GetDirection(strAP{:},sgn(2));
		case 'transverse'
			ifo.ScanDirection	= GetDirection(strIS{:},sgn(3));
		case 'saggital'
			ifo.ScanDirection	= GetDirection(strRL{:},sgn(1));
		otherwise
			ifo.ScanDirection	= 'unknown';
	end
%------------------------------------------------------------------------------%
function ifo = GetVolumeDimensions(ifo)
	dcRow	= ifo.etc.ImageOrientationPatient(1:3);
	dcCol	= ifo.etc.ImageOrientationPatient(4:6);
	xyzRow	= find(dcRow~=0);
	xyzCol	= find(dcCol~=0);
	
	%inplane dimensions
		ifo.InPlaneDimensions	= [ifo.etc.Rows ifo.etc.Columns];
	%number of slices
		ifo.NumSlices			= ifo.etc.ImagesInAcquisition;
	%number of volumes
		if isfield(ifo.etc,'NumberOfTemporalPositions')
			ifo.NumVolumes		= ifo.etc.NumberOfTemporalPositions;
		else
			ifo.NumVolumes		= 1;
		end
	%resolution + FOV
		[r,s]	= deal(zeros(3,1));	%ap, rl, is
		
		r([xyzRow xyzCol])	= ifo.etc.PixelSpacing;
		s([xyzRow xyzCol])	= ifo.InPlaneDimensions;
		
		switch ifo.SlicePlane
			case 'coronal'
				r(2)	= ifo.etc.SliceThickness;
				s(2)	= ifo.NumSlices;
			case 'transverse'
				r(3)	= ifo.etc.SliceThickness;
				s(3)	= ifo.NumSlices;
			case 'saggital'
				r(1)	= ifo.etc.SliceThickness;
				s(1)	= ifo.NumSlices;
			otherwise
				return;
		end
		
		ifo.Resolution_RL		= r(1);
		ifo.Resolution_AP		= r(2);
		ifo.Resolution_IS		= r(3);
		
		ifo.FOV_RL	= s(1)*r(1);
		ifo.FOV_AP	= s(2)*r(2);
		ifo.FOV_IS	= s(3)*r(3);
%------------------------------------------------------------------------------%
function ifo = GetTiming(ifo)
	switch ifo.ScanType
		case 'functional (epi)'
			ifo.TemporalResolution	= ifo.etc.RepetitionTime;
			ifo.InterSliceTime		= ifo.TemporalResolution / ifo.NumSlices;
	end
%------------------------------------------------------------------------------%
function ifo = GetScanOrder(ifo,cPath,bDirectory)
	if numel(cPath)<2 || ~bDirectory
		ifo.ScanOrder		= 'unknown';
		ifo.ScanInterleaved	= 'unknown';
		
		return;
	end
	ifo2	= dicominfo(cPath{2});
	
	%get ascending or descending and interleaving
		switch ifo.etc.InstanceNumber
			case 1
				switch ifo2.InstanceNumber
					case 2
						ifo.ScanOrder		= 'ascending';
						ifo.ScanInterleaved	= 'no';
					case 3
						ifo.ScanOrder		= 'ascending';
						ifo.ScanInterleaved	= 'odd even';
					otherwise
						ifo.ScanOrder		= 'unknown';
						ifo.ScanInterleaved	= 'unknown';
				end
			case 2
				switch ifo2.InstanceNumber
					case 4
						ifo.ScanOrder		= 'ascending';
						ifo.ScanInterleaved	= 'even odd';
					otherwise
						ifo.ScanOrder		= 'unknown';
						ifo.ScanInterleaved	= 'unknown';
				end
			case ifo.NumSlices
				switch ifo2.InstanceNumber
					case ifo.NumSlices-1
						ifo.ScanOrder		= 'descending';
						ifo.ScanInterleaved	= 'no';
					case ifo.NumSlices-2
						ifo.ScanOrder		= 'descending';
						ifo.ScanInterleaved	= 'odd even';
					otherwise
						ifo.ScanOrder		= 'unknown';
						ifo.ScanInterleaved	= 'unknown';
				end
			case ifo.NumSlices-1
				switch ifo2.InstanceNumber
					case ifo.NumSlices-3
						ifo.ScanOrder		= 'descending';
						ifo.ScanInterleaved	= 'even odd';
					otherwise
						ifo.ScanOrder		= 'unknown';
						ifo.ScanInterleaved	= 'unknown';
				end
			otherwise
				ifo.ScanOrder		= 'unknown';
				ifo.ScanInterleaved	= 'unknown';
		end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function ifo = CheckGradient(ifo)
%According to Sharmeen, for anatomical scans the frequency gradient direction
%should be along the "long axis" of the slice, so S/I for coronal and saggital
%and A/P for transverse.  For EPI scans it should be along the short axis.
	strRL	= StringRL;
	strAP	= StringAP;
	strIS	= StringIS;
	
	%get the direction strings we expect, depending on scan type and slice plane
		switch ifo.ScanType
			case 'functional (epi)'
				cDir	= {strRL strAP strRL};
			case 'unknown'
				return;
			otherwise %structural
				cDir	= {strIS strIS strAP};
		end
		switch ifo.SlicePlane
			case 'coronal'
				strDir	= cDir{1};
			case 'saggital'
				strDir	= cDir{2};
			case 'transverse'
				strDir	= cDir{3};
			otherwise
				return;
		end
		cDir	= {GetDirection(strDir{:},1),GetDirection(strDir{:},-1)};
		
	if ~IsMemberCell({ifo.FrequencyEncodingDirection},cDir)
		ifo.warning	= [ifo.warning; {['Frequency encoding direction should be ' cDir{1}]}];
	end
%------------------------------------------------------------------------------%
function ifo	= CheckUnknown(ifo)
	cField	= fieldnames(ifo);
	nField	= numel(cField);
	
	for k=1:nField
		if isequal(ifo.(cField{k}),'unknown')
			ifo.warning	= [ifo.warning; {[cField{k} ' is unknown']}];
		end
	end
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function strLog = ConstructLog(ifo)
	%labels
		cLabel	= {	'Scan Date'
					'Session'
					'Scan Type'
					'Slice Plane'
					'Phase Encoding Direction'
					'Frequency Encoding Direction'
					'Scan Direction'
					'Inplane Dimensions'
					'Number of Slices'
					'Number of Volumes'
					'Resolution (right/left)'
					'Resolution (anterior/posterior)'
					'Resolution (inferior/superior)'
					'Field of View (right/left)'
					'Field of View (anterior/superior)'
					'Field of View (inferior/superior)'
					'Scan Order'
					'Scan Interleaving'
					'Warnings'};
		nLabel	= numel(cLabel);
	
	%colons
		strColon	= repmat(':  ',[nLabel 1]);
	
	%values
		nWarning	= numel(ifo.warning);
		if nWarning==0
			strWarning	= 'none';
		else
			strWarning	= ifo.warning{1};
		end
		
		cValue	= {	ifo.ScanDate
					ifo.Session
					ifo.ScanType
					ifo.SlicePlane
					ifo.PhaseEncodingDirection
					ifo.FrequencyEncodingDirection
					ifo.ScanDirection
					[num2str(ifo.InPlaneDimensions(1)) 'x' num2str(ifo.InPlaneDimensions(2))]
					num2str(ifo.NumSlices)
					num2str(ifo.NumVolumes)
					[num2str(ifo.Resolution_RL) ' mm']
					[num2str(ifo.Resolution_AP) ' mm']
					[num2str(ifo.Resolution_IS) ' mm']
					[num2str(ifo.FOV_RL) ' mm']
					[num2str(ifo.FOV_AP) ' mm']
					[num2str(ifo.FOV_IS) ' mm']
					ifo.ScanOrder
					ifo.ScanInterleaved
					strWarning
					};
		
		strLabel	= StringAlign(cLabel,'right');
		strValue	= StringAlign(cValue,'left');
		strLog		= [strLabel strColon strValue];
	
	%add warnings
		if nWarning>1
			nPad	= size(strLabel,2);
			strWarning	= [repmat(' ',[nWarning-1 nPad+3]) StringAlign(ifo.warning(2:end),'left')];
			strLog		= char({strLog strWarning});
		end
		
	%add header
		strSeries	= ['series #' num2str(ifo.SeriesNumber)];
		strDate		= datestr(now,31);
		strHeader	= ['DICOM Check for ' strSeries ' of session "' ifo.Session '" performed ' strDate];
		strLog	= char({strHeader strLog});
%------------------------------------------------------------------------------%
