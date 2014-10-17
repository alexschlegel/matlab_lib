function Run(s,x,rate,varargin) 
% SoundGen.Segment.Uniform.Run
% 
% Description:	calculate uniformly-spaced segments
% 
% Syntax:	s.Run(x,rate,<options>)
% 
% In:
% 	x		- an Nx1 audio signal
%	rate	- the sampling rate of the audio signal, in Hz
%	<options>:
%		segment_dur:	(s.dur) the duration of each segment, in seconds
%		reset		:	(false) true to reset results calculated during previous
%						runs
% 
% Side-effects: sets s.result, an Mx2 array of segment start and end indices
% 
% Updated: 2012-11-15
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'segment_dur'	, s.dur	, ...
		'reset'			, false	  ...
		);

ns	= status(['segmenting data (uniform, dur=' num2str(opt.segment_dur) ')'],'silent',s.silent);

bRan	= s.ran && ~opt.reset;

kStart		= (1:opt.segment_dur*rate:numel(x)+1)';
s.result	= [kStart(1:end-1) kStart(2:end)-1];
