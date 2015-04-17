function cPathOut = SaveSampleImages(strPathNII,varargin)
% NIfTI.SaveSampleImages
% 
% Description:	save some sample images from a NIfTI data set
% 
% Syntax:	cPathOut = NIfTI.SaveSampleImages(strPathNII,[strDirOut]=<same dir>,[strSession]=<find>,<options>)
% 
% In:
% 	strPathNII		- the path to a NIfTI file
%	[strDirOut]		- the directory to which to save the images
%	[strSession]	- the session code for the data
%	<options>:
%		bound:		(1/4) the bounds for determining slice location
%		output_box	([1600 1600]) resize the output to fit in a box of the
%					specified size
%		rotate:		(90) clockwise angle, in degrees, to rotate each image
%		zip:		(true) true to also zip the images
%		force:		(false) true to force saving of the images
% 
% Out:
% 	cPathOut	- a cell of output image file paths
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[strDirOut,strSession,opt]	= ParseArgs(varargin,'',[],...
	'bound'			, 1/4			, ...
	'output_box'	, [1600 1600]	, ...
	'rotate'		, 90			, ...
	'zip'			, true			, ...
	'force'			, false			  ...
	);


if isempty(strSession)
%find the session code
	cDir	= DirSplit(PathRel2Abs(strPathNII));
	nDir	= numel(cDir);
	
	re1	= '^\d\d*[A-Za-z]+\d\d\d*\w+$';
	re2	= '\w{2,3}';
	for kD=nDir:-1:1
		if ~isempty(regexp(cDir{kD},re1)) || ~isempty(regexp(cDir{kD},re2))
			strSession	= cDir{kD};
			break;
		end
	end
end
strDirOut	= unless(strDirOut,PathGetDir(strPathNII));

strSessionOrig	= strSession;
strSession		= conditional(isempty(strSession),strSession,[strSession '-']);

nPerPlane	= 3;
nFill		= numel(num2str(nPerPlane));
cPlaneName	= {'sag','cor','axi'};

%check for the output files
	cPathOut	= {};
	for kP=1:3
		for kN=1:nPerPlane
			cPathOut	= [cPathOut; PathUnsplit(strDirOut,[strSession cPlaneName{kP} '-' StringFill(kN,nFill)],'jpg')];
		end
	end
	if opt.zip
		cPathZip	= {PathUnsplit(strDirOut,[strSessionOrig '_brain_images'],'zip')};
	else
		cPathZip	= {};
	end
	
	if ~opt.force && all(FileExists([cPathOut; cPathZip]))
		return;
	end

%get the output paths
	kNum	= repmat((1:nPerPlane)',[3 1]);
	
	mOrient		= NIfTI.ImageGridOrientation(strPathNII);
	cPlaneName	= cPlaneName([find(mOrient(1,:)) find(mOrient(2,:)) find(mOrient(3,:))]);
	cPlaneName	= [repmat(cPlaneName(1),[nPerPlane 1]); repmat(cPlaneName(2),[nPerPlane 1]); repmat(cPlaneName(3),[nPerPlane 1])]; 
	
	cPathOut	= cell(3*nPerPlane,1);
	for k=1:3*nPerPlane
		cPathOut{k}	= PathUnsplit(strDirOut,[strSession cPlaneName{k} '-' StringFill(kNum(k),nFill)],'jpg');
	end
	
	if opt.zip
		strPathZip	= PathUnsplit(strDirOut,[strSessionOrig '_brain_images'],'zip');
		
		cPathCheck	= [cPathOut; {strPathZip}];
	else
		cPathCheck	= cPathOut;
	end

%load the file
	nii	= NIfTI.Read(strPathNII);
%get the images
	sData	= size(nii.data);
	fPos	= GetInterval(opt.bound,1-opt.bound,nPerPlane)';
	pos		= round(repmat(fPos,[1 3]).*repmat(sData-1,[nPerPlane 1]));
	
	im	= cell(3*nPerPlane,1);
	
	%first plane
	kPlane	= 1;
	for k=1:nPerPlane
		im{(kPlane-1)*nPerPlane + k}	= squeeze(nii.data(1+pos(k,kPlane),:,:,1));
	end
	
	%second plane
	kPlane	= 2;
	for k=1:nPerPlane
		im{(kPlane-1)*nPerPlane + k}	= squeeze(nii.data(:,1+pos(k,kPlane),:,1));
	end
	
	%third plane
	kPlane	= 3;
	for k=1:nPerPlane
		im{(kPlane-1)*nPerPlane + k}	= squeeze(nii.data(:,:,1+pos(k,kPlane),1));
	end
%save the images
	for k=1:3*nPerPlane
		sNew	= size(im{k})/max(size(im{k})).*opt.output_box;
		imCur	= normalize(imrotate(imresize(im{k},sNew,'bicubic'),opt.rotate,'bicubic'),'prctile',0.01);
		
		rgbWrite(imCur,cPathOut{k});
	end
%zip the images
	if opt.zip
		zip(strPathZip,cPathOut);
	end
