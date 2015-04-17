function [hdr,fid] = ReadHeader(strPathEEG,varargin)
% EEG.ReadHeader
% 
% Description:	read an EEG file header
% 
% Syntax:	[hdr,[fid]] = EEG.ReadHeader(strPathEEG,<options>)
% 
% In:
% 	strPathEEG	- the path to an EEG file
%	<options>:
%		fid:	([]) the fid if the file is already open
% 
% Out:
% 	hdr	- a header struct with (at least) the following fields:
%		id:				file type identifier
%		subject:		subject description
%		recording:		recording description
%		time:			time of the recording
%		version:		file version
%		records:		number of records in the file
%		channel.status:	if status channels exist, a struct of status channel
%						info with the following fields:
%			label:			channel labels
%			transducer:		channel transducer types
%			unit:			units of physical data
%			prefilter:		prefiltering descriptions
%			rate:			sampling rates of the data
%			samples:		number of samples in each data record
%			range_digital:	min/max of values stored in file
%			range_physical:	min/max of physical values
%			index:			the indices of the channels in the file data
%		channel.data:	a struct of data channel info with the same fields as
%						the status struct
%	fid	- the data file's FID. if this output or the <fid> option is specified,
%		  the data file is left open.
% 
% Updated: 2015-04-10
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'fid'		, []	  ...
			);
	
	bOpen	= isempty(opt.fid);
	bClose	= bOpen && nargout<2;

%read the header
	strExt	= lower(PathGetExt(strPathEEG));
	
	switch lower(strExt)
		case {'nii','nii.gz'}
			[hdr,fid]	= ReadHeader_NIfTI;
		case 'bdf'
			[hdr,fid]	= ReadHeader_BDF;
		otherwise
			error('unsupported file type.');
	end

%keep track of the original version of the header
	if ~isfield(hdr,'orig')
		hdr.orig	= hdr;
	end

%close the file?
	if bClose && ~isempty(fid)
		fclose(fid);
	end

%------------------------------------------------------------------------------%
function [hdr,fid] = ReadHeader_NIfTI()
	strPathHeader	= PathAddSuffix(strPathEEG,'','hdr');
	hdr				= load(strPathHeader,'-mat');
	
	fid	= [];
end
%------------------------------------------------------------------------------%
function [hdr,fid] = ReadHeader_BDF()
	hdr	= struct;
	
	%input path
		hdr.path	= strPathEEG;
	
	%open the file
		if bOpen
			fid	= fopen(strPathEEG,'r');
		else
			fid	= opt.fid;
		end
		
		%seek to the start of the file
			fseek(fid,0,'bof');
	
	%file type identifier
		hdr.id			= ReadNext(fid,8,false,1);
	%subject description
		hdr.subject		= ReadNext(fid,80,false,1);
	%recording description
		hdr.recording	= ReadNext(fid,80,false,1);
	%time of recording
		strDate		= ReadNext(fid,8,false,1);
		strTime		= ReadNext(fid,8,false,1);
		hdr.time	= FormatTime(sprintf('%s.%s',strDate,strTime),'dd.mm.yy.HH.MM.SS');
	%we don't need to know how many bytes are in the header
		s	= fseek(fid,8,'cof');
	%file version
		hdr.version	= ReadNext(fid,44,false,1);
	%number of records, time per record
		hdr.records	= ReadNext(fid,8,true,1);
		tPerRecord	= ReadNext(fid,8,true,1);
	%number of channels
		nChannel	= ReadNext(fid,4,true,1);
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
		
		assert(uniform(nSample),'only implemented for files in which all channels have the same sampling rate.');
		
		cRate			= num2cell(nSample./tPerRecord);
		cRangePhysical	= mat2cell([dimPhysicalMin dimPhysicalMax],ones(nChannel,1),2);
		cRangeDigital	= mat2cell([dimDigitalMin dimDigitalMax],ones(nChannel,1),2);
		
		hdr.samples		= nSample(1)*hdr.records;
		hdr.rate		= cRate{1};
		
		nSample	= num2cell(nSample);
		
		cIndex	= num2cell(reshape(1:nChannel,[],1));
		
		sChannel	= struct(...
						'label'				, cLabel			, ...
						'transducer'		, cTransducer		, ...
						'unit'				, cUnit				, ...
						'prefilter'			, cPrefilter		, ...
						'rate'				, cRate				, ...
						'samples'			, nSample			, ...
						'range_digital'		, cRangeDigital		, ...
						'range_physical'	, cRangePhysical	, ...
						'index'				, cIndex			  ...
						);
	%reserved end of header
		hdr.reserved	= ReadNext(fid,nChannel*32,false,1);
		hdr.length		= ftell(fid);
	%classify the channels
		bStatus				= strcmp(cellfun(@lower,{sChannel.label},'uni',false),'status');
		hdr.channel.status	= restruct(sChannel(bStatus));
		
		bData				= ~bStatus;
		hdr.channel.data	= restruct(sChannel(bData));
	%get the data type
		if all(dimDigitalMin==-8388608) && all(dimDigitalMax==8388607)
			hdr.datatype	= 'int24';
		else
			hdr.datatype	= 'unknown';
		end
	
	%--------------------------------------------------------------------------%
	function x = ReadNext(fid,nBytes,bIsNumber,nRep)
		x	= reshape(fread(fid,nBytes*nRep,'char=>char'),nBytes,nRep)';
		
		if nRep>1
			x	= cellstr(x);
		end
		
		if bIsNumber
			x	= cellfun(@str2num,ForceCell(x));
		else
			x	= cellfun(@StringTrim,ForceCell(x),'uni',false);
			
			if nRep==1
				x	= x{1};
			end
		end
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%

end