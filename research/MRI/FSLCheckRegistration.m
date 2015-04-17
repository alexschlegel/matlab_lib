function bGood = FSLCheckRegistration(cPathCheck,cPathRef,varargin)
% FSLCheckRegistration
% 
% Description:	visually check the results of registration in FSLView
% 
% Syntax:	bGood = FSLCheckRegistration(cPathCheck,cPathRef,<options>)
% 
% In:
% 	cPathCheck	- a path, cell of paths, or cell of cells of paths to registered
%				  data (last one fslview only)
%	cPathRef	- a path or cell of paths to the data cPathCheck was registered
%				  to
%	<options>:
%		method:		('slices') one of the following strings to specify the
%					method to use:
%						'slices':	use FSL's slices tool
%						'fslview':	use FSLView
%		low_check:	(<auto>) lower brightness cutoff for check data (fslview
%					only)
%		high_check:	(<auto>) upper brightness cutoff for check data (fslview 
%					only)
%		low_ref:	(<auto>) lower brightness cutoff for ref data (fslview only)
%		high_ref:	(<auto>) upper brightness cutoff for ref data (fslview only)
% 
% Out:
% 	bGood	- a logical array indicating which registrations the user marked as
%			  good
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'method'		, 'slices'	, ...
		'low_check'		, NaN		, ...
		'high_check'	, NaN		, ...
		'low_ref'		, NaN		, ...
		'high_ref'		, NaN		  ...
		);

[bSlices,bFSLView]	= deal(false);
switch lower(opt.method)
	case 'slices'
		bSlices	= true;
	case 'fslview'
		bFSLView	= true;
	otherwise
		error(['"' tostring(opt.method) '" is not a valid method for FSLCheckRegistration.']);
end

[cPathCheck,cPathRef]	= ForceCell(cPathCheck,cPathRef);
[cPathCheck,cPathRef]	= FillSingletonArrays(cPathCheck,cPathRef);

nPath	= numel(cPathCheck);

bGood	= NaN(size(cPathCheck));

progress('action','init','total',nPath,'label','Checking registration results');
for kP=1:nPath
	if bSlices
		FSLSlices(cPathCheck{kP},cPathRef{kP});
	elseif bFSLView
		cPathCheckCur	= ForceCell(cPathCheck{kP});
		nPathCheck		= numel(cPathCheckCur);
		
		cPathView	= [reshape(cPathCheckCur,[],1);cPathRef(kP)];
		vLow		= [repmat(opt.low_check,nPathCheck,1); opt.low_ref];
		vHigh		= [repmat(opt.high_check,nPathCheck,1); opt.high_ref];
		cLUT		= [repmat({'Red'},nPathCheck,1); {'Green'}];
		
		FSLView(cPathView	, ...
			'low'	, vLow	, ...
			'high'	, vHigh	, ...
			'lut'	, cLUT	, ...
			'alpha'	, 0.5	  ...
			);
	end
	
	res	= ask('Good registration?','choice',{'Yes','No','Cancel'});
	
	switch res
		case 'Yes'
			bGood(kP)	= true;
		case 'No'
			bGood(kP)	= false;
		otherwise
			error('Aborted by user.');
	end
	
	progress;
end
