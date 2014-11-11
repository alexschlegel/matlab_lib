classdef PsychoCurve < handle
% PsychoCurve
% 
% Description:	an object for fitting psychometric curves.  Uses the Weibull
%				function (see weibull) for fitting curves Computer Adaptive
%				Testing based on info here:
%					http://echo.edres.org:8080/scripts/cat/catdemo.htm
% 
% Syntax:	p = PsychoCurve([xStim]=[],[bResponse]=[],<options>)
% 
% 			subfunctions:
%				Clear		- clear existing data
%				Run			- run a procedure to probe and fit a psychometric
%							  curve
%				Plot		- plot the results of the fitting procedure
%				Fit			- fit a psychometric curve from xStim and bResponse
% 				Fake		- generate a set of x values and subject responses,
%							  given the current psychometric curve parameters
%				Step:		- run one step of the procedure to probe and fit
%							  a psychometric curve
%				StepThresh	- iterate the treshold estimate based on xStim and
%							  bResponse
%				P			- the predicted response at a stimulus value
%				I			- calculate the amount of information revealed by a
%							  test at a particular x value
%				S			- calculate the difference between a subject's
%							  response and that predicted by their psychometric
%							  curve
% 
% 			properties:
%				xStim		- the stimulus values tested
%				bResponse	- the subject response at each test represented by
%							  xStim
%				t			- the subject's treshold x-value
%				tmin		- the minimum possible t-value
%				tmax		- the maximum possible t-value
%				b			- the "slope" of the psychometric curve
%				bmin		- the minimum possible b-value
%				bmax		- the maximum possible b-value
%				xmin		- the minimum stimulus value
%				xmax		- the maximum stimulus value
%				xstep		- the smallest stimulus step
%				g			- the minimum expected performance (0->1)
%				a			- the performance at threshold (0->1)
%				x (get)		- the unique x values tested
%				f (get)		- the performance at each x value (0->1)
%				n (get)		- the number of tests at each unique value
%				ffit (get)	- the best-fit performance
%				r2 (get)	- the r^2 (coefficient of determination) of the fit
%				se (get)	- the standard error of the threshold estimate
%				F:			- a function that takes a stimulus value as input and
%							  returns the subject response (true or false)
%				randomness	- the amount of randomness in choosing the next
%							  stimulus value to probe
%				hist (get)	- a struct tracking the history of the t, b, r2, and
%							  se values
%				debug		- true to debug the results
% 
% In:
% 	[xStim]		- the stimulus values tested
%	[bResponse]	- the subject response (false or true) at each test represented
%				  by xStim
%	<options>:
%		fit:		(true) true to fit a curve automatically if parameters are
%					passed in on object creation
%		t:			((xmin+xmax)/2) initial t value
%		tmin:		(<xmin>) initial tmin value
%		tmax:		(<xmax>) initial tmax value
%		b:			(5) initial b value
%		bmin:		(0) initial bmin value
%		bmax:		(50) initial bmax value
%		xmin:		(0) initial xmin value
%		xmax:		(1) initial xmax value
%		xstep:		((<10% of range>) the initial xstep value
%		g:			(0) initial g value
%		a:			((1+g)/2) initial a value
%		F:			(<none>) initial test function
%		randomness:	(0.1) initial randomness value
%		debug:		(false) true to debug the results
%
% Example:
%	f = @(x) binornd(1,weibull(x,0.5,5,0,0,0.5));
%	pc = PsychoCurve('F',f,'debug',true);
%	figure; figure; figure;
%	pc.Run;
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

	%PUBLIC PROPERTIES---------------------------------------------------------%
	properties
		xStim;
		bResponse;
		t;
		tmin;
		tmax;
		b;
		bmin;
		bmax;
		xmin;
		xmax;
		xstep;
		g;
		a;
		F;
		randomness;
		debug;
	end
	properties (SetAccess=protected)
		x;
		f;
		n;
		ffit;
		r2;
		se;
		
		hist;
	end
	%PUBLIC PROPERTIES---------------------------------------------------------%
	
	
	%PRIVATE PROPERTIES--------------------------------------------------------%
	properties (SetAccess=private, GetAccess=private)
		opt; 
		
		bNextMode	= 0;
		
		xvalid;
	end
	%PRIVATE PROPERTIES--------------------------------------------------------%
	
	
	%PROPERTY GET/SET----------------------------------------------------------%
	methods
		function p = set.xStim(p,xStim)
			p.xStim	= xStim;
			p.x		= reshape(unique(xStim),[],1);
			
			p_GetFit(p);
		end
		function p = set.bResponse(p,bResponse)
			p.bResponse	= bResponse;
			
			p_GetFit(p);
		end
		function p = set.x(p,x)
			p.x		= x;
			
			p_GetFit(p);
		end
		function p = set.t(p,t)
			p.t		= t;
			
			p_GetFit(p);
		end
		function p = set.b(p,b)
			p.b		= b;
			
			p_GetFit(p);
		end
		function p = set.g(p,g)
			p.g		= g;
			
			p_GetFit(p);
		end
		function p = set.xmin(p,xmin)
			p.xmin	= xmin;
			
			p_GetFit(p);
		end
		function p = set.xstep(p,xstep)
			p.xstep	= xstep;
			
			p.xvalid	= p.xmin:p.xstep:p.xmax;
		end
		function p = set.a(p,a)
			p.a		= a;
			
			p_GetFit(p);
		end
	end
	%PROPERTY GET/SET----------------------------------------------------------%
	
	
	%PUBLIC METHODS------------------------------------------------------------%
	methods
		function p = PsychoCurve(varargin)
			[xStim,bResponse,p.opt]	= ParseArgs(varargin,[],[],...
											'fit'			, true			, ...
											't'				, []			, ...
											'tmin'			, []			, ...
											'tmax'			, []			, ...
											'b'				, 5				, ...
											'bmin'			, 0				, ...
											'bmax'			, 50			, ...
											'xmin'			, 0				, ...
											'xmax'			, 1				, ...
											'xstep'			, []			, ...
											'g'				, 0				, ...
											'a'				, []			, ...
											'F'				, @(x) false	, ...
											'randomness'	, 0.1			, ...
											'debug'			, false			  ...
											);
			
			p.xStim			= xStim;
			p.bResponse		= bResponse;
			
			p_Init(p);
		end
	end
	methods (Static)
		function [x,f,n] = BinResponses(xStim,bResponse,nBin)
		% PsychoCurve.BinResponses
		% 
		% Description:	bin responses into fractional responses in a smaller
		%				number of bins
		% 
		% Syntax:	[x,f,n] = BinResponses(xStim,bResponse,nBin)
		% 
		% In:
		% 	xStim		- an array of stimulus values
		%	bResponse	- an array of the binary response for each stimulus in
		%				  xStim
		%	nBin		- the number of bins to use
		% 
		% Out:
		% 	x	- the bin stimulus values
		%	f	- the fraction of true responses for stimuli in each x bin
		%	n	- the number of tests in each bin
		% 
		% Updated: 2012-02-01
		% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
		% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
		% License.
		
		%get the bin centers
			[n,x]	= hist(xStim,nBin);
			x		= reshape(x,[],1);
		%assign each unique stimulus to a bin
			xU		= unique(xStim);
			nX		= numel(xU);
			kBin	= NaN(nX,1);
			for kX=1:nX
				xDiff		= abs(x - xU(kX));
				kBin(kX)	= find(xDiff==min(xDiff),1);
			end
		%get the response fraction for each bin
			[s,n]	= deal(zeros(nBin,1));
			
			for kX=1:nX
				b	= xStim==xU(kX);
				
				s(kBin(kX))	= s(kBin(kX)) + sum(bResponse(b));
				n(kBin(kX))	= n(kBin(kX)) + sum(b);
			end
			
			f	= s./n;
		%destroy NaNs
			bIgnore	= isnan(x) | isnan(f);
			
			n(bIgnore)	= [];
			x(bIgnore)	= [];
			f(bIgnore)	= [];
		end
	end
	%PUBLIC METHODS------------------------------------------------------------%
	
	
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	methods
		
	end
	%OVERLOADED FUNCTIONS------------------------------------------------------%
	
	
	%PRIVATE METHODS-----------------------------------------------------------%
	methods (Access=private)
		
	end
	%PRIVATE METHODS-----------------------------------------------------------%
	
end
