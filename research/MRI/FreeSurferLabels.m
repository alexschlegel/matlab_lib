function varargout = FreeSurferLabels(varargin)
% FreeSurferLabels
% 
% Description:	get a struct of labels and indices FreeSurfer uses for various
%				segmentations and parcellations
% 
% Syntax:	sLabel = FreeSurferLabels([strDirSubject]=<none>) OR
%			[cLabel,cAbb,kLabel,strName] = FreeSurferLabels(cLabel,[strHemisphere]=<none>,<options>)
% 
% In:
%	[strDirSubject]	- if specified, extra fields will be added for paths to
%					  label files
%	cLabel			- a string or cell of strings specifying aseg, a2009s, and
%					  a2009svol labels
%	[strHemisphere]	- if a structure has both left and right hemisphere
%					  components (e.g. 'Left-Amygdala'), you can specify only the
%					  name of the structure(s) in cLabel (e.g. 'Amygdala') and
%					  'lh' or 'rh' here
%	<options>:
%		name:		(<auto>) a name for the set of labels
%		crop:		(<no crop>) the fractional bounding box that will be cropped
%					from the merged label mask, or a cell of bounding boxes that
%					will be cropped before merging the structures (see
%					MRIMaskCrop).  this is only used to construct the default
%					label set name.
%		index_type:	('vol') only 'vol' is supported.  this is included in case i
%					ever want to return label indices for other than a2009svol
%					labels
% 
% Out:
%	sLabel	- a struct of label info
%	cLabel	- the specified labels as they appear in sLabel
%	cAbb	- abbreviations for each of the labels specified
%	kLabel	- the index of the label in FreeSurfer segmentation volumes
%	strName	- a name for the set of labels
% 
% Updated: 2012-04-16
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
persistent sl;

if nargin==0 || (nargin==1 && ischar(varargin{1}) && isdir(varargin{1}))
%just return the label struct
	varargout{1}	= GetLabelStruct(varargin{:});
else
%return info about specific labels
	[cLabel,strHemisphere,opt]	= ParseArgs(varargin,{},[],...
									'name'			, []	, ...
									'crop'			, []	, ...
									'index_type'	, 'vol'	  ...
									);
	
	bCropBefore	= ~isempty(opt.crop) && iscell(opt.crop);
	
	bHemisphere	= ~isempty(strHemisphere);
	if bHemisphere
		switch lower(strHemisphere)
			case 'lh'
				strPrefix		= 'lh.';
				strHemiLabel	= 'Left-';
			case 'rh'
				strPrefix		= 'rh.';
				strHemiLabel	= 'Right-';
			otherwise
				error(['"' tostring(strHemisphere) '" is not a valid hemisphere.']);
		end
	else
		strPrefix		= '';
		strHemiLabel	= '';
	end
	
	cLabel	= ForceCell(cLabel);
	szLabel	= size(cLabel);
	nLabel	= numel(cLabel);
	
	sLabel	= GetLabelStruct;
	
	%get the indices of the labels to extract
		cAbb	= cell(szLabel);
		kLabel	= NaN(szLabel);
		
		%first look for non-hemispheric aseg labels
			bCheck	= ~cellfun(@isempty,cLabel);
			if any(bCheck)
				b				= false(szLabel);
				[b(bCheck),k]	= ismember(lower(cLabel(bCheck)),lower(sLabel.aseg.label));
				k				= k(b(bCheck));
				cLabel(b)		= sLabel.aseg.label(k);
				cAbb(b)			= sLabel.aseg.abb(k);
				kLabel(b)		= sLabel.aseg.k(k);
			else
				b	= bCheck;
			end
		%now look for hemispheric aseg labels
			bHemi	= bCheck & ~b;
			if bHemisphere && any(bHemi)
				%rename the labels
					cLabelCur	= cellfun(@(s) [strHemiLabel s],cLabel(bHemi),'UniformOutput',false);
				
				[b(bHemi),k]		= ismember(lower(cLabelCur),lower(sLabel.aseg.label));
				k					= k(b(bHemi));
				cLabel(b&bHemi)		= sLabel.aseg.label(k);
				cAbb(b&bHemi)		= sLabel.aseg.abb(k);
				kLabel(b&bHemi)		= sLabel.aseg.k(k);
			end
		%now look for a2009s cortex labels
			bSurf	= bCheck & ~b;
			if bHemisphere && any(bSurf)
				%rename the labels
					cLabelCur	= cellfun(@(s) ['ctx_' lower(strHemisphere) '_' s],cLabel(bSurf),'UniformOutput',false);
				
				[b(bSurf),k]	= ismember(lower(cLabelCur),lower(sLabel.a2009svol.label));
				[bs,ks]			= ismember(lower(cLabel(bSurf)),lower(sLabel.a2009s.label));
				k				= k(b(bSurf));
				ks				= ks(bs);
				cLabel(b&bSurf)	= sLabel.a2009svol.label(k);
				cAbb(b&bSurf)	= sLabel.a2009s.abb(ks);
				kLabel(b&bSurf)	= sLabel.a2009svol.k(k);
			end
		%now look for a2009s cortex labels based on a2009svol
			bSurf2	= bCheck & ~b;
			if any(bSurf2)
				cLabelCur	= cLabel(bSurf2);
				
				[b(bSurf2),k]		= ismember(lower(cLabelCur),lower(sLabel.a2009svol.label));
				k					= k(b(bSurf2));
				cLabel(b&bSurf2)	= sLabel.a2009svol.label(k);
				kLabel(b&bSurf2)	= sLabel.a2009svol.k(k);
				cAbb(b&bSurf2)		= sLabel.a2009svol.abb(k);
			end
		
		%if ~all(b)
		%	error(['The following are not valid labels:' 10 join(cLabel(~b),10)]);
		%end
	
	if bCropBefore
		cF	= cellfun(@(c) num2cell(roundn(c,-2)),opt.crop,'UniformOutput',false);
		for kL=1:nLabel
			if ~isempty(cF{kL})
				cF{kL}	= ['-(' join(cF{kL}(1,:),',') ';' join(cF{kL}(2,:),',') ')'];
			else
				cF{kL}	= '';
			end                     
		end
		
		cAbb	= cellfun(@(a,c) [a c],reshape(cAbb,[],1),reshape(cF,[],1),'UniformOutput',false);
	end
	
	strName	= [strPrefix unless(opt.name,join(cAbb,'_'))];
	
	varargout	= {cLabel cAbb kLabel strName};
end

%------------------------------------------------------------------------------%
function sLabel = GetLabelStruct(varargin)
	strDirSubject	= ParseArgs(varargin,[]);

	%get the label struct
		if isempty(sl)
			strDirFS	= FreeSurferDirRoot;
			
			%aseg from the LUT
				sLUT	= LUTStruct(PathUnsplit(strDirFS,'FreeSurferColorLUT','txt'));
				sl.aseg	= SubLUT(sLUT,0:999);
			%a2009s volume labels from the LUT
				sl.a2009svol	= SubLUT(sLUT,11100:12175);
			%a2009s surface labels from the other guy
				sa2009s		= LUTStruct(PathUnsplit(strDirFS,'Simple_surface_labels2009','txt'));
				sl.a2009s	= SubLUT(sa2009s,0:75);
				
		end
		sLabel	= sl;
	%add path information
		if ~isempty(strDirSubject)
			strDirLabel		= DirAppend(strDirSubject,'label');
			strDirMRI		= DirAppend(strDirSubject,'mri');
			
			sLabel.aseg.path		= LabelPaths(sLabel.aseg,strDirMRI);
			sLabel.a2009svol.path	= LabelPaths(sLabel.a2009svol,strDirMRI);
			sLabel.a2009s.path.lh	= LabelPaths(sLabel.a2009s,strDirLabel,'lh','label');
			sLabel.a2009s.path.rh	= LabelPaths(sLabel.a2009s,strDirLabel,'rh','label');
		end
end
%------------------------------------------------------------------------------%
function s = LUTStruct(strPath)
	%read the color LUT file
		strLUT		= fget(strPath);
	%separate into lines
		cLUT	= split(strLUT,'[\r\n]*');
	%eliminate comment lines
		bDelete			= cellfun(@(s) ~isempty(regexp(s,'^#')),cLUT);
		cLUT(bDelete)	= [];
	%convert to a struct
		s	= table2struct(join([{'k label r g b a'}; cLUT],10),'delim','\s+');
end
%------------------------------------------------------------------------------%
function s = SubLUT(sLUT,k)
	b	= ismember(sLUT.k,k);
	s	= struct('k',sLUT.k(b),'label',{sLUT.label(b)});
	
	%get the abbreviations
		s.abb	= cellfun(@(str) split(str,'_|-'),s.label,'UniformOutput',false);
		s.abb	= cellfun(@(c) cell2mat(cellfun(@Word2Abb,c,'UniformOutput',false)'),s.abb,'UniformOutput',false);
end
%------------------------------------------------------------------------------%
	function str = Word2Abb(str)
		strPre	= '';
		strPost	= '';
		
		if regexp(str,'^pre')
			strPre	= 'Pr';
			str		= str(4:end);
		elseif regexp(str,'^sub')
			strPre	= 'Sub';
			str		= str(4:end);
		elseif regexp(str,'^sup')
			strPre	= 'Sup';
			str		= str(4:end);
		end
		
		if regexp(str,'^post')
			strPre	= 'Po';
			str		= str(5:end);
		end
		
		switch lower(str)
			case 'and'
				str	= '&';
			case 'opercular'
				str	= 'Op';
			case 'orbital'
				str	= 'Orb';
			case 'central'
				str	= 'Cent';
			case 'putamen'
				str	= 'Put';
			case 'pallidum'
				str	= 'Pal';
			case 'cerebral'
				str	= 'Cbrl';
			case 'cerebellum'
				str	= 'Cblm';
			case 'amygdala'
				str	= 'Amyg';
			case 'insula'
				str	= 'Ins';
			case 'vessel'
				str	= 'Ves';
			case 'ventricles'
				str	= 'Vs';
			otherwise
				if numel(str)>3
					str	= upper(str(1));
				end
		end
		
		str	= [strPre str strPost];
	end
%------------------------------------------------------------------------------%
function cPath = LabelPaths(sLabel,strDir,varargin)
	[strPre,strExt]	= ParseArgs(varargin,'','nii.gz');
	
	cPath	= cellfun(@(str) PathUnsplit(strDir,[strPre str],strExt),sLabel.label,'UniformOutput',false);
end
%------------------------------------------------------------------------------%

end