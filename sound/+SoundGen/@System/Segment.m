function Segment(sys,varargin)
% SoundGen.System.Segment
% 
% Description:	segment the input sound
% 
% Syntax:	sys.Segment(<options>)
% 
% In:
% 	<options>: options to the segmenter function or object 
% 
% Updated: 2012-11-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if isa(sys.segmenter,'SoundGen.Segment.Segmenter')
	sys.segmenter.Run(sys.src,sys.rate,varargin{:});
	
	sys.segment	= sys.segmenter.result;
else
	sys.segment	= sys.segmenter(sys.src,sys.rate,varargin{:});
end
