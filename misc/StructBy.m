function s = StructBy(cVal,cVar)
% STRUCTBY
%
% Description:	separate the value in cVal such that cVal{k} is an element of
%				the cell s.(cVar{k}).
%
% Syntax:	s = StructBy(cVal,cVar)
%
% In:
%	cVal	- a cell of values to separate
%	cVar	- the name of the array/struct element of s to which the elements of
%			  cVal should be transferred
%
% Out:
%	s	- a struct as describe above
%
% Example: StructBy({1,2,3},{'a','b','b'}) ->
%			s.a	= {1};
%			s.b	= {2 3};
%
% Copyright 2006 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

s	= struct();

%fix field names
cVar	= strrep(cVar,'-','_');
cVar	= strrep(cVar,' ','_');
cVar	= strrep(cVar,'''','_');

n	= numel(cVal);
for k=1:n
	if ~isfield(s,cVar{k})
		s.(cVar{k})	= {};
	end
	
	s.(cVar{k})	= [s.(cVar{k}) {cVal{k}}];
end
