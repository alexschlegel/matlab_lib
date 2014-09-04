function strPathAtlas = FSLPathAtlas(varargin)
% FSLPathAtlas
% 
% Description:	get the path to the an FSL atlas file
% 
% Syntax:	strPathAtlas = FSLPathAtlas([strDirFSL]=<find>,[strAtlas]='talairach_1mm')
% 
% In:
% 	[strDirFSL]	- the path to the base FSL directory
%	[strAtlas]	- one of the following to specify the atlas path to return:
%						'talairach_1mm': 1mm resolution Talairach atlas in
%							MNI space
%						'talairach_2mm': 2mm resolution Talairach atlas in
%							MNI space
% 
% Out:
% 	strPathAtlas	- the path to the NIfTI atlas file
% 
% Updated: 2011-02-06
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
switch nargin
	case 1
		strDirFSL	= [];
		strAtlas	= varargin{1};
	otherwise
		[strDirFSL,strAtlas]	= ParseArgs(varargin,[],'talairach_1mm');
end
if isempty(strDirFSL)
	strDirFSL	= GetDirFSL();
end

switch lower(strAtlas)
	case 'talairach_1mm'
		strDir		= 'Talairach';
		strFilePre	= 'Talairach-labels-1mm';
	case 'talairach_2mm'
		strDir		= 'Talairach';
		strFilePre	= 'Talairach-labels-2mm';
	otherwise
		error(['"' tostring(strAtlas) '" is an unrecognized FSL atlas.']);
end

strPathAtlas	= PathUnsplit(DirAppend(strDirFSL,'data','atlases',strDir),strFilePre,'nii.gz');
