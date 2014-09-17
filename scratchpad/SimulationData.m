% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SimulationData < handle
	% SimulationData:  Data for CausalSimulation
	%   TODO: Add detailed comments
	
	properties (SetAccess = private)
		source
		dest
	end
	properties
		weights
	end
	
	methods
		function obj = SimulationData
			obj.source = RegionData;
			obj.dest = RegionData;
			obj.weights = [];
		end
	end
	
end

