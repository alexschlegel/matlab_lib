% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

classdef SignalSynthesizer < handle
% SignalSynthesizer
%
% Description:	class for generating possibly interdependent synthetic signals
%
% Syntax:	sy = SignalSynthesizer;
%			sy.defineRecurrence(recurrenceMatrix,newDataCoeffs);
%			signals = sy.generateSignals(numSamples);
%
%	Instances of this class can be configured to generate synthetic
%	time-varying signals whose values at any given time are linear
%	combinations of past states, with the optional inclusion of noise
%	or other new data.  The class's behavior may be customized through
%	subclassing.
%
%	(TODO:  May wish to consider making this into an abstract class,
%	and moving some of the current default methods into a subclass.)
%
%	(TODO:  Probably should transpose dimensions of generated signals.
%	In other words, each column of signal matrix should probably be a
%	time series for a given signal (currently each row is a time
%	series), and each row should hold a multivariate sample for a
%	given time point (currently each column does).)
%
%	(TODO:  In comments below, matrix variables are upper-case, but
%	vector variables are lower-case (the exception being X, which in
%	the default case is a random variable, and is capitalized for that
%	reason.  Are these the right conventions?)
%
%	(TODO:  Current tabbing convention is problematic in connection
%	with MATLAB help facility (as invoked by function key F1).
%	Evidently MATLAB editor preferences regarding tabbing do not carry
%	over to the display of the help window.)
%
% Basic use case:
%
%	Suppose you wish to generate a sequence of signal vectors s(1),
%	s(2), ..., s(n) according to a recurrence relation
%
%		s(t) = R * s(t-1) + diag(N) * X(t).
%
%	This recurrence is equivalent to the system of scalar equations
%
%		s_1(t) = R(1,1)*s_1(t-1) + ... + R(1,m)*s_m(t-1) + N(1)*X_1(t)
%		s_2(t) = R(2,1)*s_1(t-1) + ... + R(2,m)*s_m(t-1) + N(2)*X_2(t)
%		...
%		s_m(t) = R(m,1)*s_1(t-1) + ... + R(m,m)*s_m(t-1) + N(m)*X_m(t).
%
%	The variables in these equations are as follows:
%
%		m		The number of signals.
%		t		A time index taking integer values 1, 2, 3, ....
%		s_i(t)	Signal number i at time t, for i from 1 to m;
%				collectively, the s_i(t) for fixed t constitute a
%				column vector s(t).  For t <= 0, s(t) is zero.
%		R(i,j)	Elements of the recurrence-coefficients matrix R.
%		N(i)	The new-data coefficient for signal i.  Collectively,
%				the N(i) constitute a vector of length m.
%		X_i(t)	The new-data input to signal i at time t.  By default,
%				the X_i(t) are independent, normally distributed
%				pseudo-random variables with mean 0 and variance 1,
%				and by default they do not depend on t.  Collectively,
%				the X_i(t) for fixed t constitute a column vector.
%
%	If sy is an instance of SignalSynthesizer, you would set up the
%	recurrence with the invocation
%
%		sy.defineRecurrence(R,N);
%
%	To obtain a matrix S of m signals of length n each, you would call
%
%		S = sy.generateSignals(n);
%
%	Then each of the row vectors S(i,:), for 1 <= i <= m, represents
%	one of the signals s_i, while each of the column vectors S(:,t),
%	for 1 <= t <= n, represents the m-dimensional signal s at time t.
%
%	To prevent unbounded growth of the signal values, the coefficients
%	R(i,:) are required to obey the inequality
%
%		|R(i,1)| + ... + |R(i,m)| < 1.
%
%	The method defineRecurrence raises an exception if this inequality
%	does not hold.
%
%
% More general use case:
%
%	[TODO:  Change variable naming in this comment *or* in the code to
%	make the names consistent.]
%
%	The method defineRecurrenceStack allows recurrenceMatrix to be a
%	three-dimensional matrix representing a "stack" of square 2-D
%	matrices R_1, R_2, ..., R_k.  Such a stack defines a potentially
%	higher-order signal recurrence, in which the signal at time t can
%	depend directly on the values at times earlier than t - 1:
%
%		s(t) = R_1 * s(t-k+1) + R_2 * s(t-k+2) + ... +
%							R_[k-1] * s(t-1) + R_k * X(t).
%
%	In this case, there is no argument newDataCoeffs, since R_k
%	provides the coefficients for X(t).  Because R_k is a matrix
%	(whereas newDataCoeffs was just a vector), it provides for the
%	possibility of correlated random values in the new data.
%
% [TODO:]
% [Last-change date to be maintained through source-code control keywords.]
%
% Copyright (c) 2014 Trustees of Dartmouth College. All rights reserved.

	properties (SetAccess = private)
		numSignals;			% Number of interdependent signal vectors to be generated
		recurrenceStack;	% Stack of recurrence matrices
		recurrenceLength;	% Third dimension of recurrenceStack
		recurrenceOrder;	% Number of past states influencing present state
		linearRecurrenceLength; % Product of recurrenceStack's 2nd and 3rd dimensions
		combiningMatrix;	% Concatenation of recurrence matrices
	end

	methods
		function obj = SignalSynthesizer
			obj.defineRecurrenceStack(0);
		end

		function checkStability(obj,historyCoeffs) %#ok
			if any(sum(sum(abs(historyCoeffs),3),2) >= 1)
				error(['Potentially unstable recurrence; ' ...
					'keep row sums of coefficient magnitudes below 1.']);
			end
		end

		function defineRecurrence(obj,recurrenceMatrix,newDataCoeffs)
			obj.checkIsSquare(recurrenceMatrix);
			obj.checkIsVector(newDataCoeffs);
			if numel(newDataCoeffs) ~= size(recurrenceMatrix,1)
				error(['Number of new-data coefficients must match ' ...
					'matrix dimension.']);
			end
			stack = recurrenceMatrix;
			stack(:,:,end+1) = diag(newDataCoeffs);
			obj.defineRecurrenceStack(stack);
		end

		function defineRecurrenceStack(obj,stack)
			if numel(stack) == 0 || numel(size(stack)) > 3
				error('Recurrence stack must be 2-D or 3-D matrix.');
			end
			if size(stack,1) ~= size(stack,2)
				error('Recurrence matrices must be square.');
			end
			obj.checkStability(stack(:,:,1:end-1));
			obj.numSignals = size(stack,1);
			obj.recurrenceStack = stack;
			obj.recurrenceLength = size(stack,3);
			obj.recurrenceOrder = obj.recurrenceLength - 1;
			obj.linearRecurrenceLength = ...
				obj.numSignals * obj.recurrenceLength;
			obj.combiningMatrix = reshape(stack,...
				obj.numSignals,obj.linearRecurrenceLength);
		end

		function newData = generateNewData(obj,index) %#ok
			newData = obj.generateNoise;
			%newData = ones(obj.numSignals,1); % tmp for debugging
		end

		function noise = generateNoise(obj)
			noise = randn(obj.numSignals,1);
		end

		function sample = generateSample(obj,history,newData)
			if ~ismatrix(history) || size(history,1) ~= obj.numSignals
				error('History should have one row per signal.');
			end
			if nargin >= 3
				obj.checkVectorLen(newData,obj.numSignals);
				history(:,end+1) = reshape(newData,obj.numSignals,1);
			end
			shortfall = obj.recurrenceLength - size(history,2);
			if shortfall > 0
				history = cat(2,zeros(obj.numSignals,shortfall),history);
			elseif shortfall < 0
				history = history(:,1-shortfall:end);
			end
			sample = obj.combiningMatrix * ...
				reshape(history,obj.linearRecurrenceLength,1);
		end

		function signals = generateSignals(obj,numSamples)
			signals = zeros(obj.numSignals,numSamples);
			for i = 1:numSamples
				earliestIndexForHistory = max(1,i-obj.recurrenceOrder);
				history = signals(:,earliestIndexForHistory:i-1);
				signals(:,i) = obj.generateSample(history,...
					obj.generateNewData(i));
			end
		end

		function signals = plotNewSignals(obj,numSamples)
			signals = obj.generateSignals(numSamples);
			figure;
			plot(signals');
		end

	end

	methods (Static)
		%TODO:  Move these checks into a dedicated size-checking class.
		function checkIsSquare(m)
			if ~ismatrix(m) || size(m,1) ~= size(m,2)
				error('Argument must be a square matrix.');
			end
		end
		function checkIsVector(v)
			if ~isvector(v)
				error('Argument must be a vector.');
			end
		end
		function checkVectorLen(v,len)
			if SignalSynthesizer.vectorLen(v) ~= len
				error('Vector length %d should be %d.',numel(v),len);
			end
		end
		function len = vectorLen(v)
			SignalSynthesizer.checkIsVector(v);
			len = numel(v);
		end
	end

end

