function x = envelope(x,varargin)
% envelope
% 
% Description:	apply an envelope to a signal
% 
% Syntax:	x = envelope(x,<options>)
% 
% In:
% 	x	- an nSample x nSignal signal
%	<options>:
%		type:	('hanning') the type of envelope to apply.  can be a function
%				that accepts a number between 0 and 1 (the fractional position in
%				the signal) as an input, or one of the following preset
%				functions:
%					'hanning'
%		fmax:	(0.5) if the type option is a preset, the fractional distance
%				at which the envelope reaches 1
% 
% Out:
% 	x	- the signal with the envelop applied
% 
% Updated: 2011-11-29
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'type'	, 'hanning'	, ...
		'fmax'	, 0.5		  ...
		);

[n,c]	= size(x);
t		= GetInterval(0,1,n)';

if isa(opt.type,'function_handle')
	e	= opt.type(t);
else
	switch lower(opt.type)
		case 'hanning'
			kMax	= round(opt.fmax*n);
			h		= normalize(hanning(2*kMax));
			e		= [h(1:kMax); ones(n - 2*kMax,1); h(kMax+1:end)];
		otherwise
			error(['"' tostring(opt.type) '" is not a recognized preset envelope type.']);
	end
end

x	= x.*repmat(e,[1 c]);
