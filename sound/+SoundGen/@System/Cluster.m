function Cluster(sys,varargin)
% SoundGen.System.Cluster
% 
% Description:	cluster the segments
% 
% Syntax:	sys.Cluster(<options>)
% 
% In:
% 	<options>: options to the clusterer function or object 
% 
% Updated: 2012-11-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
if sys.segmented
	if isa(sys.clusterer,'SoundGen.Cluster.Clusterer')
		sys.clusterer.Run(sys.src,sys.rate,sys.segment,varargin{:});
		
		sys.cluster	= sys.clusterer.result;
	else
		sys.cluster	= sys.clusterer(sys.src,sys.rate,sys.segment,varargin{:});
	end
else
	error('Segmentation must be performed before clustering.');
end