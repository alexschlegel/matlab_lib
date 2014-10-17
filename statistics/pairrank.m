function x = pairrank(xWin,xLose,varargin)
% pairrank
% 
% Description:	use Elo's rating system to rank a set of items based on
%				pair-wise comparisons
% 
% Syntax:	x = pairrank(xWin,xLose,<options>)
% 
% In:
% 	xWin	- an array specifying the item that won in each comparison
%	xLose	- an array specifying the item that lost in each comparison
%	<options>:
%		k:	(32) the K-factor to use for updating rankings
% 
% Out:
% 	x	- the ranked items, from best to worst
% 
% Updated: 2012-02-28
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'k'	, 32	  ...
		);

xWin	= reshape(xWin,[],1);
xLose	= reshape(xLose,[],1);

%get the items to rank
	x	= unique([xWin; xLose]);
	nX	= numel(x);
%get the index of each pair item in the set
	[b,kWin]	= ismember(xWin,x);
	[b,kLose]	= ismember(xLose,x);
%everybody gets 1500 as an initial rating
	r	= 1500*ones(nX,1);

%update the ratings based on the tests
	nTest		= numel(xWin);
	for kT=1:nTest
		%expected score
			qWin	= 10^(r(kWin(kT))/400);
			qLose	= 10^(r(kLose(kT))/400);
			eWin	= qWin/(qWin+qLose);
			eLose	= qLose/(qWin+qLose);
		%update the rankings
			r(kWin(kT))		= r(kWin(kT))  + opt.k*(1 - eWin);
			r(kLose(kT))	= r(kLose(kT)) + opt.k*(0 - eLose);
	end
%rank each item
	[r,k]	= sort(r,1,'descend');
	x		= x(k);
