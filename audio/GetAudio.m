function [wav,ifo,fid] = GetAudio(varargin)
% GetAudio
% 
% Description:	get audio samples from a sound file
% 
% Syntax:	[wav,ifo,fid] = GetAudio([strPathAudio],<options>)
% 
% In:
% 	[strPathAudio]	- path to the audio file (currently only WAV files are
%					  supported).  must be specified if 'fid' option isn't
%	<options>:
%		'fid':		(<open>) specify if the file is already open
%		'ifo':		(<none>) if fid is specified, also pass the ifo returned by
%					the previous call to GetAudio or OpenAudio
%		'close':	(true) set to true to close the file after reading, false
%					to leave it open and return the fid.
%		'channel':	('both') 'left' for the left channel, 'right' for the right
%					channel, and 'both' for both channels.  If the file is mono
%					that channel is returned regardless of this value
%		'offset':	(0) start reading from the offset+1-th sample
%		'step':		(1) read every step-th sample
%		'block':	(1) the function will read this many samples centered on
%					each sample index it lands on (biased toward the end of data
%					if the value is even).  if a block reaches beyond the edge
%					of the data then the corresponding entries in wav are set to
%					NaN (or 0 if ifo.nBit==8).
%		'ksample':	(<all>) an array of indices of the samples to return.
%					specifying this value overrides offset/step values
% 
% Out:
% 	wav	- the sample. size is nSample x nChannel if the 'block' option is 1,
%		  nPerBlock x nBlock x nChannel otherwise
%	ifo	- an info struct about the WAV file and data
%	fid	- the file identifier of the file if <options>.close==false, 0
%		  otherwise.
% 
% Updated:	2009-02-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%optional arguments
	[strPathAudio,opt]	= ParseArgsOpt(varargin,[],			  ...
										'fid',		[]		, ...
										'ifo',		[]		, ...
										'close',	true	, ...
										'channel',	'both'	, ...
										'offset',	0		, ...
										'step',		1		, ...
										'block',	1		, ...
										'ksample',	[]		...
									  );

%open the file
	if isempty(opt.fid)
		[fid,ifo]	= OpenAudioRead(strPathAudio);
	else
		fid	= opt.fid;
		ifo	= opt.ifo;
	end
%fill in optional arguments
	if ifo.nChannel==1
		kChannel	= 1;
		opt.channel	= 'mono';
	else
		switch lower(opt.channel)
			case 'left'
				kChannel	= 1;
			case 'right'
				kChannel	= 2;
			case 'both'
				kChannel	= [1 2];
			otherwise
				error(['"' opt.channel '" is not a valid channel specification.']);
		end
		ifo.channel	= opt.channel;
	end
	nChannel	= numel(kChannel);
%read the data
	if ~isempty(opt.ksample)
		%number of samples to read
			nRead	= numel(opt.ksample);
		
		%initialize the data array
			switch ifo.nBit
				case 8
					strDataType	= 'uint8=>uint8';
					wav			= zeros(nRead,nChannel,'uint8');
					dataMult	= 1;
					seekMult	= 1;
				otherwise
					strDataType	= ['bit' num2str(ifo.nBit)];
					wav			= zeros(nRead,nChannel);
					dataMult	= 1/2^(ifo.nBit-1);
					seekMult	= ifo.nBit*nChannel;
			end
		%offset info
			nChannelOffset	= kChannel(1)-1;
			kDataStart		= ifo.kDataStart;
			kOffset			= kDataStart + nChannelOffset*ifo.blockAlign/ifo.nChannel;
		
		%read each sample
			pFact	= 100;
			progress(nRead/pFact,'label','Sample','ptotal',ifo.nSample,'pstart',opt.ksample(1),'pend',opt.ksample(end));
			for kS=1:nRead
				kSample	= opt.ksample(kS);
				
				%seek to the sample
					kSeek	= (kSample-1)*ifo.blockAlign + kOffset;
					if fseek(fid,kSeek,-1)
						GetAudioError(['Error occured while seeking to sample ' num2str(kSample) '.']);
					end
				
				%git it!
					wav(kS,1:nChannel)	= fread(fid,nChannel,strDataType);
					
				kTest	= kS/pFact;
				if kTest==floor(kTest)
					progress(kSample);
				end
			end
	else
		%index info
			%user + channel offset bytes
				nByteOffset		= opt.offset*ifo.blockAlign;
			%number of samples forward to step for each block center
				nStep			= opt.step;
			%number of samples in each block
				nSamplePerBlock	= round(opt.block);
			%number of data points in each block
				nDataPerBlock	= nSamplePerBlock*ifo.nChannel;
			%number of blocks is the number of block centers that can fit in
			%the subset of data we're reading from
				nBlock			= ceil((ifo.nSample - opt.offset)/nStep);
			%number of samples to read
				nSample			= nBlock*nSamplePerBlock;
			%number of data points to read
				nData			= nBlock*nDataPerBlock;
			%number of samples to skip between each block
				nSampleSkip		= nStep - nSamplePerBlock;
			
			%number of samples before the sample center
				nSampleBefore	= floor((nSamplePerBlock-1)/2);
			%byte to start reading from
				kStart			= ifo.kDataStart + nByteOffset - nSampleBefore*ifo.blockAlign;
			
			
		%initialize the data array
			switch ifo.nBit
				case 8
					strTypeVar	= 'uint8';
					strTypeRead	= [num2str(nDataPerBlock) '*uint8=>uint8'];
					nSkip		= nSampleSkip*ifo.blockAlign;
					dataMult	= 1;
					wav			= zeros(ifo.nChannel,nSample,strTypeVar);
				otherwise
					strTypeVar	= 'double';
					strTypeRead	= [num2str(nDataPerBlock) '*bit' num2str(ifo.nBit)];
					nSkip		= nSampleSkip*ifo.blockAlign*8;
					dataMult	= 1/2^(ifo.nBit-1);
					wav			= NaN(ifo.nChannel,nSample,strTypeVar);
			end
			
		%seek to the start of the data
			fseek(fid,kStart,-1);
		%get every ifo.step-th sample
			d	= fread(fid,nData,strTypeRead,nSkip);
			
			%with a large step fread is returning an Nx2 array, what?
				d	= d(:,1);
		%make sure we're not getting any pre-sound file data
			nPreData		= (ifo.kDataStart-kStart)/ifo.blockAlign*ifo.nChannel;
			d(1:nPreData)	= NaN;
		%insert it
			wav(1:numel(d))	= d;
		%reshape to nSamplePerBlock x nBlock x nChannel
			%make (nSamplePerBlock * nBlock) x nChannel
				wav	= wav';
			%make (nSamplePerBlock * nBlock * nChannel) x 1
				wav	= reshape(wav,[],1);
			%make nSamplePerBlock x nBlock x nChannel
				wav	= reshape(wav,nSamplePerBlock,nBlock,ifo.nChannel);
			%only return the channel we want
				wav	= wav(:,:,kChannel);
			%squeeze in case nBlock==1
				wav	= squeeze(wav);
	end
	
%scale the data
	wav	= wav*dataMult;

%close the file
	if opt.close
		fclose(fid);
		fid	= 0;
	end

%------------------------------------------------------------------------------%
function GetAudioError(str,varargin)
	fid	= ParseArgs(varargin,[]);
	
	%first close the file
		if ~isempty(fid)
			fclose(fid);
		end
	%now raise an error
		error(str);
%------------------------------------------------------------------------------%
