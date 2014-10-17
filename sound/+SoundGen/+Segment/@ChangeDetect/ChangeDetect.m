classdef ChangeDetect < SoundGen.Segment.Segmenter
% SoundGen.Segment.ChangeDetect
% 
% Description:	set segments at points in time where some distance metric
%				crosses a threshold
% 
% Syntax:	s = SoundGen.Segment.ChangeDetect(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the segmenter
% 			 
% 			properties:
%				target			- the target mean segment duration, in seconds
%				feature			- the audio feature to use.  must be either a
%								  function that takes an audio signal and
%								  sampling rate and returns a feature vector,
%								  one of the following presets:
%									'signal':	use the signal data
%									'lcqft':	use low-quefrency constant-Q
%												fourier transforms
%									'hcqft':	use high-quefrency constant-Q
%												fourier transforms
%								  or a cell of the above, in which case the
%								  maximum distance resulting from applying the
%								  distance function to all of the specified
%								  features is used.
%				nfft			- the N to use for fourier transforms
%				dur				- the duration of audio to use for each feature
%								  calculation, in seconds.
%				hop				- the hop size for audio features, in seconds
%				dist			- the distance metric to use on the features.
%								  segment borders occur where the median of
%								  distances between the current feature and the
%								  previous features exceeds a threshold. can be
%								  any metric allowed by pdist.
%				compare			- the number of previous features to compare
%								  the current feature to when calculating the
%								  the median distance (see dist)
%				depoly			- the order of polynomial to remove from the
%								  distance timecourse before thresholding
%				result			- an Mx2 array of segment start and end indices
%								  that gets set during a call to Run
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the segmenter has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		segment_target:		(0.5) the initial target value
%		segment_feature:	({'lcqft','hcqft'}) the initial feature value
%		segment_nfft:		(512) the initial nfft value
%		segment_dur:		(0.25) the initial dur value
%		segment_hop:		(0.1) the initial hop value
%		segment_dist:		('correlation') the initial dist value
%		segment_compare:	(5) the initial compare value
%		segment_depoly:		(2) the initial depoly value
%		silent:				(false) true if processes should be silent
%
% Updated: 2012-11-18
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		target	= 0;
		feature	= [];
		nfft	= 0;
		dur		= 0;
		hop		= 0;
		dist	= [];
		compare	= 0;
		depoly	= 0;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function s = set.target(s,target)
			if isnumeric(target)
				s.target	= target;
				s.ran		= false;
			else
				error('Invalid target duration.');
			end
		end
		function s = set.feature(s,feature)
			feature	= ForceCell(feature);
			
			cClass	= cellfun(@class,feature,'UniformOutput',false);
			bChar	= cellfun(@ischar,feature);
			
			feature(bChar)	= cellfun(@(str) CheckInput(str,'feature',{'signal','lcqft','hcqft'}),feature,'UniformOutput',false);
			
			if any(~ismember(cClass,{'char','function_handle'}))
				error('Invalid feature specification.');
			end
			
			s.feature	= feature;
			s.ran		= false;
		end
		function s = set.nfft(s,nfft)
			if isnumeric(nfft)
				s.nfft	= nfft;
				s.ran	= false;
			else
				error('Invalid segment nfft.');
			end
		end
		function s = set.dur(s,dur)
			if isnumeric(dur)
				s.dur	= dur;
				s.ran	= false;
			else
				error('Invalid segment duration.');
			end
		end
		function s = set.hop(s,hop)
			if isnumeric(hop)
				s.hop	= hop;
				s.ran	= false;
			else
				error('Invalid segment hop.');
			end
		end
		function s = set.dist(s,dist)
			%try out a simple pdist call to see if dist is valid
				bError	= false;
				
				try
					d	= pdist(eye(2),dist);
				catch me
					error('Invalid segment distance metric.');
				end
				
			s.dist	= dist;
			s.ran	= false;
		end
		function s = set.compare(s,compare)
			if isnumeric(compare)
				s.compare	= compare;
				s.ran		= false;
			else
				error('Invalid compare specification.');
			end
		end
		function s = set.depoly(s,p)
			if isnumeric(p)
				s.depoly	= round(p);
				s.ran		= false;
			else
				error('Invalid depoly specification.');
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function s = ChangeDetect(parent,varargin)
			s	= s@SoundGen.Segment.Segmenter(parent,varargin{:});
			
			opt	= ParseArgs(varargin,...
					'segment_target'	, 0.5				, ...
					'segment_feature'	, {'lcqft','hcqft'}	, ...
					'segment_nfft'		, 512				, ...
					'segment_dur'		, 0.25				, ...
					'segment_hop'		, 0.1				, ...
					'segment_dist'		, 'correlation'		, ...
					'segment_compare'	, 5					, ...
					'segment_depoly'	, 2					  ...
					);
			
			s.target	= opt.segment_target;
			s.feature	= opt.segment_feature;
			s.nfft		= opt.segment_nfft;
			s.dur		= opt.segment_dur;
			s.hop		= opt.segment_hop;
			s.dist		= opt.segment_dist;
			s.compare	= opt.segment_compare;
			s.depoly	= opt.segment_depoly;
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
