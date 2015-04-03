function p	= bvCoordConvert(strFrom,strTo,p,varargin)
% bvCoordConvert
%
% Description: converts between BrainVoyager's various coordinate systems
%
% Syntax:	p = bvCoordConvert(strFrom,strTo,p,<options>)
%
% In:
%	strFrom	- the coordinate space of p.  one of the following strings:
%				'bvint'/'srf':	internal BV coordinate system (used for data
%								bounds in VTCs and vertex coordinates in SRFs)
%				'vmr':			BV system coordinates (used in VMRs)
%				'tal':			Talairach coordinates (used in VOIs)
%			  	'vtc':			indices in a VTC data array
%	strTo	- the coordinate space to which to convert p.  Use one of the
%			  strings above
%	p		- an Nx3 matrix of coordinates
%	<options>:
%		'vtc':		([]) for conversions involving VTCs, the VTC object involved
%					in the conversion
%		'fcube':	(256) size of the framing cube of the data to convert
%
% Out:
%	p - p converted to the strTo coordinate space
%
% Example: p = bvCoordConvert('tal','vtc',[-53 0 44],'vtc',vtc);
%
% Updated: 2009-08-17
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
opt	= ParseArgs(varargin,...
		'vtc',		[]	, ...
		'fcube',	256	  ...
		);

if isempty(p)
	return;
end

%first convert to BV external system space
	if ~isequal(strFrom,'vmr')
		bbox	= EmptyBBox();
		
		switch lower(strFrom)
			case {'bvint','srf'}
				ct	= 'bvi2bvs';
			case 'tal'
				ct			= 'tal2bvs';
				bbox.FCube	= opt.fcube;
			case 'vtc'
				ct			= 'bvc2bvs';
				bbox.BBox	= [opt.vtc.XStart opt.vtc.YStart opt.vtc.ZStart; opt.vtc.XEnd opt.vtc.YEnd opt.vtc.ZEnd];
				bbox.ResXYZ	= repmat(opt.vtc.Resolution,[1 3]);
			otherwise
				error(['"' strFrom '" is not a recognized coordinate space.']);
		end
		
		p	= bvcoordconv(p,ct,bbox);
	end
	
%now convert to the output space
	if ~isequal(strTo,'vmr')
		bbox	= EmptyBBox();
		
		bFloor	= false;
		switch lower(strTo)
			case {'bvint','srf'}
				ct	= 'bvs2bvi';
			case 'tal'
				ct			= 'bvs2tal';
				bbox.FCube	= opt.fcube;
			case 'vtc'
				ct			= 'bvs2bvc';
				bbox.BBox	= [opt.vtc.XStart opt.vtc.YStart opt.vtc.ZStart; opt.vtc.XEnd opt.vtc.YEnd opt.vtc.ZEnd];
				bbox.ResXYZ	= repmat(opt.vtc.Resolution,[1 3]);
				
				bFloor	= true;
			otherwise
				error(['"' strFrom '" is not a recognized coordinate space.']);
		end
		
		p	= bvcoordconv(p,ct,bbox);
		if bFloor
			p	= floor(p);
		end
	end

%------------------------------------------------------------------------------%
function bbox = EmptyBBox()
	[bbox.BBox,bbox.CBox]		= deal([0 0 0; 0 0 0]);
	[bbox.DimXYZ,bbox.ResXYZ]	= deal([0 0 0]);
	bbox.FCube	= 0;
%------------------------------------------------------------------------------%
