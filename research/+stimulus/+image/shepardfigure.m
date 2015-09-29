function [im,b,ifo] = shepardfigure(varargin)
% stimulus.image.shepardfigure
% 
% Description:	render a Shepard/Metzler figure
% 
% Syntax:	[im,b,ifo] = stimulus.image.shepardfigure(<options>)
% 
% In:
%	<options>: (see also stimulus.image.common_defaults)
%		figure:			(<random>) the figure index (1-8)
%		tx:				('') a string specifying the transformations to perform
%						on the figure. takes the form
%							'<x1>[<n1>] <x2>[<n2>] ... <xN>[<nN>]'
%						where <xK> is the operation and possible <nK> is the
%						parameter for the operation. possible operations are:
%							RX:	rotate around x-axis nK degrees
%							RY:	rotate around y-axis nK degrees
%							RZ:	rotate around z-axis nK degrees
%							RB:	"back" rotate nK degrees
%							RF:	"forward" rotate nK degrees
%							RL:	"left" rotate nK degrees
%							RR:	"right" rotate nK degrees
%							FX:	flip along x-axis (no parameter)
%							FY:	flip along y-axis (no parameter)
%							FZ:	flip along z-axis (no parameter)
%						e.g. 'RX-90 RF45.5 FX' rotate -90 degrees around the
%						x-axis, then rotates forward 45.5 degrees, then flips
%						along the x-axis.
%		view:			([-60 15 0]) the rotation to introduce around each axis
%						for the viewpoint, in degrees
%		axis_radius:	(3.5) the axis radius from the origin to include in the
%						viewport
%		edge:			([0 0 0]) the edge color
%		thickness:		(0.5) the line thickness (maybe in points? not sure)
% 
% Out:
% 	im	- the figure
%	msk	- a binary mask of the figure
%	ifo	- a struct of info about the stimulus
% 
% Updated: 2015-09-24
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.

%get the stimulus parameters
		param	= Shepard_Param;
		nFigure	= numel(param.fig);

%default option values
	persistent cDefault;
	
	if isempty(cDefault)
		cDefault	=	{
							'figure'		, []			, ...
							'tx'			, ''			, ...
							'view'			, [-60 15 0]	, ...
							'axis_radius'	, 3.5			, ...
							'edge'			, [0 0 0]		, ...
							'thickness'		, 0.5			  ...
							};
	end

%generate the stimulus
	[im,b,ifo]	= stimulus.image.common_pipeline(...
					'vargin'		, varargin			, ...
					'defaults'		, cDefault			, ...
					'f_validate'	, @Shepard_Validate	, ...
					'f_generate'	, @Shepard_Generate	  ...
					);

%------------------------------------------------------------------------------%
function [opt,ifo] = Shepard_Validate(opt,ifo) 
	%get the figure number
		if isempty(opt.figure)
			opt.figure	= randFrom(1:nFigure,'seed',false);
		end
		
		assert(isscalar(opt.figure) && isint(opt.figure) && opt.figure>=1 && opt.figure<=nFigure,'figure must be an integer between 1 and %d',nFigure);
	
	%parse the transformations
		opt.tx	= split(opt.tx,' ');
		opt.tx	= cellfun(@(tx) regexp(tx,'(?<op>(R[XYZBFLR]|F[XYZ]))(?<param>[-]?\d*\.?\d*)','names'),opt.tx,'uni',false);
		
		assert(~any(cellfun(@isempty,opt.tx)),'malformed transform string');
	
	opt.edge	= str2rgb(opt.edge);
end
%------------------------------------------------------------------------------%
function [im,b,ifo] = Shepard_Generate(opt,ifo)
	fig		= param.fig{opt.figure};
	rotView	= d2r(opt.view);
	
	%prepare the figure
		hF	= figure('visible','off');
		set(hF,...
			'color'				, [0.5 0 0]	, ...
			'PaperPosition'		, [0 0 1 1]	, ...
			'inverthardcopy'	, 'off'		, ...
			'visible'			, 'off'		  ...
			);
		
		hA	= axes;
		set(hA,...
			'position'	, [0 0 1 1]	  ...
			);
	
	%draw each cube
		nCube	= size(fig,1);
		
		fig_shift		= repmat((max(fig) + min(fig))/2,[nCube 1]);
		fig_shifted		= fig - fig_shift;
		
		for kC=1:nCube
			%get the cube coordinates
				p		= param.cube.p;
				for kXYZ=1:3
					p(:,kXYZ)	= p(:,kXYZ) + fig_shifted(kC,kXYZ);
				end
				
				%perform the operations
					nTX	= numel(opt.tx);
					
					for kTX=1:nTX
						op	= opt.tx{kTX}.op;
						prm	= str2num(opt.tx{kTX}.param);
						
						switch op(1)
							case 'R' %rotate
								kRot	= switch2(op(2),'X',2,'Y',3,'Z',1,'R',1,'L',1,'B',3,'F',3);
								rotSign	= switch2(op(2),'L',-1,'B',-1,1);
								
								assert(~isempty(kRot),'malformed transform string');
								
								rot			= repmat({0},[3 1]);
								rot{kRot}	= rotSign*d2r(prm);
								
								p	= RotatePoints(p,rot{:});
							case 'F' %flip
								kFlip	= switch2(op(2),'X',1,'Y',2,'Z',3);
								
								assert(~isempty(kFlip),'malformed transform string');
								
								p(:,kFlip)	= -p(:,kFlip);
							otherwise
								error('malformed transform string');
						end
					end
					
				%rotate for the viewpoint
					p	= RotatePoints(p,rotView(1),rotView(2),rotView(3));
				
				x	= reshape(p(:,1),param.cube.size);
				y	= reshape(p(:,2),param.cube.size);
				z	= reshape(p(:,3),param.cube.size);
			
			%draw each cube face
				for kF=1:6
					hP	= patch(x(:,kF),y(:,kF),z(:,kF),[1 1 1]);
					set(hP,'LineWidth',opt.thickness);
				end
		end
	
	%fix the view settings
		%axis vis3d;
		axis off;
		axis equal;
		view(0,0);
		set(hA,...
			'xlim'	, [-opt.axis_radius opt.axis_radius]	, ...
			'ylim'	, [-opt.axis_radius opt.axis_radius]	, ...
			'zlim'	, [-opt.axis_radius opt.axis_radius]	  ...
			);
		
		pos			= get(hF,'position');
		pos(3:4)	= opt.size;
		set(gcf,'position',pos);
	
	%extract the figure image
		im	= im2double(hardcopy(hF,'-Dopengl',sprintf('-r%d',opt.size)));
		
		close(hF);
		
		im	= uint8(2*im(:,:,1));
	
	%calculate the figure mask
		b	= im~=1;
	
	%set the image colors
		im	= ind2im(im,[opt.edge; opt.background; opt.foreground]);
end
%------------------------------------------------------------------------------%
function param = Shepard_Param()
	persistent p
	
	if isempty(p)
		p.fig	=	{
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; -1 3 0; 0 0 1; 0 0 2; 0 0 3; 1 0 3; 2 0 3]
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; 0 3 1; 0 0 1; 0 0 2; 0 0 3; 1 0 3; 2 0 3]
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; 0 3 -1; 0 0 1; 0 0 2; 0 0 3; 1 0 3; 2 0 3]
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; 0 3 -1; 0 3 -2; 0 0 1; 0 0 2; 0 0 3; 1 0 3]
						[0 0 0; 0 1 0; 0 2 0; 1 2 0; 0 0 1; 0 0 2; 0 0 3; -1 0 3; -2 0 3]
						[0 0 0; 0 1 0; 0 2 0; 1 2 0; 0 0 1; 0 0 2; 0 0 3; -1 0 3; -2 0 3; -3 0 3]
						[0 0 0; 0 1 0; 0 2 0; 1 2 0; 2 2 0; 3 2 0; 0 0 1; 0 0 2; 0 0 3; -1 0 3]
						[0 0 0; 0 1 0; 0 2 0; 0 2 -1; 0 2 -2; 0 0 1; 0 0 2; 0 0 3; 1 0 3; 2 0 3]
						[0 0 0; 0 1 0; 0 2 0; 1 2 0; 2 2 0; 0 0 1; 0 0 2; 0 0 3; -1 0,3; -2 0 3]
						[0 0 0; 0 1 0; 0 2 0; 1 2 0; 2 2 0; 0 0 1; 0 0 2; 0 0 2; -1 0 2; -2 0 2; -3 0 2]
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; 0 3 -1; 0 0 1; 0 0 2; 0 0 3; 0 0 4; 1 0 4]
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; 0 4 0; 0 4 -1; 0 0 1; 0 0 2; 0 0 3; 1 0 3]
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; 1 3 0; 0 0 1; 0 0 2; 0 0 3; 0 0 4; -1 0 4]
						[0 0 0; 0 1 0; 0 2 0; 0 3 0; 0 4 0; 1 4 0; 0 0 1; 0 0 2; 0 0 3; -1 0 3]
% 						[0 0 1;  0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 -1 3; -3 -2 3]
% 						[0 1 0;  0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 -1 3; -3 -2 3]
% 						[0 0 -1; 0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 1 3; -3 2 3]
% 						[0 1 0;  0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -4 0 3; -5 0 3]
% 						[0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 1 3; -3 2 3; -4 2 3]
% 						[0 0 0; 0 1 0; 0 2 0; 0 3 0; -1 3 0; -2 3 0; -2 3 1; -2 3 2; -2 3 3; -2 4 3]
% 						[0 -1 0; 0 -2 0; 0 0 0; -1 0 0; -2 0 0; -3 0 0; -3 0 1; -3 0 2; -3 0 3; -3 1 3; -3 2 3]
% 						[0 -1 0; 0 -2 0; 0 0 0; -1 0 0; -2 0 0; -2 0 1; -2 0 2; -2 0 3; -2 1 3; -2 2 3]
					};
		
		p.cube.x	=	[
							0 1 1 0 0 0
							1 1 0 0 1 1
							1 1 0 0 1 1
							0 1 1 0 0 0
						] - 0.5;
		p.cube.y	=	[
							0 0 1 1 0 0
							0 1 1 0 0 0
							0 1 1 0 1 1
							0 0 1 1 1 1
						] - 0.5;
		p.cube.z	=	[
							0 0 0 0 0 1
							0 0 0 0 0 1
							1 1 1 1 0 1
							1 1 1 1 0 1
						] - 0.5;
		
		p.cube.size	= size(p.cube.x);
		p.cube.p	= [reshape(p.cube.x,[],1) reshape(p.cube.y,[],1) reshape(p.cube.z,[],1)];
	end
	
	param	= p;
end
%------------------------------------------------------------------------------%

end
