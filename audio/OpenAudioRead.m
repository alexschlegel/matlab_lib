function [fid,ifo] = OpenAudioRead(strPathAudio)
% OpenAudioRead
% 
% Description:	open an audio file for reading and return information about it.
% 
% Syntax:	[fid,ifo] = OpenAudioRead(strPathAudio)
% 
% In:
% 	strPathAudio	- path to an audio file
% 
% Out:
% 	fid	- the file identifier for the file stream
%	ifo	- an info struct about the file
% 
% Updated:	2012-09-13
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent C

if isempty(C)
	%constants
		%compression codes
			C.COMPRESSION.Unknown			= struct('code',0,		'description','Unknown');
			C.COMPRESSION.PCM				= struct('code',1,		'description','PCM/uncompressed');
			C.COMPRESSION.MSADPCM			= struct('code',2,		'description','Microsoft ADPCM');
			C.COMPRESSION.ITUG771alaw		= struct('code',6,		'description','ITU G.711 a-law');
			C.COMPRESSION.ITUG771Amulaw	= struct('code',7,		'description','ITU G.711 µ-law');
			C.COMPRESSION.IMAADPCM			= struct('code',17,		'description','IMA ADPCM');
			C.COMPRESSION.ITUG723ADPCM		= struct('code',20,		'description','ITU G.723 ADPCM (Yamaha)');
			C.COMPRESSION.GSM610			= struct('code',49,		'description','GSM 6.10');
			C.COMPRESSION.ITUG721ADPCM		= struct('code',64,		'description','ITU G.721 ADPCM');
			C.COMPRESSION.MPEG				= struct('code',80,		'description','MPEG');
			C.COMPRESSION.Experimental		= struct('code',65536,	'description','Experimental');
end

%open the file
	fid	= fopen(strPathAudio,'r');
	
%get the file header info
	%chunk ID
		idChunk	= fread(fid,4,'*char')';
		if ~isequal(idChunk,'RIFF')
			GetAudioError(['Expected file type "RIFF", got "' idChunk '".'],fid);
		end
	%chunk data size
		sChunk	= fread(fid,1,'uint32');
	%RIFF type
		ifo.riffType	= fread(fid,4,'*char')';
		if ~isequal(ifo.riffType,'WAVE')
			GetAudioError(['Expected RIFF type "WAVE", got "' ifo.riffType '".'],fid);
		end
%get the fmt chunk
	%chunk ID
		idChunk	= fread(fid,4,'*char')';
		if ~isequal(idChunk,'fmt ')
			GetAudioError(['"' idChunk '" chunk found before "fmt " chunk. This function requires that the format chunk occur first.'],fid);
		end
	%chunk size
		sChunk	= fread(fid,1,'uint32');
	%compression code
		vCompression	= fread(fid,1,'uint16');
		strCompression	= FindStruct(C.COMPRESSION,'code',vCompression);
		strCompression	= strCompression{1};
		if ~isequal(strCompression,'PCM')
			strDescription	= C.COMPRESSION.(strCompression).description;
			GetAudioError(['This function only supports uncompressed PCM WAV files.  The specified file is "' strDescription '".'],fid);
		else
			ifo.compression	= C.COMPRESSION.(strCompression);
		end
	%number of channels
		ifo.nChannel	= fread(fid,1,'uint16');
	%sample rate
		ifo.rate		= fread(fid,1,'uint32');
	%average bytes per second
		ifo.bps			= fread(fid,1,'uint32');
	%block align
		ifo.blockAlign	= fread(fid,1,'uint16');
	%significant bits per sample
		ifo.nBit		= fread(fid,1,'uint16');
	%extra format bytes
		if ~isequal(strCompression,'PCM')
			nExtra			= fread(fid,1,'uint16')
			%read the extra formatting data
				ifo.fmtExtra	= fread(fid,nExtra,'*char')';
			%read another byte if the extra formatting info wasn't word-aligned
				if ~iseven(nExtra)
					fread(fid,1,'uint8');
				end
		end
%get the info about the data chunk
	%chunk ID
		idChunk	= fread(fid,4,'*char')';
		if ~isequal(idChunk,'data')
			GetAudioError(['"' idChunk '" chunk found before "data" chunk. This function requires that the data chunk occur first.'],fid);
		end
	%data size
		nData		= fread(fid,1,'uint32');
		ifo.nSample	= nData/ifo.blockAlign;
	%get the position at the start of the data chunk
		ifo.kDataStart	= ftell(fid);
		
%calculate some extra info
	ifo.dur	= ifo.nSample ./ ifo.rate;

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
