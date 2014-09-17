% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef CausalSimulator < handle
	% CausalSimulator:  Parent class for study of causal flows
	%   TODO: Add detailed comments

	properties (SetAccess = protected)
		numTimeSteps
		numFuncSigs
		numVoxelSigs
		numTopComponents
	end
	properties
		autoShowResults = true
	end

	methods
		function set.numTimeSteps(obj,value)
			obj.numTimeSteps = value;
		end
		function set.numFuncSigs(obj,value)
			obj.numFuncSigs = value;
		end
		function set.numVoxelSigs(obj,value)
			obj.numVoxelSigs = value;
		end
		function set.numTopComponents(obj,value)
			obj.numTopComponents = value;
		end
	end

	methods
		function obj = CausalSimulator
			obj.defineInitialParams;
		end
		function defineInitialParams(obj)
			obj.defineStandardTestParams;
		end
		function defineStandardTestParams(obj)
			obj.numTimeSteps = 100;
			obj.numFuncSigs = 10;
			obj.numVoxelSigs = 500;
			obj.numTopComponents = 10;
		end
		function defineTinyTestParams(obj)
			obj.numTimeSteps = 10;
			obj.numFuncSigs = 3;
			obj.numVoxelSigs = 5;
			obj.numTopComponents = 3;
		end
		function [A1,A2] = generateRandomAddends(~,A)
			fracs = rand(size(A));
			A1 = A .* fracs;
			A2 = A .* (1 - fracs);
		end
		function W = generateSourceToDestinationWeights(obj,absSums)
			nf = obj.numFuncSigs;
			W = zeros(nf);
			% Absolute sum across row i must equal absSums(i)
			for i = 1:nf
				rawRow = randn(1,nf);
				absSum = sum(abs(rawRow));
				if absSum > 0
					normFac = absSums(i) / absSum;
					W(i,:) = rawRow * normFac;
				else
					% Sum of raw row is zero (extremely unlikely under
					% current assumptions, but better safe than sorry)
					W(i,:) = ones(1,nf) * absSums(i) / nf;
				end
			end
		end
		function V = generateVoxelMixer(obj)
			% Note theoretical risk of degenerate transformation;
			% however, likelihood is low enough that this risk can
			% probably be ignored
			V = randn(obj.numFuncSigs,obj.numVoxelSigs);
		end
		function weights = generateWeights(obj)
			nf = obj.numFuncSigs;
			weights = struct;
			funcOnes = ones(nf,1);
			[weights.sourceRecurDiag, weights.sourceNoise] = ...
				obj.generateRandomAddends(funcOnes);
			[destDeterministic, weights.destNoise] = ...
				obj.generateRandomAddends(funcOnes);
			[weights.destRecurDiag, crossSums] = ...
				obj.generateRandomAddends(destDeterministic);
			weights.W = obj.generateSourceToDestinationWeights(crossSums);
		end
		function M = makeColumnMeansZero(~,M)
			M = M - repmat(mean(M),size(M,1),1);
		end
		function [srcF,dstF] = makeFunctionalSigs(obj,weights)
			nt = obj.numTimeSteps;
			nf = obj.numFuncSigs;
			Rs = diag(weights.sourceRecurDiag);
			Rd = diag(weights.destRecurDiag);
			Qs = weights.sourceNoise;
			Qd = weights.destNoise;
			W = weights.W;
			srcF = zeros(nt,nf);
			dstF = zeros(nt,nf);
			srcF(1,:) = obj.makeNoise(Qs)';
			dstF(1,:) = obj.makeNoise(Qd)';
			for i = 2:nt
				srcF(i,:) = (Rs * srcF(i-1,:)' + obj.makeNoise(Qs))';
				dstF(i,:) = (Rd * dstF(i-1,:)' + obj.makeNoise(Qd) + ...
					W * srcF(i-1,:)' )';
			end
			srcF = obj.massageFunctionalSigs(srcF);
			dstF = obj.massageFunctionalSigs(dstF);
		end
		function noise = makeNoise(~,noiseWeights)
			noise = noiseWeights .* randn(size(noiseWeights));
		end
		function F = massageFunctionalSigs(obj,F) %#ok
			% (Action specialized in subclasses)
			%
			%F = obj.makeColumnMeansZero(F);
		end
		function data = performAll(obj)
			rng('default');
			data = SimulationData;
			obj.performFunctionalSynthesis(data);
			obj.performVoxelSynthesis(data);
			obj.performPCA(data);
			obj.performCausalityComputation(data);
			if obj.autoShowResults
				obj.showResults(data);
			end
		end
		function performCausalityComputation(obj,data)
			nc = obj.numTopComponents;
			data.wStar = zeros(nc,nc);
			for i = 1:nc
				for j = 1:nc
					srcP = data.source.pcaSigs(:,i);
					dstP = data.dest.pcaSigs(:,j);
					data.wStar(i,j) = GrangerCausality(srcP,dstP);
				end
			end
		end
		function performFunctionalSynthesis(obj,data)
			obj.setWeights(data);
			[data.source.funcSigs, data.dest.funcSigs] = ...
				obj.makeFunctionalSigs(data.weights);
		end
		function performPCA(obj,data)
			obj.performRegionPCA(data.source);
			obj.performRegionPCA(data.dest);
		end
		function performRegionPCA(~,region)
			[region.pcaCoeff, region.pcaSigs] = pca(region.voxelSigs);
		end
		function performVoxelSynthesis(obj,data)
			Vs = obj.generateVoxelMixer;
			Vd = obj.generateVoxelMixer;
			data.source.voxelSigs = data.source.funcSigs * Vs;
			data.dest.voxelSigs = data.dest.funcSigs * Vd;
		end
		function runTest(obj)
			obj.performAll;
		end
		function setWeights(obj,data)
			if isempty(data.weights)
				data.weights = obj.generateWeights;
			end
		end
		function showParams(obj)
			fprintf('Num time steps = %d\nNum functional sigs = %d\n',...
				obj.numTimeSteps, obj.numFuncSigs);
			fprintf('Num voxel sigs = %d\nNum top components = %d\n',...
				obj.numVoxelSigs, obj.numTopComponents);
		end
		function showRatios(obj,data)
			ratios = data.source.pcaSigs(:,1:obj.numFuncSigs) ...
				./ data.source.funcSigs;
			CausalSimulator.showUpperLeftAndMeanAndVariance(ratios,...
				{'Ratios of pcaSigs to funcSigs:',...
				'Means of ratios:',...
				'Variances of ratios:'});
		end
		function showResults(obj,data)
			disp(repmat('=',1,70));
			disp(class(obj));
			obj.showParams;
			disp(repmat('-',1,70));
			maxDisplayRows = 10;
			maxDisplayCols = 3;
			fprintf(...
				'Matrices below are clipped for readability.\n\n');
			disp(['Source funcSigs vs. source pcaSigs ' ...
				'(with zero column as separator):']);
			Sf = CausalSimulator.clipmat(data.source.funcSigs,...
				maxDisplayRows,maxDisplayCols);
			Sp = CausalSimulator.clipmat(data.source.pcaSigs,...
				maxDisplayRows,maxDisplayCols);
			disp([Sf zeros(size(Sf,1),1) Sp]);
			obj.showRatios(data);
			maxWStarRowsAndCols = 7;
			disp('Granger causality scores among top components:');
			disp(CausalSimulator.clipmat(data.wStar,...
				maxWStarRowsAndCols,maxWStarRowsAndCols));
		end
	end

	methods (Static)
		function M = clipmat(M,maxrows,maxcols)
			nrows = min(size(M,1),maxrows);
			ncols = min(size(M,2),maxcols);
			M = M(1:nrows,1:ncols);
		end
		function runExampleSuite
			AltCausalSimulator1_Mean().runTest;
			AltCausalSimulator2_Ortho().runTest;
			AltCausalSimulator3_Descend.runShrink(100,50);
			AltCausalSimulator3_Descend.runUnshrink(100);
		end
		function showUpperLeftAndMeanAndVariance(M,headings)
			disp(headings{1});
			maxDisplayRows = 12;
			maxDisplayCols = 5;
			disp(CausalSimulator.clipmat(M,...
				maxDisplayRows,maxDisplayCols));
			disp(headings{2});
			disp(CausalSimulator.clipmat(mean(M),1,maxDisplayCols));
			disp(headings{3});
			disp(CausalSimulator.clipmat(var(M),1,maxDisplayCols));
		end
	end

end

