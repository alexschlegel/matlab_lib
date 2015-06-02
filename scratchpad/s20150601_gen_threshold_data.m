% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% TODO: Comments
%

function h = s20150601_gen_threshold_data(varargin)
	stem		= 's20150601_threshold_data';
	timestamp	= FormatTime(nowms,'yyyymmdd_HHMMSS');

	sketch('nRun'		, 2:20);
	sketch('nSubject'	, 1:20);
	sketch('nTBlock'	, 1:20);
	sketch('nRepBlock'	, 2:15);
	sketch('WStrength'	, 0.01:0.001:0.8);

	function sketch(testvarName,testvarValues)
		valuesStr		= sprintf('_%d',testvarValues([1,end]));
		data_label		= sprintf('%s_%s%s',stem,testvarName,valuesStr);
		[dataset,ts]	= get_dataset(data_label,@create_threshPts,'timestamp',timestamp);
		%{
		FIXME: Adapt following to this context
		if ~opt.noplot
			ha				= plot_SNR_vs_testvar(threshPts,opt.yvarname,{},{},{},constPairs);
			h(end+1)		= ha.hF;
			cap_ts{end+1}	= ts;
		end
		%}

		function threshPts = create_threshPts
			threshPts	= ThresholdSketch(...
							'yname'		, testvarName		, ...
							'yvals'		, testvarValues		, ...
							'seed'		, 0					, ...
							varargin{:} ...
							);
		end
	end
end

function [dataset,ts] = get_dataset(data_label,fcreate_dataset,varargin)
	opt		= ParseArgs(varargin, ...
				'not_before'	, '20150601_'		, ...
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
		fprintf('Creating new dataset for %s\n',data_label);
		dataset	= fcreate_dataset();
		ts		= unless(opt.timestamp,FormatTime(nowms,'yyyymmdd_HHMMSS'));
		if opt.savedata
			path	= sprintf('%s/%s%s',dirpath,ts,suffix);
			save(path,'dataset','-v7.3');
			fprintf('Saved dataset to %s\n',path);
		end
	else
		fprintf('Using preexisting dataset for %s\n',data_label);
		newest_name	= recent_names{end};
		path		= sprintf('%s/%s',dirpath,newest_name);
		fprintf('Loading %s...\n',path);
		content		= load(path);
		dataset		= content.dataset;
		ts_regexp	= sprintf('^(.*)%s$',suffix);
		ts			= regexprep(newest_name,ts_regexp,'$1');
	end
end
