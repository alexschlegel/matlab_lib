function Abort(ptb,varargin)
% PTB.Abort
% 
% Description:	abort an experiment
% 
% Syntax:	ptb.Abort([bError]=true)
% 
% In:
%	[bError]	- true to raise an error
% 
% Updated: 2011-12-19
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bError	= ParseArgs(varargin,true);

ptb.End;

if bError
	error('experiment aborted.');
end
