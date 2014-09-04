function Run(s,x,rate,varargin) 
% SoundGen.Segment.Segmenter.Run
% 
% Description:	base Run function for SoundGen.Segment.* objects
% 
% Syntax:	s.Run(x,rate,<options>)
% 
% In:
% 	x		- an Nx1 audio signal
%	rate	- the sampling rate of the audio signal, in Hz
%	<options>:
%		reset:	(false) true to reset results calculated during previous runs
% 
% Side-effects: sets s.result, an Mx2 array of segment start and end indices
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('segmenting data (segmenter)','silent',s.silent);

s.result	= [1 numel(x)];
