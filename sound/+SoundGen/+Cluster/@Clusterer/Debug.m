function dbg = Debug(c,varargin)
% SoundGen.Cluster.Clusterer.Debug
% 
% Description:	return a struct of debug info about the clustering result
% 
% Syntax:	dbg = c.Debug(<options>)
%
% In:
%	<options>:
%		cluster_n:		(10) the number of instances of each cluster item to
%						include
%		cluster_gap:	(0.5) the amount of time between each segment, in
%						seconds
%		cluster_pause:	(2) the amount of time between cluster groups, in
%						seconds
% 
% Updated: 2012-11-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
dbg	= Debug@SoundGen.Operation(c,varargin{:});

opt	= ParseArgs(varargin,...
		'cluster_n'		, 10	, ...
		'cluster_gap'	, 0.25	, ...
		'cluster_pause'	, 1		  ...
		);

if c.ran
	kCluster	= unique(c.result);
	nCluster	= numel(kCluster);
	
	dbg.clusters	= [];
	for kC=1:nCluster
		kSegment	= find(c.result==kCluster(kC),opt.cluster_n);
		nSegment	= numel(kSegment);
		
		for kS=1:nSegment
			kX				= c.parent.segmenter.result(kSegment(kS),:);
			dbg.clusters	= [dbg.clusters; c.parent.src(kX(1):kX(2)); zeros(round(opt.cluster_gap*c.parent.rate),1)];
		end
		
		dbg.clusters	= [dbg.clusters; zeros(round(opt.cluster_pause*c.parent.rate),1)];
	end
	
	%image
		seg			= arrayfun(@(ks,ke) c.parent.src(ks:ke),c.parent.segmenter.result(:,1),c.parent.segmenter.result(:,2),'UniformOutput',false);
		cCluster	= num2cell(c.result);
		
		clust	= arrayfun(@(c) cellfun(@(s,cc) conditional(c==cc,s,NaN(size(s))),seg,cCluster,'UniformOutput',false),kCluster,'UniformOutput',false);
		clust	= cellfun(@(c) cat(1,c{:}),clust,'UniformOutput',false);
		k		= round(GetInterval(1,numel(clust{1}),10000));
		clust	= cellfun(@(c) c(k),clust,'UniformOutput',false);
		
		h					= alexplot(clust,'showxvalues',false,'showyvalues',false,'showgrid',false,'lax',0,'tax',0,'wax',1,'hax',1,'l',0,'t',0,'w',600,'h',200);
		dbg.image.cluster	= fig2png(h.hF);
end
