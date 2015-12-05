function Fit(p,varargin)
% PsychoCurve.Fit
% 
% Description:	fit a psychometric curve to the subject responses stored in
%				the xStim and bResponse properties
% 
% Syntax:	p.Fit(<options>)
%
% In:
%	<options>:
%		freezet:	(false) true to hold the t parameter fixed
%		robust:		(true) true for robust (and slower) fitting
% 
% Updated: 2012-02-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent ftTB ftB;

if isempty(ftTB)
	ftTB	= fittype('abs(weibull(x,t,b,xmin,g,a))','coefficients',{'t','b'},'problem',{'xmin','g','a'});
	ftB		= fittype('abs(weibull(x,t,b,xmin,g,a))','coefficients',{'b'},'problem',{'t','xmin','g','a'});
end

opt	= ParseArgs(varargin,...
		'freezet'	, false	, ...
		'robust'	, true	  ...
		);
strRobust	= conditional(opt.robust,'on','off');

%get the data to fit
	x	= p.x;
	f	= p.f;
	n	= p.n;
	
	%ignore bad data
		bIgnore	= isnan(x) | isnan(f);
		
		x(bIgnore)	= [];
		f(bIgnore)	= [];
		n(bIgnore)	= [];
	%repeat points with more measurements
		x	= arrayfun(@(x,n) repmat(x,[n 1]),x,n,'UniformOutput',false);
		f	= arrayfun(@(f,n) repmat(f,[n 1]),f,n,'UniformOutput',false);
		
		x	= cat(1,x{:});
		f	= cat(1,f{:});

%start at reasonable parameters
	bStart	= 5;
	tStart	= (p.xmin + p.xmax)/2;

%fit!
	try
		if opt.freezet
			[fo,gf,op]	= fit(x,f,ftB,'problem',{p.t, p.xmin, p.g, p.a},'startpoint',bStart,'lower',p.bmin,'upper',p.bmax,'robust',strRobust);
			
			p.b		= fo.b;
		else
			[fo,gf,op]	= fit(x,f,ftTB,'problem',{p.xmin, p.g, p.a},'startpoint',[tStart; bStart],'lower',[p.tmin p.bmin],'upper',[p.tmax p.bmax],'robust',strRobust);
			
			p.t		= fo.t;
			p.b		= fo.b;
		end
	catch me
		
	end
	
	p_GetFit(p);
