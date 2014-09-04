function Run(c,x,rate,s,str,varargin) 
% SoundGen.Concatenate.OverlapAdd.Run
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
% Updated: 2012-11-14
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
ns	= status('concatenating segment exemplars (overlapadd)','silent',c.silent);

n	= numel(x);

%construct the segments with overlap accounted for
	%get the padded segment start and end indices
		nOverlap	= t2k(abs(c.overlap/2),rate)-1;
		
		s	= [max(1,s(:,1)-nOverlap) min(n,s(:,2)+nOverlap)];
	%construct the segments
		kStart	= s(str,1);
		kEnd	= s(str,2);
		
		c.result	= arrayfun(@(ks,ke) x(ks:ke),kStart,kEnd,'UniformOutput',false);
%concatenate
	c.result	= signalcat(c.result{:},rate,...
					'insert'	, c.overlap	, ...
					'weight'	, c.weight	, ...
					'silent'	, c.silent	  ...
					);
