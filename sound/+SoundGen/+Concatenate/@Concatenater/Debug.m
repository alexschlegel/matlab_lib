function dbg = Debug(c,varargin)
% SoundGen.Concatenate.Concatenater.Debug
% 
% Description:	return a struct of debug info about the concatenation result
% 
% Syntax:	dbg = c.Debug(<options>)
%
% In:
%	<options>:
% 
% Updated: 2012-11-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dbg	= Debug@SoundGen.Operation(c,varargin{:});

if c.ran
	%image
		k						= round(GetInterval(1,numel(c.result),10000));
		h						= alexplot(c.result(k),'showxvalues',false,'showyvalues',false,'showgrid',false,'lax',0,'tax',0,'wax',1,'hax',1,'l',0,'t',0,'w',600,'h',200);
		dbg.image.concatenate	= fig2png(h.hF);
end
