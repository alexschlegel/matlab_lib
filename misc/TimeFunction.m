function [tM,tSD,tHist,nHist,t]	= TimeFunction(f,varargin)
% TimeFunction
% 
% Description:	test the time it takes a function to run
% 
% Syntax:	[tM,tSD,tHist,nHist,t]	= TimeFunction(f,<options>)
% 
% In:
% 	f	- the handle to a function that takes no arguments
%	<options>:
%		timeout:	(10000) the target maximum duration of the test, in ms
%		maxcall:	(10000) the maximum number of executions of the function
% 
% Out:
% 	tM		- the mean execution time, in ms
%	tSD		- the standard deviation of the execution time
%	tHist	- the t-values of a histogram of execution times
%	nHist	- the n-values of a histogram of execution times
%	t		- the actual execution times
% 
% Updated: 2011-12-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent tGetSecs;

if isempty(tGetSecs)
	nTest		= 1000;
	tGetSecs	= zeros(nTest,1);
	
	for k=1:nTest
		tGetSecs(k)	= GetSecs-GetSecs;
	end
	tGetSecs	= mean(-tGetSecs);
end

opt	= ParseArgs(varargin,...
		'timeout'	, 10000	, ...
		'maxcall'	, 10000	  ...
		);

t	= NaN(opt.maxcall,1);

tStart	= GetSecs;
for k=1:opt.maxcall
	if GetSecs>tStart+opt.timeout/1000
		break;
	end
	
	t1	= GetSecs;
	f();
	t2	= GetSecs;
	
	t(k)	= t2-t1;
end

t	= 1000*t(~isnan(t)) - tGetSecs;

tM	= mean(t);
tSD	= std(t);

t1	= prctile(t,1);
t99	= prctile(t,99);

tHist	= GetInterval(t1,t99,max(10,numel(t)/10))';
nHist	= hist(t,tHist);
nHist	= reshape(nHist,[],1);

if nargout>2
	plot(tHist,100*nHist/numel(t));
	xlabel('ms');
	ylabel('%');
	title(['mean: ' num2str(tM) 'ms, sd: ' num2str(tSD) 'ms']);
end
