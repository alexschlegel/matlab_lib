function [bSuccess,strPathOut,strSuffix] = FreeSurferLabelCrop(strPathLabel,f,varargin)
% FreeSurferLabelCrop
% 
% Description:	crop a FreeSurfer label based on a fractional bounding box
%				volume
% 
% Syntax:	[bSuccess,strPathOut,strSuffix] = FreeSurferLabelCrop(strPathLabel,f,<options>)
% 
% In:
% 	strPathLabel	- the path to the label
%	f				- a 2x3 array specifying the fractional (x,y,z) coordinates
%					  of the bounding box to crop.  e.g. if
%					  <f>==[0 0.5 0; 0.5 1 1], then half of the label will be
%					  kept in the x direction (from the lowest to the halfway
%					  point), half in the y direction (from the halfway point to
%					  the highest), and all in the z direction.
%	<options>:
%		output:	(<input>-<f>) the output file path
%		force:	(true) true to crop the label even if the output already exists
% 
% Out:
% 	bSuccess	- true if the label was successfully cropped
%	strPathOut	- the output label path
%	strSuffix	- the suffix added to the cropped label file path, if the
%				  <output> option was unspecified
% 
% Notes:	FreeSurfer surface coordinates are x=(L->R), y=(P->A), z=(I->S) (I
%			think).
% 
% Updated: 2011-02-26
% Copyright 2011 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'output'	, []	, ...
		'force'		, true	  ...
		);

cF			= num2cell(roundn(f,-2));
strF		= ['(' join(cF(1,:),',') ';' join(cF(2,:),',') ')'];

bSuccess	= false;

if isempty(opt.output)
	strSuffix	= ['-' strF];
	strPathOut	= PathAddSuffix(strPathLabel,strSuffix);
else
	strSuffix	= '';
	strPathOut	= opt.output;
end

if opt.force | ~FileExists(strPathOut)
	%read the label
		sLabel	= FreeSurferLabelRead(strPathLabel);
		
		if isempty(sLabel)
			return;
		end
	%crop the vertices
		nVertex	= numel(sLabel.k);
		
		vMin	= min(sLabel.v,[],1);
		vRange	= range(sLabel.v,1);
		
		vCropMin	= repmat(vMin + f(1,:).*vRange,[nVertex 1]);
		vCropMax	= repmat(vMin + f(2,:).*vRange,[nVertex 1]);
		
		bCrop	= all(sLabel.v >= vCropMin & sLabel.v <= vCropMax,2);
		
		sLabel.k	= sLabel.k(bCrop);
		sLabel.v	= sLabel.v(bCrop,:);
		sLabel.stat	= sLabel.stat(bCrop);
	%append the header
		sLabel.hdr	= [sLabel.hdr 'cropped ' strF ' '];
	%write the label to file
		bSuccess	= FreeSurferLabelWrite(sLabel,strPathOut);
else
	bSuccess	= true;
end
