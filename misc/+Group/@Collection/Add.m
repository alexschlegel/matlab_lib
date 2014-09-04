function Add(col,strName,varargin)
% Group.Collection.Add
% 
% Description:	add a member to the collection
% 
% Syntax:	col.Add(strName,...)
%
% In:
%	strName	- the member name
%	...		- the arguments to the class constructor beyond the parent and
%			  strType arguments
%
% Updated: 2011-12-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[p,c]	= ClassSplit(col);

import Group.*
import([p '.*']);

if isempty(col.members)
	col.members		= {strName};
	col.collection	= eval([col.Info.Get('collection_class') '(col,strName,varargin{:});']);
else
	col.members{end+1}		= strName;
	col.collection(end+1)	= eval([col.Info.Get('collection_class') '(col,strName,varargin{:});']);
end

col.collection(end).Start;
