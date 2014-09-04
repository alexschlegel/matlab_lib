function Run(g,c,kStart,S,varargin) 
% SoundGen.Generate.Generator.Run
% 
% Description:	base Run function for SoundGen.Generate.* objects
% 
% Syntax:	g.Run(c,kStart,S,<options>)
% 
% In:
% 	c		- an Mx1 cluster string array
%	kStart	- the index in c at which to start
%	S		- the length of the cluster string to generate
%	<options>:
%		reset:	(false) true to reset results calculated during previous runs
% 
% Side-effects:	sets g.result, an Sx1 generated cluster string array
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('generating cluster string (generator)','silent',g.silent);

g.result	= [c(kStart); randFrom(unique(c),[S-1 1],'unique',false)];
