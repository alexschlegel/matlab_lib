function [xSample,tSample] = Generate(osc,f,t,varargin)
% Synth.Oscillator.Generate
% 
% Description:	generate samples from an oscillator
% 
% Syntax:	[xSample,tSample] = osc.Generate(f,t,<options>)
% 
% In:
% 	f	- the output frequency, or an array of frequency control points
%	t	- the sample duration, in seconds, or an array of time control points
%	<options>:
%		interp:		(<default>) the interpolation method for stepping between
%					frequencies.  one of the following:
%						'step':	stay at each frequency until the start of the
%								next 
%						or one of the interpolation methods in interp1
%		step_dur:	(<default>) for 'step' interpolation, the transition time in
%					seconds from one frequency to another
% 
% Out:
% 	xSample	- the sample
%	tSample	- the timepoints associated with x
% 
% Updated: 2011-12-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(t)
	[xSample,tSample]	= deal([]);
end

opt	= ParseArgs(varargin,...
		'interp'	, []	, ...
		'step_dur'	, []	  ...
		);
if isempty(opt.interp)
	opt.interp	= osc.interp;
end
if isempty(opt.step_dur) && isequal(opt.interp,'step')
	opt.step_dur	= osc.step_dur;
end


[t,kSort]	= sort(t);
f			= f(kSort);

[t,f]	= varfun(@(x) reshape(x,[],1),t,f);

if numel(t)==1 && t(1)~=0
	t	= [0; t];
	f	= [f(1); f];
end

step	= 1/osc.rate;
tSample	= GetInterval(min(t),max(t)-step,step,'stepsize')';

switch lower(opt.interp)
	case 'step'
		if opt.step_dur==0
			tInterp		= interp1(t,t,tSample,'nearest');
			[b,kT]		= ismember(tInterp,t);
			tDiff		= tSample - t(kT);
			bBump		= tDiff<0;
			kT(bBump)	= max(1,kT(bBump)-1);
			
			fSample	= f(kT);
		else
			tInner	= [t(2:end)-opt.step_dur t(2:end)]';
			fInner	= [f(1:end-1) f(2:end)]';
			
			tMod	= [t(1); reshape(tInner,[],1)];
			fMod	= [f(1); reshape(fInner,[],1)];
			
			fSample	= interp1(tMod,fMod,tSample,'pchip');
		end
	otherwise
		fSample	= interp1(t,f,tSample,opt.interp);
end

xSample	= fevalWarp(osc.f,tSample,fSample./osc.frequency);
