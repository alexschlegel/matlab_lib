% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% TODO: Comments
%

function h = s20150601_plot_threshold_data(varargin)
	stem		= 's20150601_threshold_data';
	opt			= ParseArgs(varargin, ...
					'fakedata'			, true				, ...
					'forcegen'			, false				, ...
					'nogen'				, true				, ...
					'noplot'			, false				, ...
					'savedata'			, []				  ...
					);
	extraargs	= opt2cell(opt.opt_extra);

	opt.nogen		= opt.nogen && ~opt.forcegen;
	opt.savedata	= unless(opt.savedata,~opt.fakedata);

	timestamp	= FormatTime(nowms,'yyyymmdd_HHMMSS');
	h			= [];
	cap_ts		= {};

	sketch('nRun'		, 2:20);
	sketch('nSubject'	, 1:20);
	sketch('nTBlock'	, 1:20);
	sketch('nRepBlock'	, 2:15);
	sketch('WStrength'	, 0.01:0.001:0.8);

	function sketch(testvarName,testvarValues)
		valuesStr		= sprintf('_%d',testvarValues([1,end]));
		data_label		= sprintf('%s_%s%s',stem,testvarName,valuesStr);
		fcreate_dataset	= conditional(opt.nogen,[],@create_threshPts);
		not_before		= conditional(opt.forcegen,timestamp,'00000000_');
		[dataset,ts]	= get_dataset(data_label,fcreate_dataset, ...
							'not_before'	, not_before	, ...
							'savedata'		, opt.savedata	, ...
							'timestamp'		, timestamp		  ...
							);
		if ~opt.noplot
			if ~isempty(dataset)
				h(end+1)		= plot_points(dataset,0.05,testvarName); % FIXME: should use threshold from data
				cap_ts{end+1}	= ts;
			end
		end

		function threshPts = create_threshPts
			threshPts	= ThresholdSketch(...
							'fakedata'	, opt.fakedata		, ...
							'noplot'	, true				, ...
							'yname'		, testvarName		, ...
							'yvals'		, testvarValues		, ...
							'seed'		, 0					, ...
							extraargs{:} ...
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
		if isempty(fcreate_dataset)
			fprintf('Preexisting dataset not available for %s\n',data_label);
			dataset	= [];
			ts		= [];
		else
			fprintf('Creating new dataset for %s\n',data_label);
			dataset	= fcreate_dataset();
			ts		= unless(opt.timestamp,FormatTime(nowms,'yyyymmdd_HHMMSS'));
			if opt.savedata
				path	= sprintf('%s/%s%s',dirpath,ts,suffix);
				save(path,'dataset','-v7.3');
				fprintf('Saved dataset to %s\n',path);
			end
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

% TODO: Following function is redundant with same function in ThresholdSketch.
% Should clean up this redundancy.
function [h,area,color] = plot_points(sPoint,pThreshold,varname)
	ratio		= max(1e-6,min([sPoint.p]./pThreshold,1e6));
	area		= 30+abs(60*log(ratio));
	leThreshold	= [sPoint.p] <= pThreshold;
	blue		= leThreshold.';
	red			= ~blue;
	green		= zeros(size(red));
	color		= [red green blue];
	h			= figure;
	scatter([sPoint.x],[sPoint.y],area,color);
	title(sprintf('%s vs SNR',varname));
end
