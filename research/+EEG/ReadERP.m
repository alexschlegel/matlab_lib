function [eeg,t,fid] = EEGRead(strPathEEG,varargin)
% EEGRead
% 
% Description:	read an EEG file into a struct (only supports BDF files)
% 
% Syntax:	[eeg,t,fid] = EEGRead(strPathEEG,<options>)
% 
% In:
% 	strPathEEG	- the path to the EEG file
%	<options>:
%		channel:		(<all>) the indices of the channels to read, or a cell
%						of indices or labels of channels to read
%		twinbase:		(<none>) the base start time of the windows to read.  if
%						this is specified, the input sample array has size
%						<numel(twinbase)> x <number of samples in window>
%		twinstart:		(0) the start time of each window, relative to the base
%						time, in the same units as the sampling frequency stored
%						in the file header
%		twinend:		(0) the end time of each window, relative to the base
%						time, in the same units as the sampling frequency stored
%						in the file header
%		sample:			(<all>) the samples to read
%		reference:		(<none>) specify channels to use as a reference
%		event_type:		('number') one of the following to specify how events
%						should be processed:
%							'number'	- the Status channel is treated as
%										  numbers
%							'bit'		- the Status channel is treated as a set
%										  of bits that are individually set
%							'none'			- don't process events
%		event_bits:		(<all>) the bits to consider when processing events (1
%						indicates the low bit)
%		rate:			(<unchanged>) the sampling rate of the output.  assumes
%						data are organized as nSignal x ... x nSample
%		fid:			(<open>) the fid if the file is already open
%		hdr:			(<none>) a header struct if one has already been read
%						for the specified file
%		close:			(<true if no fid was specified>) true to close the file
%						before returning
%		silent:			(false) true to suppress status output
% 
% Out:
% 	eeg	- a struct containing the data and header information:
%			.hdr:		the header information
%			.status:	an nChannelStatus x (size of sample) array of status
%						data (only if unpreprocessed data were read)
%			.data:		an nChannelData x (size of sample) array of the
%						electrode data
%			.event:		a struct of event info
%	t	- an array of the time represented by each data sample, in seconds.  if
%		  window periods are specified through twinbase/twinstart/twinend, then
%		  t is a 1 x <number of sample in window> array of the time within each
%		  window, relative to twinbase.
%	fid	- the fid of the file if it was left open
%
% Assumptions:	assumes data are stored as signed 24-bit integers
% 
% Notes:	only implemented for files in which all channels have the same
%			sampling rate.
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
t	= [];

opt	= ParseArgs(varargin,...
		'channel'		, []		, ...
		'twinbase'		, []		, ...
		'twinstart'		, 0			, ...
		'twinend'		, 0			, ...
		'sample'		, []		, ...
		'reference'		, []		, ...
		'event_type'	, 'number'	, ...
		'event_bits'	, []		, ...
		'rate'			, []		, ...
		'hdr'			, []		, ...
		'fid'			, []		, ...
		'close'			, []		, ...
		'silent'		, false		  ...
		);
%open the file?
	bOpen	= isempty(opt.fid);
%close the file?
	if isempty(opt.close)
		opt.close	= bOpen;
	end

%display a status
	strFile		= PathGetFileName(strPathEEG);
	if ~isempty(opt.channel)
		strChannel	= [' (channels: ' tostring(reshape(opt.channel,1,[])) ')'];
	else
		strChannel	= ' (all channels)';
	end
	
	status(['Reading EEG data from ' strFile strChannel],'silent',opt.silent);

%open the file
	if bOpen
		fid	= fopen(strPathEEG,'r');
	else
		fid	= opt.fid;
	end
%get the header
	if isempty(opt.hdr)
		eeg.hdr	= EEGReadHeader(strPathEEG,'fid',fid,'silent',opt.silent);
	else
		eeg.hdr	= opt.hdr;
	end
	
	if isfield(eeg.hdr,'event')
		eeg.event	= eeg.hdr.event;
	end
	
	kChannel	= reshape([[eeg.hdr.channel.data.k] [eeg.hdr.channel.status.k]],[],1);
	nChannel	= numel(kChannel);
	
	fs	= [[eeg.hdr.channel.data.rate] [eeg.hdr.channel.status.rate]];
	fs	= fs(1);
%get the channels to read
	if isempty(opt.channel)
		opt.channel	= kChannel;
	else
		opt.channel	= EEGChannel2Index(opt.channel,eeg.hdr);
	end
	opt.channel	= reshape(opt.channel,[],1);
	
	if ~isempty(opt.reference)
		opt.reference	= EEGChannel2Index(opt.reference,eeg.hdr);
	end
	opt.reference	= reshape(opt.reference,[],1);
	
	if any(opt.channel==0) || any(opt.reference==0)
		error('Some specified channels were not found in the data.');
	end
	
	kChannelRead	= [opt.channel; opt.reference(~ismember(opt.reference,opt.channel))];
	nChannelRead	= numel(kChannelRead);
%get the samples to read
	if isempty(opt.sample)
		bWin	= ~isempty(opt.twinbase);
		
		if bWin
			[opt.sample,t]	= ExtractWindowIndices([1 eeg.hdr.nsample],opt.twinbase,'start',opt.twinstart,'end',opt.twinend,'rate',fs);
		else
			opt.sample	= 1:eeg.hdr.nsample;
		end
	else
		bWin	= false;
	end
	
	nSampleRead	= numel(opt.sample);
%read based on the file type
	switch lower(PathGetExt(strPathEEG))
		case 'dat'
			status('reading preprocessed data','silent',opt.silent,'noffset',1);
			
			EEGRead_Preprocessed;
		case 'bdf'
			status('reading BioSemi data','silent',opt.silent,'noffset',1);
			
			EEGRead_BDF;
		otherwise
			error('Unsupported file type.');
	end
%close the file
	if opt.close
		fclose(fid);
	end
%only keep the header channels we're reading
	[bChannelData,kChannelData]		= ismember(kChannelRead,[eeg.hdr.channel.data.k]);
	kChannelData						= kChannelData(bChannelData);
	[bChannelStatus,kChannelStatus]	= ismember(kChannelRead,[eeg.hdr.channel.status.k]);
	kChannelStatus						= kChannelStatus(bChannelStatus);
	
	eeg.hdr.channel.data	= eeg.hdr.channel.data(kChannelData);
	eeg.hdr.channel.status	= eeg.hdr.channel.status(kChannelStatus);
%convert data to physical units
	%get the sets of channels that have the same mapping
		rngDigital			= cell2mat({eeg.hdr.channel.data.range_digital}');
		rngPhysical			= cell2mat({eeg.hdr.channel.data.range_physical}');
		m					= [rngDigital rngPhysical];
		[mSet,kSet,kInSet]	= unique(m,'rows');
		nSet				= numel(kSet);
	%map each set
		for kS=1:nSet
			bInSet				= kInSet==kS;
			eeg.data(bInSet,:)	= MapValue(eeg.data(bInSet,:),mSet(kS,1),mSet(kS,2),mSet(kS,3),mSet(kS,4));
		end
%apply the reference
	ApplyReference;
%detect events
	DetectEvents;
%reshape samples to the input size
	sReshape		= num2cell(size(opt.sample));
	if sReshape{1}==1
		sReshape	= sReshape(2:end);
	end
	if isfield(eeg,'data')
		eeg.data	= reshape(eeg.data,[],sReshape{:});
	end
	if isfield(eeg,'status')
		eeg.status	= reshape(eeg.status,[],sReshape{:});
	end
%get the output time array
	if bWin
		t	= reshape(t,1,[]);
	else
		t	= k2t(opt.sample,fs);
	end
%resample if specified
	if ~isempty(opt.rate) & ~isequal(opt.rate,fs)
		status('resampling data','silent',opt.silent,'noffset',1);
		
		[eeg,t]	= EEGResample(eeg,opt.rate,t);
		fs		= opt.rate;
	end

%------------------------------------------------------------------------------%
function EEGRead_Preprocessed()
	nBitPerSample		= 24;
	nBytePerSample		= nBitPerSample/8;
	strNBitPerSample	= num2str(nBitPerSample);
	strPrecision		= ['bit' strNBitPerSample '=>real*4'];
	
	nBytePerChannel	= nBytePerSample*eeg.hdr.nsample;
	
	%initialize the data
		eeg.data	= NaN(nChannelRead,nSampleRead,'single');
	%get the indices of the channels in the preprocessed data file
		[bMember,kChannelReadProc]	= ismember(kChannelRead,[eeg.hdr.channel.data.k]);
	%group into contiguous blocks of samples
		[cSample,cKSample]	= GroupContiguous(opt.sample);
		
		%get rid of the NaN block if it exists
			if numel(cSample)>0 && isnan(cSample{end}(1))
				cSample		= cSample(1:end-1);
				cKSample	= cKSample(1:end-1);
			end
		
		nGroupSample		= numel(cSample);
	%get the samples from each channel for each sample block
		if nChannelRead>0 && nGroupSample>0
			progress('action','init','total',nChannelRead,'label','Reading Channel','silent',opt.silent | nChannelRead<2);
		
			for kC=1:nChannelRead
				nOffsetChannel	= nBytePerChannel*(kChannelReadProc(kC)-1);
				
				for kG=1:nGroupSample
					nSampleCur		= numel(cSample{kG});
					nOffsetSample	= nBytePerSample*(cSample{kG}(1)-1);
					
					kFile	= nOffsetChannel + nOffsetSample;
					fseek(fid,kFile,'bof');
					
					eeg.data(kC,cKSample{kG})	= fread(fid,nSampleCur,strPrecision);
				end
				
				progress;
			end
		end
end
%------------------------------------------------------------------------------%
function EEGRead_BDF()
% read a BioSemi EEG file
	%parse samples/records
		nSamplePerChannelRecord	= eeg.hdr.nsample/eeg.hdr.nrecord;
		kRecord						= floor((opt.sample-1)/nSamplePerChannelRecord)+1;
		kSampleInRecord				= opt.sample - nSamplePerChannelRecord*(kRecord-1);
		[kRecordU,kToU,kFromU]		= unique(kRecord);
		nRecordU					= numel(kRecordU);
		
		clear kToU kRecord;
	%error check
		if any(kRecordU < 1 | kRecordU > eeg.hdr.nrecord)
			error('Specified records are outside the valid range.');
		end
		if ~isequal(eeg.hdr.datatype,'int24')
			error('Unsupported data type');
		end
	
	kChannelDataAll		= [eeg.hdr.channel.data.k];
	kChannelStatusAll	= [eeg.hdr.channel.status.k];
	nChannelTotal		= numel(kChannelStatusAll)+numel(kChannelDataAll);
	
	nBitPerSample		= 24;
	nBytePerSample		= nBitPerSample/8;
	strNBitPerSample	= num2str(nBitPerSample);
	
	nSamplePerRecord		= nSamplePerChannelRecord*nChannelTotal;
	%initialize the full data
		d	= zeros(nSamplePerChannelRecord,nChannelRead,nRecordU,'single');
	%get the contiguous blocks of records
		[cRecord,cKRecord]	= GroupContiguous(kRecordU);
		nGroupRecord		= numel(cRecord);
	%get the contiguous blocks of channels
		[cChannel,cKChannel]	= GroupContiguous(kChannelRead);
		nGroupChannel			= numel(cChannel);
	%seek to the start of the data
		kDataStart	= eeg.hdr.length;
		fseek(fid,kDataStart,'bof');
	
	%read data by record then channel
		for kGR=1:nGroupRecord
			kOffsetRecord	= (cRecord{kGR}(1)-1)*nSamplePerRecord;
			nRecordCur		= numel(cRecord{kGR});
			
			for kGC=1:nGroupChannel
				kOffsetChannel	= (cChannel{kGC}(1)-1)*nSamplePerChannelRecord;
				nChannelCur		= numel(cChannel{kGC});
				
				%seek to the start of the data for the current channel group
					kFile	= kDataStart + nBytePerSample*(kOffsetRecord + kOffsetChannel);
					
					fseek(fid,kFile,'bof');
				%read the data as a group of channels through the records
					nSamplePerRecordCur	= nChannelCur*nSamplePerChannelRecord;
					nSampleTotalCur		= nRecordCur*nSamplePerRecordCur;
					nRep				= num2str(nSamplePerRecordCur);
					
					nChannelSkipCur	= nChannelTotal - nChannelCur;
					nSampleSkipCur	= nChannelSkipCur*nSamplePerChannelRecord;
					nBitSkip		= nSampleSkipCur*nBitPerSample;
					
					dCur								= fread(fid,nSampleTotalCur,[nRep '*bit' strNBitPerSample '=>real*4'],nBitSkip);
					d(:,cKChannel{kGC},cKRecord{kGR})	= reshape(dCur,nSamplePerChannelRecord,nChannelCur,nRecordCur);
					
					clear dCur;
			end 
		end
	%reshape to sample x channels
		d	= permute(d,[2 1 3]);
		d	= reshape(d,nChannelRead,[]);
	%keep only the samples we're interested in
		kSample	= nSamplePerChannelRecord*(kFromU-1)+reshape(kSampleInRecord,[],1);
		d		= d(:,kSample);
	%split into data and status samples
		bChannelData	= ismember(kChannelRead,kChannelDataAll);
		bChannelStatus	= ismember(kChannelRead,kChannelStatusAll);
		
		kChannelData	= kChannelRead(bChannelData);
		kChannelStatus	= kChannelRead(bChannelStatus);
		
		eeg.data	= d(bChannelData,:);
		eeg.status	= d(bChannelStatus,:);
		
		clear d;
	%fix the status values (the BDF file actually stores them as unsigned)
		eeg.status	= uint32(eeg.status + 2.^(nBitPerSample-1));
end
%------------------------------------------------------------------------------%
function ApplyReference()
% apply a reference to the data
	if ~isempty(opt.reference)
		status('applying reference','silent',opt.silent);
		
		%reference channels
			bReference	= ismember([eeg.hdr.channel.data.k],opt.reference);
		%reference channels to delete
			bRefDelete	= bReference & ~ismember([eeg.hdr.channel.data.k],opt.channel);
		%reference average
			dReference	= mean(eeg.data(bReference,:),1);
		%delete the unwanted reference channels
			eeg.data(bRefDelete,:)				= [];
			eeg.hdr.channel.data(bRefDelete)	= [];
		%subtract from the data
			nData		= size(eeg.data,1);
			eeg.data	= eeg.data - repmat(dReference,[nData 1]);
	end
end
%------------------------------------------------------------------------------%
function DetectEvents()
% detect events from the status channels
	if ~isequal(lower(opt.event_type),'none') && size(GetFieldPath(eeg,'status'),1)>0
		status('detecting events','silent',opt.silent);
		
		%error if there's more than one status channel (this probably won't
		%happen and I don't want to have to deal with implementing it)
			if size(eeg.status,1)>1
				error('Event detection is only implemented for data files with one status channel.');
			end
		%eliminate the discarded bits
			s	= eeg.status;
			if ~isempty(opt.event_bits)
				s		= bitkeep(s,opt.event_bits,'compress',true);
			end
		
		eeg.event	= struct('type',[],'start',[],'duration',[]);
		
		switch lower(opt.event_type)
			case 'number'
				DetectEventsByNumber;
			case 'bit'
				DetectEventsByBit;
			otherwise
				error(['"' opt.event_type '" is not a recognized event type.']);
		end
	end
%------------------------------------------------------------------------------%
	function DetectEventsByBit()
		%get the active bits
			sU		= reshape(setdiff(unique(s),0),[],1);
			nU		= numel(sU);
			bitMax	= floor(max(log2(sU)));
			
			bitU	= int2bit(sU,bitMax);
			
			[kStatus,kBit]	= find(bitU);
			kBit			= unique(kBit);
			kType			= bitshift(1,kBit-1);
			nBit			= numel(kBit);
		%get the points when an event starts or ends
			kChange		= reshape(find((s - [0 s(1:end-1)])~=0),[],1);
			sChange		= reshape(s(kChange),[],1);
			bitChange	= int2bit(sChange);
		%determine when each event type started and ended
			for kB=1:nBit
				bDiff	= bitChange(:,kBit(kB)) - [0; bitChange(1:end-1,kBit(kB))];
				kStart	= kChange(find(bDiff==1));
				kEnd	= kChange(find(bDiff==-1))-1;
				if numel(kStart)>numel(kEnd)
					kEnd	= [kEnd; numel(s)];
				end
				nEvent	= numel(kStart);
				
				eeg.event.type		= [eeg.event.type;		repmat(kType(kB),[nEvent 1])];
				eeg.event.start		= [eeg.event.start;		kStart];
				eeg.event.duration	= [eeg.event.duration; 	kEnd-kStart+1];
			end
		%reorder by start time
			[eeg.event.start,kOrder]	= sort(eeg.event.start);
			eeg.event.type				= eeg.event.type(kOrder);
			eeg.event.duration			= eeg.event.duration(kOrder);
	end
%------------------------------------------------------------------------------%
	function DetectEventsByNumber()
		%get the indices in which a status channel changes
			bChange	= reshape(s~=[0 s(1:end-1)],[],1);
			
			kStart	= reshape(find(bChange),[],1);
			kEnd	= [kStart(2:end); numel(s)+1];
			kEvent	= reshape(find(s(kStart)~=0),[],1);
		%classify the events
			eeg.event.type		= reshape(s(kStart(kEvent)),[],1);
			eeg.event.start		= kStart(kEvent);
			eeg.event.duration	= kEnd(kEvent)-kStart(kEvent);
	end
%------------------------------------------------------------------------------%
end

end
