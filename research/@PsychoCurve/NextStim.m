function xStim = NextStim(p)
% PsychoCurve.NextStim
% 
% Description:	get the next stimulus value to test.  alternates between
%				choosing:
%					1) the stimulus with maximal information content
%					2) the stimulus whose prior responses lie farthest away from
%					   the best-fit psychometric curve.
% 
% Syntax:	xStim = p.NextStim
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

switch p.bNextMode
	case 0
	%choose a random value around the best-guess threshold until it is in an
	%acceptable range
		xStim	= Inf;
		while xStim<p.xmin || xStim>p.xmax
			xStim	= p.t + (p.xmax-p.xmin)*randn*p.randomness;
		end
 	case 1
	%most abnormal stimulus
		nX				= numel(p.x);
		fDiff			= abs(p.f - p.ffit);
		[fDiff,kSort]	= sort(fDiff);
		
		kTest	= max(1,nX - floor(nX*abs(randn)*p.randomness));
		kTest	= kSort(kTest);
		
		xStim	= p.x(kTest);
	case 1
	%maximal information stimulus
		xTest	= GetInterval(p.xmin,p.xmax,20);
		ITest	= p.I(xTest);
		xTest	= xTest(ITest~=0);
		xStimMI	= fminbnd(@(x) -p.I(x),min(xTest),max(xTest));
		
		if isempty(xStimMI)
			xStimMI	= p.t;
		end
		
		xStim	= Inf;
		while xStim<p.xmin || xStim>p.xmax
			xStim	= min(p.xmax,max(p.xmin,xStimMI + (p.xmax-p.xmin)*randn*p.randomness));
		end
end

%get the nearest acceptable value
	xStim	= closest(xStim,p.xvalid);

p.bNextMode	= mod(p.bNextMode+1,1);
