function b = ProcessError(val,errVal,varargin)
% ProcessError
% 
% Description:	raise an error if val==errVal after a caught error
% 
% Syntax:	b = ProcessError(val,errVal,arg1,...,argN)
% 
% In:
% 	val		- the test value
%	errVal	- the value of val if an error occurred
%	argK	- an argument to include in any error message
% 
% Out:
% 	b	- true if no error occurred, false otherwise
% 
% Updated:	2008-12-03
% Copyright 2008 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

if isequal(val,errVal)
	err	= lasterror;
	
	strState	= 'State:';
	for k=1:numel(varargin)
		strInput	= inputname(k+2);
		if isempty(strInput)
			strInput	= ['arg' num2str(k)];
		end
		
		err.(strInput)	= varargin{k};
		
		strVal	= evalc(['disp(varargin{' num2str(k) '})']);
		k10		= numel(strVal);
		while strVal(k10)==10
			k10	= k10-1;
		end
		strVal	= strVal(1:k10);
		
		strState	= [strState 10 '  ' strInput ': ' strVal];
	end
	strState	= [strState 10 10];
	
	strErr	= 'Error Struct:';
	for k=fieldnames(err)'
		strVal	= evalc(['disp(err.(k{1}))']);
		k10		= numel(strVal);
		while strVal(k10)==10
			k10	= k10-1;
		end
		strVal	= strVal(1:k10);
		
		strErr	= [strErr 10 '  ' k{1} ': ' strVal];
	end
	
	err.message		= ['An error occurred.' 10 10 strState strErr];
	err.identifier	= 'ProcessError:error';
	rethrow(err);
	
	b	= false;
else
	b	= true;
end
