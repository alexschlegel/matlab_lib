function voi = bvSRF2VOI(srf,varargin)
% bvSRF2VOI
% 
% Description:	convert the vertices of an SRF to a VOI
% 
% Syntax:	voi = bvSRF2VOI(srf,<options>)
% 
% In:
% 	srf		- an SRF loaded with BVQXfile
%	<options>:
%		'pad':		(0) optionally pad each VOI point with the specified number
%					of voxels
%		'index':	(<all>) a cell of arrays of vertex color indices to include
%					in each VOI
%		'name'		('SRF2VOI') a cell of names of the VOIs defined by the
%					color indices specified through the 'index' option
%		'voicolor:	([255 0 0]) an nVOI x 3 or 1 x 3 array of 0-255 RGB color
%					values for each VOI
% 
% Out:
% 	voi	- the VOI constructed from the specified vertices in srf
%
% Note:	vertices with negative colors aren't converted
% 
% Updated:	2009-08-17
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
opt	= ParseArgsOpt(varargin,...
		'pad'		, 0			, ...
		'index'		, []		, ...
		'name'		, 'SRF2VOI'	, ...
		'voicolor'	, [255 0 0]   ...
		);
%fix sizes
	nCol			= size(opt.voicolor,1);
	opt.voicolor	= mat2cell(opt.voicolor,ones(nCol,1),3);
	
	[opt.index,opt.name,opt.voicolor]	= ForceCell(opt.index,opt.name,opt.voicolor);
	[opt.index,opt.name,opt.voicolor]	= FillSingletonArrays(opt.index,opt.name,opt.voicolor);
	
	nVOI	= numel(opt.index);

%initialize the VOI
	voi				= bless(BVQXfile('new:voi'));
	voi.NrOfVOIs	= nVOI;
	voi.VOI			= struct(	'Name'			, opt.name		, ...
								'Color'			, opt.voicolor	, ...
								'NrOfVoxels'	, 0				, ...
								'Voxels'		, []			  ...
								);
%construct each VOI
	bValid	= ~any(srf.VertexColor<0,2);
	
	for kVOI=1:nVOI
		%get the SRF vertices
			if isempty(opt.index{kVOI})
				bConvert	= bValid;
			else
				bConvert	= bValid & ismember(srf.VertexColor(:,1),opt.index{kVOI});
			end
			pSRF	= srf.VertexCoordinate(bConvert,:);
		%get the VOI coordinates
			pVOI	= unique(bvCoordConvert('srf','tal',pSRF),'rows');
		%pad the voxels
			pVOI	= PadVoxels(pVOI,opt.pad);
			nVoxel	= size(pVOI,1);
		%add to the VOI
			voi.VOI(kVOI).NrOfVoxels	= nVoxel;
			voi.VOI(kVOI).Voxels		= pVOI;
	end

%------------------------------------------------------------------------------%
function p = PadVoxels(p,nPad)
	if nPad==0
		return;
	end
	
	dPad	= 2*nPad+1;
	
	%try to avoid memory errors by stepping through the points and only keeping
	%unique ones as we go
	
	%reshape to make things easier
		p	= p';
	%number of points in the padding cube around each point
		nPadPer		= dPad^3-1;
	%100,000,000MB limit, 3 coordinates per point
		nPointMax	= 100000000/3;
	%maximum number of points to pad per iteration
		nPointPer	= nPointMax/nPadPer;
	%get the relative coordinates for the padding points
		xRel	= reshape(repmat(reshape(-nPad:nPad,[],1,1),[1 dPad dPad]),1,1,[]);
		yRel	= reshape(repmat(reshape(-nPad:nPad,1,[],1),[dPad 1 dPad]),1,1,[]);
		zRel	= reshape(repmat(reshape(-nPad:nPad,1,1,[]),[dPad dPad 1]),1,1,[]);
		
		%eliminate the self-reference
			kSelf		= ceil(dPad*3/2);
			xRel(kSelf)	= [];
			yRel(kSelf)	= [];
			zRel(kSelf)	= [];
			
		rel	= [xRel;yRel;zRel];
	%step through each chunk
		for kPoint=1:nPointPer:nPoint
			kPointCur	= kPoint:min(nPoint,kPoint+nPointPer-1);
			nPointCur	= numel(kPointCur);
			
			%get the x, y, and z coordinates
				pCur	= repmat(p(:,kPointCur),[1 1 nPadPer]) + repmat(rel,[1 nPointCur 1]);
			%reshape to Nx3
				pCur	= reshape(pCur,3,[]);
			%get the unique ones
				pCur	= unique(pCur','rows');
			%add to p and get the unique ones again
				p		= unique([p';pCur],'rows')';
		end
%------------------------------------------------------------------------------%
