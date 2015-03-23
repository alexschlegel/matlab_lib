function [cf,uf] = cellnestflatten(c)
% cellnestflatten
% 
% Description:	flatten a nested cell into a single Nx1 cell
% 
% Syntax:	[cf,uf] = cellnestflatten(c)
%
% In:
%	c	- a nested cell
%
% Out:
%	cf	- the flattened cell
%	uf	- a struct to pass to cellnestunflatten
% 
% Updated: 2015-03-22
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
if iscell(c)
	if any(cellfun(@iscell,c(:)))
		[cf,uf]	= cellfun(@cellnestflatten,c,'uni',false);
		
		cf	= cat(1,cf{:});
		uf	= struct('n',sum(cellfun(@(s) s.n,uf(:))),'s',cell2mat(uf));
	else
		uf	= struct('n',numel(c),'s',size(c));
		cf	= reshape(c,[],1);
	end
else
	cf	= c;
	uf	= struct('n',1,'s',NaN);
end
