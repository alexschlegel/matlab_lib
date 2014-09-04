function Run(c,x,rate,s,str,varargin) 
% SoundGen.Concatenate.Concatenater.Run
% 
% Description:	base Run function for SoundGen.Concatenate.* objects
% 
% Syntax:	c.Run(x,rate,s,str,<options>)
% 
% In:
%	x		- an Nx1 audio signal
%	rate	- the sampling rate of x, in Hz
%	s		- an Mx2 array of segment start and end indices 
%	str		- an Sx1 segment exemplar string
%	<options>:
%		reset:	(false) true to reset results calculated during previous runs
% 
% Side-effects:	sets c.result, a Px1 concatenated audio signal
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('concatenating segment exemplars (concatenater)','silent',c.silent);

y			= arrayfun(@(ks,ke) x(ks:ke),s(str,1),s(str,2),'UniformOutput',false);
c.result	= cat(1,y{:});
