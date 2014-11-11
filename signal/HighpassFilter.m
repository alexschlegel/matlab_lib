function [x,f] = HighpassFilter(x,fs,fC,varargin)
% HighpassFilter
% 
% Description:	highpass filter a signal
% 
% Syntax:	x = HighpassFilter(x,fs,fC,<options>)
% 
% In:
% 	x	- a signal or nSignal x nSample array of signals
%	fs	- the sampling rate of the signal
%	fC	- the cutoff frequency
%	<options>:
%		f:		([]) the filter returned by a previous call to the function if
%				the same parameters should be used (saves time)
%		silent:	(false) true to suppress status output
% 
% Out:
% 	x	- the filtered signal
%	f	- the filter used
% 
% Updated: 2010-07-26
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'f'			, []	, ...
		'silent'	, false	  ...
		);

status('Highpass filtering','silent',opt.silent);

%reshape the data
	bColumn	= size(x,2)==1;
	if bColumn
		x	= reshape(x,1,[]);
	end

%get the filter
	if isempty(opt.f)
		%filter order
			n	= ceil(3*(fs./fC));
		%design the filter
			d	= fdesign.highpass('N,Fc',n,fC,fs);
			f	= design(d);
	else
		f	= opt.f;
	end
	
%filter
	x	= filter(f,x,2);
%fix the offset error
	n2	= round(n/2);
	x	= [x(:,n2+1:end) repmat(x(:,end),[1 n2])];

%unreshape
	if bColumn
		x	= reshape(x,[],1);
	end
