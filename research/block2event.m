function [event,durRun] = block2event(block,durBlock,durRest,varargin)
% block2event
% 
% Description:	convert a block design specification to an event design
%				specification
% 
% Syntax:	[event,durRun] = block2event(block,durBlock,durRest,[durPre]=0,[durPost]=0)
% 
% In:
% 	block		- a 1D array specifying the condition order.  elements of block
%				  are column indices of the output EVs, e.g. a block value of 3
%				  specifies that the condition represented by the 3rd EV was
%				  presented during that block
%	durBlock	- the number of timepoints per block
%	durRest		- the number of timepoints per rest period
%	[durPre]	- the number of blank timepoints to prepend to the EV (can be
%				  negative)
%	[durPost]	- the number of blank timepoints to append to the EV (can be
%				  negative)
% 
% Out:
% 	event		- an nEvent x 3 array specifying the condition number, time, and
%				  duration of each event
%	durRun		- the run duration, in TRs
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[event,durRun]	= ev2event(block2ev(block,durBlock,durRest,varargin{:}));
