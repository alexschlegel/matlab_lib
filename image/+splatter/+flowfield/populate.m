function im = populate(f,fObject,varargin)
% splatter.flowfield.populate
% 
% Description:	populate a flow field
% 
% Syntax:	im = splatter.flowfield.populate(f,fObject,<options>)
% 
% In:
%	f		- the flow field (see splatter.flowfield.generate)
%	fObject	- the handle to a function to generate the objects with which to
%			  populate the flowfield. should accept the following arguments:
%				a	- an angle (0->2*pi)
%			  and return the following outputs:
%				im		- the object image
%				alpha	- an alpha map for the image
%	<options>:
%		n:			(100) the number of objects with which to populate the
%					flowfield
%		sz:			(<flowfield size>) the size of the output image
%		p:			('uniform') an array of size <sz> specifying the probability
%					of an object occuring at each position, or one of the
%					following:
%						'uniform':	uniform probability across the field
%						'source':	probability that decreases with distance
%									from the source point
%		f_insert:	(@InsertImage) the handle to a function that accepts two
%					images and an alpha map and inserts the second into the
%					first, using the alpha map for transparency
% 
% Out:
% 	im	- an image of objects placed in the flow field
% 
% Updated: 2013-05-19
% Copyright 2013 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent fInsertDefault;

if isempty(fInsertDefault)
	fInsertDefault	= @(im1,im2,alpha) InsertImage(im1,im2,'alpha',alpha);
end

opt	= ParseArgsOpt(varargin,...
		'n'			, 100				, ...
		'sz'		, size(f.obj)		, ...
		'p'			, 'uniform'			, ...
		'f_insert'	, fInsertDefault	  ...
		);

%parse the probability array
	if ischar(opt.p)
		opt.p	= CheckInput(opt.p,'probability',{'uniform','source'});
		
		switch opt.p
			case 'uniform'
				opt.p	= ones(opt.sz);
			case 'source'
				szObj			= size(f.obj);
				[yField,xField]	= ndgrid(1:szObj(1),1:szObj(2));
				d				= dist(cat(3,yField,xField),f.source);
				opt.p			= max(d(:))-d;
		end
	end
	
	opt.p	= imresize(opt.p,opt.sz,'nearest');

%insert the objects
	%calculate object positions and orientations
		%calculate the flowfield positions and orientations
			stream.b	= imresize(any(f.stream.b,3),opt.sz,'nearest');
			stream.a	= imresize(nanmean(f.stream.a,3),opt.sz,'nearest');
		%get the probability distribution for the stream points
			kImStream	= find(stream.b);
			pStream		= opt.p(kImStream);
			pStream		= pStream./sum(pStream);
		%sort and get the cdf along the distribution
			[pStream,kP]	= sort(pStream);
			cumPStream		= [0; cumsum(pStream)];
		%pick random points from 0->1 and find the cdf value closest to them
			r		= rand(opt.n,1);
			kPoint	= kImStream(kP(arrayfun(@(x) find(x>=cumPStream,1,'last'),r)));
			
			[yObject,xObject]	= ind2sub(opt.sz,kPoint);
			aObject				= stream.a(kPoint);
			
	progress(opt.n,'label','populating the flowfield');
	for kO=1:opt.n
		%generate the object
			[imObj,alphaObj]	= fObject(aObject(kO));
		
		if kO==1
		%initialize the image
			[im,imBlank]	= deal(cast(zeros([opt.sz size(imObj,3)]),class(imObj)));
			alphaBlank		= false(opt.sz);
		end
		
		%insert the object
			imObj		= InsertImage(imBlank,imObj,[yObject(kO) xObject(kO)],[],'center');
			alphaObj	= InsertImage(alphaBlank,alphaObj,[yObject(kO) xObject(kO)],[],'center');
			im			= opt.f_insert(im,imObj,alphaObj);
		
		progress;
	end
