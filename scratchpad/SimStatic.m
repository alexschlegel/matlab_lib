% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SimStatic
	% SimStatic:  General static methods for causal simulation
	%   TODO: Add detailed comments

	methods (Static)
		function M = clipmat(M,maxrows,maxcols)
			nrows = min(size(M,1),maxrows);
			ncols = min(size(M,2),maxcols);
			M = M(1:nrows,1:ncols);
		end
		function [A1,A2] = generateRandomAddends(A)
			fracs = rand(size(A));
			A1 = A .* fracs;
			A2 = A .* (1 - fracs);
		end
		function noise = makeNoise(noiseWeights)
			noise = noiseWeights .* randn(size(noiseWeights));
		end
	end
end
