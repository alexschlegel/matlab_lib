function cTarget = event2target(event,durRun,cCondition,varargin)
% event2target
% 
% Description:	generate a target cell array, given an event design
%				specification
% 
% Syntax:	cTarget = event2target(event,durRun,cCondition,<options>)
% 
% In:
% 	event		- an nEvent x 3 array specifying the condition number, time, and
%				  duration of each event
%	durRun		- the run duration, in TRs
%	cCondition	- a cell of condition names
%	<options>:
%		hrf:	(0) the HRF delay to incorporate into the target array
% 
% Out:
%	cTarget	- an nTimepoint x 1 cell of the target name at each TR. blanks are
%			  labeled 'Blank'.
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cTarget	= ev2target(event2ev(event,durRun),cCondition,varargin{:});
