function eeg = Read(strPathEEG,varargin)
% EEG.Read
% 
% Description:	read data from an EEG file
% 
% Syntax:	eeg = EEG.Read(strPathEEG,<options>)
% 
% In:
% 	strPathEEG	- the path to an EEG file, or an EEG header struct read with
%				  EEG.ReadHeader
%	<options>:
%		channel:	(<all>) a cell of data channel names to read. set to false
%					to skip reading data channels.
%		status:		(true) true to read the status channel (if raw data are
%					being read)
%		sample:		(<all>) the samples to read
%		load:		(false) for NIfTI data, true to load the data, false to use
%					a file_array
%		fid:		(<open>) the fid of the file if it is already open
% 
% Out:
% 	eeg	- a struct containing the data and header information:
%			.hdr:		the header information
%			.status:	an nChannelStatus x (sample size) array of status
%						data (only if <status>==true)
%			.data:		an nChannelData x (sample size) array of the electrode
%						data
%
% Updated: 2015-05-11
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%process the inputs
	opt	= ParseArgs(varargin,...
			'channel'		, {}	, ...
			'status'		, true	, ...
			'sample'		, []	, ...
			'load'			, false	, ...
			'fid'			, []	  ...
			);
	
	if notfalse(opt.channel)
		opt.channel	= ForceCell(opt.channel);
	end

%read the header
	if isstruct(strPathEEG)
		eeg.hdr	= strPathEEG;
		fid		= opt.fid;
	else
		[eeg.hdr,fid]	= EEG.ReadHeader(strPathEEG,'fid',opt.fid);
	end
	
	bOpen	= isempty(fid);

%process the channels
	if ~isempty(opt.channel)
		if isequal(opt.channel,false)
			[bChannel,kChannel]	= deal([]);
		else
			opt.channel	= reshape(opt.channel,[],1);
			
			[bChannel,kChannel]	= ismember(opt.channel,eeg.hdr.channel.data.label);
		end
		
		assert(all(bChannel),'the following channels are not valid: %s',join(opt.channel(~bChannel),','));
		
		eeg.hdr.channel.data	= restruct(eeg.hdr.channel.data);
		eeg.hdr.channel.data	= eeg.hdr.channel.data(kChannel);
		eeg.hdr.channel.data	= restruct(eeg.hdr.channel.data,'array',true);
	end
	
	kChannelRead	= eeg.hdr.channel.data.index;
	nChannelRead	= numel(kChannelRead);

%process the samples
	if ~isempty(opt.sample)
		szSampleRead	= size(opt.sample);
		
		if numel(szSampleRead)==2 && szSampleRead(1)==1
			opt.sample		= opt.sample';
			szSampleRead	= szSampleRead(end:-1:1);
		end
		
		if isfield(eeg.hdr,'sample')
			eeg.hdr.sample	= eeg.hdr.sample(opt.sample);
		else
			eeg.hdr.sample	= cast(opt.sample,'uint32');
		end
		
		kSampleRead		= double(reshape(eeg.hdr.sample,[],1));
	else
		kSampleRead		= reshape(1:eeg.hdr.samples,[],1);
		szSampleRead	= [eeg.hdr.samples 1];
	end
	
	nSampleRead	= numel(kSampleRead);

%read the data
	strExt	= lower(PathGetExt(eeg.hdr.path));
	
	switch lower(strExt)
		case {'nii','nii.gz'}
			ReadData_NIfTI;
		case 'bdf'
			ReadData_BDF;
		otherwise
			error('unsupported file type.');
	end

%close the file?
	if bOpen
		fclose(fid);
	end

%reshape the output data
	if isfield(eeg,'data')
		eeg.data	= reshape(eeg.data,[nChannelRead szSampleRead]);
	end
	
	if isfield(eeg,'status')
		eeg.status	= reshape(eeg.status,[size(eeg.status,1) szSampleRead]);
	end
	
	eeg.hdr.samples	= numel(kSampleRead);

%------------------------------------------------------------------------------%
function ReadData_NIfTI()
	eeg.data	= NIfTI.Read(strPathEEG,...
					'load'		, opt.load	, ...
					'return'	, 'data'	  ...
					);
end
%------------------------------------------------------------------------------%
function ReadData_BDF()
	%open the file?
		if bOpen
			fid	= fopen(eeg.hdr.path,'r');
		end
		
	%parse samples/records
		nSamplePerRecord	= eeg.hdr.samples/eeg.hdr.records;
		
		kRecord			= floor((kSampleRead-1)/nSamplePerRecord)+1;
		kSampleInRecord	= kSampleRead - nSamplePerRecord*(kRecord-1);
		
		[kRecordU,kToU,kFromU]	= unique(kRecord);
		nRecordU				= numel(kRecordU);
		
		clear kToU kRecord;
	%parse other stuff
		kChannelData	= eeg.hdr.orig.channel.data.index;
		kChannelStatus	= eeg.hdr.orig.channel.status.index;
		nChannelTotal	= numel(kChannelStatus)+numel(kChannelData);
		
		nBitPerSample		= 24;
		nBytePerSample		= nBitPerSample/8;
		
		nSampleTotalPerRecord	= nSamplePerRecord*nChannelTotal;
		
		if opt.status
			kChannelReadAll	= [kChannelRead; kChannelStatus];
		else
			kChannelReadAll	= kChannelRead;
		end
		
		nChannelReadAll	= numel(kChannelReadAll);
	
	%error check
		assert(all(kRecordU>=1 & kRecordU<=eeg.hdr.records),'specified records are outside the valid range.');
		assert(strcmp(eeg.hdr.datatype,'int24'),'unsupported data type.');
	
	%initialize the full data
		d	= zeros(nSamplePerRecord,nChannelReadAll,nRecordU,'single');
	%get the contiguous blocks of records
		[cRecord,cKRecord]	= GroupContiguous(kRecordU);
		nGroupRecord		= numel(cRecord);
	%get the contiguous blocks of channels
		[cChannel,cKChannel]	= GroupContiguous(kChannelReadAll);
		nGroupChannel			= numel(cChannel);
	%seek to the start of the data
		kDataStart	= eeg.hdr.length;
		fseek(fid,kDataStart,'bof');
	
	%read data by record then channel
		for kGR=1:nGroupRecord
			kOffsetRecord	= (cRecord{kGR}(1)-1)*nSampleTotalPerRecord;
			nRecordCur		= numel(cRecord{kGR});
			
			for kGC=1:nGroupChannel
				if numel(cChannel{kGC})>0
					kChannelStart	= cChannel{kGC}(1);
				else
					kChannelStart	= 1;
				end
				kOffsetChannel	= (kChannelStart-1)*nSamplePerRecord;
				nChannelCur		= numel(cChannel{kGC});
				
				%seek to the start of the data for the current channel group
					kFile	= kDataStart + nBytePerSample*(kOffsetRecord + kOffsetChannel);
					
					fseek(fid,kFile,'bof');
				%read the data as a group of channels through the records
					if nChannelCur>0
						nSamplePerRecordCur	= nChannelCur*nSamplePerRecord;
						nSampleTotalCur		= nRecordCur*nSamplePerRecordCur;
						
						nChannelSkipCur	= nChannelTotal - nChannelCur;
						nSampleSkipCur	= nChannelSkipCur*nSamplePerRecord;
						nBitSkip		= nSampleSkipCur*nBitPerSample;
						
						strPrecision	= sprintf('%d*bit%d=>real*4',nSamplePerRecordCur,nBitPerSample);
						dCur			= fread(fid,nSampleTotalCur,strPrecision,nBitSkip);
						
						d(:,cKChannel{kGC},cKRecord{kGR})	= reshape(dCur,nSamplePerRecord,nChannelCur,nRecordCur);
					end
			end 
		end
		
		clear dCur;
	
	if nChannelReadAll>0
		%reshape to channels x samples
			d	= permute(d,[2 1 3]);
			d	= reshape(d,nChannelReadAll,[]);
		%keep only the samples we're interested in
			kSample	= nSamplePerRecord*(kFromU-1)+reshape(kSampleInRecord,[],1);
			d		= d(:,kSample);
		%split into data and status samples
			bChannelData	= ismember(kChannelReadAll,kChannelData);
			bChannelStatus	= ismember(kChannelReadAll,kChannelStatus);
			
			if any(bChannelData)
				eeg.data	= d(bChannelData,:);
			end
			
			if any(bChannelStatus)
				eeg.status	= d(bChannelStatus,:);
				
				%fix the status values (the BDF file actually stores them as unsigned)
					eeg.status	= uint32(eeg.status + 2.^(nBitPerSample-1));
			end
			
			clear d;
	end
	
	%convert data to physical units
		if isfield(eeg,'data')
			%get the sets of channels that have the same mapping
				rngDigital	= cat(1,eeg.hdr.channel.data.range_digital{:});
				rngPhysical	= cat(1,eeg.hdr.channel.data.range_physical{:});
				
				m					= [rngDigital rngPhysical];
				[mSet,kSet,kInSet]	= unique(m,'rows');
				nSet				= numel(kSet);
			%map each set
				for kS=1:nSet
					mSetCur	= num2cell(mSet(kS,:));
					bInSet	= kInSet==kS;
					
					eeg.data(bInSet,:)	= MapValue(eeg.data(bInSet,:),mSetCur{:});
				end
		end

end
%------------------------------------------------------------------------------%

end
