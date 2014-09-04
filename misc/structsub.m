function s = structsub(s,f);
% structsub
% 
% Description:	return a subset of a struct
% 
% Syntax:	s = structsub(s,f)
% 
% In:
% 	s	- a struct
%	f	- a cell of the fields to return
% 
% Out:
% 	s	- the specified subset of s
% 
% Updated: 2010-07-26
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
f	= ForceCell(f);
fn	= fieldnames(s);
nf	= numel(fn);

[bField,kField]	= ismember(f,fn);
cStruct			= reshape(struct2cell(s),[],nf);
s				= cell2struct(cStruct(:,kField(bField)),f(bField),2);

if numel(s)==0
	s	= struct;
end
