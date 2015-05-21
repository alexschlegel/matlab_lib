% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% This script creates plots in two phases (each of which is optional
% in any given run):
%
%  1. Generation of so-called plot-data capsules;
%  2. Conversion of plot-data capsules to plot figures.
%
% TODO: More comments

% For old plot-capsule-creation and plot-creation scripts, see
%   scratchpad/archived/separated-data-and-plot-scripts/*/*
%

function h = s20150520_plot_SNR_effects(varargin)
	stem		= 's20150520_SNR_effects';
	not_before	= '20150521_';
	opt			= ParseArgs(varargin, ...
					'noplot'		, false				, ...
					'not_before'	, not_before		, ...
					'savedata'		, []				, ...
					'saveplot'		, false				, ...
					'yvarname'		, 'alex_log10_p'	  ...
					);
	extraargs	= opt2cell(opt.opt_extra);
	pipeline	= Pipeline(extraargs{:});
	pipeline	= pipeline.changeDefaultsForBatchProcessing;
	pipeline	= pipeline.changeOptionDefault('analysis','alex');
	pipeline	= pipeline.changeOptionDefault('seed',0);

	if opt.noplot && opt.saveplot
		error('Cannot set both ''noplot'' and ''saveplot'' to true.');
	end
	if ~opt.noplot
		if ~feature('ShowFigureWindows')
			fprintf('''ShowFigureWindows'' is off; plot rendering will be deferred.\n');
			opt.noplot	= true;
		end
	end
	if ~opt.noplot && ~opt.saveplot
		fprintf('To save plot(s) as fig file, set option ''saveplot'' to true.\n');
	end
	if isempty(opt.savedata)
		opt.savedata	= ~ismember('stubsim',pipeline.uopt.fudge);
	end

	new_timestamp	= FormatTime(nowms,'yyyymmdd_HHMMSS');
	h				= [];
	cap_ts			= {};

	constPairs		= {};
	if strcmp(opt.yvarname,'alex_log10_p')
		constPairs	= {											  ...
						'log(0.05)'		, log(0.05)/log(10)		  ...
					  };
	end

	plot_SNR_vs('nRun'		, 2:20);
	plot_SNR_vs('nSubject'	, 1:20);
	plot_SNR_vs('nTBlock'	, 1:20);
	plot_SNR_vs('nRepBlock'	, 2:15);

	plot_vs_SNR('nRun'		, [5 8 11 14 17]);
	plot_vs_SNR('nSubject'	, [5 8 11 14 17]);
	plot_vs_SNR('nTBlock'	, [1 3 6 10 15]);
	plot_vs_SNR('nRepBlock'	, [3 4 5 6 7]);

	if numel(h) > 0
		if ~opt.saveplot
			fprintf('Skipping save of plot(s) to fig file.\n');
		else
			cap_ts		= sort(cap_ts);
			dirpath		= 'scratchpad/figfiles';
			prefix		= sprintf('%s_%s-%s',cap_ts{end},stem,opt.yvarname);
			figfilepath	= sprintf('%s/%s-%s.fig',dirpath,prefix,FormatTime(nowms,'mmdd'));
			savefig(h(end:-1:1),figfilepath);
			fprintf('Plot(s) saved to %s\n',figfilepath);
		end
	end

	function plot_SNR_vs(testvarName,testvarValues)
		valuesStr		= sprintf('_%d',testvarValues([1,end]));
		data_label		= sprintf('%s_SNR_vs_%s%s',stem,testvarName,valuesStr);
		[capsule,ts]	= get_capsule(data_label,@create_capsule);
		if ~opt.noplot
			ha				= plot_SNR_vs_testvar(capsule,opt.yvarname,{},{},{},constPairs);
			h(end+1)		= ha.hF;
			cap_ts{end+1}	= ts;
		end

		function capsule = create_capsule
			spec	= make_spec_for_SNR_vs_testvar(testvarName,testvarValues);
			capsule	= pipeline.makePlotCapsule(spec);
		end
	end

	function plot_vs_SNR(testvarName,testvarValues)
		valuesStr		= sprintf('_%d',testvarValues);
		data_label		= sprintf('%s_%s%s_vs_SNR',stem,testvarName,valuesStr);
		[capsule,ts]	= get_capsule(data_label,@create_capsule);
		if ~opt.noplot
			ha				= plot_testvar_vs_SNR(capsule,opt.yvarname,{},{},{},constPairs);
			h(end+1)		= ha.hF;
			cap_ts{end+1}	= ts;
		end
						
		function capsule = create_capsule
			spec	= make_spec_for_testvar_vs_SNR(testvarName,testvarValues);
			capsule	= pipeline.makePlotCapsule(spec);
		end
	end

	function [capsule,ts] = get_capsule(data_label,fcreate_capsule)
		dirpath			= '../data_store';
		filenames		= split(ls(dirpath),'\n');
		suffix			= sprintf('_%s.mat',data_label);
		filename_regexp	= sprintf('^[_\\d]{4,}%s$',suffix);
		matches			= filenames(~cellfun(@isempty,regexp(filenames,filename_regexp)));
		sorted_names	= sort(cat(1,matches,{opt.not_before}));
		recent_names	= sorted_names((1+find(strcmp(opt.not_before,sorted_names))):end);
		if numel(recent_names) == 0
			fprintf('Creating new capsule for %s\n',data_label);
			capsule	= fcreate_capsule();
			ts		= new_timestamp;
			if opt.savedata
				path	= sprintf('%s/%s%s',dirpath,ts,suffix);
				save(path,'capsule','-v7.3');
				fprintf('Saved capsule to %s\n\n',path);
			end
		else
			fprintf('Using preexisting capsule for %s\n',data_label);
			newest_name	= recent_names{end};
			path		= sprintf('%s/%s',dirpath,newest_name);
			fprintf('Loading %s...\n\n',path);
			data		= load(path);
			capsule		= data.capsule;
			ts_regexp	= sprintf('^(.*)%s$',suffix);
			ts			= regexprep(newest_name,ts_regexp,'$1');
		end
	end
end

function spec = make_spec_for_SNR_vs_testvar(testvarName,testvarValues)
	snr_values		= (9:4:25)/100;

	spec.varName	= {'SNR' testvarName};
	spec.varValues	= {snr_values,testvarValues};
	spec.nIteration	= 15;
end

function spec = make_spec_for_testvar_vs_SNR(testvarName,testvarValues)
	snr_range		= [0.1,0.25];
	nSNR			= 15;

	spec.pseudoVar	= 'SNR_index';
	spec.varName	= {testvarName 'SNR_index' 'SNR'};
	spec.varValues	= {testvarValues, 1:nSNR, NaN};
	spec.transform	= @transform;
	spec.nIteration	= 15;

	function [testvar,SNR_index,SNR] = transform(testvar,SNR_index,~)
		testvar_progress	= (find(testvar==testvarValues) - 1)/numel(testvarValues);
		snr_progress		= max(0,(SNR_index-testvar_progress - 1)/(nSNR - 1));
		SNR					= snr_range * splitdiff(snr_progress).';
		assert(isscalar(SNR),'bug');
	end

	function interpolation_vector = splitdiff(frac)
		interpolation_vector	= [1-frac, frac];
	end
end

function ha = plot_SNR_vs_testvar(capsule,yVarName,horizVar,vertVar,fixedPairs,constPairs)
	spec			= capsule.plotSpec;
	testvarName		= spec.varName{2};
	snr_values		= spec.varValues{1};
	snr_subset		= snr_values(1:end);

	assert(isempty(horizVar),'unexpected horizVar');
	assert(isempty(vertVar),'unexpected vertVar');

	p			= Pipeline;
	ha			= p.renderMultiLinePlot(capsule,testvarName		, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, 'SNR'				, ...
					'lineVarValues'			, snr_subset		, ...
					'fixedVarValuePairs'	, fixedPairs		, ...
					'constLabelValuePairs'	, constPairs		  ...
					);
end

function ha = plot_testvar_vs_SNR(capsule,yVarName,horizVar,vertVar,fixedPairs,constPairs)
	spec			= capsule.plotSpec;
	testvarName		= spec.varName{1};
	testvarValues	= spec.varValues{1};

	testvarSubset	= testvarValues(1:end);

	assert(isempty(horizVar),'unexpected horizVar');
	assert(isempty(vertVar),'unexpected vertVar');

	p			= Pipeline;
	ha			= p.renderMultiLinePlot(capsule,'SNR'			, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, testvarName		, ...
					'lineVarValues'			, testvarSubset		, ...
					'fixedVarValuePairs'	, fixedPairs		, ...
					'constLabelValuePairs'	, constPairs		  ...
					);
end
