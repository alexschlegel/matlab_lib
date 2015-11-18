function param = distract_parameters(obj,nDistractor,param)
% stimulus.image.scribble.distract_parameters
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

%flip the most extreme points across the origin
	r			= sqrt(param.x.^2 + param.y.^2);
	[r,kSort]	= sort(r,'descend');
	
	nPoint	= numel(param.x);
	for kD=1:nDistractor
		param(kD)	= paramOrig;
		
		if kD<=nPoint
			kFlip	= kSort(kD);
			
			param(kD).x(kFlip)	= -param(kD).x(kFlip);
			param(kD).y(kFlip)	= -param(kD).y(kFlip);
		else
		%no more points to flip, just choose random values
			param(kD).x	= obj.get_coordinates('x');
			param(kD).y	= obj.get_coordinates('y');
		end
	end

