function dbg = Debug(g,varargin)
% SoundGen.Generate.Generator.Debug
% 
% Description:	return a struct of debug info about the generating result
% 
% Syntax:	dbg = g.Debug(<options>)
%
% In:
%	<options>:
% 
% Updated: 2012-11-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dbg	= Debug@SoundGen.Operation(g,varargin{:});

if g.ran
	%image
		c	= unique(g.result);
		nC	= numel(c);
		
		lut	= GetPlotColors(nC);
		
		s	= [667 2000];
		
		dbg.image.generate	= imresize(ind2rgb(g.result',lut),s,'nearest');
end
