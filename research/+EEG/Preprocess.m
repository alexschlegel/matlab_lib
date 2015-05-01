function hdr = Preprocess(cPathEEG,varargin)
% EEG.Preprocess
% 
% Description:	preprocess a raw EEG data file for further analysis.
%				preprocessed data are stored in NIfTI format with an
%				accompanying .hdr header file.
% 
% Syntax:	hdr = EEG.Preprocess(cPathEEG,<options>)
% 
% In:
% 	cPathEEG		- the path to the EEG file, or a cell of paths
%	<options>:
%		output:				(<<orig>-pp.nii.gz>) the output file path or cell
%							of output file paths
%		channel:			(<all>) a cell of names of channels to preprocess
%		reference:			(<none>) a cell of names of channels to use to
%							re-reference the data
%		event_type:			(<see EEG.ParseEvent>) 
%		event_bits:			(<see EEG.ParseEvent>)
%		crop_start_event:	(<none>) include all data at or after the first
%							occurrence of the specified event
%		crop_end_event:		(<none>) include all data at or before the last
%							occurrence of the specified event
%		hp_stop:			(0.016) the FFT high pass filter stop frequency, in
%							Hz. set to false to skip highpass filtering
%		hp_pass:			(0.032) the FFT high pass filter pass frequency, in
%							Hz. set to false to skip highpass filtering.
%		lp_cutoff:			(70) the low pass filter cutoff frequency, in Hz.
%							set to false to skip lowpass filtering.
%		rate:				(<input rate>) the output sampling rate, in Hz
%		cores:				(1) the number of processor cores to use
%		force:				(true) true to force preprocessing if output data
%							already exist
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	hdr	- a struct of header info about the preprocessed data, or a cell of such
%		  a cell of paths was passed
% 
% Notes:	if a reference is applied, then those data are no longer saved in
%			the preprocessed data.
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,[],...
						'output'			, []	, ...
						'channel'			, {}	, ...
						'reference'			, {}	, ...
						'event_type'		, []	, ...
						'event_bits'		, []	, ...
						'crop_start_event'	, []	, ...
						'crop_end_event'	, []	, ...
						'hp_stop'			, 0.016	, ...
						'hp_pass'			, 0.032	, ...
						'lp_cutoff'			, 70	, ...
						'rate'				, []	, ...
						'cores'				, 1		, ...
						'force'				, true	, ...
						'silent'			, false	  ...
						);
	
	opt.channel		= ForceCell(opt.channel);
	opt.reference	= ForceCell(opt.reference);
	
	[cPathEEG,opt.output,bNoCell,dummy]	= ForceCell(cPathEEG,opt.output);
	[cPathEEG,cPathOut]					= FillSingletonArrays(cPathEEG,opt.output);
	
	%default output file paths
		cPathOut	= cellfun(@(fi,fo) unless(fo,PathAddSuffix(fi,'-pp','nii.gz')),cPathEEG,cPathOut);

%determine which files need to be processed
	sz	= size(cPathEEG);
	n	= numel(cPathEEG);
	
	if opt.force
		bDo	= true(sz);
	else
		bDo	= ~FileExists(cPathOut);
	end

%load existing headers
	hdr			= cell(sz);
	
	hdr(~bDo)	= cellfun(@EEG.ReadHeader,cPathOut(~bDo),'uni',false);

%preprocess the new files
	if any(bDo(:))
		hdr(bDo)	= MultiTask(@PreprocessOne,{cPathEEG(bDo) cPathOut(bDo) opt},...
						'description'	, 'preprocessing EEG data'	, ...
						'cores'			, opt.cores					, ...
						'silent'		, opt.silent				  ...
						);
	end

%uncellify
	if bNoCell
		hdr	= hdr{1};
	end

%------------------------------------------------------------------------------%
function hdr = PreprocessOne(strPathEEG,strPathOut,opt) 
	strFile	= PathGetFileName(strPathEEG);
	
	%read the header
		[hdr,fid]	= EEG.ReadHeader(strPathEEG);
		
		rate	= hdrRaw.rate;
		nSample	= hdrRaw.samples;
		
		assert(hdr.channels.data>0,'%s has no data channels.',strPathEEG);
	
	%keep a record of the preprocessing options
		hdr.preprocess.opt		= opt;
		hdr.preprocess.input	= strPathEEG;
		hdr.path				= strPathOut;
	
	%read the reference data
		bReference	= ~isempty(opt.reference);
		if bReference
			status('reading reference channels','silent',opt.silent);
			
			%read the reference channels
				eegRef	= EEGRead(strPathEEG,...
							'channel'	, opt.reference	, ...
							'status'	, false			, ...
							'fid'		, fid			, ...
							'hdr'		, hdr			, ...
							'silent'	, true			  ...
							);
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

%------------------------------------------------------------------------------%
