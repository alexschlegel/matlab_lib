classdef Uniform < SoundGen.Segment.Segmenter
% SoundGen.Segment.Uniform
% 
% Description:	segments into uniform duration segments
% 
% Syntax:	s = SoundGen.Segment.Uniform(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the uniform segmenter
% 			 
% 			properties:
%				result			- an Mx2 array of segment start and end indices
%								  that gets set during a call to Run
%				dur				- the duration of each segment, in seconds
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the segmenter has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		segment_dur:	(0.25) the duration of each segment, in seconds
%		silent:			(false) true if processes should be silent
%
% Updated: 2012-11-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		dur	= 0;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function s = set.dur(s,dur)
			if isnumeric(dur)
				s.dur	= dur;
				s.ran	= false;
			else
				error('Invalid segment duration.');
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function s = Uniform(parent,varargin)
			s	= s@SoundGen.Segment.Segmenter(parent,varargin{:});
			
			opt	= ParseArgs(varargin,...
					'segment_dur'	, 0.25	  ...
					);
			
			s.dur	= opt.segment_dur;
		end
	end
	methods (Static)
		
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
