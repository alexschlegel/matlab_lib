% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% See also s20150610_plot_nSample_wwo_HRF.m

% TODO: Comments
%

function h = s20150612_plot_nSample_w_HRF(varargin)
	stem		= 's20150612_nSample_w_HRF';
	opt			= ParseArgs(varargin, ...
					'fakedata'		, []			, ...
					'forcegen'		, false			, ...
					'nogen'			, []			, ...
					'noplot'		, []			, ...
					'savedata'		, []			, ...
					'saveplot'		, false			, ...
					'yvarname'		, 'acc+logp'	  ...
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
	if ~strcmp(opt.yvarname,'acc+logp')
		plotCapsule(capsule,opt.yvarname);
	else
		plotCapsule(capsule,'acc');
		plotCapsule(capsule,'alex_log10_p');
	end

	if numel(h) > 0
		if ~opt.saveplot
			fprintf('Skipping save of plot(s) to fig file.\n');
		else
			%cap_ts		= sort(cap_ts);
			%capTS		= cap_ts{end};
			dirpath		= 'scratchpad/figfiles';
			prefix		= sprintf('%s_%s',capTS,stem);
			figfilepath	= sprintf('%s/%s-%s-%s.fig',dirpath,prefix,opt.yvarname,FormatTime(nowms,'mmdd'));
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
			spec.pseudoVar	= {'CRecurFrac' 'nSamplePerRun'};
			spec.varName	= {'SNR' 'WStrength' 'CRecurFrac' 'CRecur' 'nSamplePerRun' 'nTBlock' 'nRepBlock' 'HRF'};
			spec.varValues	= {[0.2 0.3 0.4],[0.5 0.6 0.7],[0 0.5 1],NaN,12*(2:6),[1 2 3 4 6 12],NaN,1};
			spec.transform	= @transform;
			capsule			= pipeline.makePlotCapsule(spec);

			function [SNR,WStrength,CRecurFrac,CRecur,nSamplePerRun,nTBlock,nRepBlock,HRF] ...
					= transform(SNR,WStrength,CRecurFrac,~,nSamplePerRun,nTBlock,~,HRF)
				CRecur		= CRecurFrac*(1-WStrength);
				nRepBlock	= round(nSamplePerRun/nTBlock);
			end
		end
	end

	function plotCapsule(capsule,yVarName)
		plotGrid(capsule,yVarName,1,[2 3],3,[2 3],2,1);
	end

	function plotGrid(capsule,yVarName,v_var,v_sel,h_var,h_sel,fixed_var,fixed_sel)
		if ~all(sort([v_var h_var fixed_var]) == [1 2 3])
			error('Var numbers must be a permutation of [1 2 3].');
		end
		spec		= capsule.plotSpec;
		vname		= spec.varName{v_var};
		vvals		= spec.varValues{v_var};
		hname		= spec.varName{h_var};
		hvals		= spec.varValues{h_var};
		fixedname	= spec.varName{fixed_var};
		fixedvals	= spec.varValues{fixed_var};
		fixedpairs	= {fixedname,fixedvals{fixed_sel}};

		ha	= pipeline.renderMultiLinePlot(capsule,'nTBlock', ...
				'tag'					, stem				, ...
				'yVarName'				, yVarName			, ...
				'lineVarName'			, 'nSamplePerRun'	, ...
				'lineVarValues'			, 12*(2:6)			, ...
				'vertVarName'			, vname				, ...
				'vertVarValues'			, vvals(v_sel)		, ...
				'horizVarName'			, hname				, ...
				'horizVarValues'		, hvals(h_sel)		, ...
				'fixedVarValuePairs'	, fixedpairs		  ...
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
