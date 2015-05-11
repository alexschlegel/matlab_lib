function eeg = Create(eeg)
% EEG.Create
% 
% Description:	create an EEG data set
% 
% Syntax:	eeg = EEG.Create(eeg)
% 
% In:
% 	eeg	- an eeg struct or eeg header struct. if the path referred to by the
%		  eeg struct is not a NIfTI file, its file extension is changed to
%		  'nii'.
% 
% Out:
%	eeg	- the updated eeg struct
%
% Updated: 2015-04-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	if ~isfield(eeg,'hdr')
		eeg	= struct('hdr',eeg);
	end

%fix the path
	strExt	= PathGetExt(eeg.hdr.path);
	
	if ~strcmp(lower(strExt),'nii')
		eeg.hdr.path	= PathAddSuffix(eeg.hdr.path,'','nii');
	end
	
%create a NIfTI object for the eeg data
	if isfield(eeg,'data')
		szData	= size(eeg.data);
	else
		nChannel	= numel(eeg.hdr.channel.data.label);
		
		if isfield(eeg.hdr,'sample')
			szSample	= size(eeg.hdr.sample);
		else
			szSample	= eeg.hdr.samples;
		end
		
		szData	= [nChannel szSample];
	end
	
	nii			= nifti;
	nii.dat		= file_array(eeg.hdr.path,szData,'float32-BE');
	nii.mat		= eye(4);
	nii.mat0	= eye(4);
	create(nii);

%fill the data
	if isfield(eeg,'data')
		nii.dat(:)	= eeg.data(:);
	%else
		%nii.dat(:)	= 0;
	end
	
	eeg.data	= nii.dat;
