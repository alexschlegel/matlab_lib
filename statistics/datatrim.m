function [x,kKeep,kTrim] = datatrim(x,f)
% datatrim
% 
% Description:	trim a fraction of the lowest and highest values in a data array
% 
% Syntax:	[x,kKeep,kTrim] = datatrim(x,f)
% 
% In:
% 	x	- a numeric array
%	f	- the fraction of lowest/highest values to remove, i.e. a total fraction
%		  of 2*f of values are removed
% 
% Out:
% 	x		- the trimmed data
%	kKeep	- an array of the indices of x that were kept
%	kTrim	- an array of the indices of x that were trimmed
% 
% Updated: 2012-03-25
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if isempty(x)
	[kKeep,kTrim]	= deal([]);
	
	return;
end

s1	= size(x,1);
n	= numel(x);

x		= reshape(x,[],1);
[xs,kS]	= sort(x);

kMin	= max(1,round(n*f));
kMax	= min(n,kMin + round(n-2*n*f-1));

kTrim		= sort([kS(1:kMin-1); kS(kMax+1:end)]);
kKeep		= sort(kS(kMin:kMax));
x(kTrim)	= [];

n		= numel(x);
sFinal	= conditional(s1>1,[n 1],[1 n]);

x	= reshape(x,sFinal);
