function [block,durBlock,durRest,durPre,durPost] = ev2block(ev)
% ev2block
% 
% Description:	generate a block design specification, given its equivalent as
%				a set of EVs
% 
% Syntax:	[block,durBlock,durRest,durPre,durPost] = ev2block(ev)
% 
% In:
% 	ev	- an nTimepoint x nCondition design matrix of 1s and 0s
% 
% Out:
% 	block		- a 1D array specifying the condition order.  elements of block
%				  are column indices of the input EVs, e.g. a block value of 3
%				  specifies that the condition represented by the 3rd EV was
%				  presented during that block
%	durBlock	- the number of timepoints per block
%	durRest		- the number of timepoints per rest period
%	durPre		- the number of additional blank timepoints at the beginning of
%				  a run (can be negative)
%	durPost		- the number of additional blank timepoints at the end of a run
%				  (can be negative) 
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[nTimepoint,nCondition]	= size(ev);

%make sure we have a well-formatted EV
	if any(sum(any(ev,2),2)>1)
		error('Multiple blocks detected at the same time point.');
	end

%convert to a 1D array of the blocks occuring at each time point
	evblock	= sum(ev.*repmat(1:nCondition,[nTimepoint 1]),2);
	
	bChange	= [false; diff(evblock)~=0];
	kChange	= find(bChange);
%get the durations
	durRestPre	= kChange(1)-1;
	durBlock	= kChange(2:2:end) - kChange(1:2:end);
	durRest		= kChange(3:2:end) - kChange(2:2:end-1);
	durRestPost	= numel(evblock) - kChange(end) + 1;
	
	if ~uniform(durBlock)
		error('Non-uniform block durations.');
	end
	if ~uniform(durRest)
		error('Non-uniform rest durations.');
	end
	
	durBlock	= durBlock(1);
	durRest		= durRest(1);
	durPre		= durRestPre - durRest;
	durPost		= durRestPost - durRest;
	
	block	= evblock(kChange(2:2:end) - 1);
