function y = constrain(x,varargin)
% constrain
% 
% Description:	constrain values between two extremes
% 
% Syntax:	y = constrain(x,[mn]=<none>,[mx]=<none>,<options>)
% 
% In:
% 	x	- the values to be constrained
%	mn	- the minimum
%	mx	- the maximum
%	<options>:
%		nan	: (false) true to replace out of range values with NaNs
% 
% Out:
% 	y	- the constrained values
% 
% Updated: 2010-04-30
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[mn,mx,opt]	= ParseArgs(varargin,NaN,NaN,...
							'nan'	, false	  ...
							);

bNaN	= isnan(x);

tmp	= mn;
if ~isnan(mn)
	mn	= nanmin(mn,mx);
end
if ~isnan(mx)
	mx	= nanmax(tmp,mx);
end
		
if opt.nan
	y				= x;
	y(x<mn | x>mx)	= NaN;
else
	y	= max(mn,min(mx,x));
end

y(bNaN)	= NaN;
