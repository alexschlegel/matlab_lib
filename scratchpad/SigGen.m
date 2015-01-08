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
			preWTrans = rp.preW.';
			wTrans = rp.W.';
			nsWTrans = rp.nonsourceW.';
			srcCoeffSums = rp.recurDiagonals{2}.' + ...
				opt.noiseAtSource;
			dstCoeffSums = rp.recurDiagonals{4}.' + sum(wTrans,2) + ...
				opt.noiseAtDest;
			nt = opt.numTimeSteps;
			nf = opt.numFuncSigs;
			src = zeros(nt,nf);
			dst = zeros(nt,nf);
			prevPre = zeros(nf,1);
			prevSrc = zeros(nf,1);
			prevNon = zeros(nf,1);
			prevDst = zeros(nf,1);
			for i = 1:nt
				currPre = diag(rp.recurDiagonals{1}) * prevPre;
				currSrc = diag(rp.recurDiagonals{2}) * prevSrc;
				currNon = diag(rp.recurDiagonals{3}) * prevNon;
				currDst = diag(rp.recurDiagonals{4}) * prevDst;

				currSrc = currSrc + preWTrans * prevPre;
				currDst = currDst + wTrans * prevSrc + nsWTrans * prevNon;

				% TODO: May want to change breakdown of noise params;
				% at present, noiseAtSource is reused for three purposes.
				currPre = currPre + opt.noiseAtSource * randn(nf,1);
				currSrc = currSrc + opt.noiseAtSource * randn(nf,1);
				currNon = currNon + opt.noiseAtSource * randn(nf,1);
				currDst = currDst + opt.noiseAtDest * randn(nf,1);

				if obj.opt.lizierNorm
					currSrc = currSrc ./ srcCoeffSums;
					currDst = currDst ./ dstCoeffSums;
				end
				src(i,:) = currSrc';
				dst(i,:) = currDst';
				prevPre = currPre;
				prevSrc = currSrc;
				prevNon = currNon;
				prevDst = currDst;
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
				'noise'					, 1		, ...
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
