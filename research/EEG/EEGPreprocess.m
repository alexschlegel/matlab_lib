function hdr = EEGPreprocess(strPathEEG,varargin)
% EEGPreprocess
% 
% Description:	preprocess a raw EEG data file for further analysis
% 
% Syntax:	hdr = EEGPreprocess(strPathEEG,[cChannelProc]=<all>,<options>)
% 
% In:
% 	strPathEEG		- the path to the EEG file, a directory containing EEG
%					  files, or a cell of paths
%	[cChannelProc]	- a cell of channel names/indices/groups to preprocess
%	<options>:
%		suffix:				(<none>) a suffix to add on to the preprocessed
%							file name.  file name will be
%							<orig>-preprocessed-<suffix>.dat
%		reference:			(true) true to apply the reference based on the
%							scheme used on the session date, false not to apply a
%							reference, or an array of channel indices to use as
%							the reference
%		event_type:			(<see EEGRead>) 
%		event_bits:			(<see EEGRead>)
%		crop_start_k:		(1) the first sample to keep in the preprocessed data
%		crop_end_k:			(<end>) the last sample to keep in the preprocessed
%							data
%		crop_start_t:		(<from crop_start_k>) the first time point to keep
%		crop_end_t:			(<from crop_end_k>) the last time point to keep
%		crop_start_event:	(<none>) keep everything after the first occurrence
%							of the specified event
%		crop_end_event:		(<none>) keep everything before the last occurrence
%							of the specified event
%		hp_stop:			(0.016) the FFT high pass filter stop frequency, in Hz.
%							specify false to skip highpass filtering
%		hp_pass:			(0.032) the FFT high pass filter pass frequency, in
%							Hz. set to false to skip highpass filtering.
%		lp_cutoff:			(70) the low pass filter cutoff frequency, in Hz.
%							specify false to skip lowpass filtering
%		session_date:		(<from hdr>) the session date as milliseconds from
%							the epoch, for determining the scheme to use
%		rate:				(<input rate>) the output sampling rate, in Hz
%		close:				(true) true to close the output data file (fid is in
%							hdr.fid)
%		cores:				(1) the number of processor cores to use
%		force:				(false) true to force preprocessing again if
%							preprocessed data already exists
%		silent:				(false) true to suppress status output
% 
% Out:
% 	hdr	- a struct of header info about the preprocessed data, or a cell of such
%		  if a directory or cell of raw data files was passed
% 
% Side-effects:	saves the preprocessed data with the extension .dat and the
%				header struct as a MATLAB file with the extension .hdr
% 
% Notes:	if a reference is applied that data is no longer saved in the
%			preprocessed data.  if events are processed the status channel is
%			also deleted from the preprocessed data
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the optional arguments
	[cChannelProc,opt]	= ParseArgs(varargin,[],...
							'suffix'			, ''		, ...
							'reference'			, true		, ...
							'event_type'		, 'number'	, ...
							'event_bits'		, []		, ...
							'crop_start_k'		, []		, ...
							'crop_end_k'		, []		, ...
							'crop_start_t'		, []		, ...
							'crop_end_t'		, []		, ...
							'crop_start_event'	, []		, ...
							'crop_end_event'	, []		, ...
							'hp_stop'			, 0.016		, ...
							'hp_pass'			, 0.032		, ...
							'lp_cutoff'			, 70		, ...
							'session_date'		, []		, ...
							'rate'				, []		, ...
							'close'				, true		, ...
							'cores'				, 1			, ...
							'force'				, false		, ...
							'silent'			, false		  ...
							);
if ~isempty(opt.suffix)
	opt.suffix	= ['-' opt.suffix];
end

%process each file if a cell of paths was passed
	if iscell(strPathEEG)
		hdr	= MultiTask(@(x) EEGPreprocess(x,varargin{:}),{strPathEEG},'description','Preprocessing cell of files','cores',opt.cores,'silent',opt.silent);
		return;
	end
%process each file in the directory if a directory was passed
	if isdir(strPathEEG)
		strPathEEG	= FindFilesByExtension(strPathEEG,'bdf'); 
		hdr			= MultiTask(@(x) EEGPreprocess(x,varargin{:}),{strPathEEG},'description','Preprocessing directory','cores',opt.cores,'silent',opt.silent);
		return;
	end

strFile	= PathGetFileName(strPathEEG);

status(['Preprocessing EEG file ' strFile],'silent',opt.silent);

%save the input parameters
	optInput	= opt;
%delete the existing data if we're forcing a repreprocess
	strPathHeader	= PathAddSuffix(strPathEEG,['-preprocessed' opt.suffix],'hdr');
	strPathData		= PathAddSuffix(strPathHeader,'','dat');
	
	if opt.force
		if FileExists(strPathHeader)
			delete(strPathHeader);
		end
		if FileExists(strPathData)
			delete(strPathData);
		end
	end
%read the header
	[hdrRaw,fidRaw]	= EEGReadHeader(strPathEEG,'silent',opt.silent,'close',false);
	fs				= hdrRaw.channel.data(1).rate;
	nSample			= hdrRaw.nsample;
	
	if numel(hdrRaw.channel.data)==0
		error(['File ' strPathEEG ' has no data channels.']);
	end
	
	if isempty(cChannelProc)
		kChannelProc	= [hdrRaw.channel.data.k];
	else
		[sChannel,sKFile,sKHeader]	= EEGChannel(cChannelProc,hdrRaw,'session_date',opt.session_date);
		kChannelProc				= sKFile.read(ismember(sKFile.read,[hdrRaw.channel.data.k]));
	end
%do we need to preprocess?
	bPreprocess	= true;
	bAlready	= false;
	
	%initial header info
		hdr					= hdrRaw;
		hdr.opt_input		= optInput;
		hdr.path_header		= strPathHeader;
		hdr.path_data		= strPathData;
		hdr.channel.data	= hdr.channel.data([]);
		hdr.channel.status	= hdr.channel.status([]);
	%if we already preprocessed,  did we use the same parameters?
		if FileExists(strPathHeader) && FileExists(strPathData)
			cFieldIgnore	= {'close','cores','force','silent'};
			
			hdrProc		= load(strPathHeader,'-mat');
			optProc		= rmfield(hdrProc.opt_input,cFieldIgnore);
			
			bAlready	= isequal(optProc,rmfield(optInput,cFieldIgnore));
		end
	%if we don't have a blank header, are there channels we haven't preprocessed
	%yet?
		if bAlready
			hdr				= hdrProc;
			hdr.path_data	= strPathData;
			hdr.path_header	= strPathHeader;
				
			kAlready		= [hdrProc.channel.data.k];
			kChannelProc	= setdiff(kChannelProc,kAlready);
			
			if isempty(kChannelProc)
				status('preprocessing already complete','noffset',1,'silent',opt.silent);
				
				return;
			end
	%otherwise delete and start over
		else
			if FileExists(strPathHeader)
				delete(strPathHeader);
			end
			if FileExists(strPathData)
				delete(strPathData);
			end
		end
%get the reference channels
	bReference	= notfalse(opt.reference);
	if bReference
		status('reading reference channels','noffset',1,'silent',opt.silent);
		
		%get the channel indices
			if isequal(opt.reference,true)
				[sChannelRef,sKFileRef]	= EEGChannel('ref',hdrRaw,'readstatus',false,'session_date',opt.session_date);
				opt.reference				= sKFileRef.ref;
			end
		%read the reference channels
			eegRef	= EEGRead(strPathEEG,'channel',opt.reference,'rate',opt.rate,'fid',fidRaw,'hdr',hdrRaw,'silent',true);
	end
%get the events
	bEvent	= ~isequal(opt.event_type,'none');
	if bEvent
		status('processing status channel','noffset',1,'silent',opt.silent);
		
		%read the status channel
			eegStatus	= EEGRead(strPathEEG,'channel','Status','event_type',opt.event_type,'event_bits',opt.event_bits,'rate',opt.rate,'fid',fidRaw,'hdr',hdrRaw,'silent',true);
	end
%get the cropping indices
	%start
		if isempty(opt.crop_start_k)
			if isempty(opt.crop_start_t)
				if isempty(opt.crop_start_event)
					opt.crop_start_k	= 1;
				else
					opt.crop_start_k	= eegStatus.event.start(find(eegStatus.event.type==opt.crop_start_event,1,'first'));
				end
			else
				opt.crop_start_k	= t2k(opt.crop_start_t,fs);
			end
		end
	%end
		if isempty(opt.crop_end_k)
			if isempty(opt.crop_end_t)
				if isempty(opt.crop_end_event)
					opt.crop_end_k	= nSample;
				else
					opt.crop_end_k	= eegStatus.event.start(find(eegStatus.event.type==opt.crop_end_event,1,'last'));
				end
			else
				opt.crop_end_k	= t2k(opt.crop_end_t,fs);
			end
		end
		
	bCrop	= ~isequal(opt.crop_start_k,1) || ~isequal(opt.crop_end_k,nSample);
%crop the reference/status
	if bCrop
		hdr.nsample	= opt.crop_end_k - opt.crop_start_k + 1;
		
		if bReference
			eegRef			= EEGCrop(eegRef,opt.crop_start_k,opt.crop_end_k);
		end
		if bEvent
			eegStatus		= EEGCrop(eegStatus,opt.crop_start_k,opt.crop_end_k);
		end
	end
%finish processing the reference/events
	if bReference
		dRef	= mean(eegRef.data,1);
		clear eegRef;
		
		%eliminate the reference from the channels to preprocess
			kChannelProc	= setdiff(kChannelProc,opt.reference);
	end
	if bEvent
		hdr.event	= eegStatus.event;
		clear eegStatus;
	end
%should we filter?
	bHighpass	= notfalse(opt.hp_stop) && notfalse(opt.hp_pass);
	bLowpass	= notfalse(opt.lp_cutoff);
%save the input parameters
	hdr.opt	= opt;
%open the output data file
	hdr.fid	= fopen(hdr.path_data,'a');
%preprocess each channel and save it to t
	nChannelProc	= numel(kChannelProc);
	
	progress('action','init','total',nChannelProc,'label',['Preprocessing data channels in ' strFile],'silent',opt.silent);
	status('preprocessing channels','noffset',1,'silent',opt.silent);
	
	%output sampling rate status message
		strRate	= conditional(isempty(opt.rate),'',[' (output rate: ' tostring(opt.rate) 'Hz)']);
	
	for kC=1:nChannelProc
		kChannelCur	= kChannelProc(kC);
		
		status(['channel ' num2str(kChannelCur)],'noffset',2,'silent',opt.silent);
		
		%load the channel
			status(['reading from file' strRate],'noffset',3,'silent',opt.silent);
			
			eeg	= EEGRead(strPathEEG,'channel',kChannelCur,'rate',opt.rate,'fid',fidRaw,'hdr',hdrRaw,'silent',true);
			
			fs	= eeg.hdr.channel.data.rate;
		%crop it
			if bCrop
				status('cropping','noffset',3,'silent',opt.silent);
				
				eeg			= EEGCrop(eeg,opt.crop_start_k,opt.crop_end_k);
				nSample		= eeg.hdr.nsample;
			end
		%apply the reference
			if bReference
				status('applying reference','noffset',3,'silent',opt.silent);
				
				eeg.data	= eeg.data - dRef;
			end
		%filter it
			if bHighpass
				status('highpass FFT filter','noffset',3,'silent',opt.silent);
				
				eeg.data	= HighpassFilterFFT(eeg.data,fs,opt.hp_stop,opt.hp_pass,'silent',true);
			end
			if bLowpass
				status('lowpass filter','noffset',3,'silent',opt.silent);
				
				eeg.data	= LowpassFilter(eeg.data,fs,opt.lp_cutoff,'silent',true);
			end
		%convert data to digital uint24 units
			status('converting to storage format','noffset',3,'silent',opt.silent);
			
			rngDigital			= eeg.hdr.channel.data.range_digital;
			rngPhysical			= eeg.hdr.channel.data.range_physical;
			
			eeg.data	= int32(round(MapValue(eeg.data,rngPhysical(1),rngPhysical(2),rngDigital(1),rngDigital(2))));
		%append the channel to the header
			hdr.channel.data	= [hdr.channel.data; eeg.hdr.channel.data];
		%append the channel to the data
			status('writing to file','noffset',3,'silent',opt.silent);
			
			fwrite(hdr.fid,eeg.data,'bit24');
			
		progress;
	end
%close the raw data file
	fclose(fidRaw);
%close the preprocessed data file
	if opt.close
		fclose(hdr.fid);
	end
%save the header file
	save(hdr.path_header,'-struct','hdr');
