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
			%low = min(ws);
			%high = max(ws);
			%range = high - low;
			%clims = [(low-range) (high+range)];
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
end
