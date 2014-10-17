function b = DeleteCheck(strPath,varargin)
% DeleteCheck
% 
% Description:	delete a file and make sure it doesn't exist afterward
% 
% Syntax:	b = DeleteCheck(strPath,<options>)
% 
% In:
% 	strPath	- the path to the file
%	<options>:
%		error:	(false) true to raise an error if the file couldn't be deleted
% 
% Out:
% 	b	- true if the file was successfully deleted or didn't exist in the first
%		  place
% 
% Updated: 2011-03-07
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
b	= false;

opt	= ParseArgs(varargin,...
		'error'	, false	  ...
		);

if FileExists(strPath)
%delete and capture the output
	try
		evalc('delete(strPath);');
	catch me
		RaiseError;
		return;
	end
%check for the file
	if FileExists(strPath)
	%file still exists
		RaiseError;
		return;
	end
end

%success!
	b	= true;

%------------------------------------------------------------------------------%
function RaiseError
	if opt.error
		error(['Could not delete file "' strPath '".']);
	end
end
%------------------------------------------------------------------------------%

end