function dbg = Debug(sys,varargin)
% SoundGen.Debug
% 
% Description:	return a struct of debug info about the soundgen result
% 
% Syntax:	dbg = sys.Debug(<options>)
%
% In:
%	<options>: see options for the operation subobjects
% 
% Updated: 2012-11-20
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%image
	k				= round(GetInterval(1,numel(sys.src),10000));
	h				= alexplot(sys.src(k),'showxvalues',false,'showyvalues',false,'showgrid',false,'lax',0,'tax',0,'wax',1,'hax',1,'l',0,'t',0,'w',600,'h',200);
	dbg.image.src	= fig2png(h.hF);


dbg	= StructMerge(dbg,...
		sys.segmenter.Debug(varargin{:})	, ...
		sys.clusterer.Debug(varargin{:})	, ...
		sys.generator.Debug(varargin{:})	, ...
		sys.exemplarizer.Debug(varargin{:})	, ...
		sys.concatenater.Debug(varargin{:})	  ...
		);
