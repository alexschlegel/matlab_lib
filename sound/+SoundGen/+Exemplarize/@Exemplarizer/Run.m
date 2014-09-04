function Run(e,x,rate,s,c,str,kStart,varargin) 
% SoundGen.Exemplarize.Exemplarizer.Run
% 
% Description:	base Run function for SoundGen.Exemplarize.* objects
% 
% Syntax:	e.Run(x,rate,s,c,str,kStart,<options>)
% 
% In:
%	x		- an Nx1 audio signal
%	rate	- the sampling rate of x, in Hz
%	s		- an Mx2 array of segment start and end indices 
% 	c		- an Mx1 cluster string array
%	str		- an Sx1 generated cluster string
%	kStart	- the index in c at which the generator started
%	<options>:
%		reset:	(false) true to reset results calculated during previous runs
% 
% Side-effects:	sets e.result, an Sx1 array of segment index exemplars
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('exemplarizing data (exemplarizer)','silent',e.silent);

[cU,kSegment]	= unique(c,'first');
[b,kCluster]	= ismember(str,cU);

if any(kCluster)==0
	error('Some clusters in str do not exist in c.');
end

e.result	= kSegment(kCluster);
