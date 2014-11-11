function varargout = PowerSpec(x,fs,varargin)
% PowerSpec
% 
% Description:	return the power spectrum of signal x, recorded with sampling
%				frequency fs.  optionally specify "plot" as the last argument
%				to plot the spectrum
%
% Syntax:	[p,freq,h] = PowerSpec(x,fs,<options>)
%
% In:
%	x				- an nData x nSignal array of signals or ffts
%	fs				- the sampling frequency, in Hz
%	<options>:
%		input:	('signal') a string specifying what was passed as x.  can be
%				'signal' or 'fft'.
%		plot:	(false) true to plot results. defaults to true if no output is
%				specified
%		out:	('dB') either 'dB' or 'abs' to specify the output type
%
% Out:
%	p		- an nData x nSignal array of the power spectra, in dB
%	freq	- an nData x 1 array of the frequency at each point of p, in Hz
%	h		- the handle to the plot, if specified
% 
% Updated:	2011-11-25
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'input'	, 'signal'	, ...
		'plot'	, []		, ...
		'out'	, 'dB'		  ...
		);
if isempty(opt.plot)
	opt.plot	= nargout==0 && size(x,2)==1;
end

%get the fourier transform
	switch lower(opt.input)
		case 'fft'
			f	= x;
		otherwise
			f	= fft(x);
	end

%get size info
	[nData,nSignal]	= size(f);
	nFreq			= floor(nData/2)+1;

%get the power
	switch lower(opt.out)
		case 'db'
			p	= 20*log10(abs(f(1:nFreq,:))+eps);
		otherwise
			p	= abs(f(1:nFreq,:));
	end
%get the frequencies
	freq	= reshape(k2f(1:nFreq,fs,nData),[],1);

if opt.plot
	strInput	= inputname(1);
	if ~isempty(strInput)
		strInput	= [' of ' strInput];
	end
	strTitle	= ['Power Spectrum' strInput];
	
	strXLabel	= 'Frequency (Hz)';
	strYLabel	= ['Power' conditional(isequal(lower(opt.out),'db'),' (dB)','')];
	h	= alexplot(freq,p,'title',strTitle,'xlabel',strXLabel,'ylabel',strYLabel);
else
	h	= [];
end

if nargout>0
	[varargout{1:3}]	= deal(p,freq,h);
end
