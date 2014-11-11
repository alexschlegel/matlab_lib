function [bSuccess,strScript] = FSLView(cPath,varargin)
% FSLView
% 
% Description:	call fslview
% 
% Syntax:	[bSuccess,strScript] = FSLView(cPath,<options>)
% 
% In:
% 	cPath	- a path or cell of paths to data to view
%	<options>:
%		run:	(true) true to actually run fslview
%		low:	(<auto>) the lower brightness bound(s). use NaNs to auto-select.
%		high:	(<auto>) the upper brightness bound(s). use NaNs to auto-select.
%		lut:	('Greyscale') the look up table (see fslview -h)
%		alpha:	(1) the display transparency (0->1)
% 
% Out:
% 	bSuccess	- true if FSLView exited without error
%	strScript	- the script used to call FSLView
% 
% Updated: 2011-02-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'run'	, true			, ...
		'low'	, NaN			, ...
		'high'	, NaN			, ...
		'lut'	, 'Greyscale'	, ...
		'alpha'	, 1				  ...
		);

%parse arguments
	[cPath,opt.lut]								= ForceCell(cPath,opt.lut);
	[cPath,opt.low,opt.high,opt.lut,opt.alpha]	= FillSingletonArrays(cPath,opt.low,opt.high,opt.lut,opt.alpha);
	nPath										= numel(cPath);
%construct the script
	strScript	= 'fslview';
	
	for kP=1:nPath
		%brightness range
			bLow	= ~isnan(opt.low(kP));
			bHigh	= ~isnan(opt.high(kP));
			
			if bLow | bHigh
				strLow	= conditional(bLow,num2str(opt.low(kP)),'0');
				strHigh	= conditional(bHigh,num2str(opt.high(kP)),'0');
				
				strOpt	= [' -b ' strLow ',' strHigh];
			else
				strOpt	= '';
			end
		%LUT
			strOpt	= [strOpt ' -l "' opt.lut{kP} '"'];
		%transparency
			strOpt	= [strOpt ' -t ' num2str(opt.alpha(kP))];
		
		
		strScript	= [strScript ' ' cPath{kP} strOpt];
	end
%call the script
	if opt.run
		bSuccess	= ~RunBashScript(strScript,'silent',true);
	else
		bSuccess	= true;
	end
