function bvFMRFlip(fmr,varargin)
% bvFMRFlip
% 
% Description:	flip an FMR along an axis
% 
% Syntax:	bvFMRFlip(fmr,<options>)
% 
% In:
% 	fmr	- and FMR object loaded with BVQXfile
%	<options>:
%		'axs':	('x') either 'x' or 'y' specifying the axis along which to flip
% 
% Updated:	2009-06-10
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin, ...
					'axis'	, 'x'	  ...
					);

switch lower(opt.axis)
	case 'x'
		bFlipX	= true;
	case 'y'
		bFlipX	= false;
	otherwise
		error(['"' opt.axis '" is not a valid axis.']);
end
					
%flip each slice
	s	= zeros(size(fmr.Slice(1).STCData));
	
	nSlice	= numel(fmr.Slice);
	for k=1:nSlice
		s(:)	= fmr.Slice(k).STCData;
		
		if bFlipX
			fmr.Slice(k).STCData	= s(end:-1:1,:,:);
		else
			fmr.Slice(k).STCData	= s(:,end:-1:1,:);
		end
	end
