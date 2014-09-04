function [wav,rate,nBit] = ExtractAudio(strPathVideo,varargin)
% ExtractAudio
% 
% Description:	extract the audio as a WAV file from the specified video file
% 
% Syntax:	[wav,rate,nBit] = ExtractAudio(strPathVideo,[strPathOut]=<see below>,[bDeleteFile]=<true if nargout > 0>)
% 
% In:
% 	strPathVideo	- path to the video file
%	[strPathOut]	- the path to which to save the wave file.  if bDeleteFile
%					  is true defaults to a temporary file.  Otherwise defaults
%					  to strPathVideo with extension replaced by "wav".
%	[bDeleteFile]	- true to delete the file after extraction
% 
% Out:
% 	wav		- the audio data
%	rate	- the sampling rate, in Hz
%	nBit	- the number of bits per sample
% 
%
% Assumptions:	assumes ffmpeg is installed at
%				c:\programs\media\ffmpeg\ffmpeg.exe
%
% Updated:	2009-02-28
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[strPathOut,bDeleteFile]	= ParseArgs(varargin,[],nargout>0);

%get the output path
	if isempty(strPathOut)
		if bDeleteFile
			strPathOut	= GetTempFile('wav');
		else
			strPathOut	= PathAddSuffix(strPathVideo,'','wav');
		end
	end

%check for ffmpeg
	strPathEXE	= 'c:\programs\media\ffmpeg\ffmpeg.exe';
	if ~exist(strPathEXE,'file')
		error(['ffmpeg not found at "' strPathEXE '".']);
	end

%execute the command
	strCommand		= [strPathEXE ' -y -i "' strPathVideo '" "' strPathOut '"'];
	[status,res]	= system(strCommand);

if status==0
	%get the wav data
		if nargout>0
			[varargout{:}]	= wavread(strPathOut);
		end
	%delete the temporary file
		if bDeleteFile
			delete(strPathOut);
		end
else
	error('ffmpeg command failed!');
end
