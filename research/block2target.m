function cTarget = block2target(block,durBlock,durRest,cCondition,varargin)
% block2target
% 
% Description:	generate a target cell array, given a block design
%				specification
% 
% Syntax:	cTarget = block2target(block,durBlock,durRest,cCondition,[durPre]=0,[durPost]=0,<options>)
% 
% In:
% 	block		- a 1D array specifying the condition order.  elements of block
%				  are column indices of the output EVs, e.g. a block value of 3
%				  specifies that the condition represented by the 3rd EV was
%				  presented during that block
%	durBlock	- the number of timepoints per block
%	durRest		- the number of timepoints per rest period
%	cCondition	- a cell of condition names
%	[durPre]	- the number of blank timepoints to prepend to the EV (can be
%				  negative)
%	[durPost]	- the number of blank timepoints to append to the EV (can be
%				  negative)
%	<options>:
%		hrf:			(0) the HRF delay to incorporate into the target array
%		block_offset:	(0) only use the portion of the block at or after the
%						specified offset
%		block_sub:		(<all>) only use a subset of each block
% 
% Out:
%	cTarget	- an nTimepoint x 1 cell of the target name at each TR. blanks are
%			  labeled 'Blank'.
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[durPre,durPost,opt]	= ParseArgs(varargin,0,0,...
							'hrf'			, 0			, ...
							'block_offset'	, 0			, ...
							'block_sub'		, durBlock	  ...
							);

%convert to an event specification
	[event,durRun]	= block2event(block,durBlock,durRest,durPre,durPost);
%retool the events
	event(:,2)	= event(:,2) + opt.block_offset;
	event(:,3)	= min(event(:,3)-opt.block_offset,opt.block_sub);

cTarget	= ev2target(event2ev(event,durRun),cCondition,varargin{:});
