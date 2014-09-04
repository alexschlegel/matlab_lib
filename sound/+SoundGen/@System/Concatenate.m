function Concatenate(sys,varargin)
% SoundGen.System.Concatenate
% 
% Description:	concatenate a string of segment exemplars into a new audio
%				signal
% 
% Syntax:	sys.Concatenate(<options>)
% 
% In:
% 	<options>: options to the concatenater function or object 
% 
% Updated: 2012-11-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if sys.exemplarized
	if isa(sys.concatenater,'SoundGen.Concatenate.Concatenater')
		sys.concatenater.Run(sys.src,sys.rate,sys.segment,sys.exemplar,varargin{:});
		
		sys.result	= sys.concatenater.result;
	else
		sys.result	= sys.concatenater(sys.src,sys.rate,sys.segment,sys.exemplar,varargin{:});
	end
else
	error('Exemplarizing must be performed before concatenation.');
end
