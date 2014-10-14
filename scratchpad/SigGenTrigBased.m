% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SigGenTrigBased < handle
	% SigGenTrigBased:  Trig-based signal generator for set of like trials
	%   (Applies to functional signals only, not voxel signals.)
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		baseParams
		W
		isDestBalancing
	end
	methods
		function obj = SigGenTrigBased(baseParams,W,isDestBalancing)
			baseParams.validateW(W);
			obj.baseParams = baseParams;
			obj.W = W;
			obj.isDestBalancing = isDestBalancing;
		end
		function [src,dst] = genSigs(obj)
			wTrans = obj.W.';
			nt = obj.baseParams.numTimeSteps;
			nf = obj.baseParams.numFuncSigs;
			src = zeros(nt,nf);
			dst = zeros(nt,nf);
			evenFreqs = 2*(1:nf)';
			prevSrc = zeros(nf,1);
			for i = 1:nt
				currSrc = obj.makeSines(i,evenFreqs-1);
				currDst = obj.makeSines(i,evenFreqs) + wTrans * prevSrc;
				if obj.isDestBalancing
					fakeSrc = obj.makeSines(i,evenFreqs-1);
					currDst = currDst + (1 - wTrans) * fakeSrc;
				end
				src(i,:) = currSrc';
				dst(i,:) = currDst';
				prevSrc = currSrc;
			end
		end
		function vals = makeSines(obj,i,freqs)
			nt = obj.baseParams.numTimeSteps;
			vals = sin(((i-1)/(nt-1) * 2*pi) * freqs) + ...
				obj.baseParams.noisiness * randn(size(freqs));
		end
	end
end
