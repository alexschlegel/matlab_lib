function [as,varargout] = CronbachAlpha(x)
% CronbachAlpha
% 
% Description:	calculate Cronbach's alpha for a set of psychometric measurements
% 
% Syntax:	[as,au] = CronbachAlpha(x)
% 
% In:
% 	x	- an nRep x nItem array of ratings, so that each row is the set of
%		  obvservations from one repetition and each column is the set of all
%		  observations for a given item
% 
% Out:
% 	as	- the standardized Cronbach's alpha
%	au	- the unstandardized Cronbach's alpha
% 
% Updated: 2012-09-24
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nItem	= size(x,2);

%logical array for selecting upper triangular part of the correlation and
%covariance matrices, where the good stuff is
	b	= triu(true(nItem),1);

%standardized alpha
	%pairwise correlations between items
		r	= corrcoef(x);
	%mean of the meaningful, non-redundant correlations
		r	= nanmean(r(b));
	
	as	= nItem*r/(1 + (nItem-1)*r);

%unstandardized alpha
if nargout>1
	%variance/covariance matrix
		vc	= nancov(x);
	%mean variance (variances are along the diagonal)
		v	= nanmean(diag(vc));
	%mean covariance, not including variances
		c	= nanmean(vc(b));
	
	varargout{1}	= nItem*c/(v + (nItem-1)*c);
end
