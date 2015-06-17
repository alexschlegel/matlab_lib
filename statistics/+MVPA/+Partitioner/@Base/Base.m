classdef Base < MVPA.Object
% MVPA.Partitioner.Base
% 
% Description:	base partitioner class
% 
% Syntax:	prt = MVPA.Partitioner.Base(<options>)
%
% 			methods:
% 				Partitioner:	construct a partitioning of the data into
%								training and testing sets
%
% Notes:
%	subclasses only need to implement the p_partition private function
% 
% Updated: 2015-06-03
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PROTECTED PROPERTIES------------------------------------------------------%
	properties (SetAccess=protected)
		
	end
	properties (GetAccess=protected, SetAccess=protected)
		
	end
	%PROTECTED PROPERTIES------------------------------------------------------%
	
	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%DERIVED PROPERTIES--------------------------------------------------------%
	methods
		
	end
	%DERIVED PROPERTIES--------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function prt = Base(varargin)
			prt	= prt@MVPA.Object;
			
			%parse the input options
				for k=1:2:nargin
					opt	= varargin{k};
					val	= varargin{k+1};
					
					assert(ischar(opt),'options must be specified as string/value pairs');
					assert(isprop(prt,opt),'"%s" is not a valid option',opt);
					
					prt.(opt)	= val;
				end
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Abstract, Access=public)
		[cChunkTrain,cChunkTest] = p_partition(prt,nChunk)
		% p_partition
		% 
		% Description:	actual construction of partitions happens here 
		% 
		% Syntax:	[cChunkTrain,cChunkTest] = prt.p_partition(nChunk)
		% 
		% In:
		% 	nChunk	- the number of chunks in the data
		% 
		% Out:
		% 	cChunkTrain	- an nPartition x 1 cell of nChunkTrain x 1 arrays
		%				  specifying the indices of the training chunks in each
		%				  partition
		%	cChunkTest	- an nPartition x 1 cell of nChunkTest x 1 arrays
		%				  specifying the indices of the testing chunks in each
		%				  partition
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
