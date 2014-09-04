function b = IsPathRelative(strPath)
% IsPathRelative
% 
% Description:	determine if a path is relative or absolute
% 
% Syntax:	b = IsPathRelative(strPath)
% 
% Updated:	2009-07-10
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
reAbs	= {'^\\','^/','^[a-zA-Z]:'};

nRE		= numel(reAbs);
b		= true;
for k=1:nRE
	if ~isempty(regexp(strPath,reAbs{k}))
		b	= false;
		return;
	end
end
