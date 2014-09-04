function dbg = Debug(s,varargin)
% SoundGen.Segment.ChangeDetect.Debug
% 
% Description:	return a struct of debug info about the segmentation result
% 
% Syntax:	dbg = s.Debug(<options>)
%
% In:
%	<options>:
%		segment_dur:	(<full>) the amount of the original audio for which to
%						construct debug info, in seconds
%		segment_pause:	(0.5) the duration of the pause in between segments, in
%						seconds
% 
% Updated: 2012-11-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dbg	= Debug@SoundGen.Segment.Segmenter(s,varargin{:});

if s.ran
	dbg.dist	= s.intermediate.dist;
end
