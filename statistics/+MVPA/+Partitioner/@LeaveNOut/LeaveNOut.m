classdef LeaveNOut < MVPA.Partitioner.Base
% MVPA.Partitioner.LeaveNOut
% 
% Description:	leave-n-out partitioner
% 
% Syntax:	prt = MVPA.Partitioner.LeaveNOut(<options>)
%
% 			methods:
% 				Partitioner:	construct a partitioning of the data into
%								training and testing sets
%
% In:
%	<option>:
%		n:	(1) the number of chunks to leave out in each partition
%
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		n	= 1;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function prt = LeaveNOut(varargin)
			prt	= prt@MVPA.Partitioner.Base(varargin{:});
		end
		%----------------------------------------------------------------------%
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=public)
		function [cChunkTrain,cChunkTest] = p_partition(prt,nChunk)
			kChunk	= reshape(1:nChunk,nChunk,1);
			
			cChunkTest	= handshakes(kChunk,'group',prt.n);
			cChunkTest	= mat2cell(cChunkTest,ones(size(cChunkTest,1),1),prt.n);
			
			cChunkTrain	= cellfun(@(k) setdiff(kChunk,k),cChunkTest,'uni',false);
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
