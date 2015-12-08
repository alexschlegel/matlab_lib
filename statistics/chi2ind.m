function [h,p,stats] = chi2ind(varargin)
% chi2ind
% 
% Description:	perform a chi-square test for independence
% 
% Syntax:	[h,p,stats] = chi2ind(ct,<options>) OR
%			[h,p,stats] = chi2ind(x,y,<options>)
% 
% In:
% 	ct		- an nGroup x nLabel contingency table. each row is the data from
%			  one group and each column represents a label that can be assigned
%			  to a group member. e.g. are democrats more likely to be female
%			  than republicans?
%							male	female
%				democrat	  5       8
%				republican	  7       6
%			  would yield the contingency table [5 8; 7 6].
%	[x/y]	- an array specifying the label assigned to each member of one group
% <options>:
%		yates:	(false) true to apply Yates' correction
%		alpha:	(0.05) the significance cutoff
% 
% Out:
% 	h		- true if the null hypothesis should be rejected
%	p		- the p-value
%	stats	- a struct of stats
% 
% Notes:
%	adapted from http://www.mathworks.com/matlabcentral/answers/96572-how-can-i-perform-a-chi-square-test-to-determine-how-statistically-different-two-proportions-are-in
% 
% Updated: 2015-12-07
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[x,y,opt]	= ParseArgs(varargin,[],[],...
				'yates'	, false	, ...
				'alpha'	, 0.05	  ...
				);

if ~isempty(y)
	nX	= numel(x);
	nY	= numel(y);
	
	x	= reshape(x,[],1);
	y	= reshape(y,[],1);
	
	lbl		= unique([x; y]);
	nLabel	= numel(lbl);
	kLabel	= (1:nLabel)';
	
	[b,x]	= ismember(x,lbl);
	[b,y]	= ismember(y,lbl);
	
	ctX	= arrayfun(@(k) sum(x==k),kLabel);
	ctY	= arrayfun(@(k) sum(y==k),kLabel);
	
	ct	= [ctX ctY]';
else
	ct	= x;
end

[nGroup,nLabel]	= size(ct);
nObs			= sum(ct(:));

nByLabel	= sum(ct,1);
nByGroup	= sum(ct,2);
fByLabel	= nByLabel./nObs;

nExpected	= repmat(fByLabel,[nGroup 1]).*repmat(nByGroup,[1 nLabel]);

observed	= reshape(ct,[],1);
expected	= reshape(nExpected,[],1);

yates			= conditional(opt.yates,0.5,0);
stats.ct		= ct;
stats.chi2stat	= sum( (abs(observed - expected) - yates).^2./expected);
stats.df		= (nLabel - 1).*(nGroup - 1);

p	= 1 - chi2cdf(stats.chi2stat,stats.df);
h	= p <= opt.alpha;
