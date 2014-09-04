function s = NIfTIDimensions(strPathNII)
% NIfTIDimensions
% 
% Description:	get the dimensions of a NIfTI data set.  requires FSL
% 
% Syntax:	s = NIfTIDimensions(strPathNII)
% 
% Updated: 2011-11-01
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
s	= [];

if ~FileExists(strPathNII)
	return;
end

try
	[ec,strOutput]	= RunBashScript(['fslinfo ' strPathNII],'silent',true);
	cLine			= split(strOutput,'[\r\n]+');
	cBreak			= cellfun(@(s) split(s,'\s+'),cLine,'UniformOutput',false);
	nBreak			= numel(cBreak);
	
	for k=1:nBreak
		ifo.(cBreak{k}{1})	= cBreak{k}{2};
	end
	
	s	= [];
	
	kDim=1;
	while isfield(ifo,['dim' num2str(kDim)])
		s	= [s str2num(ifo.(['dim' num2str(kDim)]))];
		
		kDim	= kDim+1;
	end
catch me
	return;
end