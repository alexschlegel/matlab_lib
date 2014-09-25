function [h,p,ci,stats] = ttestJK(x,varargin)
% ttestJK
% 
% Description:	perform a one-sample or paired t-test on jackknifed data
% 
% Syntax:	[h,p,ci,stats] = ttestJK(x,[m]=0,[alpha]=0.05,[tail]='both',[dim]='')
% 
% In:
% 	x		- the jackknifed sample data
%	m		- null-hypothesis is that x comes from a population with mean m. for
%			  a paired t-test, m should be an array the same size as x.
%	alpha	- significance level for the test (0->1)
%	tail	- one of the following:
%				'both':		two-tailed test (i.e. sig if x~=m)
%				'right':	right-tailed test (i.e. sig if x>m)
%				'left':		left-tailed test (i.e. sig if x<m)
%	dim		- the dimension along which to perform the t-test
% 
% Out:
% 	h		- a boolean value indicating whether the test rejected the null
%			  hypothesis
%	p		- the significance level
%	ci		- the 100*(1-alpha)% confidence interval of the mean
%	stats	- a struct of the following statistics:
%				tstat:	the t-statistic
%				df:		the degrees of freedom of the test
%				sd:		the jackknife-adjusted estimate of the population
%						standard deviation
% 
% Updated: 2014-09-25
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[m,alpha,tail,dim]	= ParseArgs(varargin,0,0.05,'both','');
tail				= CheckInput(tail,'tail',{'both','right','left'});

%check for paired t-test
if isequal(size(x),size(m))
	x	= x - m;
	m	= 0;
end

if isempty(dim)
	dim	= unless(find(size(x)~=1,1),1);
end

bUse	= ~isnan(x);
n		= sum(bUse,dim);
mX		= nanmean(x,dim);

stats.df	= n-1;
stats.sd	= nanstdJK(x,[],dim);
se			= stats.sd./sqrt(n);
stats.tstat	= (mX - m)./se;

switch tail
	case 'both'
		p	= 2*tcdf(-abs(stats.tstat),stats.df);
		mCI	= se.*tinv(1-alpha/2, stats.df);
		ci	= cat(dim,mX-mCI,mX+mCI);
	case 'right'
		p	= tcdf(-stats.tstat,stats.df);
		mCI	= se.*tinv(1-alpha,stats.df);
		ci	= cat(dim,mX-mCI,inf(size(p)));
	case 'left'
		p	= tcdf(stats.tstat,stats.df);
		mCI	= se.*tinv(1-alpha,stats.df);
		ci	= cat(dim,-inf(size(p)),mX+mCI);
end

h	= p<=alpha;
