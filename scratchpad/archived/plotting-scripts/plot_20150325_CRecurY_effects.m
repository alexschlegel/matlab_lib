% For old plotting scripts, see scratchpad/archived/plotting-scripts/*

% Script to create figures from exploratory data capsules

% FIXME:  The legends for the plots created by this script initially
% appear correctly on the generated figures, but disappear from the
% figures that are combined into multiplots.
%
% TODO: Consider restoring automatic date labeling using this construct:
% ['.....' FormatTime(nowms,'yyyymmdd_HHMM') '.....'];

function [cHF,cMP] = plot_20150325_CRecurY_effects
cHF	= cell(1,0);
cMP	= cell(1,0);

load(['scratchpad/capsules/' '20150324_211457_recurY_plot_data' '.mat']);
cHa			= Pipeline.constructTestPlotsFromData(plot_data);
ha			= cellfun(@(h) h.hF,cHa(end:-1:1));
figfilename	= '20150325_CRecurY_00_35_70.fig';
savefig(ha,figfilename);
fprintf('Plots saved to %s\n',figfilename);
close(ha);


% CRecurY=0.7  CRecurY=0.6
% CRecurY=0.5  CRecurY=0.4
plotQuadCapsule(...
	{'20150317_194248_iflow_plot_data' '20150323_205518_iflow_plot_data';...
	 '20150323_103041_iflow_plot_data' '20150323_225643_iflow_plot_data'},...
	 '20150325_CRecurY_multi_70_60_50_40.fig');

%{
% CRecurY=0.7  CRecurY=0.6
% CRecurY=0.5  CRecurY=0.35
[cHF{end+1},cMP{end+1}]=plotQuadCapsule(...
	{'20150317_194248_iflow_plot_data' '20150323_205518_iflow_plot_data';...
	 '20150323_103041_iflow_plot_data' '20150323_123209_CRecurY_0_35_plot_data'});
%}

end

function [HF,mp] = plotQuadCapsule(cCapsuleName,figfilename)
	if any(size(cCapsuleName) ~= [2 2])
		error('Expected 2x2 grid of names.');
	end
	pp			= Pipeline39e313e;
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

