function r = rms(x,varargin)
% rms
% 
% Description:	compute the root-mean-square value of the non-NaN elements of
%				array x
% 
% Syntax:	r = rms(x,[dim]=1)
% 
% Updated:	2008-11-05
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
dim	= ParseArgs(varargin,[]);
if isempty(dim)
	if isequal(size(x),[1 numel(x)])
		dim	= 2;
	else
		dim	= 1;
	end
end

r	= sqrt(nanmean(x.^2,dim));
