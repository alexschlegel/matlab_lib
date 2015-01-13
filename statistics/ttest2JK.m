function [h,p,ci,stats] = ttest2JK(x,y,varargin)
% ttestJK
% 
% Description:	perform an unpaired t-test on jackknifed data
% 
% Syntax:	[h,p,ci,stats] = ttest2JK(x,y,[alpha]=0.05,[tail]='both',[vartype]='equal',[dim]='')
% 
% In:
% 	x		- the first set of jackknifed sample data
%	y		- the second set of jackknifed sample data
%	alpha	- significance level for the test (0->1)
%	tail	- one of the following:
%				'both':		two-tailed test (i.e. sig if x~=m)
%				'right':	right-tailed test (i.e. sig if x>m)
%				'left':		left-tailed test (i.e. sig if x<m)
%	vartype	- the type of variance to assume (see ttest2)
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
[alpha,tail,vartype,dim]	= ParseArgs(varargin,0.05,'both','equal','');
tail						= CheckInput(tail,'tail',{'both','right','left'});
vartype						= CheckInput(vartype,'vartype',{'equal','unequal'});

if isempty(dim)
	dim	= unless(find(size(x)~=1,1),1);
end

bUseX	= ~isnan(x);
nX		= sum(bUseX,dim);
mX		= nanmean(x,dim);
s2X		= nanvarJK(x,[],dim);

bUseY	= ~isnan(y);
nY		= sum(bUseY,dim);
mY		= nanmean(y,dim);
s2Y		= nanvarJK(y,[],dim);

d	= mX - mY;
switch vartype
	case 'equal'
		df			= nX + nY - 2;
		stats.df	= df;
		stats.sd	= sqrt(((nX-1) .* s2X + (nY-1) .* s2Y) ./ stats.df);
		se			= stats.sd .* sqrt(1./nX + 1./nY);
	case 'unequal'
		s2XBar		= s2X./nX;
		s2YBar		= s2Y./nY;
		df			= (s2XBar + s2YBar) .^2 ./ (s2XBar.^2 ./ (nX-1) + s2YBar.^2 ./ (nY-1));
		stats.df	= df;
		se			= sqrt(s2XBar + s2YBar);
		
		if se==0
			df	= 1;
		end
end
stats.tstat	= d ./ se;
stats	= orderfields(stats,{'tstat','df','sd'});

if isscalar(stats.df) && ~isscalar(stats.tstat)
	stats.df	= repmat(stats.df,size(stats.tstat));
end

switch tail
	case 'both'
		p	= 2*tcdf(-abs(stats.tstat),df);
		mCI	= se.*tinv(1-alpha/2, df);
		ci	= cat(dim,d-mCI,d+mCI);
	case 'right'
		p	= tcdf(-stats.tstat,df);
		mCI	= se.*tinv(1-alpha,df);
		ci	= cat(dim,d-mCI,inf(size(p)));
	case 'left'
		p	= tcdf(stats.tstat,df);
		mCI	= se.*tinv(1-alpha,df);
		ci	= cat(dim,-inf(size(p)),d+mCI);
end

h	= p<=alpha;
