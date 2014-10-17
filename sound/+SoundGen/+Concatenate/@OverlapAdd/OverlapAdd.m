classdef OverlapAdd < SoundGen.Concatenate.Concatenater
% SoundGen.Concatenate.OverlapAdd
% 
% Description:	SoundGen.Concatenate object that uses an overlap-add technique
%				for concatenating
% 
% Syntax:	c = SoundGen.Concatenate.OverlapAdd(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the concatenate process
% 			 
% 			properties:
%				overlap			- the overlap duration, in seconds (see
%								  signalcat)
%				weight			- the blend weighting function (see signalcat)
%				result			- a Px1 concatenated audio signal
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the concatenation has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		concatenate_overlap:	(-0.1) the initial overlap property value
%		concatenate_weight:		('hann') the initial weight property value
%		silent:					(false) true if processes should be silent
%
% Updated: 2012-11-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		overlap	= 0;
		weight	= '';
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
		function c = OverlapAdd(parent,varargin)
			c	= c@SoundGen.Concatenate.Concatenater(parent,varargin{:});
			
			opt	= ParseArgs(varargin,...
					'concatenate_overlap'	, -0.1		, ...
					'concatenate_weight'	, 'hann'	  ...
					);
			
			c.overlap	= opt.concatenate_overlap;
			c.weight	= opt.concatenate_weight;
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
