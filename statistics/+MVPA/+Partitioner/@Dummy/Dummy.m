classdef Dummy < MVPA.Partitioner.Base;
% MVPA.Partitioner.Dummy
% 
% Description:	dummy partitioner
% 
% Syntax:	prt = MVPA.Partitioner.Dummy()
%
% 			methods:
% 				Partitioner:	construct a partitioning of the data into
%								training and testing sets
%
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=public)
		function [cChunkTrain,cChunkTest] = p_partition(prt,nChunk)
			cChunkTrain	= {(1:2:nChunk)'};
			cChunkTest	= {(2:2:nChunk)'};
		end
	end
	%PRIVATE METHODS-----------------------------------------------------------%
end
