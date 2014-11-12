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
		function figHandle = showWStarGrayscale(obj)
			figHandle = IntensityPlot.showGrayscale(obj.wStar);
		end
	end
	methods (Static)
	end
end
