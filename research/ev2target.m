function cTarget = ev2target(ev,cCondition,varargin)
% ev2target
% 
% Description:	generate a target cell array, given a set of EVs
% 
% Syntax:	cTarget = ev2target(ev,cCondition,<options>)
% 
% In:
% 	ev			- an nTimepoint x nCondition design matrix of 1s and 0s
%	cCondition	- a cell of condition names
%	<options>:
%		hrf:	(0) the HRF delay to incorporate into the target array
% 
% Out:
%	cTarget	- an nTimepoint x 1 cell of the target name at each TR. blanks are
%			  labeled 'Blank'.
% 
% Updated: 2013-10-20
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'hrf'	, 0	  ...
		);

[nTimepoint,nCondition]	= size(ev);

ev	= sum(ev.*repmat(1:nCondition,[nTimepoint 1]),2)+1;

%HRF delay
	ev	= [ones(opt.hrf,1); ev(1:end-opt.hrf)];

%construct the target array
	cCondition	= ['Blank'; reshape(ForceCell(cCondition),[],1)];
	cTarget		= cCondition(ev);
