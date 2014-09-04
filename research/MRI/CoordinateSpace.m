% CoordinateSpace
% 
% Description:	an object to use working with and converting between coordinate
%				spaces
% 
% Syntax:	cs = CoordinateSpace.<space>
%				return a CoordinateSpace object for the specified space.
%				<space> can be:
%					'BVQX_Internal':	BrainVoyagerQX's internal coordinate
%										system.  Used in SRFs and VTCs
%					'BVQX_System':		BrainVoyagerQX system coordinates.  Used
%										in VMRs
%					'Talairach':		Talairach coordinates
%					'Analyze75':		Analyze 7.5 coordinates
%					'DICOM':			DICOM coordinates
%					'NIfTI':			NIfTI 1.1 coordinates
%			k = CoordinateSpace.<space>.axis[LR,PA,IS]
%				return the coordinate position of the specified axis
%			d = CoordinateSpace.<space>.dir[LR,PA,IS]
%				access parameters <space>
% 
% Example:	csDICOM = CoordinateSpace.DICOM;
%			k = CoordinateSpace.DICOM.axisPA;
% 
% Updated:	2009-07-31
% Copyright 2009 Alex Schlegel (alex@roguecheddar.com).  All Rights Reserved.
classdef CoordinateSpace
	properties (SetAccess=private)
		axisLR;
		axisPA;
		axisIS;
		dirLR;
		dirPA;
		dirIS;
	end
	methods (Static=true)
		function csChild = BVQX_Internal(cs)
			csChild	= CoordinateSpace(3,1,2,-1,-1,-1);
		end
		function csChild = BVQX_System(cs)
			csChild	= CoordinateSpace(1,2,3,-1,-1,-1);
		end
		function csChild = Talairach(cs)
			csChild	= CoordinateSpace(1,2,3,1,1,1);
		end
		function csChild = Analyze75(cs)
			csChild	= CoordinateSpace(1,2,3,-1,1,1);
		end
		function csChild = DICOM(cs)
			csChild	= CoordinateSpace(1,2,3,-1,-1,1);
		end
		function csChild = NIfTI(cs)
			csChild	= CoordinateSpace(1,2,3,1,1,1);
		end
	end
	
	methods (Access=private)
		function cs = CoordinateSpace(aLR,aPA,aIS,dLR,dPA,dIS)
			cs.axisLR	= aLR;
			cs.axisPA	= aPA;
			cs.axisIS	= aIS;
			
			cs.dirLR	= dLR;
			cs.dirPA	= dPA;
			cs.dirIS	= dIS;
		end
	end
end
