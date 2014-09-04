function savefigure(h,strPathOut,varargin)
% savefigure
% 
% Description:	save figure or alexplot to file
% 
% Syntax:	saveplot(h,strPathOut,[bClose]=false,<options>)
% 
% In:
% 	h			- the figure handle or struct returned by alexplot
%	strPathOut	- the path to which to save the file
%	[bClose]	- true to close the figure after saving
%	<options>:
%		format:	(<auto>) the format of the file to save
%		width:	(<auto>) the width, in inches, of the output
%		dpi:	(300) the resolution of the save image, in dots per inch (if
%				applicable)
% 
% Updated:	2011-03-14
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
[bClose,opt]	= ParseArgsOpt(varargin,false,...
					'width'		, []	, ...
					'format'	, []	, ...
					'dpi'		, 300	  ...
					);
if isempty(opt.format)
	switch lower(PathGetExt(strPathOut))
		case 'bmp'
			opt.format	= 'bmp';
		case 'eps'
			opt.format	= 'epsc2';
		case 'jpg'
			opt.format	= 'jpeg95';
		otherwise
	end
end

%get the figure handle
	if isstruct(h)
		h	= h.hF;
	end
%resize the paper if specified
	if ~isempty(opt.width)
		set(h,'PaperUnits','inches');
		
		pf		= get(h,'Position');
		hNew	= opt.width * (pf(4)/pf(3));
		
		pp		= get(h,'PaperPosition');
		ppNew	= [pp(1:2) opt.width hNew];
		
		set(h,'PaperPosition',ppNew);
	end
%check to see if we should use saveas or print
	if isempty(opt.format)
		saveas(h,strPathOut);
	elseif ismember(exist(['saveas' opt.format]),[2 3 5 6])
		saveas(h,strPathOut,opt.format);
	else
		print(h,strPathOut,['-d' opt.format],['-r' num2str(opt.dpi)]);
	end
%close the figure?
	if bClose
		close(h)
	end
