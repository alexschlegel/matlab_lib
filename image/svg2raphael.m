function raph = svg2raphael(strPathSVG)
% svg2raphael
% 
% Description:	use rappar convert an SVG shape to a Raphael path
% 
% Syntax:	raph = svg2raphael(strPathSVG)
% 
% In:
% 	strPathSVG	- the path to the SVG file
% 
% Out:
% 	raph	- the resulting Raphael path info
% 
% Updated: 2014-10-17
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent strPathRappar

if isempty(strPathRappar)
	strPathM		= mfilename('fullpath');
	strDirRappar	= DirAppend(PathGetDir(strPathM),'rappar');
	strPathRappar	= PathUnsplit(strDirRappar,'rappar','js');
end

[ec,cOut]	= CallProcess('node',{strPathRappar,strPathSVG},'silent',true);

raph = json.from(cOut{1});
