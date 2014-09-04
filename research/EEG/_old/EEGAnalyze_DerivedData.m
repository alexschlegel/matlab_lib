function dat = EEGAnalyze_DerivedData(dat,sSession,cDerivedData,varargin)
% EEGAnalyze_DerivedData
% 
% Description:	compute derived data for a data set
% 
% Syntax:	dat = EEGAnalyze_DerivedData(dat,sSession,cDerivedData,<options>)
% 
% In:
% 	dat				- the data struct
%	sSession		- the session struct
%	cDerivedData	- an Nx3 cell specifying extra calculations to include in
%					  the dat struct.  the first column is the name of the field
%					  to create. the second column is the function to use,
%					  either a function handle or a string that evaluates to a
%					  function handle.  if this function will be called via a
%					  MATLAB parallel processing job then use the string form,
%					  since function handles apparently don't carry over to the
%					  labs that process the function.  the third column is a
%					  cell of field names from sSession.trial, specifying the
%					  inputs to the function.  For example, if the reaction time
%					  should be included, the row might look like:
%						'tReaction' @(x,y) y-x {'tPrompt','tKey'}
%	
%	<options>:
%		silent:	(false) true to suppress status messages
% 
% Out:
% 	dat	- the update data struct
% 
% Updated: 2010-11-15
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'silent'	, false	  ...
		);

nDerived	= size(cDerivedData,1);
	
if nDerived>0
	status('calculating derived data','silent',opt.silent);
end

nTrial	= numel(sSession.trial.bError);

for kD=1:nDerived
	strField	= cDerivedData{kD,1};
	
	f			= cDerivedData{kD,2};
	if ischar(f)
		f	= str2func(f);
	end
	
	cInput		= cellfun(@(x) sSession.trial.(x),ForceCell(cDerivedData{kD,3}),'UniformOutput',false);
	
	dat.(strField)	= f(cInput{:});
	
	%calculate for the classification tree if this is a vector of values for
	%each trial
		if numel(dat.(strField))==nTrial
			dat.(strField)	= structtreefun(@(b) dat.(strField)(b), dat.b.Tree);
		end
end
