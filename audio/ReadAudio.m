function [x,rate,varargout] = ReadAudio(strPath,varargin)
% ReadAudio
% 
% Description:	read any audio file supported by ConvertAudio
% 
% Syntax:	[x,rate,t] = ReadAudio(strPath,<options>)
% 
% In:
% 	strPath	- the path to the audio file
%	<options>:
%		start:	(<beginning>) the start of the period to read, in seconds
%		end:	(<end>) the end of the period to read, in seconds
%		silent:	(true) true to suppress status messages
% 
% Out:
% 	x		- an nSample x nChannel audio signal
%	rate	- the sampling rate, in Hz
%	t		- the time of each sample, in seconds
% 
% Updated: 2011-11-27
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'start'		, []	, ...
		'end'		, []	, ...
		'silent'	, true	  ...
		);

[x,rate,t]	= deal([]);

%convert the sample to wav
	strPathTemp	= GetTempFile('ext','wav');
	b			= ConvertAudio(strPath,strPathTemp,'start',opt.start,'end',opt.end,'silent',opt.silent);
if b
%read the file
	[x,rate]	= wavread(strPathTemp);
%delete the intermediate file
	delete(strPathTemp);
end

if nargout>2
	varargout{1}	= k2t((1:size(x,1))',rate);
end
