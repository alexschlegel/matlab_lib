function x = ChangeFromBaseline(x,varargin)
% ChangeFromBaseline
% 
% Description:	calculate the change of a signal from baseline
% 
% Syntax:	x = ChangeFromBaseline(x,<options>)
% 
% In:
% 	x	- a single signal or an nSignal x nSample array of signals
%	<options>:
%		type:		('percent') one of the following:
%						'percent':	percent change from baseline mean
%						'diff':		difference from baseline mean
%						'detrend':	detrend each signal based on a best-fit line
%									through the baseline
%		t:			(0->end based on rate) the time corresponding to each point
%					in the data
%		start:		(0) the time at which to begin baseline calculation 
%		end:		(0) the time at which to end baseline calculation
%		rate:		(1) the rate of data acquisition
% 
% Out:
% 	x	- the data as change from the baseline period
% 
% Updated: 2010-07-28
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'type'		, 'percent'	, ...
		't'			, []		, ...
		'start'		, 0			, ...
		'end'		, 0			, ...
		'rate'		, 1			 ...
		);

%reshape the data
	bColumn	= size(x,2)==1;
	if bColumn
		x	= reshape(x,1,[]);
	end


[nSignal,nSample]	= size(x);

%get t
	if isempty(opt.t)
		opt.t	= k2t(1:nSample,opt.rate);
	end

%points in the baseline
	bBaseline	= opt.t>=opt.start & opt.t<=opt.end;
%calculate the change from baseline
	switch lower(opt.type)
		case 'percent'
			m		= nanmean(x(:,bBaseline),2);
			bZero	= m==0;
			m		= repmat(m,[1 nSample]);
			bZero	= repmat(bZero,[1 nSample]);
			
			x(bZero)	= NaN;
			x(~bZero)	= (x(~bZero)-m(~bZero))./m(~bZero);
		case 'diff'
			m	= repmat(nanmean(x(:,bBaseline),2),[1 nSample]);
			
			x	= x - m;
		case 'detrend'
			tBaseline	= opt.t(bBaseline);
			xBaseline	= x(:,bBaseline);
			
			[m,b]	= polyfit2(tBaseline,xBaseline,1);
			m		= repmat(m,[1 nSample]);
			b		= repmat(b,[1 nSample]);
			
			t	= repmat(opt.t,[nSignal 1]);
			x	= x - (m.*t + b);
		otherwise
			error(['"' opt.type '" is an unrecognized change type.']);
	end
%unreshape
	if bColumn
		x	= reshape(x,[],1);
	end
