function [bSuccess,strPathROI] = FSLTract2ROI(strDirDTI,strNameTract,varargin)
% FSLTract2ROI
% 
% Description:	convert the output of a probtrackx call to an ROI
% 
% Syntax:	[bSuccess,strPathROI] = FSLTract2ROI(strDirDTI,strNameTract,<options>)
% 
% In:
% 	strDirDTI		- the DTI data directory path
%	strNameTract	- the name of the tract (i.e. the name of the tract folder in
%					  <strDirDTI>.probtrackX/)
%	<options>:
%		lengthcorrect:	(false) use length-corrected data to calculate the ROI
%		cutoff: 		(<see <cutoff_method>>) voxel values must pass this
%						threshold to be considered for the ROI
%		cutoff_method:	('hist') the method to use to calculate the cutoff:
%							'hist':	model the path value histogram (with bottom
%								and top 1% discarded) as a*x^b. threshold is the
%								x value of this function where the slope is
%								-abs(cutoff * max(n)/max(x)) (i.e. where a line
%								from the origin through the stretched curve would
%								split it in two) (default==1).
%							'waytotal':	threshold is cutoff*waytotal
%								(default==1/10)
%							'abs':	threshold is cutoff (default==0)
%		method:			('weight') the method to use to create the ROI.  one of
%						the following: 
%							mask: create a binary mask of voxels that passed the
%								specified ROI cutoff
%							weight: ROI values will indicate the weight to give
%								to each voxel.  values sum to 1.
%		output:			(<dir>/roi.nii.gz) the output file path
%		force:			(true) true to calculate the ROI even if the output file
%						already exists
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- true if the ROI was successfully saved
%	strPathROI	- the path to the ROI
% 
% Updated: 2015-04-13
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent ft fopt;

bSuccess	= false;

%parse the input
	opt	= ParseArgs(varargin,...
			'lengthcorrect'	, false		, ...
			'cutoff'		, []		, ...
			'cutoff_method'	, 'hist'	, ...
			'method'		, 'weight'	, ...
			'output'		, []		, ...
			'force'			, true		, ...
			'silent'		, false		  ...
			);
	if isempty(opt.cutoff)
		switch lower(opt.cutoff_method)
			case 'hist'
				opt.cutoff	= 1;
			case 'waytotal'
				opt.cutoff	= 1/10;
			case 'abs'
				opt.cutoff	= 0;
		end
	end

strPathTract	= FSLPathTract(strDirDTI,strNameTract,'lengthcorrect',opt.lengthcorrect);
strPathROI		= unless(opt.output,FSLPathTractROI(strDirDTI,strNameTract,'lengthcorrect',opt.lengthcorrect));

if ~opt.force && FileExists(strPathROI)
	bSuccess	= true;
	return;
end

if ~FileExists(strPathTract)
	status(['Probtrackx output doesn''t exist at ' strPathTract '.'],'warning',true,'silent',opt.silent);
	return;
end

%load the paths
	try
		nii			= NIfTI.Read(strPathTract);
		nii.data	= double(nii.data);
	catch me
		status(['Could not load the paths file ' strPathTract '.'],'warning',true,'silent',false);
		return;
	end
%apply the threshold
	%get the absolute threshold
		switch lower(opt.cutoff_method)
			case 'hist'
				status('using histogram-based ROI cutoff','silent',opt.silent);
				
				nHistMin	= 3;
				nFitMin		= 2;
				prcHist		= 1;
				
				d		= nii.data(nii.data~=0);
				nD		= numel(d);
				dMin	= min(d);
				dMax	= max(d);
				
				if nD>=nHistMin && dMin~=dMax
				%get the paths histogram
					%at least 100 or nD, at most 1000
					nxHist	= min(1000,max(min(100,nD),floor(nD/10)));
					dxHist	= (dMax-dMin)/nxHist;
					xHist	= GetInterval(dMin+dxHist/2,dMax-dxHist/2,nxHist);
					nHist	= hist(d,xHist);
					bHist	= nHist > prctile(nHist,prcHist) & nHist<prctile(nHist,100-prcHist);
					
					if ~any(bHist)
						bHist	= true(nxHist,1);
					end
					
					nHist	= reshape(nHist(bHist),[],1);
					xHist	= reshape(xHist(bHist),[],1);
					nH		= numel(xHist);
					
					if nH>=nFitMin
					%model as a*x^b
						if isempty(ft)
							ft 		= fittype('power1');
							fopt	= fitoptions('power1','Robust','on');
						end
						
						fo		= fit(xHist,nHist,ft,fopt);
					%get the threshold as the x value where the slope is
					%-abs(n_max/x_max)
						m		= -abs(max(nHist)./max(xHist));
						thresh	= (m/(fo.b*fo.a))^(1/(fo.b-1));
					%make sure nothing goes wrong
						if ~isreal(thresh) || isinf(thresh) || isequal(thresh,0) || isnan(thresh)
							thresh	= inf;
						end
					else
						thresh	= inf;
					end
				else
					thresh	= inf;
				end
			case 'waytotal'
				status('ROI cutoff will be a fraction of the waytotal','silent',opt.silent);
				
				%total number of paths included in the data
					nWaytotal	= FSLTractWaytotal(strDirDTI,strNameTract);
					
					if isnan(nWaytotal)
						status('waytotal file does not exist','warning',true,'silent',opt.silent);
						return;
					end
				
				thresh	= opt.cutoff*nWaytotal;
			case 'abs'
				status('using absolute ROI cutoff','silent',opt.silent);
				
				thresh	= opt.cutoff;
			otherwise
				error(['"' tostring(opt.cutoff_method) '" is not a valid cutoff method.']);
		end
	%apply the cutoff
		nii.data(nii.data<thresh)	= 0;
%create the ROI
	switch lower(opt.method)
		case 'mask'
			nii.data	= nii.data>0;
		case 'weight'
			%we need the output file to be float
				%don't think this is necessary anymore since we're using nii_tool
				%nii.orig.dat.dtype	= regexprep(nii.orig.dat.dtype,'^INT','FLOAT');
			
			s	= nansum(nii.data(:));
			if s~=0
				nii.data	= nii.data/s;
			end
		otherwise
			error(['"' tostring(opt.method) '" is not a valid ROI method.']);
	end
%save the ROI
	try
		NIfTI.Write(nii,strPathROI);
	catch me
		status(['Could not save the ROI file ' strPathROI '.'],'warning',true,'silent',false);
		return;
	end
%success!
	bSuccess	= true;
