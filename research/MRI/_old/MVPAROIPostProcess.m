function res = MVPAROIPostProcess(res,cMask,varargin)
% MVPAROIPostProcess
% 
% Description:	perform post-processing after an ROI-based MVPAClassify call
% 
% Syntax:	res = MVPAROIPostProcess(res,cMask,<options>)
% 
% In:
%	res		- an (nMask * nData) cell of outputs from MVPAClassify run with the
%			  <combine> option set to false
%	cMask	- a cell of mask names
% 	<options>:
%		<+ options for MVPAClassifyExtraStats>
%		type:			('roiclassify') the type of analysis that was performed
%		combine:		(true) true to attempt to combine the results of all the
%						classification analyses
%		group_stats:	(<combine>) true to perform group stats on the
%						accuracies and confusion matrices (<combine> must also
%						be true)
%		extra_stats:	(<group_stats>) true to calcuate some extra stats (FDR
%						corrected p-values and confusion matrix correlations)
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	res	- the updated result struct
% 
% Updated: 2015-03-23
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'type'			, 'roiclassify'	, ...
			'combine'		, true			, ...
			'group_stats'	, []			, ...
			'extra_stats'	, []			, ...
			'silent'		, false			  ...
			);
	
	opt.group_stats	= unless(opt.group_stats,opt.combine);
	opt.extra_stats	= unless(opt.extra_stats,opt.group_stats);
	
	nMask	= numel(cMask);

%combine the results
	if opt.combine
		try
			%construct dummy structs for failed classifications
				bFailed	= cellfun(@isempty,res);
				if any(bFailed)
					kGood	= find(~bFailed,1);
					if isempty(kGood)
						error('none of the classifications completed. results cannot be combined.');
					end
					
					resDummy		= dummy(res{kGood});
					res(bFailed)	= {resDummy};
				end
			
			nSubject	= numel(res)/nMask;
			sCombine	= [nMask nSubject];
			
			res			= structtreefun(@CombineResult,res{:});
			res.mask	= cMask;
			res.type	= opt.type;
		catch me
			status('combine option was selected but analysis results are not uniform.','warning',true,'silent',opt.silent);
			return;
		end
		
		if opt.group_stats && nSubject>1
			res	= GroupStats(res);
			
			if opt.extra_stats
				opt_extrastats	= optadd(opt.opt_extra,...
									'silent'	, opt.silent	  ...
									);
				
				res.stat	= MVPAClassifyExtraStats(res,opt_extrastats);
			end
		end
	end


%------------------------------------------------------------------------------%
function x = CombineResult(varargin)
	if nargin==0
		x	= [];
	else
		if isnumeric(varargin{1}) && uniform(cellfun(@size,varargin,'uni',false))
			if isscalar(varargin{1})
				x	= reshape(cat(1,varargin{:}),sCombine);
			else
				sz	= size(varargin{1});
				x	= reshape(stack(varargin{:}),[sz sCombine]);
			end
		else
			x	= reshape(varargin,sCombine);
		end
	end
end
%------------------------------------------------------------------------------%
function res = GroupStats(res)
	if isstruct(res)
		res	= structfun2(@GroupStats,res);
		
		if isfield(res,'accuracy')
			%accuracies
				acc		= res.accuracy.mean;
				nd		= ndims(acc);
				chance	= res.accuracy.chance(1,end);
				
				res.stats.accuracy.mean	= nanmean(acc,nd);
				res.stats.accuracy.se	= nanstderr(acc,[],nd);
				
				[h,p,ci,stats]	= ttest(acc,chance,'tail','right','dim',nd);
				
				res.stats.accuracy.chance	= chance;
				res.stats.accuracy.df		= stats.df;
				res.stats.accuracy.t		= stats.tstat;
				res.stats.accuracy.p		= p;
			%confusion matrices
				conf	= res.confusion;
				
				if ~iscell(conf)
					res.stats.confusion.mean	= nanmean(conf,4);
					res.stats.confusion.se		= nanstderr(conf,[],4);
				end
		end
	end
end
%------------------------------------------------------------------------------%

end
