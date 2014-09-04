function StepThresh(p)
% PsychoCurve.StepThresh
% 
% Description:	iterate the treshold estimate based on xStim and bResponse
% 
% Syntax:	p.StepThresh
% 
% Updated: 2012-02-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%p.Fit('freezet',true,'robust',false);
p.Fit('robust',false);

% mxStep	= (p.xmax-p.xmin)/4;
% tStep	= nansum(p.S(p.xStim,p.bResponse))*p.se^2;
% tStep	= sign(tStep).*min(mxStep,abs(tStep));

% if ~isnan(tStep)
% 	pad		= (p.xmax-p.xmin)/20;
	
% 	p.t		= min(p.xmax-pad,max(p.xmin+pad,p.t + tStep));
% 	p.se	= 1/sqrt(nansum(p.I(p.xStim)));
% else
% 	p.Fit('bin',10);
% end

p.hist.t(end+1)		= p.t;
p.hist.b(end+1)		= p.b;
p.hist.r2(end+1)	= p.r2;
p.hist.se(end+1)	= p.se;
