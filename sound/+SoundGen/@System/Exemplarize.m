function Exemplarize(sys,kStart,varargin)
% SoundGen.System.Exemplarize
% 
% Description:	convert a cluster string array into a segment exemplar string
% 
% Syntax:	sys.Exemplarize(<options>)
% 
% In:
%	kStart	- the cluster string array index at which the generator started
% 	<options>: options to the exemplarizer function or object 
% 
% Updated: 2012-11-03
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if sys.generated
	if isa(sys.exemplarizer,'SoundGen.Exemplarize.Exemplarizer')
		sys.exemplarizer.Run(sys.src,sys.rate,sys.segment,sys.cluster,sys.gen,kStart,varargin{:});
		
		sys.exemplar	= sys.exemplarizer.result;
	else
		sys.exemplar	= sys.exemplarizer(sys.src,sys.rate,sys.segment,sys.cluster,sys.gen,kStart,varargin{:});
	end
else
	error('Generation must be performed before exemplarizing.');
end
