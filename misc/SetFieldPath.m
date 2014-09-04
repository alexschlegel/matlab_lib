function s = SetFieldPath(s,varargin)
% SetFieldPath
% 
% Description:	set a field path in a struct to a value
% 
% Syntax:	s = SetFieldPath(s,[k]=1,f1,...,fN,v)
% 
% In:
% 	s	- a struct
%	[k]	- an array of indices from which to get the field in the corresponding
%		  substruct.  will be filled with ones to length N
%	fK	- a string representing the Kth field
%	v	- the value
% 
% Out:
% 	s	- the updated struct
% 
% Assumptions:	assumes the field path is valid
% 
% Updated: 2010-09-01
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if ~ischar(varargin{1})
	k			= varargin{1};
	varargin	= varargin(2:end);
else
	k	= [];
end

cFieldPath	= varargin(1:end-1);
v			= varargin{end};

nField			= numel(cFieldPath);
k(end+1:nField)	= 1;

if nField>0
	if ~isstruct(s) || numel(s)<k(1)
		s	= repmat(struct,[k(1) 1]);
	end
	
	if isfield(s,cFieldPath{1});
		sSub	= s(k(1)).(cFieldPath{1});
	else
		sSub	= struct;
	end
	
	s(k(1)).(cFieldPath{1})	= SetFieldPath(sSub,k(2:end),cFieldPath{2:end},v);
else
	s	= v;
end
