function bSuccess = FSLSlices(strPath1,strPath2,varargin)
% FSLSlices
% 
% Description:	call FSL's slices tool
% 
% Syntax:	bSuccess = FSLSlices(strPath1,strPath2,<options>)
% 
% In:
% 	strPath1	- the first data set to display (as an intensity image)
%	strPath2	- the second data set to display (as red edges)
%	<options>:
%		pause:	(true) true to pause with a prompt before continuing
%		scale:	(1) the image scale
%		min:	(<auto>) the intmin slices option.  must be specified with <max>
%		max:	(<auto>) the intmax slices option.  must by specified with <min>
% 
% Out:
% 	bSuccess		- true if slices exited without error
% 
% Note:	slices doesn't wait for the window to be closed to return
% 
% Updated: 2011-02-16
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'prompt'	, true	, ...
		'scale'		, 1		, ...
		'min'		, []	, ...
		'max'		, []	  ...
		);

strScale	= conditional(~isempty(opt.scale),[' -s ' num2str(opt.scale)],'');
strMinMax	= conditional(~isempty(opt.min),[' -i ' num2str(opt.min) ' ' num2str(opt.max)],'');

bSuccess	= ~RunBashScript(['slices ' strPath1 ' ' strPath2 strScale strMinMax],'silent',true);

if opt.prompt
	ask('Press Enter to continue...','dialog',false);
end
