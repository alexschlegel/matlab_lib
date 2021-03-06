function sF = sndFunctionSetParam(sF,varargin)
% sndFunctionSetParam
% 
% Description:	set the value of a parameter of one of the functions that forms
%				the sound function struct sF
% 
% Syntax:	sF = sndFunctionSetParam(sF,[kF],kP,val)
% 
% In:
% 	sF		- a function struct returned by sndFunctionDefin
%	[kF]	- either an index to the function whose parameter should be set, or
%			  the function handle
%	kP		- either the index or name of the parameter to set.  if kF is
%			  unspecified, kP must be a unique parameter name
%	val		- the new parameter value
% 
% Out:
% 	sF	- the updated function struct
% 
% Updated: 2010-11-24
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
switch nargin
	case 3
		[kP,val]	= varargin{1:2};
		
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
	case 4
		[kF,kP,val]	= deal(varargin{1:3});
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

sF.p{kF}{kP}	= val;
