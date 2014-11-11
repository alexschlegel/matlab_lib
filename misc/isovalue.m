function v = isovalue(d,varargin)
% isovalue
% 
% Description:	an improved version of MATLAB's builtin isovalue function
% 
% Syntax:	v = isovalue(d,<options>)
% 
% In:
% 	d	- the data for which to calculate the isovalue
%	<options>:
%		sample:	(<as in the builtin function>) the number of values to sample
%				from the data.  set to 0 to use all data
% 
% Out:
% 	v	- the isovalue
% 
% Updated: 2011-04-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'sample'	, []	  ...
		);

%sample the data
	nData	= numel(d);
	
	if isempty(opt.sample)
		kStep	= conditional(nData>20000,floor(nData/10000),1);
		kSample	= 1:kStep:nData;
	else
		nSample	= conditional(opt.sample<=0,nData,opt.sample);
		kSample	= round(GetInterval(1,nData,nSample));
	end
	
	d		= d(kSample);
%get the distribution
	[n,x]	= hist(d,100);
	nMax	= max(n);
%ignore small dominating values
	kLarge	= find(n==nMax,1,'first');
	
	kCutoff	= 2;
	if kLarge<=kCutoff && max(n(1:kCutoff)) > 10*mean(n)
		[n,x]	= varfun(@(v) v(kCutoff+1:end),n,x);
	end
%get a happy middle value
	bSmall	= n < nMax/50;
	if sum(bSmall)<90
		x(bSmall)	= [];
	end
	
	v	= x(floor(numel(x)/2));
