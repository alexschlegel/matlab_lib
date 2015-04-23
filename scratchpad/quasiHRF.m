function kernel = quasiHRF(varargin)
%
% quasiHRF
%
% Description:	construct a quasi-HRF convolution kernel
%
% Syntax:	kernel = quasiHRF(<options>)
%
% In:
%	<options>:
%		length:				(15) the length of the kernel
%		lambda:				(3) the mean of the initial-response function
%		bounce_dilation:	(3) the mean of the bounce function, as a multiple of
%								lambda
%		bounce_strength:	(0.12) the strength of the bounce, as a proportion of
%								the initial response
%
% Out:
% 	kernel	- a quasi-HRF convolution kernel
%
% Copyright (c) 2015 Trustees of Dartmouth College. All rights reserved.
opt		= ParseArgs(varargin			, ...
			'length'			, 15	, ...
			'lambda'			, 3		, ...
			'bounce_dilation'	, 3		, ...
			'bounce_strength'	, 0.12	  ...
			);

k1		= 1:opt.length;
k		= k1 - 1;
%term0	= opt.lambda.^k ./ gamma(k1);
term	= poisspdf(k,opt.lambda) - opt.bounce_strength * ...
			poisspdf(k,opt.bounce_dilation*opt.lambda);
kernel	= term/sum(term);

end
