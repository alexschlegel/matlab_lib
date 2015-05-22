function [cChunkTrain,cChunkTest] = Partition(prt,nChunk)
% Partition
% 
% Description:	construct training and testing partitions
% 
% Syntax:	[cChunkTrain,cChunkTest] = prt.Partition(nChunk)
% 
% In:
% 	nChunk	- the number of chunks into which the data have been divided
% 
% Out:
% 	cChunkTrain	- an nPartition x 1 cell of nChunkTrain x 1 arrays specifying
%				  the indices of the training chunks in each partition
% 	cChunkTest	- an nPartition x 1 cell of nChunkTest x 1 arrays specifying
%				  the indices of the testing chunks in each partition
% 
% Updated: 2015-05-21
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[cChunkTrain,cChunkTest]	= prt.p_partition(nChunk);
