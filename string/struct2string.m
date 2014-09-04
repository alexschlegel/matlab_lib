function str = struct2string(s,varargin)
% struct2string
% 
% Description:	convert a string to a comma-separated list of field/value pairs
% 
% Syntax:	str = struct2string(s,<options>)
%
% In:
%	s	- the struct
%	<options>: see tostring
% 
% Updated: 2013-05-01
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
cField	= fieldnames(s);
cValue	= struct2cell(structfun(@(s) tostring(s,varargin{:}),s,'UniformOutput',false));

cPair	= cellfun(@(f,v) [f ': ' v],cField,cValue,'UniformOutput',false);

str	= join(cPair,10);
