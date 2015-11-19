function param = validate(obj,param)
% stimulus.sound.pitch.validate
% 
% Description:	validate a set of parameter values
% 
% Syntax: param = obj.validate(param)
% 
% In:
%	param	- a struct of parameter values
%
% Out:
%	param	- the validated parameter struct
% 
% Updated:	2015-10-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%validate superclass stuff
	param	= validate@stimulus.sound.base(obj,param);

%number of beats
	assert(isscalar(param.n) && isint(param.n) && param.n>0,'n must be a positive integer scalar');

%instrument
	param.instrument	= ForceCell(param.instrument);
	nInstrument			= numel(param.instrument);
	
	param.fInstrument	= cell(nInstrument,1);
	for kI=1:nInstrument
		%replace preset indices with their samples
		if isscalar(param.instrument{kI})
			nPreset	= numel(obj.presetSample);
			assert(param.instrument{kI}<=nPreset,'preset instrument index must be between 1 and %d',nPreset);
			
			param.instrument{kI}	= obj.presetSample{kI};
		end
		
		switch class(param.instrument{kI})
			case 'char'
				try
					param.fInstrument{kI}	= str2func(param.instrument{kI});
				catch me
					error('instrument %d is invalid',kI);
				end
				
				nArg	= nargin(param.fInstrument{kI});
				assert(nArg~=0,'instrument function %d must take at least one input argument',kI);
			otherwise
				assert(isnumeric(param.instrument{kI}),'instrument %d must be either a function name or a numeric sample array',kI);
				
				param.fInstrument{kI}	= param.instrument{kI};
		end
	end
	
%frequency
	assert(isscalar(param.f) && param.f>0,'f must be a postive scalar');

%pattern
	param.pattern	= CheckInput(param.pattern,'pattern',{'random','uniform'});

%beat times
	param.t	= sort(reshape(param.t,[],1));
	nT		= numel(param.t);
	
	assert(isnumeric(param.t) && all(param.t>=0) && all(param.t<param.dur),'the array of beat times must be an array of non-negative values less than the sequence duration (%f s)',param.dur);

%instrument sequence
	param.sequence	= reshape(param.sequence,[],1);
	
	assert(numel(param.sequence)==nT,'t and sequence must have the same length');
	assert(isnumeric(param.sequence) && all(isint(param.sequence)) && all(param.sequence>0) && all(param.sequence<=nInstrument),'sequence must be an array of instrument indices');
