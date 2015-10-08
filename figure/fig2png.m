function varargout = fig2png(h,varargin)
% fig2png
% 
% Description:	save a figure as a png image file
% 
% Syntax:	im = fig2png(h,[strPathOut]=<none>,<options>)
% 
% In:
% 	h				- the handle to the figure
%	[strPathOut]	- the output file path
%	<options>:
%		method:		('plot2svg') the method to use.  one of the following:
%						plot2svg:	use the plot2svg function and svg2png script
%						print:	use MATLAB's builtin print function
%						saveas:	use MATLAB's builtin saveas function
%		dpi:		(300) the image resolution, in dots per inch
%		close:		(true) true to close the figure
%		movesvg:	(true) true to move the intermediate svg files to the 'svg'
%					subdirectory
%		silent:		(true) true to suppress output messages
%
% Out:
%	im	- the figure as an image array
% 
% Updated: 2014-07-28
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strPathOut,opt]	= ParseArgs(varargin,[],...
						'method'	, 'plot2svg'	, ...
						'dpi'		, 300			, ...
						'close'		, true			, ...
						'movesvg'	, true			, ...
						'silent'	, true			  ...
						);

opt.method	= CheckInput(opt.method,'method',{'plot2svg','print','saveas'});

bSave	= ~isempty(strPathOut);
if ~bSave
	strPathOut	= GetTempFile('ext','png');
end

switch opt.method
	case 'plot2svg'
		strPathSVG	= PathAddSuffix(strPathOut,'','svg');
		
		%get the files not to move
			if opt.movesvg
				[strDirOut,strFileOut]	= PathSplit(strPathOut);
				
				cPathNoMove	= setdiff(FindFiles(strDirOut,['^' strFileOut '.*']),strPathSVG);
			end
		%save the svg file
			if opt.silent
				evalc('plot2svg(strPathSVG,h);');
			else
				plot2svg(strPathSVG,h);
			end
		%convert to PNG
			[ec,cOut]	= CallProcess('svg2png',{'-d',opt.dpi,strPathSVG},'silent',opt.silent);
			assert(~ec,'an error occurred when calling svg2png (%s)',StringTrim(cOut{1}));
		%move the intermediate SVG files
			if opt.movesvg
				cPathMove	= setdiff(FindFiles(strDirOut,['^' strFileOut '.*']),[cPathNoMove; {strPathOut}]);
				
				strDirSVGOut	= DirAppend(strDirOut,'svg');
				CreateDirPath(strDirSVGOut);
				
				cPathMoveOut	= cellfun(@(f) PathChangeBase(f,strDirOut,strDirSVGOut),cPathMove,'UniformOutput',false);
				
				cellfun(@movefile,cPathMove,cPathMoveOut);
			end
	case 'print'
		print(h,'-dpng',['-r' num2str(opt.dpi)],strPathOut);
	case 'saveas'
		saveas(h,strPathOut,'png');
end

%close the figure
	if opt.close
		close(h);
	end
%load the image?
	if nargout>0
		varargout{1}	= rgbRead(strPathOut);
	end
%keep the file?
	if ~bSave
		delete(strPathOut);
	end