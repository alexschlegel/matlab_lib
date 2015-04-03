function [hdr,fid] = EEGReadHeader(strPathEEG,varargin)
% EEGReadHeader
% 
% Description:	read an EEG file header.  only supports BDF file format.
% 
% Syntax:	[hdr,fid] = EEGReadHeader(strPathEEG,<options>) OR
% 
% In:
% 	strPathEEG	- the path to the EEG file
%	<options>:
%		fid:		([]) the fid if the file is already open
%		close:		(<true if no fid was specified>) true to close the file
%					before returning
%		silent:		(true) true to suppress status output
% 
% Out:
% 	hdr	- a header struct with the following fields:
%		id:				file type identifier
%		subject:		subject description
%		recording:		recording description
%		time:			time of the recording
%		version:		file version
%		nrecord:		number of records in the file
%		channel.status:	an array of structs of status channel info with the
%						following fields:
%			label:			channel label
%			transducer:		channel transducer type
%			unit:			unit of physical data
%			prefilter:		prefiltering description
%			rate:			sampling rate of the data
%			nsample:		number of samples in each data record
%			range_digital:	min/max of values stored in file
%			range_physical:	min/max of physical values
%			k:				the index of the channel in the file data
%		channel.data:	an array of structs of data channel info with the same
%						fields as the status structs
%	fid	- a handle to the file if it was left open
% 
% Updated: 2012-02-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'fid'		, []	, ...
		'close'		, []	, ...
		'silent'	, true	  ...
		);
bOpen	= isempty(opt.fid);
if isempty(opt.close)
	opt.close	= bOpen;
end

status('reading header information','silent',opt.silent);

strExt	= lower(PathGetExt(strPathEEG));

switch lower(strExt)
	case {'dat','hdr'}
		EEGReadHeader_Preprocessed;
		
		fid	= [];
	otherwise
		%open the file
			if bOpen
				fid	= fopen(strPathEEG,'r');
			else
				fid	= opt.fid;
			end
		%seek to the start of the file
			fseek(fid,0,'bof');

		switch strExt
			case 'bdf'
				EEGReadHeader_BDF;
			otherwise
				error('Unsupported file type.');
		end
		
		%close the file
			if opt.close
				fclose(fid);
			end
end

%------------------------------------------------------------------------------%
function EEGReadHeader_Preprocessed()
% read a preprocessed EEG file
	strPathHeader	= PathAddSuffix(strPathEEG,'','hdr');
	
	hdr	= load(strPathHeader,'-mat');
end
%------------------------------------------------------------------------------%
function EEGReadHeader_BDF()
% read a BDF file header
	%file type identifier
		hdr.id			= ReadNext(fid,8);
	%subject description
		hdr.subject		= ReadNext(fid,80);
	%recording description
		hdr.recording	= ReadNext(fid,80);
	%time of recording
		strDate		= ReadNext(fid,8);
		strTime		= ReadNext(fid,8);
		hdr.time	= FormatTime(FormatTime([strDate '.' strTime],'dd.mm.yy.HH.MM.SS'));
	%we don't need to know how many bytes are in the header
		s	= fseek(fid,8,'cof');
	%file version
		hdr.version	= ReadNext(fid,44);
	%number of records, time per record
		hdr.nrecord	= ReadNext(fid,8,true);
		tPerRecord	= ReadNext(fid,8,true);
	%number of channels
		nChannel	= ReadNext(fid,4,true);
	%channel-specific info
		cLabel			= ReadNext(fid,16,false,nChannel);
		cTransducer		= ReadNext(fid,80,false,nChannel);
		cUnit			= ReadNext(fid,8,false,nChannel);
		dimPhysicalMin	= ReadNext(fid,8,true,nChannel);
		dimPhysicalMax	= ReadNext(fid,8,true,nChannel);
		dimDigitalMin	= ReadNext(fid,8,true,nChannel);
		dimDigitalMax	= ReadNext(fid,8,true,nChannel);
		cPrefilter		= ReadNext(fid,80,false,nChannel);
		nSample			= ReadNext(fid,8,true,nChannel);
		
		if any(nSample~=nSample(1))
			error('This function is only implemented for files in which all channels have the same sampling rate.');
		end
		
		hdr.nsample	= nSample(1)*hdr.nrecord;
		
		cRate			= num2cell(nSample./tPerRecord);
		cRangePhysical	= mat2cell([dimPhysicalMin dimPhysicalMax],ones(nChannel,1),2);
		cRangeDigital	= mat2cell([dimDigitalMin dimDigitalMax],ones(nChannel,1),2);
		
		nSample	= mat2cell(nSample,ones(nChannel,1),1);
		
		sChannel	= struct('label',cLabel,'transducer',cTransducer,'unit',cUnit,'prefilter',cPrefilter,'rate',cRate,'nsample',nSample,'range_digital',cRangeDigital,'range_physical',cRangePhysical);
	%reserved end of header
		hdr.reserved	= ReadNext(fid,nChannel*32);
		hdr.length		= ftell(fid);
	%classify the channels
		kChannelStatus			= find(cellfun(@(x) isequal(lower(x),'status'),{sChannel.label}));
		hdr.channel.status		= sChannel(kChannelStatus);
		cKChannelStatus			= num2cell(kChannelStatus);
		[hdr.channel.status.k]	= deal(cKChannelStatus{:});
		
		kChannelData			= setdiff(1:nChannel,kChannelStatus);
		hdr.channel.data		= sChannel(kChannelData);
		cKChannelData			= num2cell(kChannelData);
		[hdr.channel.data.k]	= deal(cKChannelData{:});
	%get the data type
		if all(dimDigitalMin==-8388608) && all(dimDigitalMax==8388607)
			hdr.datatype	= 'int24';
		else
			hdr.datatype	= 'unknown';
		end
end
%------------------------------------------------------------------------------%
function x = ReadNext(fid,n,varargin)
% x = ReadNext(fid,nBytes,[bNum]=false,[nRep]=1)
% read the next bit from the header
	[bNum,nRep]	= ParseArgs(varargin,false,1);
	
	x	= reshape(fread(fid,n*nRep,'char=>char'),n,nRep)';
	
	if nRep>1
		x	= cellstr(x);
	end
	
	if bNum
		if nRep>1
			x	= cellfun(@str2num,x);
		else
			x	= str2num(x);
		end
	else
		if nRep>1
			x	= cellfun(@StringTrim,x,'UniformOutput',false);
		else
			x	= StringTrim(x);
		end
	end
end
%------------------------------------------------------------------------------%

end