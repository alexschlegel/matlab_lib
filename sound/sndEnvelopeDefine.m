function sEnvelope = sndEnvelopeDefine(strType,varargin)
% sndEnvelopeDefine
% 
% Description:	define a sound envelope
% 
% Syntax:	sEnvelope = sndEnvelopeDefine(strType,<options>)
% 
% In:
%	strType	- the type of envelope, for setting default
%				values:
%					'oscillator':
%						a_start:	1
%						a_attack:	1
%						a_sustain:	1
%						a_end:		1
%						t_attack:	0.1
%						t_decay:	0.2
%						t_release:	0.2
%						f_attack:	'constant'/1
%						f_decay:	'constant_vibrato'/1/0/0.025/0/2
%						f_sustain:	'constant_vibrato'/1/0.025/0.05/2/4
%						f_release:	'constant'/1
%					'filter'
%						a_start:	1
%						a_attack:	1
%						a_sustain:	1
%						a_end:		1
%						t_attack:	0.1
%						t_decay:	0.2
%						t_release:	0.2
%						f_attack:	'constant'/1
%						f_decay:	'constant'/1
%						f_sustain:	'constant'/1
%						f_release:	'constant'/1
%					'amplifier'
%						a_start:	0
%						a_attack:	1.25
%						a_sustain:	1
%						a_end:		0
%						t_attack:	0.1
%						t_decay:	0.2
%						t_release:	0.2
%						f_attack:	'exp_grow'/2
%						f_decay:	'exp_decay'/1
%						f_sustain:	'constant'/1
%						f_release:	'exp_decay'/1
% 	<options>:
%		rate:		(44100) the sampling frequency, in Hz
%		a_start:	the fractional amplitude at the start of the envelope
%		a_attack:	the fractional amplitude at the end of the attack
%		a_sustain:	the fractional amplitude at the beginning of the sustain
%		a_end:		the fractional amplitude at the end of the release
%		t_attack:	the attack duration, or a function of key strength and
%					frequency that returns the duration
%		t_decay:	the decay duration or function as above
%		t_release:	the release duration or function as above
%		f_attack:	one of the following to specify a function to use for the
%					attack portion of the envelope. parameters with default
%					values are listed after each function:
%						'exp_grow': exponential growth
%							abruptness	(1)
%						'exp_decay': exponential decay
%							abruptness (1)
%						'constant': constant function
%							value	(1)
%						'$$$_vibrato': $$$ with vibrato
%							vibrato_a_start	(1) vibrato amplitude at the
%								start of the period
%							vibrato_a_end	(1) vibrato amplitude at the end of
%								the period
%							vibrato_f_start	(8) vibrato frequency (in Hz) at the
%								start of the period
%							vibrato_f_end(8) vibrato frequency (in Hz) at the
%								end of the period
%						f:	a handle to a function that takes as its inputs a 
%							a vector of values between 0 and 1 (for fractional
%							time in the period), a key strength and frequency,
%							and some number of parameters, and returns values
%							between 0 and 1 (amplitude)
%						OR: a cell whose first element is one of the above and
%							whose remaining elements are name/value pairs of
%							parameters.  parameters names must be unique across
%							the envelope.
%		f_decay:	see f_attack
%		f_sustain	see f_attack
%		f_release:	see f_attack
% 
% Out:
% 	sEnvelope	- the envelope struct
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
rateDefault	= 44100;

switch lower(strType)
	case 'oscillator'
		opt	= ParseArgs(varargin,...
				'rate'		, rateDefault																											, ...
				'a_start'	, 1																														, ...
				'a_attack'	, 1																														, ...
				'a_sustain'	, 1																														, ...
				'a_end'		, 1																														, ...
				't_attack'	, 0.1																													, ...
				't_decay'	, 0.2																													, ...
				't_release'	, 0.2																													, ...
				'f_attack'	, {'constant','value',1}																								, ...
				'f_decay'	, {'constant_vibrato','value',1,'vibrato_a_start',0,'vibrato_a_end',0.005,'vibrato_f_start',0,'vibrato_f_end',5}		, ...
				'f_sustain'	, {'constant_vibrato','value',1,'vibrato_a_start',0.005,'vibrato_a_end',0.01,'vibrato_f_start',5,'vibrato_f_end',5}	, ...
				'f_release'	, {'constant','value',1}																								  ...
				);
	case 'filter'
		opt	= ParseArgs(varargin,...
				'rate'		, rateDefault				, ...
				'a_start'	, 1							, ...
				'a_attack'	, 1							, ...
				'a_sustain'	, 1							, ...
				'a_end'		, 1							, ...
				't_attack'	, 0.1						, ...
				't_decay'	, 0.2						, ...
				't_release'	, 0.2						, ...
				'f_attack'	, {'constant','value',1}	, ...
				'f_decay'	, {'constant','value',1}	, ...
				'f_sustain'	, {'constant','value',1}	, ...
				'f_release'	, {'constant','value',1}	  ...
				);
	case 'amplifier'
		opt	= ParseArgs(varargin,...
				'rate'		, rateDefault					, ...
				'a_start'	, 0								, ...
				'a_attack'	, 1.25							, ...
				'a_sustain'	, 1								, ...
				'a_end'		, 0								, ...
				't_attack'	, 0.1							, ...
				't_decay'	, 0.2							, ...
				't_release'	, 0.2							, ...
				'f_attack'	, {'exp_grow','abruptness',2}	, ...
				'f_decay'	, {'exp_decay','abruptness',1}	, ...
				'f_sustain'	, {'constant','value',1}		, ...
				'f_release'	, {'exp_decay','abruptness',1}	  ...
				);
	otherwise
		error(['"' tostring(strType) '" is not a valid envelope type.']);
end

sEnvelope			= opt;

cFunction	= {'f_attack','f_decay','f_sustain','f_release'};
nFunction	= numel(cFunction);
for kF=1:nFunction
	sEnvelope.(cFunction{kF})	= ParseFunction(cFunction{kF});
end

%------------------------------------------------------------------------------%
function sF = ParseFunction(strFunction)
	cF	= sEnvelope.(cFunction{kF});
	
	if numel(cF)==0
		error(['Bad function definition for ' strFunction '.']);
	end
	if ischar(cF{1})
		cInputType	= {'norm'};
		switch cF{1}
			case {'exp_grow','exp_grow_vibrato'}
				f		= {@(t,kS,kF,a) (exp(t.^a)-1)./(exp(1)-1)};
				cPName	= {{'abruptness'}};
			case {'exp_decay','exp_decay_vibrato'}
				f		= {@(t,kS,kF,a) (exp(-t.^(1/a))-exp(-1.^(1/a)))./(1-exp(-1.^(1/a)))};
				cPName	= {{'abruptness'}};
			case {'constant','constant_vibrato'}
				f		= {@(t,kS,kF,v) repmat(v,size(t))};
				cPName	= {{'value'}};
			otherwise
				error(['"' cF{1} '" is an unrecognized built-in function.']);
		end
		if numel(cF{1})>=8 && ~isempty(strfind(cF{1},'_vibrato'))
			cInputType{end+1}	= 'abs';
			f{end+1}			= @(t,kS,kF,aStart,aEnd,fStart,fEnd) MapValue(t,min(t),max(t),aStart,aEnd,'map_function','sigmoid').*sin(2*pi*MapValue(t,min(t),max(t),fStart,fEnd,'map_function','sigmoid').*t);
			cPName{end+1}		= {'vibrato_a_start','vibrato_a_end','vibrato_f_start','vibrato_f_end'};
		end
	else
		cInputType	= {'norm'};
		f			= {cF{1}};
		cPName		= {cF(2:2:end)};
	end
	
	sF	= sndFunctionDefine(3,f,'param_name',cPName,'input_type',cInputType);
	
	for kP=2:2:numel(cF)
		sF	= sndFunctionSetParam(sF,cF{kP},cF{kP+1});
	end
end
%------------------------------------------------------------------------------%

end