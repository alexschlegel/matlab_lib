function val = sndFunctionGetParam(sF,varargin)
% sndFunctionSetParam
% 
% Description:	get the value of a parameter of one of the functions that forms
%				the sound function struct sF
% 
% Syntax:	sF = sndFunctionSetParam(sF,[kF],kP)
% 
% In:
% 	sF		- a function struct returned by sndFunctionDefin
%	[kF]	- either an index to the function whose parameter should be set, or
%			  the function handle
%	kP		- either the index or name of the parameter to set.  if kF is
%			  unspecified, kP must be a unique parameter name
% 
% Out:
% 	val	- the parameter value
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
switch nargin
	case 2
		kP	= varargin{1};
		
		kF	= [];
		nFunc	= numel(sF.f);
		for kFunc=1:nFunc
			kParam	= FindCell(sF.p_name{kFunc},kP);
			if ~isempty(kParam)
				kP	= kParam;
				kF	= kFunc;
				break;
			end
		end
		if isempty(kF)
			error(['Parameter "' tostring(kP) '" was not found.']);
		end
	case 3
		[kF,kP]	= deal(varargin{1:2});
	otherwise
		error('Incorrect number of input arguments.');
end

if isa(kF,'function_handle')
	f	= kF;
	kF	= FindCell(sF.f,f);
	if isempty(kF)
		error(['Function ' tostring(f) ' not found.']);
	end
end
if ischar(kP)
	p	= kP;
	kP	= FindCell(sF.p_name{kF},p);
	if isempty(kP)
		error(['Parameter "' p '" not found in function ' num2str(kF)]);
	end
end

val	= sF.p{kF}{kP};
