function [bDone,cName1,cName2,cNameLabel,varargout] = FSLROITractFSInfo(cDirDTI,cNameLabel,varargin)
% FSLROITractFSInfo
% 
% Description:	return info about a set of subjects and tracts processed with
%				FSLROITractFS
% 
% Syntax:	[bDone,cName1,cName2,cNameLabel,[,d1,...,dN]] = FSLROITractFSInfo(cDirDTI,cNameLabel[,ifo1,...,ifoN],<options>)
% 
% In:
%	cDirDTI		- the DTI directories passed to FSLROITractFS
%	cNameLabel	- a cell of label names used in FSLROITractFS (without 'lh','rh')
%	[ifoK]		- a string specifying the info to return.  one of the following:
%					roi:			paths to ROI files (calculates if necessary or
%									forced)
%					fdt_paths:		paths to fdt_paths files
%					waytotal:		waytotal sums
%					tl:				tract lengths, calculated as the weighted mean
%									of expected tract lengths at each voxel in the
%									tract ROI
%					connectivity:	a 2-element cell of the fConnect and fOverlap
%									outputs from FSLTractConnectivity
%					fa:				FA, calculated as the weighted mean of FA
%									values at each voxel in the tract ROI.  if the
%									passed directory is a combined directory,
%									entries will be an Nx1 array of FA values, one
%									for each data set that was combined.  note
%									that these data must have been transformed to
%									"combined" space and must be called
%									dti_FA-tocombined.nii.gz.
%					md:				same as fa for md values
%					ad:				same as fa for ad values
%					rd:				same as fa for rd values
%					faz:			same as fa for faz values
%					mdz:			same as fa for mdz values
%					adz:			same as fa for adz values
%					rdz:			same as fa for rdz values
%	<options>:
%		hemisphere:			('both') 'lh', 'rh', or 'both' to specify
%							hemisphere(s) for which tracts are saved
%		bilateral:			(true) true if tracts were created for
%							interhemispheric connections
%		nsample:			(5000) the --nsamples option passed to probtrackx
%		lengthcorrect:		(false) true to use length-corrected paths/ROIs
%		roicutoff:			(<FSLTract2ROI default>) the FSLTract2ROI cutoff
%		roicutoffmethod:	(<FSLTract2ROI default>) the FSLTract2ROI cutoff
%							method
%		roimethod:			(<FSLTract2ROI default>) the FSLTract2ROI roi
%							creation method
%		force:				(true) true to force recalculation of values even if 
%							previously saved versions exist
%		forceprep:			(false) true to force recalculation of values that
%							the specified outputs depend on
%		silent:				(false) true to suppress status messages
% 
% Out:
% 	bDone		- an nTract x nSubject logical array indicating which tracts are
%				  finished.  all files required for the specified outputs must
%				  exist for each element to be true.
%	cName1		- an nTract x 1 cell of names of the first label in each tract
%	cName2		- an nTract x 1 cell of names of the second label in each tract,
%				  or [] if the tract is from a single mask
%	cNameLabel	- the processed label names
%	[dK]		- an nTract x nSubject array/cell based on ifoK
% 
% Note:	assumes the tract ordering is the same for each subject (e.g.
%		blah1-to-blah2 for all instead of blah2-to-blah1 for some)
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%parse the input
	%find the info/option break point
		cInfoValid	= {'roi','fdt_paths','waytotal','tl','connectivity','fa','md','ad','rd','faz','mdz','adz','rdz'};
		
		kFirstNonChar	= find(~cellfun(@ischar,varargin),1,'first');
		kLastChar		= unless(kFirstNonChar,numel(varargin)+1)-1;
		kLastInfo		= conditional(kLastChar==0,0,find(cellfun(@(s) ismember(lower(s),cInfoValid),varargin(1:kLastChar)),1,'last'));
		kLastInfo		= unless(kLastInfo,0);
	%info specification
		cInfo		= cellfun(@lower,varargin(1:kLastInfo),'UniformOutput',false);
		nInfo		= numel(cInfo);
		varargout	= cell(nargout-3,1);
	%options
		opt	= ParseArgs(varargin(kLastInfo+1:end),...
				'hemisphere'		, 'both'	, ...
				'bilateral'			, true		, ...
				'nsample'			, 5000		, ...
				'lengthcorrect'		, false		, ...
				'roicutoff'			, []		, ...
				'roicutoffmethod'	, []		, ...
				'roimethod'			, []		, ...
				'force'				, true		, ...
				'forceprep'			, false		, ...
				'silent'			, false		  ...
				);

cHemi	= reshape(ForceCell(conditional(isequal(lower(opt.hemisphere),'both'),{'lh';'rh'},opt.hemisphere)),[],1);
nHemi	= numel(cHemi);

cDirDTI		= reshape(ForceCell(cDirDTI),[],1);
nSubject	= numel(cDirDTI);

cNameLabel	= reshape(ForceCell(cNameLabel),[],1);
cNameLabel	= cellfun(@(h) cellfun(@(n) [h '.' n],cNameLabel,'UniformOutput',false),cHemi,'UniformOutput',false);

%get the tract info
	status('getting tract info','silent',opt.silent);
	
	%get the tract pairings
		if opt.bilateral
			%combine hemispheres
				cNameLabelC	= append(cNameLabel{:});
			%get the pairings
				cName	= handshakes(cNameLabelC);
				cName1	= cName(:,1);
				cName2	= cName(:,2);
		else
			%get the pairings for each hemisphere
				cName	= cellfun(@handshakes,cNameLabel,'UniformOutput',false);
			%combine hemispheres
				cName1			= cellfun(@(c) c(:,1),cName,'UniformOutput',false);
				cName2			= cellfun(@(c) c(:,2),cName,'UniformOutput',false);
				[cName1,cName2]	= varfun(@(c) append(c{:}),cName1,cName2);
		end
	%get the name of each tract
		cNameTract		= cellfun(@(n1,n2) [n1 '-to-' n2],cName1,cName2,'UniformOutput',false);
		cNameTractAlt	= cellfun(@(n1,n2) [n2 '-to-' n1],cName1,cName2,'UniformOutput',false);
	%get the tracts in the correct order
		if nSubject>0
			bExist				= cellfun(@(n) isdir(FSLDirTract(cDirDTI{1},n)),cNameTract);
			
			cTemp				= cName1;
			cName1(~bExist)		= cName2(~bExist);
			cName2(~bExist)		= cTemp(~bExist);
			cNameTract(~bExist)	= cNameTractAlt(~bExist);
		else
			bDone	= false(nTract,0);
			return;
		end
	%add the single mask tracts
		cNameLabel	= append(cNameLabel{:});
		nLabel		= numel(cNameLabel);
		
		cNameTract	= [cNameTract; cNameLabel];
		cName1		= [cName1; cNameLabel];
		cName2		= [cName2; cell(nLabel,1)];
		
		nTract		= numel(cNameTract);
	%replicate arrays
		cDirDTI		= repmat(reshape(cDirDTI,1,[]),[nTract 1]);
		cNameTract	= repmat(cNameTract,[1 nSubject]);
		sOut		= [nTract nSubject];

%get each info
	if nInfo==0
	%check for tracts
		bDone	= cellfunprogress(@(d,n) isdir(FSLDirTract(d,n)),cDirDTI,cNameTract,'label','Checking for tract directories','silent',opt.silent);
	else
		bDone	= true(sOut);
	end
	
	progress('action','init','total',nInfo,'label','Calculating requested info','silent',opt.silent);
	for kI=1:nInfo
		switch cInfo{kI}
			case 'roi'
				[bSuccess,cPathROI]	= cellfunprogress(@(d,n) FSLTract2ROI(d,n,...
										'lengthcorrect'	, opt.lengthcorrect		, ...
										'cutoff'		, opt.roicutoff			, ...
										'cutoff_method'	, opt.roicutoffmethod	, ...
										'method'		, opt.roimethod			, ...
										'force'			, opt.force				, ...
										'silent'		, opt.silent			  ...
										),cDirDTI(bDone),cNameTract(bDone),'UniformOutput',false,'label','calculating ROIs','silent',opt.silent);
				
				varargout{kI}			= cell(sOut);
				varargout{kI}(bDone)	= cPathROI;
				bDone(bDone)			= cell2mat(bSuccess);
			case 'fdt_paths'
				varargout{kI}			= cell(sOut);
				varargout{kI}(bDone)	= cellfunprogress(@(d,n) FSLPathTract(d,n,'lengthcorrect',opt.lengthcorrect),cDirDTI(bDone),cNameTract(bDone),'UniformOutput',false,'label','Constructing tract paths','silent',opt.silent);
				bDone(bDone)			= FileExists(varargout{kI}(bDone));
			case 'waytotal'
				varargout{kI}			= NaN(sOut);
				varargout{kI}(bDone)	= FSLTractWaytotal(cDirDTI(bDone),cNameTract(bDone),'silent',opt.silent);
				bDone(bDone)			= ~isnan(varargout{kI}(bDone)); 
			case 'tl'
				varargout{kI}			= NaN(sOut);
				varargout{kI}(bDone)	= FSLTractLength(cDirDTI(bDone),cNameTract(bDone),'force',opt.force,'forceprep',opt.forceprep,'silent',opt.silent);
				bDone(bDone)			= ~isnan(varargout{kI}(bDone));
			case 'connectivity'
				c							= repmat({NaN(sOut)},[2 1]);
				[c{1}(bDone),c{2}(bDone)]	= FSLTractConnectivity(cDirDTI(bDone),cNameTract(bDone),'nsample',opt.nsample,'lengthcorrect',opt.lengthcorrect,'force',opt.force,'forceprep',opt.forceprep,'silent',opt.silent);
				varargout{kI}				= c;
				bDone(bDone)				= ~isnan(varargout{kI}{1}(bDone)) & ~isnan(varargout{kI}{2}(bDone));
			case {'fa','md','ad','rd','faz','mdz','adz','rdz'}
				varargout{kI}	= cell(sOut);
				
				if nTract>0
					bCombined	= false;
					
					sProgress	= progress('action','init','total',nSubject,'name','fslroitractfsinfo_data','label',['calculating ' cInfo{kI} ' for each subject'],'silent',opt.silent);
					strName		= sProgress.name;
					for kS=1:nSubject
						[cData,bCombinedCur]	= FSLTractDataLoad(cDirDTI{1,kS},cInfo{kI},'silent',opt.silent);
						cData					= ForceCell(cData);
						
						bCombined	= bCombined || bCombinedCur;
						
						bDo						= bDone(:,kS);
						varargout{kI}(bDo,kS)	= FSLTractData(cDirDTI(bDo,kS),cNameTract(bDo,kS),cInfo{kI},...
													'data'			, cData				, ...
													'lengthcorrect'	, opt.lengthcorrect	, ...
													'force'			, opt.force			, ...
													'forceprep'		, opt.forceprep		, ...
													'silent'		, opt.silent		  ...
													);
						
						progress('name',strName);
					end
					bDone(bDone)	= cellfun(@(x) ~any(isnan(x)),varargout{kI}(bDone));
					
					if ~bCombined
					%we have a single data point for each subject/tract
						varargout{kI}	= cell2mat(varargout{kI});
					end
				end
		end
		progress;
	end
