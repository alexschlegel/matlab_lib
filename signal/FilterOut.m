function x = FilterOut(x,fFilter,fSample)
% FilterOut
% 
% Description:	filter out the specified frequency from the data
% 
% Syntax:	x = FilterOut(x,fFilter,fSample)
% 
% In:
% 	x		- the data
%	fFilter	- the frequency (in Hz) to filter out
%	fSample	- the sample frequency (in Hz)
% 
% Out:
% 	x - the filtered data
% 
% Updated:	2007-12-18
% Copyright 2007 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%zero angles
	w	= 2*pi*fFilter/fSample;
%filter coefficient
	f1	= -2*cos(w);
	f2	= 2+f1;

%filter the data
	b	= [f2 f1*f2 f2];
	x	= filter(b./sum(b), 1, [x(1) x]);

%fix the offset
	x	= x(1:end-1);
