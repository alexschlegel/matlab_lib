% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef WPairedTrialConfig < handle
	% WPairedTrialConfig:  Configuration of paired sets of trials
	%   TODO: Add detailed comments
	%
	% For now, fixed policy with simple W's and no choice of sig-gen.
	%
	% TODO: Could contemplate two-element cell array instead of
	% sigGenA, sigGenB.

	properties (SetAccess = private)
		baseParams
		sigGenA
		sigGenB
	end
	methods
		function obj = WPairedTrialConfig(baseParams,wDensity)
			baseParams.validate;
			nf = baseParams.numFuncSigs;
			wShape = [nf nf];
			wNumel = nf^2;
			wOnes = floor(wNumel * wDensity);
			if wOnes < 1
				error('W density is too low.');
			end
			flatWs = obj.genIndicatorCols(wNumel,[wOnes,wOnes]);
			wA = reshape(flatWs(:,1),wShape);
			wB = reshape(flatWs(:,2),wShape);
			obj.baseParams = baseParams;
			obj.sigGenA = SigGen(baseParams,wA);
			obj.sigGenB = SigGen(baseParams,wB);
		end
	end
	methods (Static)
		function iCols = genIndicatorCols(rows,counts)
			cols = numel(counts);
			iCols = zeros(rows,cols);
			allIndices = randperm(rows,sum(counts));
			offset = 1;
			for i = 1:cols
				indices = allIndices(offset:(offset+counts(i)-1));
				iCols(indices,i) = 1;
				offset = offset + counts(i);
			end
		end
	end
end
