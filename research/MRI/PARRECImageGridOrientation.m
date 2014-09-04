function varargout = PARRECImageGridOrientation(par,strRelease,strFatShift,bOverplus)
% PARRECImageGridOrientation
% 
% Description:	determine the orientation of the image grid in a PAR/REC file 
% 
% Syntax:	[mOrient] = PARRECImageGridOrientation(par)
% 
% In:
% 	par	- either a PARREC header struct (read with PARRECReadHeader) or a path
%		  to a PARREC file 
% Out:
% 	mOrient	- a 3x3 matrix specifying the directions of the (i,j,k) image grid
% 			  indices.  The columns of the matrix correspond to standard NIfTI
% 			  space (lr, pa, is).  The first row specifies the direction of the
% 			  i index with a 1/-1 in the corresponding column, etc.  E.g. data
% 			  oriented with (i,j,k)->(ap,is,lr) would produce the following
% 			  matrix:
% 				[ 0 -1  0
% 				  0  0  1
% 				  1  0  0 ]
% 
% Side-effects:	if no output is specified, the results are displayed
% 
% Assumptions:	assumes PAR files have always reported coordinates as (ap,is,rl)
% 
% Notes:	information for this function was adapted from Jon Farrell's
%			DTI_gradient_table_creator_Philips_RelX.m function
% 
% Updated: 2011-10-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
strFatShift	= lower(strFatShift);

%get PAR header
	if ischar(par)
		par	= PARRECReadHeader(par);
	end
	if str2num(par.version)<4
		error('Only PAR/REC files version 4.0 and more recent are supported.');
	end

%determine the orientation
	mOrient	= GetOrientation(par,strRelease,strFatShift,bOverplus);
%output
	if nargout>0
		varargout{1}	= mOrient;
	else
		cOrientNIfTI	= {'lr','pa','is'};
		cOrientData		= cell(3,1);
		
		strDisp	= 'Image grid orientation: (';
		for k=1:3
			kOrient	= find(mOrient(k,:)~=0);
			if sign(mOrient(k,kOrient))==1
				cOrientData{k}	= cOrientNIfTI{kOrient};
			else
				cOrientData{k}	= cOrientNIfTI{kOrient}(end:-1:1);
			end
		end
		strDisp	= [strDisp join(cOrientData,',') ')'];
		
		disp(strDisp);
	end

%------------------------------------------------------------------------------%
function mOrient = GetOrientation(par,strRelease,strFatShift,bOverplus)
% get the orientation given the PAR header and some other info
	strSpace	= GetInputSpace(strRelease,bOverplus);
	
	mIn	= [-1 0 0; 0 -1 0; 0 0 1];
	
	mPatient			= GetPatientTransformation(par);
	mSliceOrientation	= GetSliceOrientationTransformation(par);
	mFoldover			= GetFoldoverTransformation(par);
	mFatShift			= GetFatShiftTransformation(par,strFatShift);
	mNVW2ImageGrid		= GetNVW2ImageGridTransformation();
	
	switch strSpace
		case 'lph'
			mTransform	= mNVW2ImageGrid*mSliceOrientation;
		case 'xyz'
			mTransform	= mNVW2ImageGrid*mSliceOrientation*mPatient;
		case 'mph'
			mTransform	= mNVW2ImageGrid*mFoldover*mFatShift;
	end
	
	mOrient	= mTransform*mIn;
%------------------------------------------------------------------------------%
function str = GetPatientPosition(par)
% get the patient position from the PAR header
	str	= CodeByString(par.general.patient_position,{'head','feet'},{'f','h'},'Couldn''t determine patient position');
%------------------------------------------------------------------------------%
function str = GetPatientOrientation(par)
% get the patient orientation from the PAR header
	str	= CodeByString(par.general.patient_position,{'supine','prone','right','left'},{'s','p','r','l'},'Couldn''t determine patient orientation');
%------------------------------------------------------------------------------%
function str = GetSliceOrientation(par)
% get the slice orientation from the PAR header
	s	= unique(par.imageinfo.slice_orientation);
	if numel(s)>1
		error('More than one slice orientation exists in the PAR file');
	end
	
	switch s
		case 1
			str	= 'tra';
		case 2
			str	= 'sag';
		case 3
			str	= 'cor';
		otherwise
			error('Unknown slice orientation');
	end
%------------------------------------------------------------------------------%
function str = GetFoldover(par)
% get the folder/preparation direction from the PAR header
	str	= CodeByString(par.general.preparation_direction,{'anterior-posterior','right-left','feet-head'},{'ap','rl','fh'},'Couldn''t determine foldover');
%------------------------------------------------------------------------------%
function str = GetInputSpace(strRelease,bOverplus)
% get the input space, based on the Philips software release and whether
% gradient overplus was set
	if bOverplus
		switch strRelease
			case {'1.5','1.7','2.0','2.1','2.5'}
				str	= 'lph';
			case {'10.x','11.x','1.2'}
				str	= 'xyz';
			otherwise
				error('Software release not supported by GetInputSpace');
		end
	else
		str	= 'mps';
	end
%------------------------------------------------------------------------------%
function m = GetPatientTransformation(par)
% get the patient portion of the transformation matrix from the PAR header
	strOrientation	= GetPatientOrientation(par);
	switch strOrientation
		case 's'
			mO	= [1,0,0;0,1,0;0,0,1];
		case 'p'
			mO	= [-1,0,0;0,-1,0;0,0,1];
		case 'r'
			mO	= [0,-1,0;1,0,0;0,0,1];
		case 'l'
			mO	= [0,1,0;-1,0,0;0,0,1];
	end
	
	strPosition		= GetPatientPosition(par);
	switch strPosition
		case 'h'
			mP	= [0,1,0;-1,0,0;0,0,-1];
		case 'f'
			mP	= [0,-1,0;-1,0,0;0,0,1];
	end

	m	= mO*mP;
%------------------------------------------------------------------------------%
function m = GetSliceOrientationTransformation(par)
% get the slice orientation portion of the transformation matrix from the PAR
% header
	strOrientation	= GetSliceOrientation(par);
	switch strOrientation
		case 'tra'
			m	= [0,-1,0;-1,0,0;0,0,1];
		case 'sag'
			m	= [0,0,1;0,-1,0;-1,0,0];
		case 'cor'
			m	= [0,0,1;-1,0,0;0,1,0];
	end
%------------------------------------------------------------------------------%
function m = GetFoldoverTransformation(par)
% get the foldover portion of the transformation matrix from the PAR header
	strOrientation	= GetSliceOrientation(par);
	strFoldover		= GetFoldover(par);
	
	mPAR	= [1,0,0;0,1,0;0,0,1];
	mPER	= [0,-1,0;1,0,0;0,0,1];
	
	switch strOrientation
		case 'tra'
			switch strFoldover
				case 'ap'
					m	= mPER;
				case 'rl'
					m	= nPAR;
				otherwise
					error('Invalid foldover/slice orientation combo');
			end
		case 'sag'
			switch strFoldover
				case 'fh'
					m	= mPER;
				case 'ap'
					m	= mPAR;
				otherwise
					error('Invalid foldover/slice orientation combo');
			end
		case 'cor'
			switch strFoldover
				case 'fh'
					m	= mPER;
				case 'rl'
					m	= mPAR;
				otherwise
					error('Invalid foldover/slice orientation combo');
			end
	end

%------------------------------------------------------------------------------%
function m = GetFatShiftTransformation(par,strFatShift)
% get the fat shift transformation from the PAR header and fat shift direction
	strOrientation	= GetSliceOrientation(par);
	strFoldover		= GetFoldover(par);
	strFatShift		= lower(strFatShift);
	
	mM	= [-1,0,0;0,1,0;0,0,1];
	mP	= [1,0,0;0,-1,0;0,0,1];
	
	switch strOrientation
		case 'tra'
			switch strFoldover
				case 'ap'
					switch strFatShift
						case 'a'
							m	= mM;
						case 'p'
							m	= mP;
						otherwise
							error('Invalid foldover/fat shift combo');
					end
				case 'rl'
					switch strFatShift
						case 'r'
							m	= mP;
						case 'l'
							m	= mM;
						otherwise
							error('Invalid foldover/fat shift combo');
					end
			end
		case 'sag'
			switch strFoldover
				case 'fh'
					switch strFatShift
						case 'f'
							m	= mP;
						case 'h'
							m	= mM;
						otherwise
							error('Invalid foldover/fat shift combo');
					end
				case 'ap'
					switch strFatShift
						case 'a'
							m	= mP;
						case 'p'
							m	= mM;
						otherwise
							error('Invalid foldover/fat shift combo');
					end
			end
		case 'cor'
			switch strFoldover
				case 'fh'
					switch strFatShift
						case 'f'
							m	= mP;
						case 'h'
							m	= mM;
						otherwise
							error('Invalid foldover/fat shift combo');
					end
				case 'rl'
					switch strFatShift
						case 'r'
							m	= mP;
						case 'l'
							m	= mM;
						otherwise
							error('Invalid foldover/fat shift combo');
					end
			end
	end
%------------------------------------------------------------------------------%
function m = GetNVW2ImageGridTransformation()
% get the transformation from Philips NVW to image grid space
	m	= [0,-1,0;-1,0,0;0,0,1];
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function c = CodeByString(str,cStrSearch,cCode,strErr)
% assign a code based on the presence of a substring
	str	= lower(str);
	
	nSearch	= numel(cStrSearch);
	for kS=1:nSearch
		if strfind(str,lower(cStrSearch{kS}))
			c	= cCode{kS};
			return;
		end
	end
	
	error(strErr);
%------------------------------------------------------------------------------%
