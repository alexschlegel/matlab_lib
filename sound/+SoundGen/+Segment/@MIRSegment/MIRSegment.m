classdef MIRSegment < SoundGen.Segment.Segmenter
% SoundGen.Segment.MIRSegment
% 
% Description:	use the MIRToolbox's mirsegment function
% 
% Syntax:	s = SoundGen.Segment.MIRSegment(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the segmenter
% 			 
% 			properties:
%				method			- the segmentation method.  any method accepted
%								  by mirsegment.
%				feature			- the audio feature to use.  any feature
%								  accepted by mirsegment.
%				mextra			- a cell of extra arguments for the segmentation
%								  method
%				fextra			- a cell of extra arguments for the audio
%								  feature.
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
%		segment_method:		('HCDF') the initial method value
%		segment_feature:	('MFCC') the initial feature value
%		segment_mextra:		({}) the initial mextra value
%		segment_fextra:		({}) the initial fextra value
%		silent:				(false) true if processes should be silent
%
% Updated: 2012-11-19
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		method	= '';
		feature	= '';
		mextra	= {};
		fextra	= {};
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function s = MIRSegment(parent,varargin)
			s	= s@SoundGen.Segment.Segmenter(parent,varargin{:});
			
			opt	= ParseArgs(varargin,...
					'segment_method'	, 'HCDF'	, ...
					'segment_feature'	, 'MFCC'	, ...
					'segment_mextra'		, {}	, ...
					'segment_fextra'		, {}	  ...
					);
			
			s.method	= opt.segment_method;
			s.feature	= opt.segment_feature;
			s.mextra	= opt.segment_mextra;
			s.fextra	= opt.segment_fextra;
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
