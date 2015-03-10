% 20150124-matchedcrossclassify_test.m
% test the Matched Dataset Cross Classification functionality of MVPAClassify
strDirOut	= '/home/alex/temp/20150124-matchedcrossclassify_test';
CreateDirPath(strDirOut);

% param	= struct(...
% 			'effect_type'		, 'multivariate'	, ...
% 			'effect_size'		, 10				, ...
% 			'effect_fraction'	, 1					, ...
% 			'block_duration'	, 2					, ...
% 			'rest_duration'		, 1					, ...
% 			'reps'				, 1					, ...
% 			'runs'				, 2				, ...
% 			'space'				, 3				, ...
% 			'mean'				, 0					, ...
% 			'output_dir'		, strDirOut			  ...
% 			);
param	= struct(...
			'effect_type'		, 'multivariate'	, ...
			'effect_size'		, 3					, ...
			'effect_fraction'	, 0.50				, ...
			'block_duration'	, 10				, ...
			'rest_duration'		, 10				, ...
			'reps'				, 4					, ...
			'runs'				, 10				, ...
			'space'				, 100				, ...
			'mean'				, 1000				, ...
			'output_dir'		, strDirOut			  ...
			);

%generate the first dataset
	p1			= param;
	p1.subject	= 'dataset1';
	cOpt		= opt2cell(p1);
	
	d1	= datagen.fmri(cOpt{:});

%generate the second dataset, which is a permutation of the first
	d2	= d1;
	
	d2.param.subject	= 'dataset2';
	d2.path.data		= PathUnsplit(strDirOut,'dataset2','nii.gz');
	d2.path.attr		= PathUnsplit(strDirOut,'dataset2','attr');
	
	%permute
		d2.data	= d2.data(:,randperm(size(d2.data,2)));
	
	%save the data
		nii	= reshape(permute(d2.data,[2 1]),size(d2.data,2),1,1,size(d2.data,1));
		nii	= make_nii(nii);
		NIfTIWrite(nii,d2.path.data);
		
		FileCopy(d1.path.attr,d2.path.attr);

%generate the third dataset, which is dataset 2 with noise added
	d3	= d2;
	
	d3.param.subject	= 'dataset3';
	d3.path.data		= PathUnsplit(strDirOut,'dataset3','nii.gz');
	d3.path.attr		= PathUnsplit(strDirOut,'dataset3','attr');
	
	%add noise
		d3.data	= d3.data + 0.15*std(d3.data(:)).*randn(size(d3.data));
	
	%save the data
		nii	= reshape(permute(d3.data,[2 1]),size(d3.data,2),1,1,size(d3.data,1));
		nii	= make_nii(nii);
		NIfTIWrite(nii,d3.path.data);
		
		FileCopy(d2.path.attr,d3.path.attr);

%generate the fourth dataset, a different multivariate effect
	p4			= param;
	p4.subject	= 'dataset4';
	cOpt		= opt2cell(p4);
	
	d4	= datagen.fmri(cOpt{:});

%generate the fifth dataset, noise
	d5	= d1;
	
	d5.param.subject	= 'dataset5';
	d5.path.data		= PathUnsplit(strDirOut,'dataset5','nii.gz');
	d5.path.attr		= PathUnsplit(strDirOut,'dataset5','attr');
	
	%make the noise data
		d5.data	= randn(size(d5.data));
	
	%save the data
		nii	= reshape(permute(d5.data,[2 1]),size(d5.data,2),1,1,size(d5.data,1));
		nii	= make_nii(nii);
		NIfTIWrite(nii,d5.path.data);
		
		FileCopy(d1.path.attr,d5.path.attr);

%construct an "ROI" dataset
	dROI1	= d1.data;
	dROI2	= d2.data;
	%dROI2	= d1.data;
	
	str1	= '1';
	str2	= '2';
	%str2	= '1';
	
	%the dataset
		dROI	= [dROI1 dROI2];
		nii		= reshape(permute(dROI,[2 1]),size(dROI,2),1,1,size(dROI,1));
		nii		= make_nii(nii);
		
		strPathROI	= PathUnsplit(strDirOut,sprintf('data%s%s_roi',str1,str2),'nii.gz');
		NIfTIWrite(nii,strPathROI);
	%the masks
		msk1			= make_nii([ones(size(dROI1,2),1); zeros(size(dROI2,2),1)]);
		strPathMask1	= PathUnsplit(strDirOut,'roi1','nii.gz');
		NIfTIWrite(msk1,strPathMask1);
		
		msk2			= make_nii([zeros(size(dROI1,2),1); ones(size(dROI2,2),1)]);
		strPathMask2	= PathUnsplit(strDirOut,'roi2','nii.gz');
		NIfTIWrite(msk2,strPathMask2);

%cross classify
	cTarget		= d1.design.target;
	kChunk		= d1.design.chunk;
	
	cPathMask	= {strPathMask1; strPathMask2};
	
	res	= MVPAROICrossClassify(...
		'output_dir'		, strDirOut		, ...
		'path_functional'	, strPathROI	, ...
		'path_mask'			, cPathMask		, ...
		'melodic'			, false			, ...
		'targets'			, cTarget		, ...
		'chunks'			, kChunk		, ...
		'target_blank'		, 'Blank'		, ...
		'debug'				, 'all'			, ...
		'force'				, true			, ...
		'force_pre'			, false			  ...
		);
