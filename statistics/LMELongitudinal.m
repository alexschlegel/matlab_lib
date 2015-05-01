function [fstats,stats] = LMELongitudinal(Y,t,g,varargin)
% LMELongitudinal
% 
% Description:	perform linear mixed effects analyses on longitudinal data
%				from two groups
% 
% Syntax:	[fstats,stats] = LMELongitudinal(Y,t,g,<options>)
% 
% In:
% 	Y	- an nSubject x nTime x nLocation array of measurements collected for
%		  nSubjects subject at nTime points in time at nLocation locations.  use
%		  NaNs where data do not exist.
%	t	- an nSubject x nTime array of times at which the measurements were made
%	g	- an nSubject x 1 logical array specifying which group each subject is
%		  in. true should be used for the experimental group.
%	<options>:
%		engine:		('matlab') the "engine" to use.  either 'matlab' or 'r'
%		est_method:	({'em','fs','nc'}) the estimation method to use. one of or
%					a cell of the following:
%						'em':	expectation maximization
%						'fs':	Fisher scoring algorithm
%						'nc':	Newton-Raphson optimization
%					if a cell is specified, each will be tried in order until
%					one doesn't break.
%		fdr_q:		(0.05) the fdr correction q value
%		cores:		(1) the number of processor cores to use
% 
% Out:
%	fstats	- statistics from the analyses:
%			  For MATLAB:
%		 		F:			an nLocation x 1 array of F-statistics for the
%							group x time interaction term
%				df:			an nLocation x 2 array of [n,d] degrees of freedom
%							associated with each F-statistic
%				p:			an nLocation x 1 array of  p-values associated with
%							the F-statistics
%				Chat:		an nLocation x 1 array of interaction contrast
%							estimates
%			  For R:
%				t:			a struct of nLocation x 1 arrays of t-statistics for
%							the intercept, group, time, and group x time
%							interaction terms
%				p:			a struct of nLocation x 1 arrays of  p-values
%							associated with the t-statistics
%				Chat:		a struct of nLocation x 1 arrays of fit estimates
%			  For Both:
%				pcorrfwe:	fwe-corrected p values (Bonferroni)
%				pcorrfdr:	fdr-corrected p values
%				
%	stats	- an nLocation x 1 struct array of other crazy stats
%
% Notes:	MATLAB method adapted from the example given here:
%			https://surfer.nmr.mgh.harvard.edu/fswiki/LinearMixedEffectsModels
% 
% Updated: 2015-05-01
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
nOut	= nargout;

opt	= ParseArgs(varargin,...
		'engine'	, 'matlab'			, ...
		'est_method', {'em','fs','nc'}	, ...
		'fdr_q'		, 0.05				, ...
		'cores'		, 1					  ...
		);

opt.engine		= CheckInput(opt.engine,'engine',{'matlab','r'});
opt.est_method	= cellfun(@(m) CheckInput(m,'estimation method',{'em','fs','nc'}),ForceCell(opt.est_method),'UniformOutput',false);
fEst			= cellfun(@(m) switch2(m,'em',@lme_fit_EM,'fs',@lme_fit_FS,'nc',@lme_fit_NC),opt.est_method,'UniformOutput',false);
nEst			= numel(fEst);

[nSubject,nTime,nLocation]	= size(Y);

s	= (1:nSubject)';

%construct the IVs
	sr	= repmat(reshape(s,[],1),[1 nTime]);
	gr	= repmat(reshape(g,[],1),[1 nTime]);
	
	S	= sr(:);
	G	= gr(:);
	T	= t(:);
	I	= ones(size(S));
	
	bKeepT	= ~isnan(T);
	
	TG	= G.*(T-nanmean(T(G)));
	T	= T-nanmean(T);

if isequal(opt.engine,'matlab')
	%construct the model
		%intercept, group, time, group x time interaction
		X	= [I G T TG];
		%linear contrast for interaction term
		C	= [0 0 0 1];
	%analyze each location
		[stats,F,dfN,dfD,p,Chat]	= MultiTask(@AnalyzeOne_MATLAB,{num2cell(1:nLocation)'},...
										'description'	, 'performing linear mixed effects analysis'	, ...
										'cores'			, opt.cores										, ...
										'uniformoutput'	, true											  ...
										);
		
		fstats	= struct(...
					'F'		, F			, ...
					'df'	, [dfN dfD]	, ...
					'p'		, p			, ...
					'Chat'	, Chat		  ...
					);
else
	%analyze each location
		[stats,t,p,Chat]	= MultiTask(@AnalyzeOne_R,{num2cell(1:nLocation)'},...
								'description'	, 'performing linear mixed effects analysis'	, ...
								'cores'			, opt.cores										, ...
								'uniformoutput'	, true											  ...
								);
		
		fstats	= struct(...
					't'		, restruct(t)		, ...
					'p'		, restruct(p)		, ...
					'Chat'	, restruct(Chat)	  ...
					);
end

%corrected p values!
	if isstruct(fstats.p)
		fstats.pcorrfwe				= structfun2(@(p) p * nLocation,fstats.p);
		[pThresh,fstats.pcorrfdr]	= structfun2(@(p) fdr(p,opt.fdr_q),fstats.p);
	else
		fstats.pcorrfwe				= fstats.p * nLocation;
		[pThresh,fstats.pcorrfdr]	= fdr(fstats.p,opt.fdr_q);
	end

%------------------------------------------------------------------------------%
function [stats,F,dfN,dfD,p,Chat] = AnalyzeOne_MATLAB(kLocation)
	%eliminate missing data
		YCur	= reshape(Y(:,:,kLocation),[],1);
		bKeep	= bKeepT & ~isnan(YCur);
		
		SCur	= S(bKeep);
		XCur	= X(bKeep,:);
		YCur	= YCur(bKeep);
	%get the number of reps per
		nRep	= arrayfun(@(k) sum(SCur==k),(1:nSubject)');
	
	warning('off');
	for kE=1:nEst
		try
		%estimate the fit
			stats	= fEst{kE}(XCur,[3 4],YCur,nRep);
		%perform the contrast analysis
			%lme_F fails for bad fit results
				fstats	= lme_F(stats,C);
				
				F		= fstats.F;
				dfN		= fstats.df(1);
				dfD		= fstats.df(2);
				p		= fstats.pval;
				Chat	= C*stats.Bhat;
				
				if isnan(p)
					p	= 1;
				end
			%success!
				break;
		catch me
			[F,dfN,dfD,p,Chat]	= deal(NaN);
		end
	end
	warning('on');
	
	%if we're not saving stats, get rid of it
		if nOut<2
			stats	= struct;
		else
			stats.X	= X;
			stats.C	= C;
		end
end
%------------------------------------------------------------------------------%
function [stats,t,p,Chat] = AnalyzeOne_R(kLocation)
	%eliminate missing data
		YCur	= reshape(Y(:,:,kLocation),[],1);
		bKeep	= bKeepT & ~isnan(YCur);
		
		SCur	= S(bKeep);
		GCur	= G(bKeep);
		TCur	= T(bKeep);
		
		YCur	= YCur(bKeep);
	%save the data
		strPathData	= GetTempFile('ext','csv');
		d			= struct(...
						'subject'	, SCur	, ...
						'group'		, GCur	, ...
						'time'		, TCur	, ...
						'response'	, YCur	  ...
						);
		fput(struct2table(d,'delim','csv'),strPathData);
	%run the analysis
		strDirScript	= PathGetDir(mfilename('fullpath'));
		strPathScript	= PathUnsplit(strDirScript,'LMERLongitudinal','R');
		[ec,cOut]		= CallProcess(strPathScript,{strPathData},'silent',true);
		strOut			= cOut{1};
	%parse the results
		cTerm	= {'\(Intercept\)';'group';'time';'group:time'};
		cTermP	= {'Intercept';'group';'time';'group.time'};
		cField	= {'intercept';'group';'time';'interaction'};
		nTerm	= numel(cTerm);
		
		if ec==0
		%get the actual results part of the output
			kStart	= strfind(strOut,'[1]');
			kStart	= kStart(1);
			strOut	= strOut(kStart:end);
		%get each model result
			for kT=1:nTerm
				res	= regexp(strOut,['\n' cTerm{kT} '(?<gt> [^\n]+)'],'names');
				gt	= str2array(res(1).gt);
				
				t.(cField{kT})		= gt(3);
				Chat.(cField{kT})	= gt(1);
				%p.(cField{kT})		= gt(4);
				
				res	= regexp(strOut,['"\*\*\*p-values\*\*\*"\n\[1\](?<gt> [^\n]+)'],'names');
				gt	= str2array(res(1).gt);
				p.(cField{kT})		= gt(kT);
			end
		else
			[t,p,Chat]	= deal(dealstruct(cField,NaN));
		end
		%save all the raw results
			stats	= struct('result',strOut);
end
%------------------------------------------------------------------------------%

end
