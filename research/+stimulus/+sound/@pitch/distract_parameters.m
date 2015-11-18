function param = distract_parameters(obj,nDistractor,param)
% stimulus.sound.pitch.distract_parameters
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
paramOrig	= param;

%switch the two most extreme pitches. skip the actual extreme points, since that
%would open a simple strategy for telling a stimulus from its distractor (i.e.
%just remember when the high pitch occurred)
	[f,kSort]	= sort(param.f);
	
	nPoint	= numel(param.f);
	for kD=1:nDistractor
		param(kD)	= paramOrig;
		
		if kD<=nPoint-3
			k1	= ceil((kD+2)/2);
			k2	= nPoint-floor((kD+2)/2);
			
			kP1	= kSort(k1);
			kP2	= kSort(k2);
			
			tmp					= param(kD).f(kP1);
			param(kD).f(kP1)	= param(kD).f(kP2);
			param(kD).f(kP2)	= tmp;
		else
		%no more points to flip, just scramble the pitches
			param(kD).f	= randomize(param(kD).f,'seed',false);
		end
	end
