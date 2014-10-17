function onset = ev2onset(ev,varargin)
% ev2onset
% 
% Description:	convert a design matrix representing conditions in a block
%				design experiment to onsets
% 
% Syntax:	onset = ev2onset(ev,<options>)
% 
% In:
% 	ev	- an nT x nCondition design matrix
%	<options>:
%		tr:	(1) the number of seconds per TR
% 
% Out:
% 	onset	- an nCondition x 1 cell of condition onset arrays
% 
% Updated: 2012-04-09
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'tr'	, 1	  ...
		);

%get the block onsets
	[nT,nCondition]	= size(ev);
	cEV				= mat2cell(ev,nT,ones(nCondition,1))';
	
	onset	= cellfun(@(x) reshape(find(diff([0; x])==1),1,[]),cEV,'UniformOutput',false);
%convert to time
	onset	= cellfun(@(x) opt.tr*(x-1),onset,'UniformOutput',false);
