function [dFit,fFit,nFit] = GetFitValues(obj,d,b)
% subject.assess.base.GetFitValues
% 
% Description:	get the values to fit to the psychometric curve, given an array
%				of difficulties and resulting results
% 
% Syntax: [dFit,fFit] = obj.GetFitValues(d,b)
% 
% In:
%	d	- an array of difficulties
%	b	- a logical array of results, one for each element of d
% 
% Out:
%	dFit	- an array of difficulties
%	fFit	- an array of fractional accuracies, one for each element of dFit
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

[dFit,kTo,kFrom]	= unique(d);
nSample				= numel(dFit);

[fFit,nFit]	= deal(NaN(size(dFit)));
for kF=1:nSample
	nFit(kF)	= sum(kFrom==kF);
	fFit(kF)	= mean(b(kFrom==kF));
end
