% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef AltCausalSimulator3_Descend < CausalSimulator
	% AltCausalSimulator3_Descend:  CausalSimulator w/ ranked signals
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		columnShrinkFactor = 2
	end

	methods
		function set.columnShrinkFactor(obj,value)
			obj.columnShrinkFactor = value;
		end
	end

	methods
		function obj = AltCausalSimulator3_Descend
			obj = obj@CausalSimulator;
		end
		function defineInitialParams(obj)
			obj.defineTinyTestParams;
		end
		function M = makeColumnVariancesDescend(obj,M)
			% First, column means are forced to zero.
			% Then each column is multiplied by a constant so that
			% the column variances descend exponentially:
			% 1, v, v^2, v^3, ..., where v = 1/columnShrinkFactor.
			M = obj.makeColumnMeansZero(M);
			for i = 1:size(M,2)
				existingVariance = var(M(:,i));
				targetVariance = obj.columnShrinkFactor ^ (1-i);
				if existingVariance > 0
					rescaling = sqrt(targetVariance/existingVariance);
					M(:,i) = rescaling * M(:,i);
				end
			end
		end
		function F = massageFunctionalSigs(obj,F)
			F = obj.makeColumnVariancesDescend(F);
		end
		function showParams(obj)
			showParams@CausalSimulator(obj);
			fprintf('Column shrink factor = %d\n',...
				obj.columnShrinkFactor);
		end
	end

	methods (Static)
		function [sim,data] = runShrink(numTimeSteps,columnShrinkFactor)
			sim = AltCausalSimulator3_Descend;
			sim.numTimeSteps = numTimeSteps;
			sim.columnShrinkFactor = columnShrinkFactor;
			data = sim.performAll;
		end
		function [sim,data] = runUnshrink(numTimeSteps)
			[sim,data] = ...
				AltCausalSimulator3_Descend.runShrink(numTimeSteps,0.1);
			Sf = data.source.funcSigs;
			Sp = data.source.pcaSigs;
			numCols = size(Sf,2);
			revRatios = Sp(:,1:numCols) ./ Sf(:,numCols:-1:1);
			CausalSimulator.showUpperLeftAndMeanAndVariance(revRatios,...
				{'Ratios of pcaSigs to column-reversed funcSigs:',...
				'Means of column-reversed ratios:',...
				'Variances of column-reversed ratios:'});
		end
	end

end

