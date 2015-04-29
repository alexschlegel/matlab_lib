function s = structtreefdr(s,varargin)
% structtreefdr
% 
% Description:	FDR correct a struct tree of stats that includes p-values
% 
% Syntax:	s = structtreefdr(s,<options>)
% 
% In:
% 	s	- a struct tree that include fields named 'p' representing p-values
%	<options>:
%		q:			(0.05) the FDR q-value threshold
%		include:	(<all>) if only p-values in certain branches should be
%					included in the correction, specify a cell or cell of cells
%					of tree path segments to include (e.g. to include p values
%					in branches of the struct tree that include allway.accuracy,
%					set this to {'allway','accuracy'})
% 
% Out:
% 	s	- the structtree with fdr-corrected p-values added
% 
% Updated: 2015-04-29
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'q'			, 0.05	, ...
		'include'	, []	  ...
		);

%get the struct tree paths
	cPath	= structtreepath(s,'output','cell');
%find the ones ending in 'p'
	bP		= cellfun(@(c) strcmp(c{end},'p'),cPath);
	cPath	= cPath(bP);
%restrict to included segments
	if ~isempty(opt.include);
		opt.include	= ForceCell(opt.include,'level',2);
		nInclude	= numel(opt.include);
		
		bInclude	= false(size(cPath));
		for kI=1:nInclude
			bInclude	= bInclude | cellfun(@(p) SubPathExists(p,opt.include{kI}),cPath);
		end
		
		cPath	= cPath(bInclude);
	end
	nPath	= numel(cPath);

%for each path, factor in the size of the last struct
	nStruct	= cellfun(@(p) numel(GetFieldPath(s,p{1:end-1})),cPath,'uni',false);

%get the p-values
	p		= cellfun(@(p,n) arrayfun(@(k) GetFieldPath(s,[ones(1,numel(p)-1) k],p{:}),(1:n)','uni',false),cPath,nStruct,'uni',false);
	pFlat	= cellfun(@(cp) cellfun(@(x) reshape(x,[],1),cp,'uni',false),p,'uni',false);
	pFlat	= cellfun(@(cp) cat(1,cp{:}),pFlat,'uni',false);
	pFlat	= cat(1,pFlat{:});
%fdr correct
	[pThresh,pfdr]	= fdr(pFlat,opt.q);
%inject into the struct tree
	cPathFDR	= cellfun(@(p) [p(1:end-1); 'pfdr'],cPath,'uni',false);
	
	kFDR	= 1;
	for kP=1:nPath
		nStructCur	= nStruct{kP};
		
		for kS=1:nStructCur
			n		= numel(p{kP}{kS});
			sz		= size(p{kP}{kS});
			kFDREnd	= kFDR+n-1;
			
			pFDRCur	= reshape(pfdr(kFDR:kFDREnd),sz);
			
			s	= SetFieldPath(s,[ones(1,numel(cPathFDR{kP})-1) kS],cPathFDR{kP}{:},pFDRCur);
			
			kFDR	= kFDREnd+1;
		end
	end

%------------------------------------------------------------------------------%
function b = SubPathExists(cPath,cSubPath)
	b	= false;
	
	nPath		= numel(cPath);
	nSubPath	= numel(cSubPath);
	if nSubPath>0
		kMatch	= find(strcmp(cPath,cSubPath{1}));
		nMatch	= numel(kMatch);
		
		bPathMatch	= true;
		for kM=1:nMatch
			kPathStart	= kMatch(kM);
			
			for kS=2:nSubPath
				kPath	= kPathStart+kS-1;
				
				if kPath>nPath || ~strcmp(cPath{kPath},cSubPath{kS})
					bPathMatch	= false;
					break;
				end
			end
			
			if bPathMatch
				b	= true;
				return;
			end
		end
	end
%------------------------------------------------------------------------------%
