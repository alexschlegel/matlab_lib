classdef ClusterData < SoundGen.Cluster.Clusterer
% SoundGen.Cluster.ClusterData
% 
% Description:	clusterer based on MATLAB's clusterdata function
% 
% Syntax:	c = SoundGen.Cluster.ClusterData(parent,<options>)
% 
% 			subfunctions:
%				Run	- run the cluster process
% 			 
% 			properties:
%				result			- an Mx1 array of the cluster string array of
%								  clusters to which each segment was assigned
%								  during a call to Run
%				data			- a specifier for the data to cluster (see
%								  options)
%				nfft			- the N to use for fourier transforms (see
%								  options)
%				dist			- a specifier for the distance metric to use
%								  (see options)
%				linkage			- the clusterdata linkage parameter
%				cutoff			- the CUTOFF argument to clusterdata
%				intermediate	- a struct of intermediate processing results
%								  (read only)
%				ran				- true if the clusterer has already run
%				silent			- true if processes should be silent
% 
% In:
%	parent	- the parent SoundGen.System object
%	<options>:
%		cluster_data:		('lcqft') the data to cluster.  one of the
%							following:
%								'signal':	cluster the signal data
%								'lcqft':	cluster the low-quefrency constant-Q
%											fourier transforms of the signals
%								'hcqft':	cluster the high-quefrency
%											constant-Q fourier transforms of
%											the signals
%								f:			a function that takes a signal and
%											the sampling frequency and returns
%											the data to cluster
%		cluster_nfft:		(512) for data transformations that involve fourier
%							transform, the N value to use
%		cluster_dist:		('seuclidean') the distance function to use.  can
%							be any distance choice allowed by pdist.
%		cluster_linkage:	('ward') the clusterdata linkage parameter
%		cluster_cutoff:		(30) the CUTOFF argument to clusterdata
%		silent:				(<parent value>) true if processes should be silent
%
% Updated: 2012-11-05
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		data	= '';
		nfft	= 0;
		dist	= '';
		linkage	= '';
		cutoff	= 0;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=protected, GetAccess=protected)
		
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function c = set.data(c,data)
			if isa(data,'function_handle') || (ischar(data) && ismember(lower(data),{'signal','lcqft','hcqft'}))
				c.data	= lower(data);
				c.ran	= false;
			else
				error('Invalid cluster data specification.');
			end
		end
		function c = set.nfft(c,nfft)
			if isnumeric(nfft)
				c.nfft	= nfft;
				c.ran	= false;
			else
				error('Invalid cluster nfft.');
			end
		end
		function c = set.dist(c,dist)
			%try out a simple pdist call to see if dist is valid
				bError	= false;
				
				try
					d	= pdist(eye(2),dist);
				catch me
					error('Invalid cluster distance metric.');
				end
				
			c.dist	= dist;
			c.ran	= false;
		end
		function c = set.linkage(c,strLinkage)
			%try out a simple linkage call to see if dist is valid
				bError	= false;
				
				try
					z	= linkage(eye(2),strLinkage);
				catch me
					error('Invalid cluster linkage method.');
				end
				
			c.linkage	= strLinkage;
			c.ran		= false;
		end
		function c = set.cutoff(c,cutoff)
			if isnumeric(cutoff) && cutoff>0
				c.cutoff	= cutoff;
				c.ran		= false;
			else
				error('Invalid cluster cutoff.');
			end
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function c = ClusterData(parent,varargin)
			c	= c@SoundGen.Cluster.Clusterer(parent,varargin{:});
			
			opt	= ParseArgs(varargin,...
					'cluster_data'		, 'lcqft'		, ...
					'cluster_nfft'		, 512			, ...
					'cluster_dist'		, 'seuclidean'	, ...
					'cluster_linkage'	, 'ward'		, ...
					'cluster_cutoff'	, 30			  ...
					);
			
			c.data		= opt.cluster_data;
			c.nfft		= opt.cluster_nfft;
			c.dist		= opt.cluster_dist;
			c.linkage	= opt.cluster_linkage;
			c.cutoff	= opt.cluster_cutoff;
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
