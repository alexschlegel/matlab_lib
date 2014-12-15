% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SigGen < handle
	% SigGen:  Signal generator for set of like trials
	%   (Applies to functional signals only, not voxel signals.)
	%   TODO: Add detailed comments

	properties (SetAccess = private)
		opt
		recurrenceParams
	end
	methods
		function obj = SigGen(W,varargin)
			[opt,optcell] = Opts.getOpts(varargin);
			Opts.validateW(opt,W);
			obj.opt = opt;
			obj.recurrenceParams = RecurrenceParams(W,optcell{:});
		end
		function [src,dst] = genSigs(obj)
			opt = obj.opt;
			rp = obj.recurrenceParams;
			wTrans = rp.W.';
			nsWTrans = rp.nonsourceW.';
			if any(nsWTrans ~= 0)  % TODO: Temporary, for testing
				error('Stuff in nsWTrans');
			end
			srcCoeffSums = rp.recurDiagonals{1}.' + ...
				opt.noisinessForSource;
			dstCoeffSums = rp.recurDiagonals{2}.' + sum(wTrans,2) + ...
				opt.noisinessForDest;
			nt = opt.numTimeSteps;
			nf = opt.numFuncSigs;
			src = zeros(nt,nf);
			dst = zeros(nt,nf);
			%oth = zeros(nt,nf);
			prevSrc = zeros(nf,1);
			prevDst = zeros(nf,1);
			prevOth = zeros(nf,1);
			for i = 1:nt
				currSrc = diag(rp.recurDiagonals{1}) * prevSrc;
				currDst = diag(rp.recurDiagonals{2}) * prevDst;
				currOth = diag(rp.recurDiagonals{3}) * prevOth;

				currDst = currDst + wTrans * prevSrc + nsWTrans * prevOth;

				currSrc = currSrc + opt.noisinessForSource * randn(nf,1);
				currDst = currDst + opt.noisinessForDest * randn(nf,1);
				currOth = currOth + opt.noisinessForSource * randn(nf,1);

				if obj.opt.lizierNorm
					currSrc = currSrc ./ srcCoeffSums;
					currDst = currDst ./ dstCoeffSums;
				end
				src(i,:) = currSrc';
				dst(i,:) = currDst';
				prevSrc = currSrc;
				prevDst = currDst;
				prevOth = currOth;
			end
			if obj.opt.zScoreSigs
				src = zscore(src);
				dst = zscore(dst);
			end
		end
		function W = W(obj)
			W = obj.recurrenceParams.W;
		end
	end
	methods (Static)
		function figHandle = show(varargin)
			[opt,optcell] = Opts.getOpts(varargin,...
				'numFuncSigs'			, 1		, ...
				'numTopComponents'		, 1		, ...
				'numTimeSteps'			, 100	, ...
				'noisinessForDest'		, 1		, ...
				'noisinessForSource'	, 1		, ...
				'iterations'			, 5		  ...
				);
			W = 1;
			gen = SigGen(W,optcell{:});
			figs = zeros(1,opt.iterations);
			for count = 1:opt.iterations
				rng(opt.rngSeedBase+count-1,'twister');
				[src,dst] = gen.genSigs;
				fplotter = FuncSetPlotter;
				sigs = [src dst];
				figs(count) = fplotter.showSigs([src dst]);
			end
			set(figs, 'Position', [0 0 240 160]);
			multiplot(figs);
		end
	end
end
