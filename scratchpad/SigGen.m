% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SigGen < handle
	% SigGen:  Trig-based signal generator for set of like trials
	%   (Applies to functional signals only, not voxel signals.)
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		baseParams
		W
		isDestBalancing
	end
	methods
		function obj = SigGen(baseParams,W,isDestBalancing)
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
				currSrc = obj.makeSines(i,evenFreqs-1,...
					obj.baseParams.sourceNoisiness);
				currDst = obj.makeSines(i,evenFreqs,...
					obj.baseParams.destNoisiness) + wTrans * prevSrc;
				if obj.isDestBalancing
					fakeSrc = obj.makeSines(i,evenFreqs-1,...
						obj.baseParams.sourceNoisiness);
					fakeWt = 1.0;
					%fakeWt = 0.13;
					currDst = currDst + fakeWt * (1 - wTrans) * fakeSrc;
				end
				src(i,:) = currSrc';
				dst(i,:) = currDst';
				prevSrc = currSrc;
			end
			src = zscore(src);
			dst = zscore(dst);
		end
		function vals = makeSines(obj,i,freqs,noisiness)
			nt = obj.baseParams.numTimeSteps;
			vals = sin(((i-1)/(nt-1) * 2*pi) * freqs) + ...
				noisiness * randn(size(freqs));
		end
	end
end
