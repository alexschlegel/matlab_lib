function Step(p,varargin)
% PsychoCurve.Step
% 
% Description:	get another measurement and update the psychometric curve
% 
% Syntax:	p.Step(<options>)
%
% In:
%	<options>:
%		x:		(<any>) an array of allowed x values
%		plot:	(<debug>) true to update the plot 
%		silent:	(false) true to suppress status messages
% 
% Updated: 2012-02-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'x'			, []		, ...
		'plot'		, p.debug	, ...
		'silent'	, false		  ...
		);

%get the recommended x value
	xStim	= p.NextStim;
%get the nearest allowed value
	if ~isempty(opt.x)
		xDiff	= abs(xStim-opt.x);
		xStim	= opt.x(find(xDiff==min(xDiff),1));
	end
%get the response for that stimulus
	bResponse	= p.F(xStim);
%add to our list
	p.xStim(end+1)		= xStim;
	p.bResponse(end+1)	= bResponse;
%update the curve
	p.StepThresh;

if ~opt.silent
	disp(['T: ' StringFill(p.t,16,' ','right') ' | S.E.: ' StringFill(p.se,16,' ','right')]);
	
	if opt.plot
		p.Plot;
	end
end