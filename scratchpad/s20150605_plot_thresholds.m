% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% This script is an updated variant of s20150601_plot_threshold_data.m
%
% Among other differences, the variants of this script use different
% data formats.  Data files written by one variant can be plotted only
% by the same variant.  Files written by the earlier variant have
% names that include the stem s20150601_threshold_data.

% TODO: Comments
%

function h = s20150605_plot_thresholds(varargin)
	stem		= 's20150605_thresholds';
	opt			= ParseArgs(varargin, ...
					'fakedata'			, []			, ...
					'forcegen'			, false			, ...
					'nogen'				, []			, ...
					'noplot'			, []			, ...
					'plottype'			, []			, ...
					'savedata'			, []			, ...
					'varname'			, []			, ...
					'xge'				, []			, ...
					'xle'				, []			, ...
					'yge'				, []			, ...
					'yle'				, []			, ...
					'xstart'			, 0.06			, ...
					'xstep'				, 0.02			, ...
					'xend'				, 0.34			  ...
					);
	extraargs	= opt2cell(opt.opt_extra);

	hasFigwin		= feature('ShowFigureWindows');
	opt.fakedata	= unless(opt.fakedata,hasFigwin);
	opt.nogen		= unless(opt.nogen,hasFigwin) && ~opt.forcegen;
	opt.noplot		= unless(opt.noplot,~hasFigwin);
	opt.savedata	= unless(opt.savedata,~opt.fakedata);

	timestamp	= FormatTime(nowms,'yyyymmdd_HHMMSS');
	h			= [];
	cap_ts		= {};

	sketch('nRun'		, 2:20);
	sketch('nSubject'	, 1:20);
	sketch('nTBlock'	, 1:20);
	sketch('nRepBlock'	, 2:15);
	sketch('WStrength'	, 0.2:0.001:0.8);

	function sketch(testvarName,testvarValues)
		if ~isempty(opt.varname) && ~strcmp(testvarName,opt.varname)
			return;
		end
		snrrange		= opt.xstart:opt.xstep:opt.xend;
		plex			= opt.xend+testvarValues(end)*1i;
		data_label		= sprintf('%s_%s_%d_%s_%d_%s',stem,testvarName,numel(testvarValues), ...
							'SNR',numel(snrrange),num2str(abs(plex)));
		fcreate_dataset	= conditional(opt.nogen,[],@create_threshCapsule);
		not_before		= conditional(opt.forcegen,timestamp,'00000000_');
		[capsule,ts]	= get_dataset(data_label,fcreate_dataset, ...
							'data_varname'	, 'capsule'		, ...
							'not_before'	, not_before	, ...
							'savedata'		, opt.savedata	, ...
							'timestamp'		, timestamp		  ...
							);
		if opt.noplot || isempty(capsule)
			return;
		elseif ~isfield(capsule.version,'thresholdCapsule')
			error('Not a threshold capsule.');
		elseif ~strcmp(capsule.version.thresholdCapsule,stem)
			error('Incompatible capsule version %s',capsule.version.thresholdCapsule);
		end
		points		= capsule.points;
		pThreshold	= capsule.threshopt.pThreshold;

		xge			= unless(opt.xge,-Inf);
		xle			= unless(opt.xle,+Inf);
		yge			= unless(opt.yge,-Inf);
		yle			= unless(opt.yle,+Inf);
		okpoints	= xge <=[points.x] & [points.x] <= xle & yge <= [points.y] & [points.y] <= yle;
		points		= points(okpoints);
		if isempty(opt.plottype)
			plottype	= conditional(isempty(opt.varname),{'fit'},...
							{'fit','p_snr','p_test','test_snr'});
		elseif ~iscell(opt.plottype)
			plottype	= {opt.plottype};
		end
		nAV	= numel(plottype);
		for kAV=1:nAV
			switch plottype{kAV}
				case 'fit'
					plotfn	= @linefit_test_vs_SNR;
				case 'p_snr'
					plotfn	= @scatter_p_vs_SNR;
				case 'p_test'
					plotfn	= @scatter_p_vs_test;
				case 'test_snr'
					plotfn	= @scatter_test_vs_SNR;
				otherwise
					error('Unknown plottype ''%s''',plottype{kAV});
			end
			h(end+1)		= plotfn(points,pThreshold,testvarName);
			cap_ts{end+1}	= ts;
		end

		function capsule = create_threshCapsule
			start_ms	= nowms;

			[threshPts,pipeline,threshOpt]	...
						= ThresholdSketch(...
							'fakedata'	, opt.fakedata		, ...
							'noplot'	, true				, ...
							'yname'		, testvarName		, ...
							'yvals'		, testvarValues		, ...
							'xstart'	, opt.xstart		, ...
							'xstep'		, opt.xstep			, ...
							'xend'		, opt.xend			, ...
							'seed'		, 0					, ...
							extraargs{:} ...
							);
			end_ms		= nowms;
			version		= struct(...
							'pipeline'			, pipeline.version.pipeline	, ...
							'thresholdCapsule'	, stem						  ...
							);

			capsule.begun		= FormatTime(start_ms);
			capsule.id			= FormatTime(start_ms,'yyyymmdd_HHMMSS');
			capsule.label		= data_label;
			capsule.version		= version;
			capsule.uopt		= pipeline.uopt;
			capsule.threshopt	= threshOpt;
			capsule.points		= threshPts;
			capsule.elapsed_ms	= end_ms - start_ms;
			capsule.done		= FormatTime(end_ms);
		end
	end
end

function [dataset,ts] = get_dataset(data_label,fcreate_dataset,varargin)
% TODO: This disk-data memoization function (i.e., caching and
% retrieval function) is reasonably generic and should be usable for
% datasets other than capsules.  Should perhaps make it into a
% standalone function, or perhaps into a disk-data memoization class.
	opt		= ParseArgs(varargin, ...
				'data_varname'	, 'dataset'			, ...
				'not_before'	, '20150101_'		, ...
				'savedata'		, true				, ...
				'timestamp'		, []				  ...
				);
	dirpath			= '../data_store';
	filenames		= split(ls(dirpath),'\n');
	suffix			= sprintf('_%s.mat',data_label);
	filename_regexp	= sprintf('^[_\\d]{4,}%s$',suffix);
	matches			= filenames(~cellfun(@isempty,regexp(filenames,filename_regexp)));
	sorted_names	= sort(cat(1,matches,{opt.not_before}));
	recent_names	= sorted_names((1+find(strcmp(opt.not_before,sorted_names))):end);
	if numel(recent_names) == 0
		if isempty(fcreate_dataset)
			fprintf('Preexisting %s not available for %s\n',opt.data_varname,data_label);
			dataset	= [];
			ts		= [];
		else
			fprintf('Creating new %s for %s\n',opt.data_varname,data_label);
			dataset	= fcreate_dataset();
			ts		= unless(opt.timestamp,FormatTime(nowms,'yyyymmdd_HHMMSS'));
			if opt.savedata
				path	= sprintf('%s/%s%s',dirpath,ts,suffix);
				eval(sprintf('%s = dataset;',opt.data_varname));
				save(path,opt.data_varname,'-v7.3');
				fprintf('Saved %s to %s\n',opt.data_varname,path);
			end
		end
	else
		fprintf('Using preexisting %s for %s\n',opt.data_varname,data_label);
		newest_name	= recent_names{end};
		path		= sprintf('%s/%s',dirpath,newest_name);
		fprintf('Loading %s\n',path);
		content		= load(path);
		dataset		= content.(opt.data_varname);
		ts_regexp	= sprintf('^(.*)%s$',suffix);
		ts			= regexprep(newest_name,ts_regexp,'$1');
	end
end

function h = linefit_test_vs_SNR(sPoint,pThreshold,varname)
	xvals	= [sPoint.x];
	yvals	= [sPoint.y];
	pvals	= max(1e-6,min([sPoint.p],1e6));
	snr		= unique(xvals);
	nsnr	= numel(snr);
	ploty	= zeros(1,nsnr);
	ploterr	= zeros(1,nsnr);
	errfac	= 1;	% For error bars at 50%; TODO: revise
	for ks=1:nsnr
		b	= xvals == snr(ks);
		if sum(b) < 4
			ploty(ks)	= NaN;
		else
			y			= yvals(b);
			logp		= log10(pvals(b));
			[fit,S]		= polyfit(logp,y,1);
			[fity,dy]	= polyval(fit,log10(pThreshold),S);
			ploty(ks)	= fity;
			ploterr(ks)	= errfac*dy;
		end
	end
	titleStr	= sprintf('%s vs SNR to achieve p=%s',varname,num2str(pThreshold));

	hA	= alexplot(snr,ploty, ...
			'error'		, ploterr		, ...
			'title'		, titleStr		, ...
			'errortype'	, 'bar'			  ...
			);
	h	= hA.hF;
end

function h = scatter_p_vs_SNR(sPoint,pThreshold,varname)
	h	= scatter_p_vs_x('SNR',[sPoint.x],[sPoint.p],varname,[sPoint.y],pThreshold);
end

function h = scatter_p_vs_test(sPoint,pThreshold,varname)
	h	= scatter_p_vs_x(varname,[sPoint.y],[sPoint.p],'SNR',[sPoint.x],pThreshold);
end

function h = scatter_p_vs_x(xname,xvals,pvals,colorname,colorvals,pThreshold)
	log10_p		= log10(max(1e-6,min(pvals,1e6)));
	xdistinct	= unique(xvals);
	xmost		= xdistinct(1:end-1);
	if ~isempty(xmost)
		xgap		= diff(xdistinct);
		nbetween	= ceil(200/numel(xmost));
		dots		= reshape(repmat(xmost,nbetween,1)+(1:nbetween).'*xgap/(nbetween+1),1,[]);
	else
		dots		= [];
	end
	unit		= ones(size(dots));
	scatx		= [xvals dots];
	scaty		= [log10_p log10(pThreshold)*unit];
	color		= [colorvals max(colorvals)*unit];
	h			= figure;
	scatter(scatx,scaty,10,color);
	title(sprintf('log10(p) vs %s, with low %s as blue, high %s as red/brown',xname,colorname,colorname));
end

function h = scatter_test_vs_SNR(sPoint,pThreshold,varname)
% TODO: This function is redundant with plot_points in ThresholdSketch.
% Should clean up this redundancy.
	ratio		= max(1e-6,min([sPoint.p]./pThreshold,1e6));
	area		= 10+abs(60*log(ratio));
	leThreshold	= [sPoint.p] <= pThreshold;
	blue		= leThreshold.';
	red			= ~blue;
	green		= zeros(size(red));
	color		= [red green blue];
	h			= figure;
	scatter([sPoint.x],[sPoint.y],area,color);
	title(sprintf('%s vs SNR, with low p as blue, high p as red',varname));
end
