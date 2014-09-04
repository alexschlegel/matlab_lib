function EEGChannel2IndexDisplay(varargin)
% EEGChannel2IndexDisplay
% 
% Description:	display a channel to index mapping (see EEGChannel2Index)
% 
% Syntax:	EEGChannel2IndexDisplay([cChannel]='all',[hdr]=<default>)
% 
% Updated: 2010-07-22
% Copyright 2010 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.

%get the mapping
	[k,c]	= EEGChannel2Index(varargin{:});
%sort it
	k	= cellfun(@StringFill,num2cell(k),'UniformOutput',false);
	n	= numel(k);
%format the mapping for display
	c		= cellfun(@(x,y) [x ': ' num2str(y) '   '],k,c,'UniformOutput',false);
%reshape
	nCol			= 3;
	nRow			= ceil(n/3);
	[c{end+1:nRow*nCol}]	= deal('');
	c	= reshape(c,[],3);
%combine into an array
	nMax	= max(cellfun(@numel,c),[],1);
	s		= '';
	for kC=1:nCol
		s	= [s StringFill(c(:,kC),nMax(kC),' ','right')];
	end
%display it
	status('EEG Indices to Channel Names:');
	disp(s);