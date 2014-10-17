function [sChannel,sKFile,sKHeader] = EEGChannel(varargin)
% EEGChannel
% 
% Description:	return a struct of EEG channel labels and indices
% 
% Syntax:	[sChannel,sKFile,sKHeader] = EEGChannel([cChannel]='all',[hdr]=<default>,<options>)
% 
% In:
% 	[cChannel]	- an EEG channel or cell of channels. can be 'A1' through 'A32',
%				  'Status' for the status channel, a head label (see notes
%				  in EEGChannel2Index), a two-element cell with the name of the
%				  channel grouping and a cell of the channels, or one of the
%				  following:
%					'all':			all channels
%					'head':			head channels
%					'data':			data channels
%					'status':		status channels
%					'ref':			reference channels
%					'rp':			channels to use for RP calculation
%					'lrp':			channels to use for LRP left/right
%									calculation
%					'emg':			channels to use for EMG left/right
%									calculation
%					'eog':			eye channels
%					'eyemovement':	channels to use to detect eye movement
%	[hdr]		- an EEG header struct to reference
%	<options>:
%		readstatus:		(true) true to include the status channel in the list of
%						channels to read
%		session_date:	(<from hdr>) the session date as milliseconds from the
%						epoch, for determining the scheme to use
%		scheme:			(<from session_date>) the electrode hookup scheme to use:
%							1: used from 2010-06-24 to 2010-08-10
%							2: used from 2010-08-11 to ... 
% 
% Out:
%	sChannel	- a struct of cells of channel labels for the requested groups
% 	sKFile		- a struct of arrays of indices in the referenced EEG file of
%				  the channels in sChannel
%	sKHeader	- a struct of arrays of indices in the reference header of the
%				  channels in sChannel
% 
% Updated: 2010-08-11
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[cChannel,hdr,opt]	= ParseArgs(varargin,'all',[],...
						'readstatus'	, true	, ...
						'session_date'	, []	, ...
						'scheme'		, []	  ...
						);
if isempty(opt.session_date)
	if ~isempty(hdr)
		opt.session_date	= FormatTime(hdr.time);
	else
		opt.session_date	= 0;
	end
end

%parse the input
	if ~iscell(cChannel) || (numel(cChannel)==2 && ischar(cChannel{1}) && iscell(cChannel{2}) && all(cellfun(@ischar,cChannel{2})))
		cChannel	= {cChannel};
	end

	%do we want status channels?
		if opt.readstatus
			cChannel	= [reshape(cChannel,[],1); 'Status'];
		end
		
	nChannel	= numel(cChannel);
%get the electrode scheme
	if isempty(opt.scheme)
		if opt.session_date > FormatTime('2010-08-11','yyyy-mm-dd')
			opt.scheme	= 2;
		else
			opt.scheme	= 1;
		end
	end
	
	sScheme			= GetScheme(opt.scheme);
	cSchemeGroup	= fieldnames(sScheme);
%get the channel groupings
	[sChannel,sKFile,sKHeader]	= deal(struct);
	
	for kC=1:nChannel
		if ischar(cChannel{kC})
			switch cChannel{kC}
				case 'lrp'
					AddGroup('lrp_l');
					AddGroup('lrp_r');
				case 'emg'
					AddGroup('emg_l');
					AddGroup('emg_r');
				case 'eog'
					AddGroup('eog');
					AddGroup('eog_correlate');
				case cSchemeGroup
					AddGroup(cChannel{kC});
				otherwise
					AddGroup(str2fieldname(cChannel{kC}),{cChannel{kC}});
			end
		elseif iscell(cChannel{kC})
			AddGroup(cChannel{kC}{1},cChannel{kC}{2});
		elseif isnumeric(cChannel{kC}) && all(isnat(cChannel{kC}))
			AddGroup(['Channel' join(cChannel{kC},'_')],cChannel{kC});
		else
			error(['Channel ' num2str(kC) ' is unrecognized.']);
		end
	end
%get the channels to read
	cChannel	= struct2cell(sChannel);	cChannel	= cat(2,cChannel{:});
	kFile		= struct2cell(sKFile);		kFile		= cat(2,kFile{:});
	kHeader		= struct2cell(sKHeader);	kHeader		= cat(2,kHeader{:});
	
	%eliminate the reference channels
		if isfield(sChannel,'ref')
			[cChannel,kKeep]	= setdiff(cChannel,sChannel.ref);
			kFile				= kFile(kKeep);
			kHeader				= kHeader(kKeep);
		end
	
	%get the unique channels
		[cChannel,kUnique]	= UniqueCell(cChannel);
		kFile				= kFile(kUnique);
		kHeader				= kHeader(kUnique);
		
	sChannel.read	= cChannel;
	sKFile.read		= kFile;
	sKHeader.read	= kHeader;

%------------------------------------------------------------------------------%
function AddGroup(strField,varargin)
% add a channel group
	cGroup	= ParseArgs(varargin,[]);
	if isempty(cGroup)
		cGroup	= GetFieldPath(sScheme,strField);
	end
	if ~isempty(cGroup)
		[sKFile.(strField),sChannel.(strField),sKHeader.(strField)]	= EEGChannel2Index(cGroup,hdr);
	end
end
%------------------------------------------------------------------------------%
function s = GetScheme(kScheme)
% return the electrode hookup schemes
	s	= struct(...
				'rp'			, {{'Cz'}}		...
			,	'lrp_l'			, {{'C3'}}		...
			,	'lrp_r'			, {{'C4'}}		...
			,	'eyemovement'	, {{'Fz','Pz'}}	...
			);
	switch kScheme
		case 1
			s	= StructMerge(s,struct(						...
						'earlobe_l'		, {{'EXG3'}}		...
					,	'earlobe_r'		, {{'EXG4'}}		...
					,	'pointer_l'		, {{'EXG6'}}		...
					,	'pointer_r'		, {{'EXG7'}}		...
					));
			
			s.ref	= [s.earlobe_l s.earlobe_r];
			s.emg_l	= s.pointer_l;
			s.emg_r	= s.pointer_r;
		case 2
			s	= StructMerge(s,struct(					...
						'eog_canthus_l'	, {{'EXG1'}}	...
					,	'eog_canthus_r'	, {{'EXG2'}}	...
					,	'eog_supra_r'	, {{'EXG3'}}	...
					,	'eog_sub_r'		, {{'EXG4'}}	...
					,	'mastoid_l'		, {{'EXG5'}}	...
					,	'mastoid_r'		, {{'EXG6'}}	...
					,	'fdi_l'			, {{'EXG7'}}	...
					,	'fdi_r'			, {{'EXG8'}}	...
					));
			
			s.ref			= [s.mastoid_l s.mastoid_r];
			s.emg_l			= s.fdi_l;
			s.emg_r			= s.fdi_r;
			s.eog			= [s.eog_canthus_l s.eog_canthus_r s.eog_supra_r s.eog_sub_r];
			s.eog_correlate	= [s.eog_canthus_l s.eog_canthus_r s.eog_sub_r];
		otherwise
			error(['"' num2str(kScheme) '" is not a valid scheme.']);
	end
end
%------------------------------------------------------------------------------%

end