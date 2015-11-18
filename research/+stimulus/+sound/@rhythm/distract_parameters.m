function param = distract_parameters(obj,nDistractor,param)
% stimulus.sound.rhythm.distract_parameters
% 
% Description:	alter the stimulus parameters for the distractor
% 
% Syntax: param = obj.distract_parameters(nDistractor,param)
% 
% In:
%	nDistractor	- the number of distractors needed
%	param		- a struct of stimulus parameters
% 
% Out:
%	param	- a struct array of altered versions of param for generating the
%			  distractor stimuli
% 
% Updated:	2015-11-17
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
assert(nDistractor==1,'only one distractor can be generated');

%for patterns defined by time, place the most crowded beat into the longest
%empty period
	if ~strcmp(param.pattern,'uniform')
		%distance in between each beat
			d	= diff([param.t; param.dur]);
		%halfway into the longest silent period
			dMax	= max(d);
			kMax	= find(d==dMax,1);
			
			tSilent	= param.t(kMax) + dMax/2;
		%most crowded beat
			dAround		= d(1:end-1) + d(2:end);
			
			dCrowded	= min(dAround);
			kCrowded	= find(dAround==dCrowded,1) + 1;
		
		%move that beat
			param.t(kCrowded)	= tSilent;
			param.t				= sort(param.t);
	end

%for instrument patterns, randomly switch two of the beats
	kInstrument	= unique(param.sequence);
	
	if numel(kInstrument)>1
		k1	= find(param.sequence==kInstrument(1));
		k2	= find(param.sequence==kInstrument(2));
		
		kSwitch1	= k1(randi(numel(k1)));
		kSwitch2	= k2(randi(numel(k2)));
		
		param.sequence(kSwitch1)	= kInstrument(2);
		param.sequence(kSwitch2)	= kInstrument(1);
	end
