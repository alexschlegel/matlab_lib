function x = get(tP,strParam)
% get
% 
% Description:	TParameter get function
% 
% Syntax:	x = get(tP,strParam)
% 
% In:
% 	tP			- the TParameter object
%	strParam	- the parameter to return, either 'n', 'f', or 't'
% 
% Out:
% 	x	- the specified parameter value
% 
% Updated: 2010-06-08
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%fill in blanks
	switch strParam
		case 'f'
			if isempty(tP.f)
				if isempty(tP.t)
					tP.f	= fit([0;1],[0;1],'linearinterp');
				else
					tIn	= reshape(GetInterval(0,1,tP.n),[],1);
					tP.f	= fit(tIn,tP.t,'pchipinterp');
				end
			end
		case 't'
			if isempty(tP.t)
				if isempty(tP.f)
					tP.t	= reshape(GetInterval(0,1,tP.n),[],1);
				else
					tIn		= reshape(GetInterval(0,1,tP.n),[],1);
					tP.t	= tP.f(tIn);
				end
			end
	end

x	= tP.(strParam);
