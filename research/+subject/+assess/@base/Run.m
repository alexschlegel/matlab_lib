function Run(obj,varargin)
% subject.assess.base.Run
% 
% Description:	run the assessment
% 
% Syntax: Run(<options>)
% 
% In:
%	<options>:
%		min:	(25) the minimum number of steps
%		max:	(100) the maximum number of steps
%		rmse:	([]) stop if the rmse falls to at or below this level
%		r2:		([]) stop if the r^2 rises to at or above this level
%		silent:	(true) true to suppress status output
% 
% Updated:	2015-12-02
% Copyright 2015 Alex Schlegel (schlegel@gmail.com). This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the inputs
	opt	= ParseArgs(varargin,...
			'min'		, 25	, ...
			'max'		, 100	, ...
			'rmse'		, []	, ...
			'r2'		, []	, ...
			'silent'	, true	  ...
	);

bCheckRMSE	= ~isempty(opt.rmse);
bCheckR2	= ~isempty(opt.r2);

lenN	= numel(num2str(opt.max));

progress('action','init','label','running assessment','total',opt.max,'silent',opt.silent);
for kS=1:opt.max
	obj.Step;
	
	if (kS>=opt.min) && (bCheckRMSE && obj.rmse<=opt.rmse) || (bCheckR2 && obj.r2<=opt.r2)
		progress('action','end');
		break;
	end
	
	progress;
	
	if ~opt.silent
		fprintf(['it: %' num2str(lenN) 'd | result: %d | ability: %.3f | steepness: %6.3f | rmse: %.3f | r^2: %.3f\n'],kS,obj.history.record(end).result,obj.ability,obj.steepness,obj.rmse,obj.r2);
	end
end
