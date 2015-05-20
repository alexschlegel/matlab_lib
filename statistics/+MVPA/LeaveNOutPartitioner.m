function [kTrain,kTest] = LeaveNOutPartitioner(nItem,nLeaveOut)
% MVPA.LeaveNOutPartitioner
% 
% Description:	partition nItem items into all possible combinations of training
%				and testing groups, where nLeaveOut items are in each testing
%				group
% 
% Syntax:	[kTrain,kTest] = MVPA.LeaveNOutPartitioner(nItem,nLeaveOut)
%
% In:
% 	nItem		- the number of items
%	nLeaveOut	- the number of items to leave out of each training group
%
% Out:
%	kTrain	- an nGroup x nItemTrain array of indices of items in the training
%			  group
%	kTest	- an nGroup x nItemTest array of indices of items in the testing
%			  group
% 
% Updated: 2015-05-20
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
kItem	= 1:nItem;

kTest	= handshakes(kItem,'group',nLeaveOut);
nGroup	= size(kTest,1);

kTrain	= arrayfun(@(k) reshape(setdiff(kItem,kTest(k,:)),1,[]),1:nGroup,'uni',false);
kTrain	= cat(1,kTrain{:});
