% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to create figures from exploratory data capsules

% FIXME:  The legends for the plots created by this script initially
% appear correctly on the generated figures, but disappear when the
% figures are combined into multiplots.
%
% TODO: Consider restoring automatic date labeling using this construct:
% ['.....' FormatTime(nowms,'yyyymmdd_HHMM') '.....'];

function [cHF,cMP] = plot_20150318_presource_comparisons
cHF	= cell(1,0);
cMP	= cell(1,0);

%{
% baseline::normvar=1   (already recorded in 20150316_alex_normvar_combo.fig)
% [2nd row w/ crecur=0] (already recorded in 20150316_alex_normvar_combo.fig)
[cHF{end+1},cMP{end+1}]=plotQuadCapsule(...
	{'20150308_230040_iflow_plot_data' '20150316_204320_iflow_plot_data';...
	 '20150309_111726_iflow_plot_data' '20150316_231712_iflow_plot_data'});
%}

% baseline::presrc=0 // [2nd row w/ crecur=0]
plotQuadCapsule(...
	{'20150308_230040_iflow_plot_data' '20150317_194248_iflow_plot_data';...
	 '20150309_111726_iflow_plot_data' '20150318_001321_iflow_plot_data'},...
	 '20150318_baseline_vs_presrc0.fig');

% normvar=1::normvar=1,presrc=0 // [2nd row w/ crecur=0]
plotQuadCapsule(...
	{'20150316_204320_iflow_plot_data' '20150317_221137_iflow_plot_data';...
	 '20150316_231712_iflow_plot_data' '20150318_024149_iflow_plot_data'},...
	 '20150318_normvar1_with_presrc_1_vs_0.fig');

% presrc=0::presrc=0,normvar=1 // [2nd row w/ crecur=0]
plotQuadCapsule(...
	{'20150317_194248_iflow_plot_data' '20150317_221137_iflow_plot_data';...
	 '20150318_001321_iflow_plot_data' '20150318_024149_iflow_plot_data'},...
	 '20150318_presrc0_with_normvar_0_vs_1.fig');

end

function [HF,mp] = plotQuadCapsule(cCapsuleName,figfilename)
	if any(size(cCapsuleName) ~= [2 2])
		error('Expected 2x2 grid of names.');
	end
	pp			= Pipeline;
	cH			= cell(2,2);

	for kD1=1:2
		for kD2=1:2
			load(['scratchpad/capsules/' cCapsuleName{kD1,kD2} '.mat']);
			pd0			= plot_data;
			cCap		= pd0.cCapsule;
			if size(cCap,1) < size(cCap,2)	%FIXME: kludge--does not generalize:
				cCap	= cCap';			%Transpose prev-format capsule grid
			end
			nPlot		= size(cCap,2);
			h0			= cell(nPlot,1);
			for kP=1:nPlot
				h0{kP}	= pp.renderMultiLinePlot(cCap(:,kP),pd0.var2Spec,[1 3 5]);
			end
			cH{kD1,kD2}	= h0;
		end
	end

	nPlot			= cellfun(@(h) numel(h),cH);
	if min(nPlot(:)) ~= max(nPlot(:))
		error('Variable numbers of plots.');
	end
	nPlot			= mean(nPlot(:));

	mp				= cell(nPlot,1);
	for kP=1:nPlot
		figGrid		= cellfun(@(h) h{kP},cH,'uni',false);
		hFGrid		= cellfun(@(h) h.hF,figGrid);
		set(hFGrid,'Position',[0 0 600 350]);
		mp{kP}		= multiplot(figGrid);
	end

	HF	= cellfun(@(h) h.hF,mp(nPlot:-1:1));
	if nargin > 1
		savefig(HF,figfilename);
		fprintf('Plots saved to %s\n',figfilename);
		close(HF);
		HF			= [];
		mp			= [];
	end
end

