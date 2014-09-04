function Run(c,x,rate,s,varargin) 
% SoundGen.Cluster.Clusterer.Run
% 
% Description:	base Run function for SoundGen.Cluster.* objects
% 
% Syntax:	c.Run(x,rate,s,<options>)
% 
% In:
% 	x		- an Nx1 audio signal
%	rate	- the sampling rate of the audio signal, in Hz
%	s		- an Mx2 array of segment start and end indices
%	<options>:
%		reset:	(false) true to reset results calculated during previous runs
% 
% Side-effects: sets c.result, an Mx1 cluster string array of clusters assigned
%				to each segment
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('clustering data (clusterer)','silent',c.silent);

c.result	= (1:size(s,1))';
