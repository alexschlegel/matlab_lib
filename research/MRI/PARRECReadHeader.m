function hdr = PARRECReadHeader(strPathPAR,varargin)
% PARRECReadHeader
% 
% Description:	read a version 4, 4.1, or 4.2 PAR/REC header
% 
% Syntax:	hdr = PARRECReadHeader(strPathPAR,<options>)
% 
% In:
% 	strPathPAR	- the path to the PAR file or a .mat file storing a PAR header
%	<options>:
%		imageinfo:	(true) true to read the image info
%		usemat:		(true) true to use the corresponding .mat file if it exists
% 
% Out:
%	hdr	- a header struct
% 
% Updated: 2012-11-13
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'imageinfo'	, true	, ...
		'usemat'	, true	  ...
		);

strPathMAT	= PathAddSuffix(strPathPAR,'','mat');

if opt.usemat && FileExists(strPathMAT)
	strPathPAR	= strPathMAT;
end

if isequal(lower(PathGetExt(strPathPAR)),'mat')
	hdr	= load(strPathPAR);
	return;
end

%get the files contents
	strPAR	= fget(strPathPAR);
%separate by lines
	cPARLines	= split(strPAR,'[\r\n]+');
	nPARLines	= numel(cPARLines);
%make sure we have the right version
	hdr.version	= PARRECGetVersion(strPAR);
	
	if ~ismember(hdr.version,{'4','4.1','4.2'})
		error('Only V4, V4.1, or V4.2 PAR files are supported');
	end
%get the general information
	%get the start and end of the section
		kGeneral		= FindPARLine(cPARLines,'GENERAL INFORMATION',9);
		kGeneralStart	= FindNonComment(cPARLines,kGeneral);
		kGeneralEnd		= FindComment(cPARLines,kGeneralStart)-1;
	%parse the general information
		nGeneral	= kGeneralEnd-kGeneralStart+1;
		for kGeneral=1:nGeneral
			strLine	= cPARLines{kGeneralStart+kGeneral-1};
			
			cDataLabel	= split(strLine,'([^A-Za-z0-9\. ])|(^\.\s+)|(\s*\:\s+)');
			cDataValue	= split(strLine,'(^\.\s+)|(\s*\:\s+)');
			
			strLabel	= lower(str2fieldname(StringReduceWhitespace(cDataLabel{1})));
			strValue	= cDataValue{end};
			
			hdr.general.(strLabel)	= strValue;
		end
		
		hdr.general	= ConvertNumeric(hdr.general);

if opt.imageinfo
%get the image information definition
	%get the start and end of the section
		kIIDef		= FindPARLine(cPARLines,'IMAGE INFORMATION DEFINITION',kGeneralEnd);
		kIIDefStart	= kIIDef+3;
		kIIDefEnd	= FindPARLine(cPARLines,'IMAGE INFORMATION',kIIDefStart)-2;
	%parse the info
		mDesc2Label	= MapDescription2Label;
		nIIDef	= kIIDefEnd-kIIDefStart+1;
		
		[cInfoDescription,cInfoType]	= deal(cell(nIIDef,1));
		nInfoType						= zeros(nIIDef,1);
		for kIIDef=1:nIIDef
			strLine	= cPARLines{kIIDefStart+kIIDef-1};
			
			kInfoStart	= find(strLine~='#' & strLine~=' ',1,'first');
			kTypeEnd	= find(strLine==')',1,'last')-1;
			kTypeStart	= find(strLine=='(',1,'last')+1;
			kInfoEnd	= find(strLine(1:kTypeStart-2)~=' ',1,'last');
			
			strInfoName	= strLine(kInfoStart:kInfoEnd);
			strType		= strLine(kTypeStart:kTypeEnd);
			
			res	= regexp(strType,'(?<n>\d*)\*?(?<type>.*)','names');
			if isempty(res.n)
				res.n	= '1';
			end
			
			hdr.description.(mDesc2Label(strInfoName))	= strInfoName;
			cInfoDescription{kIIDef}						= strInfoName;
			cInfoType{kIIDef}								= res.type;
			nInfoType(kIIDef)								= str2num(res.n);
		end
%get the image information
	%get the start and end of the section
		kII			= FindPARLine(cPARLines,'IMAGE INFORMATION',kIIDefEnd);
		kIILabel	= kII+1;
		kIIStart	= kII+2;
		kIIEnd		= FindComment(cPARLines,kIIStart)-1;
	%get the image info
		cData	= cellfun(@(x) reshape(split(x,'\s+'),1,[]),cPARLines(kIIStart:kIIEnd),'UniformOutput',false);
		cData	= cat(1,cData{:});
		%d	= str2num(char(cPARLines(kIIStart:kIIEnd)));
	%split into labels
		kEnd	= 0;
		for k=1:nIIDef
			kStart	= kEnd+1;
			kEnd	= kStart+nInfoType(k)-1;
			
			dCur	= cData(:,kStart:kEnd);
			switch lower(cInfoType{k})
				case 'integer'
					dCur	= cast(str2num(char(dCur)),'int16');
				case 'float'
					dCur	= str2num(char(dCur));
				otherwise
					%do nothing, already a string
			end
			dCur	= reshape(dCur,[],nInfoType(k));
			
			hdr.imageinfo.(mDesc2Label(cInfoDescription{k}))	= dCur;
		end
end

%save the header in a more efficient form
	save(strPathMAT,'-struct','hdr');
	
%------------------------------------------------------------------------------%
function s = ConvertNumeric(s)
	cField	= fieldnames(s);
	nField	= numel(cField);
	
	for kF=1:nField
		if isempty(regexp(s.(cField{kF}),'[^0-9\.- ]'))
			s.(cField{kF})	= unless(str2num(s.(cField{kF})),s.(cField{kF}));
		end
	end
%------------------------------------------------------------------------------%
function kLine = FindPARLine(cPARLines,strSearch,kStart)
% search the PAR lines for a string
	nPARLines	= numel(cPARLines);
	kLine		= kStart;
	
	while kLine<=nPARLines
		if ~isempty(strfind(cPARLines{kLine},strSearch))
			return;
		end
		
		kLine	= kLine+1;
	end
	kLine	= [];
%------------------------------------------------------------------------------%
function kLine = FindNonComment(cPARLines,kStart)
% find the first non-comment line at or after kStart
	nPARLines	= numel(cPARLines);
	kLine		= kStart;
	
	while kLine<=nPARLines
		if numel(cPARLines{kLine})==0 || cPARLines{kLine}(1)~='#'
			return;
		end
		
		kLine	= kLine+1;
	end
	kLine	= nPARLines+1;
%------------------------------------------------------------------------------%
function kLine = FindComment(cPARLines,kStart)
% find the first comment line at or after kStart
	nPARLines	= numel(cPARLines);
	kLine		= kStart;
	
	while kLine<=nPARLines
		if numel(cPARLines{kLine})>0 && cPARLines{kLine}(1)=='#'
			return;
		end
		
		kLine	= kLine+1;
	end
	kLine	= nPARLines+1;
%------------------------------------------------------------------------------%
function m = MapDescription2Label()
	cDescription	= {	'slice number'
						'echo number'
						'dynamic scan number'
						'cardiac phase number'
						'image_type_mr'
						'scanning sequence'
						'index in REC file (in images)'
						'image pixel size (in bits)'
						'scan percentage'
						'recon resolution (x y)'
						'rescale intercept'
						'rescale slope'
						'scale slope'
						'window center'
						'window width'
						'image angulation (ap,fh,rl in degrees )'
						'image offcentre (ap,fh,rl in mm )'
						'slice thickness (in mm )'
						'slice gap (in mm )'
						'image_display_orientation'
						'slice orientation ( TRA/SAG/COR )'
						'fmri_status_indication'
						'image_type_ed_es  (end diast/end syst)'
						'pixel spacing (x,y) (in mm)'
						'echo_time'
						'dyn_scan_begin_time'
						'trigger_time'
						'diffusion_b_factor'
						'number of averages'
						'image_flip_angle (in degrees)'
						'cardiac frequency   (bpm)'
						'minimum RR-interval (in ms)'
						'maximum RR-interval (in ms)'
						'TURBO factor  <0=no turbo>'
						'Inversion delay (in ms)'
						'diffusion b value number    (imagekey!)'
						'gradient orientation number (imagekey!)'
						'contrast type'
						'diffusion anisotropy type'
						'diffusion (ap, fh, rl)'
						'label type (ASL)            (imagekey!)'
						};
	cLabel	= {	'slice_number'
				'echo_number'
				'dynamic_scan_number'
				'cardiac_phase_number'
				'image_type_mr'
				'scanning_sequence'
				'index_in_rec_file'
				'image_pixel_size'
				'scan_percentage'
				'recon_resolution'
				'rescale_intercept'
				'rescale_slope'
				'scale_slope'
				'window_center'
				'window_width'
				'image_angulation'
				'image_offcentre'
				'slice_thickness'
				'slice_gap'
				'image_display_orientation'
				'slice_orientation'
				'fmri_status_indication'
				'image_type_ed_es'
				'pixel_spacing'
				'echo_time'
				'dyn_scan_begin_time'
				'trigger_time'
				'diffusion_b_factor'
				'number_of_averages'
				'image_flip_angle'
				'cardiac_frequency'
				'minimum_rr_interval'
				'maximum_rr_interval'
				'turbo_factor'
				'inversion_delay'
				'diffusion_b_value_number'
				'gradient_orientation_number'
				'contrast_type'
				'diffusion_anisotropy_type'
				'diffusion'
				'label_type_asl'
				};
	m	= mapping(cDescription,cLabel);
%------------------------------------------------------------------------------%
