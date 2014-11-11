function onset = block2onset(block,durBlock,durRest,varargin)
% block2onset
% 
% Description:	generate a set of condition onsets given a block design
%				specification.  the experiment must have been designed as:
%					pre rest block rest block ... rest block rest post
% 
% Syntax:	onset = block2onset(block,durBlock,durRest,[durPre]=0,[nCondition]=<auto>,<options>)
% 
% In:
% 	block			- a 1D array specifying the condition order.  don't include
%					  rest periods.
%	durBlock		- the number of timepoints per block
%	durRest			- the number of timepoints per rest period
%	[durPre]		- the number of blank timepoints to prepend to the EV (can be
%					  negative)
%	[nCondition]	- the number of conditions
%	<options>:
%		tr:	(1) the number of seconds per TR
% 
% Out:
% 	onset	- an nCondition x 1 cell of condition onset arrays
% 
% Updated: 2012-04-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[durPre,nCondition,opt]	= ParseArgs(varargin,0,max(block),...
								'tr'	, 1	  ...
								);

nBlock		= numel(block);

%initialize the onset cell
	onset	= cell(nCondition,1);
%fill in the blocks
	kBlock	= 1:nBlock;
	kStart	= durPre + (kBlock-1)*durBlock + kBlock*durRest;
	
	kStart	= opt.tr*kStart;
	
	for kB=1:nBlock
		onset{block(kB)}(end+1)	= kStart(kB);
	end
