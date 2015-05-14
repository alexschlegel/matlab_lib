% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to plot data from 20150513_0043_explore_SNR.mat
% See also create_20150512_explore_SNR_WStrength.m


function hF = plot_20150512_explore_SNR_WStrength(varargin)
stem			= 'explore_SNR_WStrength';
matfilePrefix	= '20150513_0043';
opt				= ParseArgs(varargin, ...
					'yvarname'		, 'acc'		, ...
					'autosave'		, false		, ...
					'extra_plots'	, false		, ...
					'capsule'		, []		  ...
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

cap1			= cCapsule{1};

horizVar		= {									  ...
					'CRecur'		, {0 0.5}		  ...
				  };
vertVar12		= {
					{'WFullness'	, {0.15 0.25}}
					{'WFullness'	, {0.25 0.35}}
				  };
%{
fixedPairs		= { ...
					'CRecur'		, 0				, ...
					'WFullness'		, 0.25			  ...
				  };
%}
fixedPairs	= {};

hF				= plot_quads_SNR_WStrength(hF,cap1,opt.yvarname,horizVar,vertVar12{1},fixedPairs,opt);
hF				= plot_quads_SNR_WStrength(hF,cap1,opt.yvarname,horizVar,vertVar12{2},fixedPairs,opt);


if ~opt.autosave
	fprintf('Skipping auto-save.\n');
	return;
end

figfilepath		= sprintf('scratchpad/figfiles/%s-%s-%s.fig',stem, ...
					opt.yvarname,FormatTime(nowms,'mmdd'));
savefig(hF(end:-1:1),figfilepath);
fprintf('Plots saved to %s\n',figfilepath);

end

function hF = plot_quads_SNR_WStrength(hF,capsule,yVarName,horizVar,vertVar,fixedPairs,opt)
	spec			= capsule.plotSpec;
	SNR_vals		= spec.varValues{1};
	WStrength_vals	= spec.varValues{2};

	assert(numel(SNR_vals) == 8,'bad assumption');
	assert(numel(WStrength_vals) == 6,'bad assumption');

	S_subset		= SNR_vals(2:2:end);
	W_subset		= WStrength_vals(2:end);

	p			= Pipeline;
	ha			= p.renderMultiLinePlot(capsule,'SNR'			, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, 'WStrength'		, ...
					'lineVarValues'			, W_subset			, ...
					'horizVarName'			, horizVar{1}		, ...
					'horizVarValues'		, horizVar{2}		, ...
					'vertVarName'			, vertVar{1}		, ...
					'vertVarValues'			, vertVar{2}		, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
					);
	hF(end+1)	= ha.hF;

	if ~opt.extra_plots
		return;
	end

	ha			= p.renderMultiLinePlot(capsule,'WStrength'		, ...
					'yVarName'				, yVarName			, ...
					'lineVarName'			, 'SNR'				, ...
					'lineVarValues'			, S_subset			, ...
					'horizVarName'			, horizVar{1}		, ...
					'horizVarValues'		, horizVar{2}		, ...
					'vertVarName'			, vertVar{1}		, ...
					'vertVarValues'			, vertVar{2}		, ...
					'fixedVarValuePairs'	, fixedPairs		  ...
					);
	hF(end+1)	= ha.hF;
end
