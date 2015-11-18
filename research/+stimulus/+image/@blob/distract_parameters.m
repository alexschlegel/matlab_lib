function param = distract_parameters(obj,nDistractor,param)
% stimulus.image.blob.distract_parameters
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

%switch the two most extreme points
	[r,kSort]	= sort(param.r);
	
	nPoint	= numel(param.r);
	for kD=1:nDistractor
		param(kD)	= paramOrig;
		
		if kD<=nPoint-1
			k1	= ceil(kD/2);
			k2	= nPoint-floor(kD/2);
			
			kP1	= kSort(k1);
			kP2	= kSort(k2);
			
			%make sure we have at least pi/4 between the two points
				a1	= param(kD).a(kP1);
				a2	= param(kD).a(kP2);
				
				if abs(a2-a1) < pi/4
					if a1<a2
						a2	= mod(a1+pi/4,2*pi);
					else
						a1	= mod(a2+pi/4,2*pi);
					end
				end
			
			param(kD).a(kP1)	= a2;
			param(kD).a(kP2)	= a1;
		else
		%no more points to flip, just scramble the point locations
			param(kD).a	= randomize(param(kD).a,'seed',false);
		end
	end
