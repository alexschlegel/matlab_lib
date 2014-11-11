function b = WriteAudio(x,rate,strPath,varargin)
% WriteAudio
% 
% Description:	write an audio signal to any file supported by ConvertAudio
% 
% Syntax:	b = WriteAudio(x,rate,strPath,<options>)
% 
% In:
%	x		- an nSample x nChannel audio signal
%	rate	- the sampling rate of the signal, in Hz
% 	strPath	- the path to the output audio file
%	<options>:
%		silent:	(true) true to suppress status messages
% 
% Out:
%	b	- true if the file was successfully saved
% 
% Updated: 2011-11-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'silent'	, true	  ...
		);

%intermediate file?
	bIntermediate		= ~isequal(lower(PathGetExt(strPath)),'wav');
	strPathIntermediate	= conditional(bIntermediate,GetTempFile('ext','wav'),strPath);
%save the sample as a wav file
	warning('off','MATLAB:wavwrite:dataClipped');
	
	wavwrite(x,rate,strPathIntermediate);
	b	= true;
%convert to the output file and delete the intermediate
	if bIntermediate
		b	= ConvertAudio(strPathIntermediate,strPath,varargin{:});
		
		if FileExists(strPathIntermediate)
			delete(strPathIntermediate);
		end
	end
