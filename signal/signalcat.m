function x = signalcat(varargin)
% signalcat
% 
% Description:	concatenate signals
% 
% Syntax:	x = signalcat(x1,...,xN,rate,<options>)
% 
% In:
% 	xK			- the Kth signal
%	rate		- the sampling frequency of the signals
%	<options>:
%		insert:	(-0.1) the insertion point of xK+1 in xK, in seconds relative to
%				the beginning of xK. if this is a negative number it is
%				treated as a point relative to the end of xK.
%		weight:	('hann') the type of weighting scheme to use to blend the
%				signals. one of the following:
%					'hann': use a hann envelope
%					'ones': just overlap each at full amplitude
%		silent:	(false) true to suppress output messages
% 
% Out:
% 	x	- the concatenated signal
% 
% Updated: 2012-11-14
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input arguments
	bChar	= cellfun(@ischar,varargin);
	
	if any(bChar)
		kOpt	= find(bChar,1);
	else
		kOpt	= nargin+1;
	end
	
	nX	= kOpt-2;
	
	if nX==0
		x	= [];
		return;
	end
	
	cX		= cellfun(@(x) reshape(x,[],1),reshape(varargin(1:nX),[],1),'UniformOutput',false);
	n		= cellfun(@numel,cX);
	
	rate	= varargin{kOpt-1};
	opt		= ParseArgs(varargin,...
				'insert'	, -0.1		, ...
				'weight'	, 'hann'	, ...
				'silent'	, false		  ...
				);
	
	opt.weight	= CheckInput(opt.weight,'weight',{'hann','ones'});
	
	switch opt.weight
		case 'hann'
			fWeight	= @WeightHann;
		case 'ones'
			fWeight	= @WeightOnes;
	end

%concatenate the signals
	nOverlap	= t2k(abs(opt.insert),rate)-1;
	[wIn,wOut]	= fWeight(nOverlap);
	
	xPre		= cellfun(@(x)		x(nOverlap+1:end-nOverlap)							,cX(1:end-1)			,'UniformOutput',false);
	xOverlap	= cellfun(@(x1,x2)	x1(end-nOverlap+1:end).*wOut + x2(1:nOverlap).*wIn	,cX(1:end-1),cX(2:end)	,'UniformOutput',false);
	
	x	= [xPre xOverlap]';
	x	= [cX{1}(1:nOverlap); cat(1,x{:}); cX{end}(nOverlap+1:end)];

%------------------------------------------------------------------------------%
function [wIn,wOut] = WeightHann(n)
	w		= hann(2*n);
	wIn		= w(1:n);
	mn		= min(wIn);
	mx		= max(wIn);
	wIn		= (wIn-mn)./(mx-mn);
	wOut	= 1 - wIn;
end
%------------------------------------------------------------------------------%
function [wIn,wOut] = WeightOnes(n)
	[wIn,wOut]	= deal(ones(n,1));
end
%------------------------------------------------------------------------------%

end
