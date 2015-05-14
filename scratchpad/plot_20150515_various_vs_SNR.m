% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to plot data from 20150515_HHMM_various_vs_SNR.mat
% See also create_20150515_various_vs_SNR.m


function hF = plot_20150515_various_vs_SNR(varargin)
stem			= 'various_vs_SNR';
matfilePrefix	= '20150515_HHMM';
opt				= ParseArgs(varargin, ...
					'yvarname'		, 'alex_log10_p'	, ...
					'autosave'		, false				, ...
					... %'extra_plots'	, false				, ...
					'capsule'		, []				  ...
					);
hF				= zeros(1,0);

if ~opt.autosave
	fprintf('For auto-save, set option ''autosave'' to true.\n');
end

if ~isempty(opt.capsule)
	cCapsule	= opt.capsule;
	stem		= sprintf('%s_%s',cCapsule{1}.id,stem);
else
	% Try to obtain cCapsule from mat file
	stem		= sprintf('%s_%s',matfilePrefix,stem);
	load(['../data_store/' stem '.mat']);
end


horizVar	= {};
vertVar		= {};
fixedPairs	= {};
constPairs	= {};
if strcmp(opt.yvarname,'alex_log10_p')
	constPairs	= {											  ...
					'log(0.05)'		, log(0.05)/log(10)		  ...
				  };
end

nCap		= numel(cCapsule);
for kCap=1:nCap
	hF	= plot_testvar_with_SNR(hF,cCapsule{kCap},opt.yvarname,horizVar,vertVar,fixedPairs,constPairs,opt);
end

if ~opt.autosave
	fprintf('Skipping auto-save.\n');
	return;
end

figfilepath	= sprintf('scratchpad/figfiles/%s-%s-%s.fig',stem, ...
				opt.yvarname,FormatTime(nowms,'mmdd'));
savefig(hF(end:-1:1),figfilepath);
fprintf('Plots saved to %s\n',figfilepath);

end

function hF = plot_testvar_with_SNR(hF,capsule,yVarName,horizVar,vertVar,fixedPairs,constPairs,opt)
	spec			= capsule.plotSpec;
	testvarName		= spec.varName{1};
	testvarValues	= spec.varValues{1};

	testvarSubset	= testvarValues(1:end);

	p			= Pipeline;
	ha			= p.renderMultiLinePlot(capsule,'SNR'			, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, testvarName		, ...
					'lineVarValues'			, testvarSubset		, ...
					'fixedVarValuePairs'	, fixedPairs		, ...
					'constLabelValuePairs'	, constPairs		  ...
					);
	hF(end+1)	= ha.hF;

	%{
	if ~opt.extra_plots
		return;
	end
	%}
end
