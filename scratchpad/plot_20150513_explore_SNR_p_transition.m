% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to plot data from 20150514_0904_explore_SNR.mat
% See also create_20150512_explore_SNR_WStrength.m


function hF = plot_20150513_explore_SNR_p_transition(varargin)
stem			= 'explore_SNR_p_transition';
matfilePrefix	= '20150514_0904';
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


% Capsule 1 multiplots

cap1		= cCapsule{1};

horizVar	= {									  ...
				'CRecur'		, {0 0.5}		  ...
			  };
%{
vertVar12	= {
				{'WFullness'	, {0.15 0.25}}
				{'WFullness'	, {0.25 0.35}}
			  };
fixedPairs	= { ...
				'CRecur'		, 0				, ...
				'WFullness'		, 0.25			  ...
			  };
%}
vertVar		= {};
fixedPairs	= {};
constPairs	= {};
if strcmp(opt.yvarname,'alex_log10_p')
	constPairs	= {											  ...
					'log(0.05)'		, log(0.05)/log(10)		  ...
				  };
end

hF			= plot_pairs_SNR_WStrength(hF,cap1,opt.yvarname,horizVar,vertVar,fixedPairs,constPairs,opt);


if ~opt.autosave
	fprintf('Skipping auto-save.\n');
	return;
end

figfilepath	= sprintf('scratchpad/figfiles/%s-%s-%s.fig',stem, ...
				opt.yvarname,FormatTime(nowms,'mmdd'));
savefig(hF(end:-1:1),figfilepath);
fprintf('Plots saved to %s\n',figfilepath);

end

function hF = plot_pairs_SNR_WStrength(hF,capsule,yVarName,horizVar,vertVar,fixedPairs,constPairs,opt)
	spec			= capsule.plotSpec;
	WStrength_vals	= spec.varValues{2};

	W_subset		= WStrength_vals(1:end);

	p			= Pipeline;
	ha			= p.renderMultiLinePlot(capsule,'SNR'			, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, 'WStrength'		, ...
					'lineVarValues'			, W_subset			, ...
					'horizVarName'			, horizVar{1}		, ...
					'horizVarValues'		, horizVar{2}		, ...
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
