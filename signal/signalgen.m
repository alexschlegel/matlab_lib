function [x,t] = signalgen(f,varargin)
% signalgen
% 
% Description:	generate a signal
% 
% Syntax:	[x,t] = signalgen(f,[d]=1,<options>)
% 
% In:
% 	f	- the frequency of the signal, in Hz, or an array of frequencies
%	[d]	- the duration of the signal, in seconds
%	<options>:
%		type:		('sine') the type of signal to generate, or a cell of types.
%					one of the following:
%						'sine'		- sine wave
%						'cosine'	- cosine wave
%						'square'	- square wave
%						'sawtooth'	- sawtooth wave
%						f			- function handle that takes an array of
%									  times in seconds, a frequency in Hz, and a
%									  phase in radians and returns numbers
%									  between -1 and 1
%		rate:		(44100) the sampling rate, in Hz
%		amplitude:	(1) the amplitude of the signal, or an array of amplitudes
%		phase:		(0) the phase of the signal, in radians, or an array of
%					phases
% 
% Out:
% 	x	- the N x 1 signal
%	t	- the N x 1 time point of each sample
% 
% Updated: 2012-07-07
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[d,opt]	= ParseArgs(varargin,1,...
			'type'		, 'sine'	, ...
			'rate'		, 44100		, ...
			'amplitude'	, 1			, ...
			'phase'		, 0			  ...
			);

%parse the signal type
	opt.type	= ForceCell(opt.type);
	nType		= numel(opt.type);
	
	for kT=1:nType
		if ischar(opt.type{kT})
			opt.type{kT}	= CheckInput(opt.type{kT},'type',{'sine','cosine','square','sawtooth'});
			
			switch opt.type{kT}
				case 'sine'
					opt.type{kT}	= @signalgen_Sine;
				case 'cosine'
					opt.type{kT}	= @signalgen_Cosine;
				case 'square'
					opt.type{kT}	= @signalgen_Square;
				case 'sawtooth'
					opt.type{kT}	= @signalgen_Sawtooth;
			end
		end
	end

[f,opt.type,opt.amplitude,opt.phase]	= FillSingletonArrays(f,opt.type,opt.amplitude,opt.phase);
nSignal									= numel(f);

t	= (0:1/opt.rate:d-1/opt.rate)';
nT	= numel(t);

x	= zeros(nT,1);

for kS=1:nSignal
	x	= x + opt.amplitude(kS)*opt.type{kS}(t,f(kS),opt.phase(kS));
end

%------------------------------------------------------------------------------%
function x = signalgen_Sine(t,f,p)
	x	= sin(2*pi.*f.*t+p);
end
%------------------------------------------------------------------------------%
function x = signalgen_Cosine(t,f,p)
	x	= cos(2*pi.*f.*t+p);
end
%------------------------------------------------------------------------------%
function x = signalgen_Square(t,f,p)
	x	= square(2*pi.*f.*t+p);
end
%------------------------------------------------------------------------------%
function x = signalgen_Sawtooth(t,f,p)
	x	= sawtooth(2*pi.*f.*t+p);
end
%------------------------------------------------------------------------------%

end
