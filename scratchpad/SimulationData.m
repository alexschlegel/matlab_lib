% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SimulationData < handle
	% SimulationData:  Data for CausalSimulation
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		simulator
		source
		dest
	end
	properties
		wStar
	end

	methods
		function obj = SimulationData(simulator)
			obj.simulator = simulator;
			obj.source = RegionData;
			obj.dest = RegionData;
			obj.wStar = [];
		end
		function clims = getWStarClims(obj)
			ws = obj.wStar(:);
			clims = [min(ws) max(ws)];
		end
		function figHandle = showWStarGrayscale(obj,clims)
			if nargin < 2
				clims = obj.getWStarClims;
			end
			figHandle = figure;
			colormap('gray');
			imagesc(obj.wStar,clims);
		end
	end
	methods (Static)
		function clims = getGlobalWStarClims(data,outlierPercentage)
			if nargin < 2
				outlierPercentage = 5;
			end
			if outlierPercentage < 0 || outlierPercentage > 30
				error(sprintf('Nonsensical outlier percentage %g',...
					outlierPercentage));
			end
			for i = 1:numel(data)
				allW(i,:,:) = data(i).wStar(:,:);
			end
			bottomTailPct = outlierPercentage/2;
			topTailPct = 100-bottomTailPct;
			clims = prctile(allW(:),[bottomTailPct;topTailPct]).';
			%display(clims);

			%for i = 1:numel(data)
			%	climsArray(i,:) = data(i).getWStarClims;
			%end
			%disp('climsArray');
			%disp(climsArray);
			%clims = [min(climsArray(:,1)) max(climsArray(:,2))];
			%disp(clims);
		end
	end
end
