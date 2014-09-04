function p_Init(p)
% p_Init
% 
% Description:	initialize the object values
% 
% Syntax:	p_Init(p)
% 
% Updated: 2012-02-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
p.b				= p.opt.b;
p.bmin			= unless(p.opt.bmin,0);
p.bmax			= unless(p.opt.bmax,20);
p.xmin			= p.opt.xmin;
p.xmax			= p.opt.xmax;
p.xstep			= unless(p.opt.xstep,(p.xmax-p.xmin)/10);
p.g				= p.opt.g;
p.t				= unless(p.opt.t,(p.xmin+p.xmax)/2);
p.tmin			= unless(p.opt.tmin,p.xmin);
p.tmax			= unless(p.opt.tmax,p.xmax);
p.a				= unless(p.opt.a,(1+p.g)/2);
p.F				= p.opt.F;
p.randomness	= p.opt.randomness;
p.debug			= p.opt.debug;

p.hist	= dealstruct('t','b','r2','se',[]);

if ~isempty(p.xStim) && ~isempty(p.bResponse) && p.opt.fit
	p.Fit;
end
