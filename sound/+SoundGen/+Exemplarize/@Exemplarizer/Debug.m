function dbg = Debug(e,varargin)
% SoundGen.Exemplarize.Exemplarizer.Debug
% 
% Description:	return a struct of debug info about the exemplarizing result
% 
% Syntax:	dbg = e.Debug(<options>)
%
% In:
%	<options>:
% 
% Updated: 2012-11-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dbg	= Debug@SoundGen.Operation(e,varargin{:});

if e.ran
	%image
		kStart	= e.parent.segmenter.result(e.result,1);
		kEnd	= e.parent.segmenter.result(e.result,2);
		
		seg			= arrayfun(@(ks,ke) e.parent.src(ks:ke),kStart,kEnd,'UniformOutput',false);
		kCluster	= unique(e.parent.clusterer.result);
		cCluster	= num2cell(e.parent.clusterer.result(e.result));
		
		x	= arrayfun(@(c) cellfun(@(s,cc) conditional(c==cc,s,NaN(size(s))),seg,cCluster,'UniformOutput',false),kCluster,'UniformOutput',false);
		x	= cellfun(@(c) cat(1,c{:}),x,'UniformOutput',false);
		k	= round(GetInterval(1,numel(x{1}),10000));
		x	= cellfun(@(c) c(k),x,'UniformOutput',false);
		
		h						= alexplot(x,'showxvalues',false,'showyvalues',false,'showgrid',false,'lax',0,'tax',0,'wax',1,'hax',1,'l',0,'t',0,'w',600,'h',200);
		dbg.image.exemplarize	= fig2png(h.hF);
end
