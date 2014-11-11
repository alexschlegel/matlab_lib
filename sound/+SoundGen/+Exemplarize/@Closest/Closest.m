classdef Closest < SoundGen.Exemplarize.Exemplarizer
% SoundGen.Exemplarize.Closest
% 
% Description:	exemplarizer that chooses a candidate exemplar whose preceding
%				segments most closely resemble the current leading edge
%				exemplars
% 
% Syntax:	e = SoundGen.Exemplarize.Closest(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the exemplarize process
% 			 
% 			properties:
%				result			- an Sx1 array of segment index exemplars
%				n				- the number of exemplars to consider as the
%								  leading edge of the exemplar string
%				data			- a specifier for the data to cluster (see
%								  options)
%				nfft			- the N to use for fourier transforms (see
%								  options)
%				dist			- a specifier for the exemplar distance metric
%								  to use (see options)
%				groupdist		- a specifier for the exemplar group distance
%								  metric to use (see options)
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the exemplarizer has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		exemplarize_n:			('generator') the number of exemplars to
%								consider as the leading edge of the exemplar
%								string, or a parent property with an 'n'
%								property to use (or 5 if the n property doesn't
%								exist)
%		exemplarize_data:		('clusterer') the data to use in distance
%								calculations. one of the following:
%									'signal':	cluster the signal data
%									'lcqft':	cluster the low-quefrency
%										constant-Q fourier transforms of the
%										signals
%									'hcqft':	cluster the high-quefrency
%												constant-Q fourier transforms of
%												the signals
%									op:	the name of a parent property that
%										contains a .intermediate.data value to
%										use, or the same method as op if that
%										doesn't exist
%									f:	a function that takes a signal and
%										the sampling frequency and returns
%										the data to cluster
%		exemplarize_nfft:		(512) for data transformations that involve
%								fourier transform, the N value to use
%		exemplarize_dist:		('euclidean') the exemplar distance function to
%								use.  can be any distance choice allowed by
%								pdist.
%		exemplarize_groupdist:	('mean') the method for calculating the exemplar
%								group distance.  one of the following:
%									'min':	group distance is the minimum
%										distance between corresponding group
%										members
%									'max':	group distance is the maximum
%										distance between corresponding group
%										members
%									'mean':	group distance is the mean distance
%										between corresponding group members
%									f:	a function that takes an nGroupxN vector
%										of nGroup groups of N distances and
%										returns an nGroupx1 vector of the group
%										distances
%		silent:					(false) true if processes should be silent
%
% Updated: 2012-11-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		n			= [];
		data		= '';
		nfft		= 0;
		dist		= '';
		groupdist	= '';
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		n_otherwise		= 5;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function e = set.n(e,n)
			if (ischar(n) && isprop(e.parent,n)) || isnat(n)
				e.n		= n;
				e.ran	= false;
			else
				error('Invalid exemplarize n.');
			end
		end
		function e = set.data(e,data)
			bValid	= false;
			
			if isa(data,'function_handle')
				bValid	= true;
			elseif ischar(data)
				switch lower(data)
					case {'signal','lcqft','hcqft'}
						data	= lower(data);
						bValid	= true;
					otherwise
						if isprop(e.parent,data)
							bValid	= true;
						end
				end
			end
			
			if bValid
				e.data	= data;
				e.ran	= false;
			else
				error('Invalid exemplarize data specification.');
			end
		end
		function e = set.nfft(e,nfft)
			if isnumeric(nfft)
				e.nfft	= nfft;
				e.ran	= false;
			else
				error('Invalid exemplarize nfft.');
			end
		end
		function e = set.dist(e,dist)
			%try out a simple pdist call to see if dist is valid
				bError	= false;
				
				try
					d	= pdist(eye(2),dist);
				catch me
					error('Invalid exemplarize distance metric.');
				end
				
			e.dist	= dist;
			e.ran	= false;
		end
		function e = set.groupdist(e,groupdist)
			if isa(groupdist,'function_handle') || (ischar(groupdist) && ismember(lower(groupdist),{'min','max','mean'}))
				e.groupdist	= groupdist;
				e.ran		= false;
			else
				error('Invalid exemplarize groupdist specification.');
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function e = Closest(parent,varargin)
			e	= e@SoundGen.Exemplarize.Exemplarizer(parent,varargin{:});
			
			opt	= ParseArgs(varargin,...
					'exemplarize_n'			, 'generator'	, ...
					'exemplarize_data'		, 'clusterer'	, ...
					'exemplarize_nfft'		, 512			, ...
					'exemplarize_dist'		, 'euclidean'	, ...
					'exemplarize_groupdist'	, 'mean'		  ...
					);
			
			e.n			= opt.exemplarize_n;
			e.data		= opt.exemplarize_data;
			e.nfft		= opt.exemplarize_nfft;
			e.dist		= opt.exemplarize_dist;
			e.groupdist	= opt.exemplarize_groupdist;
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
