function y = PAL_WeibullExt(obj,params,x,varargin)
% subject.assess.psi.PAL_WeibullExt
% 
% Description:	like PAL_Weibull in the palamedes toolbox, but allows the
%				performance at threshold to be specified via the obj.target
%				property
% 
% Syntax: y = obj.PAL_WeibullExt(params,x,varargin)
% 
% In/Out: (see PAL_Weibull)
% 
% Updated:	2015-12-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	if ~isempty(varargin)
		strType	= lower(varargin{1})
	else
		strType	= 'default';
	end
	
	[t,b,g,lapse]	= PAL_unpackParamsPF(params);
	
	a		= obj.target;

switch strType
	case 'inverse'
		y	= iweibull(x,t,b,0,g,a,lapse);
	case 'derivative'
		y	= dxweibull(x,t,b,0,g,a,lapse);
	otherwise
		y	= weibull(x,t,b,0,g,a,lapse);
end
