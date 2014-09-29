% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef AltCausalSimulator1_Mean < CausalSimulator
	% AltCausalSimulator1_Mean:  CausalSimulator w/ zero-centered signals
	%   TODO: Add detailed comments

	methods
		function obj = AltCausalSimulator1_Mean(baseParams)
			obj = obj@CausalSimulator(baseParams);
		end
		function F = massageFunctionalSigs(obj,F)
			F = obj.makeColumnMeansZero(F);
		end
	end

end

