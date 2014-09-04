function hChildren = MoveToBack(hParent,hChildMove)
% MoveToBack
% 
% Description:	move the specified children to the back of their parent's
%				child handle list
% 
% Syntax:	hChildren = MoveToBack(hParent,hChildMove)
% 
% In:
% 	hParent		- the handle of the parent
%	hChildMove	- the handle of the children to move to the back
% 
% Out:
% 	hChildren	- the new child handle list
% 
% Updated: 2012-01-30
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
hChildMove	= reshape(hChildMove,[],1);
hChildren	= get(hParent,'Children');

hChildren(ismember(hChildren,hChildMove))	= [];

hChildren	= [hChildren; hChildMove];

set(hParent,'Children',hChildren);
