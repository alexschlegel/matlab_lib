function stat = MVPAClassifyExtraStats(res,varargin)
% MVPAClassifyExtraStats
% 
% Description:	compute some extra statistics for an MVPA classification
%				analysis that the python script doesn't do itself. specifically:
%					-> correct p-values for multiple comparisons
%					-> compare confusion matrices to model structures
% 
% Syntax:	stat = MVPAClassifyExtraStats(res,<options>)
% 
% In:
% 	res	- the results struct returned by MVPA classify (or a struct tree of
%		  results structs)
%	<options>:
%		confusion_model:	(<none>) a model confusion matrix, or a cell of
%							model confusion matrices
%		permutations:		(10000) the number of label permutations to use for
%							confusion matrix significance testing
%		silent:				(false) true to suppress status messages
% 
% Out:
%	stat	- a struct with the relevant statistical values in array form (e.g.
%			  for plotting). all except the label field are multi-dimensional
%			  arrays, with each dimension corresponding to one level of the
%			  struct tree hierarchy:
%				label:	cell containing the field names at each successive
%						level of the struct tree hierarchy
%				accuracy:	a struct with m, se, p, pfdr fields for the mean
%							accuracies across subject
%				confusion:	the same for the comparison of confusion matrices to
%							the model, along with: r (correlation), pperm
%							(p value based on permutation testing by permuting
%							labels), nperm (the number of permutations used)
% 
% Updated: 2015-03-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'confusion_model'	, {}	, ...
		'permutations'		, 10000	, ...
		'silent'			, false	  ...
		);

opt.confusion_model	= ForceCell(opt.confusion_model);
nModel				= numel(opt.confusion_model);

%are these MVPAClassify or MVPAROI*Classify results?
	if isfield(res,'type') && ismember(res.type,{'roidcclassify','roicrossclassify','roiclassify'})
		strResType	= 'mvparoiclassify';
	else
		strResType	= 'mvpaclassify';
	end

%get the labels
	switch strResType
		case 'mvparoiclassify'
			cMask		= mat2cell(res.mask,ones(size(res.mask,1),1),size(res.mask,2));
			stat.label	= cellfun(@(cm) join(cm,'-'),cMask,'uni',false);
		otherwise
			stat.label	= {};
			
			lbl	= structtreefun(@(s) NaN,res,'offset',2);
			while isstruct(lbl)
				stat.label{end+1}	= fieldnames(lbl);
				lbl					= lbl.(stat.label{end}{1});
			end
			stat.label	= reshape(stat.label,[],1);
	end
%construct the array-form of the stats
	cType	=	{
					'accuracy'
					'confusion'
				};
	nType	= numel(cType);
	
	cStat	=	{
					'mean'
					'se'
					'p'
				};
	nStat	= numel(cStat);
	
	for kT=1:nType
		strType	= cType{kT};
		
		stat.(strType).all	= Result2Array(res,strType);
		
		for kS=1:nStat
			strStat	= cStat{kS};
			
			stat.(strType).(strStat)	= Stat2Array(res,{strType,strStat});
			
			if isstruct(stat.(strType).(strStat)) && numel(fieldnames(stat.(strType).(strStat)))==0
				stat.(strType)	= rmfield(stat.(strType),strStat);
			end
		end
	end
%correlate confusion matrices
	if ~isempty(opt.confusion_model)
		%first model (so FDR values aren't screwed up by all the other models)
			%based on the group mean
				stat.confusion.corr.group	= structfun2(@(conf) ConfusionTest(conf,opt.confusion_model(1),'group'),stat.confusion.mean);
			%based on individual correlations
				stat.confusion.corr.subject	= structfun2(@(conf) ConfusionTest(conf,opt.confusion_model(1),'subject'),stat.confusion.all);
			%based on jackknifed correlations
				stat.confusion.corr.subjectJK	= structfun2(@(conf) ConfusionTest(conf,opt.confusion_model(1),'subjectJK'),stat.confusion.all);
		%model comparison
			%based on the group mean
				stat.confusion.corrcompare.group		= structfun2(@(conf) ConfusionTest(conf,opt.confusion_model,'group'),stat.confusion.mean);
			%based on individual correlations
				stat.confusion.corrcompare.subject		= structfun2(@(conf) ConfusionTest(conf,opt.confusion_model,'subject'),stat.confusion.all);
			%based on jackknifed correlations
				stat.confusion.corrcompare.subjectJK	= structfun2(@(conf) ConfusionTest(conf,opt.confusion_model,'subjectJK'),stat.confusion.all);
			%compare the models
				if nModel > 1
					stat.confusion.corrcompare.model_compare	= structfun2(@CompareConfusion,stat.confusion.corrcompare.group,stat.confusion.corrcompare.subject);
				end
	end
%correct the p-values
	stat	= PCorrect(stat);

%------------------------------------------------------------------------------%
function x = Result2Array(res,strType)
%convert a single result element to an array
	cField	= {};
	sRes	= structtreefun(@(s) Result2ArraySingle(s,strType),res,'offset',2);
	nField	= numel(cField);
	
	x	= deal(struct);
	for kF=1:nField
		f	= cField{kF};
		
		s		= structtreefun(@(s) s.(f),sRes,'offset',1);
		x.(f)	= structtree2array(s);
		
		if isempty(x.(f))
			x	= rmfield(x,f);
		end
	end
	
	%--------------------------------------------------------------------------%
	function x = Result2ArraySingle(s,strType)
		cField		= fieldnames(s);
		bConvert	= cellfun(@(f) isstruct(s.(f)),cField);
		cField		= cField(bConvert);
		nField		= numel(cField);
		
		x	= struct;
		for kF=1:nField
			strField	= cField{kF};
			
			x.(strField)	= s.(strField).(strType);
			
			if isstruct(x) && isfield(x.(strField),'mean')
				x.(strField)	= x.(strField).mean;
			end
		end
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function x = Stat2Array(res,statPath)
%convert a single stat element to an array
	cField	= {};
	sStat	= structtreefun(@(s) Stat2ArraySingle(s,statPath),res,'offset',2);
	nField	= numel(cField);
	
	x	= deal(struct);
	for kF=1:nField
		f	= cField{kF};
		
		s		= structtreefun(@(s) s.(f),sStat,'offset',1);
		x.(f)	= structtree2array(s);
		
		if isempty(x.(f))
			x	= rmfield(x,f);
		end
	end
	
	%--------------------------------------------------------------------------%
	function x = Stat2ArraySingle(s,statPath)
		x		= structfun2(@(s) GetFieldPath(s,'stats',statPath{:}),s);
		cField	= fieldnames(s);
	end
	%--------------------------------------------------------------------------%
end
%------------------------------------------------------------------------------%
function stat = ConfusionTest(conf,model,strLevel)
	%get each confusion matrix
		sz	= size(conf);
		
		switch strLevel
			case 'group'
				switch strResType
					case 'mvparoiclassify'
						cSz		= arrayfun(@(n) ones(n,1),sz(3:end),'uni',false);
						cConf	= squeeze(mat2cell(conf,sz(1),sz(2),cSz{:}));
					otherwise
						cSz		= arrayfun(@(n) ones(n,1),sz(1:end-2),'uni',false);
						cConf	= cellfun(@squeeze,mat2cell(conf,cSz{:},sz(end-1),sz(end)),'uni',false);
				end
			case {'subject','subjectJK'}
				switch strResType
					case 'mvparoiclassify'
						cSz		= arrayfun(@(n) ones(n,1),sz(3:end-1),'uni',false);
						
						%convert jackknifed versions of the confusion matrices
						if strcmp(strLevel,'subjectJK')
							nCondition	= prod(sz(3:end-1));
							confJK		= reshape(conf,[sz(1) sz(2) nCondition sz(end)]);
							for kC=1:nCondition
								confC				= permute(squeeze(confJK(:,:,kC,:)),[3 1 2]);
								confC				= jackknife(@(x) mean(x,1), confC(:,:));
								confJK(:,:,kC,:)	= reshape(permute(confC,[2 3 1]),sz([1:2 end]));
							end
							conf	= reshape(confJK,sz);
						end
						
						szSubject	= ones(sz(end),1);
						cConf		= squeeze(mat2cell(conf,sz(1),sz(2),cSz{:},szSubject));
					otherwise
						cSz	= arrayfun(@(n) ones(n,1),sz(1:end-3),'uni',false);
						
						%convert jackknifed versions of the confusion matrices
						if strcmp(strLevel,'subjectJK')
							nCondition	= prod(sz(1:end-3));
							confJK		= reshape(conf,[nCondition sz(end-2:end)]);
							for kC=1:nCondition
								confC				= permute(squeeze(confJK(kC,:,:,:)),[3 1 2]);
								confC				= jackknife(@(x) mean(x,1), confC(:,:));
								confJK(kC,:,:,:)	= reshape(permute(confC,[2 3 1]),sz(end-2:end));
							end
							conf	= reshape(confJK,sz);
						end
						
						szSubject	= ones(sz(end),1);
						cConf		= cellfun(@squeeze,squeeze(mat2cell(conf,cSz{:},sz(end-2),sz(end-1),szSubject)),'uni',false);
					end
			otherwise
				error('invalid level.');
		end
	
	%regular old correlation test
		[r,stat]	= cellfun(@(m) cellfun(@(c) corrcoef2(m(:),c(:)','twotail',false),cConf),model,'uni',false);
		
		if numel(model) > 1
			stat	= restruct(cellfun(@restruct,stat));
		else
			stat	= structfun2(@(x) {x},restruct(stat{1}));
		end
		
		nd	= numel(size(stat.r{1}));
	
	%arrayerize
		statcell	= stat;
		stat		= structfun2(@(x) cat(nd+1,x{:}),stat);
	
	%scalararrize
		stat.df		= stat.df(1);
		stat.tails	= stat.tails{1};
		stat.cutoff	= stat.cutoff(1);
	
	%group stats if r was calculated at the subject level
		if ismember(strLevel,{'subject','subjectJK'})
			if strcmp(strLevel,'subject')
				fttest	= @ttest;
				fstderr	= @stderr;
			else
				fttest	= @ttestJK;
				fstderr	= @stderrJK;
			end
				
			stat.group.r	= cellfun(@(x) mean(x,nd),statcell.r,'uni',false);
			stat.group.z	= cellfun(@(x) mean(x,nd),statcell.z,'uni',false);
			stat.group.se	= cellfun(@(x) fstderr(x,[],nd),statcell.z,'uni',false);
			
			[h,p,ci,stats]	= cellfun(@(x) fttest(x,0,0.05,'right',nd),statcell.z,'uni',false);
			
			stat.group.p	= p;
			stat.group.t	= cellfun(@(s) s.tstat,stats,'uni',false);
			
			stat.group	= structfun2(@(x) cat(nd,x{:}),stat.group);
			
			stat.group.df	= stats{1}.df(1);
		end
	
% forget it, 4x4 matrices can't do what Kriegeskorte wants
% 	%permutation test (Kriegeskorte 2008 recommends this, I think)
% 		pPerm	= cellfun(@(x) 
% 		nLabel			= size(model,1);
% 		nPermPossible	= factorial(nLabel);
% 		if nPermPossible <= opt.permutations
% 			nPerm	= nPermPossible;
% 			kPerm	= perms(1:
% 		else
% 			nPerm	= opt.permutations;
% 		end
	
end
%------------------------------------------------------------------------------%
function sCompare = CompareConfusion(sGroup,sSubject)
	sz		= size(sSubject.r);
	nd		= numel(sz);
	nModel	= sz(end);
	
	[x,kCompare]	= handshakes(1:nModel);
	nCompare		= size(kCompare,1);
	
	szOne	= sz(1:end-2);
	
	[sCompare.p,sCompare.t]	= deal(NaN([nCompare nCompare szOne]));
	
	cSub	= repmat({':'},[nd-2 1]);
	for kC=1:nCompare
		kC1	= kCompare(kC,1);
		kC2	= kCompare(kC,2);
		
		[h,p,ci,stats]	= ttest(sSubject.r(cSub{:},:,kC1),sSubject.r(cSub{:},:,kC2),'dim',nd-1);
		
		sCompare.df	= stats.df(1);
		
		[sCompare.p(kC1,kC2,cSub{:}),sCompare.p(kC2,kC1,cSub{:})]	= deal(p);
		
		sCompare.t(kC1,kC2,cSub{:})	= stats.tstat;
		sCompare.t(kC2,kC1,cSub{:})	= -stats.tstat;
	end
	
	[mx,sCompare.best]	= max(sGroup.r,[],nd-1);
end
%------------------------------------------------------------------------------%
function p = PCorrect(p,varargin)
	bCorrect	= ParseArgs(varargin,false);
	
	if isstruct(p)
		cField	= fieldnames(p);
		nField	= numel(cField);
		
		for kF=1:nField
			strField	= cField{kF};
			
			if strcmp(strField,'p')
				p.pfdr			= PCorrect(p.(strField),true);
			else
				p.(strField)	= PCorrect(p.(strField),bCorrect);
			end
		end
	elseif iscell(p)
		p	= cellfun(@(x) PCorrect(x,bCorrect),p,'uni',false);
	elseif bCorrect
		[pThresh,p]	= fdr(p,0.05,'mask',~isnan(p));
	end
end
%------------------------------------------------------------------------------%

end
