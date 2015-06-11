% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% This script is loosely based on old_20150403_explore_params.m and
% plot_20150407_explore_params.m, but also incorporates some of the
% conventions used by s20150605_plot_thresholds.m.  (The first two of
% those scripts reside in archived/separated-data-and-plot-scripts/
% capsule-{creation,plotting}-scripts/{_old/,} as of this writing.)

% TODO: Comments
%

function h = s20150610_plot_nSample_wwo_HRF(varargin)
	stem		= 's20150610_nSample_wwo_HRF';
	opt			= ParseArgs(varargin, ...
					'fakedata'		, []			, ...
					'forcegen'		, false			, ...
					'nogen'			, []			, ...
					'noplot'		, []			, ...
					'savedata'		, []			, ...
					'saveplot'		, false			  ...
					);
	extraargs	= opt2cell(opt.opt_extra);
	hasFigwin	= feature('ShowFigureWindows');
	defaultGen	= isempty(opt.nogen);
	requestPlot	= ~notfalse(opt.noplot);

	if ~nottrue(opt.noplot) && ~nottrue(opt.saveplot)
		error('Cannot set both ''noplot'' and ''saveplot'' to true.');
	end

	opt.fakedata	= unless(opt.fakedata,hasFigwin);
	opt.nogen		= unless(opt.nogen,hasFigwin) && ~opt.forcegen;
	opt.noplot		= unless(opt.noplot,false) || ~hasFigwin;
	opt.savedata	= unless(opt.savedata,~opt.fakedata);

	if defaultGen && opt.nogen
		fprintf('(Data generation disabled. Override with ''forcegen'' or set ''nogen'' false.)\n');
	end
	if ~opt.nogen && opt.fakedata
		fprintf('(Generated data (if any) will be fake. Override with ''fakedata'' false.)\n');
	end
	if ~opt.nogen && ~opt.savedata
		fprintf('(To save generated data, set option ''savedata'' to true.)\n');
	end
	if requestPlot && ~hasFigwin
		fprintf('(No ''ShowFigureWindows'' feature. Plot rendering disabled.)\n');
	end
	if ~opt.noplot && ~opt.saveplot
		fprintf('(To save plot(s) as fig file, set option ''saveplot'' to true.)\n');
	end

	pipeline		= Pipeline(extraargs{:});
	pipeline		= pipeline.changeDefaultsForBatchProcessing;
	pipeline		= pipeline.changeOptionDefault('analysis','alex');
	pipeline		= pipeline.changeOptionDefault('seed',0);
	pipeline		= pipeline.consumeRandomizationSeed;
	if opt.fakedata
		pipeline	= pipeline.changeOptionDefault('fudge',{'stubsim'});
	end

	timestamp		= FormatTime(nowms,'yyyymmdd_HHMMSS');
	h				= [];
	[capsule,capTS]	= acquireCapsule;

	if opt.noplot || isempty(capsule)
		return;
	end
	plotCapsule(capsule);

	if numel(h) > 0
		if ~opt.saveplot
			fprintf('Skipping save of plot(s) to fig file.\n');
		else
			%cap_ts		= sort(cap_ts);
			%capTS		= cap_ts{end};
			dirpath		= 'scratchpad/figfiles';
			prefix		= sprintf('%s_%s',capTS,stem);
			figfilepath	= sprintf('%s/%s-%s.fig',dirpath,prefix,FormatTime(nowms,'mmdd'));
			savefig(h(end:-1:1),figfilepath);
			fprintf('Plot(s) saved to %s\n',figfilepath);
		end
	end

	function [capsule,ts] = acquireCapsule
		data_label		= stem;
		fcreate_dataset	= conditional(opt.nogen,[],@createCapsule);
		not_before		= conditional(opt.forcegen,timestamp,'00000000_');
		[capsule,ts]	= get_dataset(data_label,fcreate_dataset, ...
							'data_varname'	, 'capsule'		, ...
							'not_before'	, not_before	, ...
							'savedata'		, opt.savedata	, ...
							'timestamp'		, timestamp		  ...
							);

		function capsule = createCapsule
			spec.pseudoVar	= {'nSamplePerRun' 'I' 'J'};
			spec.varName	= {'nSamplePerRun' 'nTBlock' 'nRepBlock' 'I' 'J' 'HRF' 'deconvTRs'};
			spec.varValues	= {12*(2:6),[1 2 3 4 6 12],NaN,1:2,1:2,NaN,NaN};
			spec.transform	= @transform;
			capsule			= pipeline.makePlotCapsule(spec);

			function [nSamplePerRun,nTBlock,nRepBlock,I,J,HRF,deconvTRs] = transform(nSamplePerRun,nTBlock,~,I,J,~,~)
				nRepBlock	= round(nSamplePerRun/nTBlock);
				deconvGrid	= {1 2; 3 false};
				deconvTRs	= deconvGrid{I,J};
				HRF			= notfalse(deconvTRs);
			end
		end
	end

	function plotCapsule(capsule)
		ha	= pipeline.renderMultiLinePlot(capsule,'nTBlock', ...
				'lineVarName'			, 'nSamplePerRun'	, ...
				'lineVarValues'			, 12*(2:6)			, ...
				'vertVarName'			, 'I'				, ...
				'vertVarValues'			, 1:2				, ...
				'horizVarName'			, 'J'				, ...
				'horizVarValues'		, 1:2				  ...
			);

		h(end+1)	= ha.hF; %#ok
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
