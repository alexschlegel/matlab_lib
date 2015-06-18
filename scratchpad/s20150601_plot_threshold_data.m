% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.

% TODO: Comments
%

function h = s20150601_plot_threshold_data(varargin)
	stem		= 's20150601_threshold_data';
	opt			= ParseArgs(varargin, ...
					'axisvars'			, 'snr_test'		, ...
					'fakedata'			, true				, ...
					'forcegen'			, false				, ...
					'nogen'				, true				, ...
					'noplot'			, false				, ...
					'savedata'			, []				, ...
					'saveplot'			, false				, ...
					'varname'			, []				, ...
					'xstart'			, 0.01				, ...
					'xstep'				, 0.001				, ...
					'xend'				, 0.7				  ...
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

	if numel(h) > 0
		if ~opt.saveplot
			fprintf('Skipping save of plot(s) to fig file.\n');
		else
			cap_ts		= sort(cap_ts);
			dirpath		= 'scratchpad/figfiles';
			prefix		= sprintf('%s_%s',cap_ts{end},stem);
			kind		= unless(opt.varname,opt.axisvars);
			figfilepath	= sprintf('%s/%s-%s-%s.fig',dirpath,prefix,kind,FormatTime(nowms,'mmdd'));
			savefig(h(end:-1:1),figfilepath);
			fprintf('Plot(s) saved to %s\n',figfilepath);
		end
	end

	function sketch(testvarName,testvarValues)
		if ~isempty(opt.varname) && ~strcmp(testvarName,opt.varname)
			return;
		end
		snrrange		= opt.xstart:opt.xstep:opt.xend;
		plex			= opt.xend+testvarValues(end)*1i;
		data_label		= sprintf('%s_%s_%d_%s_%d_%s',stem,testvarName,numel(testvarValues), ...
							'SNR',numel(snrrange),num2str(abs(plex)));
		fcreate_dataset	= conditional(opt.nogen,[],@create_threshPts);
		not_before		= conditional(opt.forcegen,timestamp,'00000000_');
		[dataset,ts]	= get_dataset(data_label,fcreate_dataset, ...
							'not_before'	, not_before	, ...
							'savedata'		, opt.savedata	, ...
							'timestamp'		, timestamp		  ...
							);
		if ~opt.noplot
			if ~isempty(dataset)
				allplots	= ~isempty(opt.varname);
				if allplots || strcmp(opt.axisvars,'snr_fittest')
					h(end+1)		= linefit_test_vs_SNR(dataset,0.05,testvarName); % FIXME: should use threshold from data
					cap_ts{end+1}	= ts;
				end
				if allplots || strcmp(opt.axisvars,'snr_test')
					h(end+1)		= scatter_test_vs_SNR(dataset,0.05,testvarName); % FIXME: should use threshold from data
					cap_ts{end+1}	= ts;
				end
				if allplots || strcmp(opt.axisvars,'snr_p')
					h(end+1)		= scatter_p_vs_SNR(dataset,0.05,testvarName); % FIXME: should use threshold from data
					cap_ts{end+1}	= ts;
				end
				if allplots || strcmp(opt.axisvars,'test_p')
					h(end+1)		= scatter_p_vs_test(dataset,0.05,testvarName); % FIXME: should use threshold from data
					cap_ts{end+1}	= ts;
				end
			end
		end

		function threshPts = create_threshPts
			threshPts	= ThresholdSketch(...
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
				save(path,'dataset');
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

function h = linefit_test_vs_SNR(sPoint,pThreshold,varname)
	xvals	= [sPoint.x];
	yvals	= [sPoint.y];
	pvals	= max(1e-6,min([sPoint.p],1e6));
	snr		= unique(xvals);
	nsnr	= numel(snr);
	ploty	= zeros(1,nsnr);
	for ks=1:nsnr
		b	= xvals == snr(ks);
		if sum(b) < 4
			ploty(ks)	= NaN;
		else
			y			= yvals(b);
			logp		= log10(pvals(b));
			fit			= polyfit(logp,y,1);
			ploty(ks)	= fit(1)*log10(pThreshold) + fit(2);
		end
	end
	h		= figure;
	plot(snr,ploty);
	title(sprintf('%s vs SNR to achieve p=%s (no error bars yet)',varname,num2str(pThreshold)));
end

function h = scatter_p_vs_SNR(sPoint,pThreshold,varname)
	h	= scatter_p_vs_x('SNR',[sPoint.x],[sPoint.p],varname,[sPoint.y],pThreshold);
end

function h = scatter_p_vs_test(sPoint,pThreshold,varname)
	h	= scatter_p_vs_x(varname,[sPoint.y],[sPoint.p],'SNR',[sPoint.x],pThreshold);
end

function h = scatter_p_vs_x(xname,xvals,pvals,colorname,colorvals,pThreshold)
	log10_p		= log10(max(1e-6,min(pvals,1e6)));
	%xsorted		= sort(xvals);
	%xdistinct	= xsorted([(xsorted(1:end-1) ~= xsorted(2:end)) true]);
	xdistinct	= unique(xvals);
	xmost		= xdistinct(1:end-1);
	xgap		= diff(xdistinct);
	nbetween	= ceil(200/numel(xmost));
	dots		= reshape(repmat(xmost,nbetween,1)+(1:nbetween).'*xgap/(nbetween+1),1,[]);
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
