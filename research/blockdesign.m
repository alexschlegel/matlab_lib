function m = blockdesign(c,nRep,nRun,varargin)
% blockdesign
% 
% Description:	generate a condition order for nRun runs of an experiment with
%				conditions in c with each condition shown nRep times each run.
%				Note: this will not complain if bad design parameters are
%				entered (e.g. more runs than can be handled by a balanced Latin
%				square)
% 
% Syntax:	m = blockdesign(c,nRep,nRun,<options>)
% 
% In:
% 	c			- an array of conditions
%	nRep		- the number of time conditions are shown per run
%	nRun		- the number of runs
%	<options>:
%		seed:	(randseed2) the seed to use for randomizing
% 
% Out:
% 	m	- an nRun x nBlock matrix of the conditions to show in each block
% 
% Updated: 2015-01-22
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

opt	= ParseArgs(varargin,...
		'seed'	, randseed2	  ...
		);
%obtain two block seeds for two calls to randomize
	rng(opt.seed,'twister');
	blockseeds = randi(intmax('uint32'),1,2);
%form the blocks
	block	= repmat(reshape(c,1,[]),[1 nRep]);
%randomize them
	block	= randomize(block,'seed',blockseeds(1));
	nBlock	= numel(block);

%get a balanced latin square for the blocks
	m	= bls(nBlock);
	
	if isodd(nBlock)
		m	= [m; m(:,end:-1:1)];
	end
%add rows until we have the desired number of runs
	nRow	= size(m,1);
	
	while nRow<nRun
		mRow	= randperm(nBlock);
		
		if ~ismember(mRow,m,'rows')
			m	= [m; mRow];
		end
		
		nRow	= size(m,1);
	end
%map to the conditions
	m	= block(m);
%randomize across rows
	m	= randomize(m,1,'rows','seed',blockseeds(2));
%keep the runs requested
	m	= m(1:nRun,:);
