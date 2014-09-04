function Remove(col,strName,varargin)
% Group.Collection.Remove
% 
% Description:	remove a member from the collection
% 
% Syntax:	col.Remove(strName,[bEnd]=true)
%
% In:
%	strName	- the member name
%	bEnd	- true to end and delete the member
%
% Updated: 2011-12-28
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
bEnd	= ParseArgs(varargin,true);

[b,k]	= ismember(strName,col.members);

if b
	col.members(k)	= [];
	
	if bEnd
		col.collection(k).End;
		delete(col.collection(k));
	end
	
	col.collection(k)	= [];
end
