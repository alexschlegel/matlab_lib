function Generate(sys,kStart,S,varargin)
% SoundGen.System.Generate
% 
% Description:	generate a cluster string array
% 
% Syntax:	sys.Generate(kStart,S,<options>)
% 
% In:
%	kStart	- the cluster string array index at which to start the generation
%			  process
%	S		- the length of the cluster string to generate
% 	<options>: options to the generator function or object 
% 
% Updated: 2012-11-01
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if sys.clustered
	if isa(sys.generator,'SoundGen.Generate.Generator')
		sys.generator.Run(sys.cluster,kStart,S,varargin{:});
		
		sys.gen	= sys.generator.result;
	else
		sys.gen	= sys.generator(sys.cluster,kStart,S,varargin{:});
	end
else
	error('Clustering must be performed before genearation.');
end
