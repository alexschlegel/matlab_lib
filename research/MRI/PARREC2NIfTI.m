function [bSuccess,cPathNII] = PARREC2NIfTI(cPathPAR,varargin)
% PARREC2NIfTI
% 
% Description:	convert a PAR/REC file(s) to NIfTI format (requires MRICron's
%				dcm2nii)
% 
% Syntax:	[bSuccess,cPathNII] = PARREC2NIfTI(cPathPAR,[cPathNII]=<*.nii[.gz]>,<options>)
% 
% In:
% 	cPathPAR	- the path to a PAR file, or a cell of paths
%	<options>:
%		copyhdr:		(true) true to copy the header struct to a .mat file in
%						the output folder
%		savediffusion:	(true) true to save bvecs/bvals files for DTI data
%		b0first:		(false) true if dcm2nii moved diffusion b0 images to the
%						the front of the file (I'm confused since it used to but
%						now looks like it isn't)
%		gzip:			(true) true to save the output as .nii.gz
%		orthogonalize:	(true) true to reorient images to the nearest orthogonal
%		reorientcrop:	(true) true to reorient and crop 3D data sets
%		nthread:		(1) the number of threads to use
%		force:			(true) true to force conversion even if the output
%						already exists
%		silent:			(false) true to suppress status messages
% 
% Out:
% 	bSuccess	- a logical array specifying which files were successfully
%				  converted
% 	cPathNII	- the path to the output NIfTI file, or a cell of paths
% 
% Updated: 2013-10-19
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[cPathNII,opt]	= ParseArgsOpt(varargin,[],...
					'copyhdr'		, true	, ...
					'savediffusion'	, true	, ...
					'b0first'		, false	, ...
					'gzip'			, true	, ...
					'orthogonalize'	, true	, ...
					'reorientcrop'	, true	, ...
					'nthread'		, 1		, ...
					'force'			, true	, ...
					'silent'		, false	  ...
					);

%get the input file paths
	[cPathPAR,bCharOut]	= ForceCell(cPathPAR);
	sPAR				= size(cPathPAR);
	nPAR				= numel(cPathPAR);
%should we do anything?
	if isempty(cPathPAR)
		bSuccess	= [];
		cPathNII	= {};
		return;
	end
%get the output file paths
	strExt	= conditional(opt.gzip,'nii.gz','nii');
	
	if isempty(cPathNII)
		cPathNII	= repmat({[]},sPAR);
	else
		cPathNII	= ForceCell(cPathNII);
	end
	cPathNII	= cellfun(@(x,y) conditional(isempty(x),PathAddSuffix(y,'',strExt),x),cPathNII,cPathPAR,'UniformOutput',false);
%which files should we convert?
	if opt.force
		bConvert	= true(sPAR);
	else
		bConvert	= ~FileExists(cPathNII);
	end
%convert!
	bSuccess			= ~bConvert;
	bSuccess(bConvert)	= MultiTask(@ConvertOne,{cPathPAR,cPathNII},...
							'description'	, 'Converting PAR/REC to NIfTI'	, ...
							'nthread'		, opt.nthread					, ...
							'uniformoutput'	, true							, ...
							'silent'		, opt.silent					  ...
							);

%------------------------------------------------------------------------------%
function b = ConvertOne(strPathPAR,strPathNII)
	b	= false;
	
	%make the temporary output directory
		strDirTemp	= GetTempDir;
	%prepare the script
		%note dcm2nii can't handle gzipping and reorient/cropping, so gzip later
		strOrthogonalize	= conditional(opt.orthogonalize,'y','n');
		strReorientCrop		= conditional(opt.reorientcrop,'y','n');
		strScriptBase		= ['dcm2nii -d n -e n -f y -g n -i n -n y -p n -r ' strOrthogonalize ' -v n -x ' strReorientCrop];
		
		strScript	= [strScriptBase ' -o ' strDirTemp ' ' strPathPAR];
		strPathTemp	= PathUnsplit(strDirTemp,PathGetFilePre(strPathPAR),'nii');
	%run the script
		[ec,strOut]	= RunBashScript(strScript,'silent',true);
		
		if ec
			return;
		end
	%get the temporary output file name
		if opt.reorientcrop
			strPathCO	= PathAddPrefix(strPathTemp,'co');
			if FileExists(strPathCO)
				strPathTemp	= strPathCO;
			end
		end
		
		if ~FileExists(strPathTemp)
			return;
		end
	%gzip if specified
		if opt.gzip
			strPathGZIP	= gzip(strPathTemp);
			strPathTemp	= PathAddSuffix(strPathTemp,'','nii.gz');
			
			if ~FileExists(strPathTemp)
				return;
			end
		end
	%move the output
		if ~movefile(strPathTemp,strPathNII)
			return;
		end
	%delete the temporary directory
		rmdir(strDirTemp,'s');
	%read the header file
		hdr		= PARRECReadHeader(strPathPAR);
		strType	= PARRECScanType(hdr);
	%save the header .mat file
		if opt.copyhdr
			strPathMAT	= PathAddSuffix(strPathNII,'','mat','favor','nii.gz');
			save(strPathMAT,'-struct','hdr');
		end
	%save diffusion parameters
		if opt.savediffusion && isequal(strType,'diffusion')
			%save bvecs/bvals
				[bvecs,bvals]	= PARRECGetDiffusion(strPathPAR,strPathNII,'b0first',opt.b0first);
		end
	%the scanner has been randomly saving functional scans with a weird slice
	%order (all slice 1, then all slice 2, etc.). fix this.
		if isequal(strType,'functional')
			nSlice	= hdr.general.max_number_of_slices;
			nVol	= hdr.general.max_number_of_dynamics;
			
			if all(reshape(repmat(1:nSlice,[nVol 1]),[],1)==hdr.imageinfo.slice_number)
			%wtf?
				%load the NIfTI file
					nii	= NIfTIRead(strPathNII);
					s	= size(nii.data);
					nd	= numel(s);
				%find the slice dimension
					dimSlice	= find(s==nSlice);
					if numel(dimSlice)~=1
						warning('Weird fMRI data set, cannot fix slice order bug!');
						return;
					end
				%reorder the slices
					nii.data	= permute(nii.data,[1:dimSlice-1 dimSlice+1:nd-1 dimSlice nd]);
					sTemp		= size(nii.data);
					nii.data	= reshape(nii.data,[sTemp(1:end-2) nVol nSlice]);
					nii.data	= permute(nii.data,[1:dimSlice-1 nd dimSlice:nd-2 nd-1]);
				%save the NIfTI file
					NIfTIWrite(nii,strPathNII);
			end
		end
	
	%success!
		b	= true;
end
%------------------------------------------------------------------------------%

end
