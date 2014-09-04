function fc = FindFrequencyComponents(x,fs,varargin)
% FindFrequencyComponents
% 
% Description:	find significant frequency components of the power spectrum of x
% 
% Syntax:	fc = FindFrequencyComponents(x,fs,[sd]=3,[bPlot]=false)
% 
% In:
% 	x		- the signal
%	fs		- the sampling frequency of the signal
%	[sd]	- a frequency must have power greater than sd standard deviations
%			  above the mean to be considered a frequency component
%	bPlot	- true to plot the results
% 
% Out:
% 	fc	- an array of the frequencies determined to be significant in x
% 
% Updated:	2009-04-02
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[sd,bPlot]	= ParseArgs(varargin,3,false);

%get the power spectrum
	[p,f]	= PowerSpec(x,fs);

%find frequencies with significant power
	thresh	= mean(p) + sd*std(p);
	fc		= f(p >= thresh);

%optionally plot the results
	if bPlot
		alexplot(f,{p,thresh*ones(size(f))});
	end
