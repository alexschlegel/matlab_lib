function ev = block2ev(block,durBlock,durRest,varargin)
% block2ev
% 
% Description:	generate a set of EVs given a block design specification.  the
%				experiment must have been designed as:
%					pre rest block rest block ... rest block rest post
% 
% Syntax:	ev = block2ev(block,durBlock,durRest,[durPre]=0,[durPost]=0,[nCondition]=<auto>)
% 
% In:
% 	block			- a 1D array specifying the condition order.  elements of
%					  block are column indices of the output EVs, e.g. a block
%					  value of 3 specifies that the condition represented by the
%					  3rd EV was presented during that block
%	durBlock		- the number of timepoints per block
%	durRest			- the number of timepoints per rest period
%	[durPre]		- the number of blank timepoints to prepend to the EV (can be
%					  negative)
%	[durPost]		- the number of blank timepoints to append to the EV (can be
%					  negative)
%	[nCondition]	- the number of conditions
% 
% Out:
% 	ev	- an nTimepoint x nCondition design matrix
% 
% Updated: 2012-03-14
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[durPre,durPost,nCondition]	= ParseArgs(varargin,0,0,max(block));

nBlock		= numel(block);

%initialize the design matrix
	nTime	= nBlock*durBlock + (nBlock+1)*durRest;

	ev	= zeros(nTime,nCondition);
%fill in the blocks
	kBlock	= 1:nBlock;
	kStart	= (kBlock-1)*durBlock + kBlock*durRest + 1;
	kEnd	= kStart + durBlock-1;
	
	for kB=1:nBlock
		ev(kStart(kB):kEnd(kB),block(kB))	= 1;
	end
%add/remove the pre and post periods
	if durPre<0
		ev(1:-durPre,:)	= [];
	else
		ev	= [zeros(durPre,nCondition); ev];
	end
	
	if durPost<0
		ev(end+durPost+1:end,:)	= [];
	else
		ev	= [ev; zeros(durPost,nCondition)];
	end
