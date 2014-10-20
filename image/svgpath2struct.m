function sPath = svgpath2struct(strPath,varargin)
% svgpath2struct
% 
% Description:	parse an SVG path. see:
%				http://www.w3.org/TR/SVG/paths.html#PathData
% 
% Syntax:	sPath = svgpath2struct(strPath,<options>)
% 
% In:
% 	strPath	- the SVG path string
%	<options>:
%		allowimplicit:	(true) true to allow implicitly defined operations
%		allowhv:		(true) true to allow h and v operations, false to
%						convert them to l
%		fill:			(false) true to rotate the coordinates so the image
%						optimally fills a box
%		normalize:		(false) true to normalize coordinates
%		precision:		(<3 for normalized else 0>) the number of decimal places
%						to include in coordinates
% 
% Out:
% 	sPath	- a struct array of the parse path. each element of the struct is
%			  one operation, with the fields 'command' and 'param'
% 
% Updated: 2014-10-18
% Copyright 2014 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
persistent defCommand defCCommand defNParam defKX defKY defKXNext defKYNext;

if isempty(defCommand)
	defCommand	= ['m'	'z'	'l'	'h'	'v'	'c'		's'		'q'		't'	'a'];
	defNParam	= [2	0	2	1	1	6		4		4		2	7];
	defKX		= {1	[]	1	1	[]	[1 3 5]	[1 3]	[1 3]	1	6};
	defKY		= {2	[]	2	[]	1	[2 4 6]	[2 4]	[2 4]	2	7};
	defKXNext	= {1	[]	1	1	[]	5		3		3		1	6};
	defKYNext	= {2	[]	2	[]	1	6		4		4		2	7};
	
	defCCommand	= num2cell(defCommand);
end

%parse the input
	opt	= ParseArgs(varargin,...
			'allowimplicit'	, true	, ...
			'allowhv'		, true	, ...
			'fill'			, false	, ...
			'normalize'		, false	, ...
			'precision'		, []	  ...
			);
	
	opt.precision	= unless(opt.precision,conditional(opt.normalize,3,0));

%separate the operations
	cOp	= reshape(regexp(strPath,'[A-Za-z][0-9,\.- ]*','match'),[],1);
	nOp	= numel(cOp);
%separate each operation into command and parameters
	cCommand	= cellfun(@(op) op(1),cOp,'uni',false);
	cParam		= cellfun(@(op) cellfun(@str2num,reshape(regexp(op(2:end),'[-]?[0-9.]+','match'),[],1)),cOp,'uni',false);

%make sure we have valid commands
	cCommandU	= unique(lower(cCommand));
	bBad		= ~ismember(cCommandU,defCCommand);
	if any(bBad)
		error('The following are invalid commands: %s',join(cCommandU(bBad),','));
	end

%expand the implicit commands
	for kO=1:nOp
		kCommand	= find(defCommand==lower(cCommand{kO}));
		
		nParam			= numel(cParam{kO});
		nParamCommand	= defNParam(kCommand);
		
		if nParam>nParamCommand
			nOpTotal	= nParam/nParamCommand;
			
			cParam{kO}	= reshape(mat2cell(reshape(cParam{kO},nParamCommand,nOpTotal),nParamCommand,ones(1,nOpTotal)),[],1);
			switch lower(cCommand{kO})
				case 'm'
					strL			= switch2(cCommand{kO},'m','l','M','L');
					cCommand{kO}	= [cCommand(kO); repmat({strL},[nOpTotal-1 1])];
				case 'z'
					error('Z takes no parameters.');
				otherwise
					cCommand{kO}	= repmat(cCommand(kO),[nOpTotal 1]);
			end
		else
			cCommand{kO}	= cCommand(kO);
			cParam{kO}		= cParam(kO);
		end
	end
	
	cCommand	= cat(1,cCommand{:});
	cParam		= cat(1,cParam{:});
	nOp			= numel(cCommand);

%convert relative operations to absolute ones and disallow h and v
	[x,y,xStart,yStart,xMin,yMin,xMax,yMax]	= deal(0);
	
	for kO=1:nOp
		kCommand	= find(defCommand==lower(cCommand{kO}));
		
		%relative to absolute coordinates
			if islower(cCommand{kO})
				%x coordinates to absolute
					for kX=defKX{kCommand}
						cParam{kO}(kX)	= x + cParam{kO}(kX);
					end
				
				%y coordinates to absolute
					for kY=defKY{kCommand}
						cParam{kO}(kY)	= y + cParam{kO}(kY);
					end
				
				cCommand{kO}	= upper(cCommand{kO});
			end
		
		%disallow h and v
			if ~opt.allowhv
				bH	= strcmp(cCommand{kO},'H');
				bV	= strcmp(cCommand{kO},'V');
				
				if bH || bV
					cParam{kO}		= conditional(bH,[cParam{kO}; y],[x; cParam{kO}]);
					cCommand{kO}	= 'L';
					kCommand		= find(defCommand==lower(cCommand{kO}));
				end
			end
		
		%calculate the new x and y
			if strcmp(cCommand{kO},'Z')
				x	= xStart;
				y	= yStart;
			else
				x	= unless(cParam{kO}(defKXNext{kCommand}),x);
				y	= unless(cParam{kO}(defKYNext{kCommand}),y);
				
				if strcmp(cCommand{kO},'M')
					xStart	= x;
					yStart	= y;
				end
			end
			
			if kO==1
				[xMin,xMax]	= deal(x);
				[yMin,yMax]	= deal(y);
			else
				xMin	= min(xMin,x);
				yMin	= min(yMin,y);
				xMax	= max(xMax,x);
				yMax	= max(yMax,y);
			end
	end

%fill the space
	if opt.fill
		%get a list of all x and y coordinates
			x	= cellfun(@(c,p) p(defKX{find(defCommand==lower(c))}),cCommand,cParam,'uni',false);
			y	= cellfun(@(c,p) p(defKY{find(defCommand==lower(c))}),cCommand,cParam,'uni',false);
			x	= cat(1,x{:});
			y	= cat(1,y{:});
			N	= numel(x);
		%calculate the orientation of the points (see regionprops Orientation
		%calculation
			%center the coordinates
				xC	= (min(x) + max(x))/2;
				yC	= (min(y) + max(y))/2;
				
				xNorm	= x - xC;
				yNorm	= y - yC;
			%normalized second central moments
				uxx	= sum(xNorm.^2)/N;
				uyy	= sum(yNorm.^2)/N;
				uxy	= sum(xNorm.*yNorm)/N;
			
			%orientation
				if uyy > uxx
					num	= uyy - uxx + sqrt((uyy - uxx)^2 + 4*uxy^2);
					den	= 2*uxy;
				else
					num	= 2*uxy;
					den	= uxx - uyy + sqrt((uxx - uyy)^2 + 4*uxy^2);
				end
				if (num == 0) && (den == 0)
					a	= 0;
				else
					a	= (180/pi) * atan(num/den);
				end
		%rotate each point so that the orientation is 45 degrees
			for kO=1:nOp
				kCommand	= find(defCommand==lower(cCommand{kO}));
				
				kX	= defKX{kCommand};
				kY	= defKY{kCommand};
				nP	= numel(kX);
				
				x	= reshape(cParam{kO}(kX) - xC,[],1);
				y	= reshape(cParam{kO}(kY) - yC,[],1);
				
				p	= RotatePoints([x y],d2r((180-a)-45));
				
				cParam{kO}(kX)	= p(:,1) + xC;
				cParam{kO}(kY)	= p(:,2) + yC;
			end
	end

%convert to normalized coordinates
	if opt.normalize
		fNorm	= 1/max(xMax-xMin,yMax-yMin);
		
		offsetX	= (1-fNorm*(xMax-xMin))/2;
		offsetY	= (1-fNorm*(yMax-yMin))/2;
		
		for kO=1:nOp
			kCommand	= find(defCommand==lower(cCommand{kO}));
			
			cParam{kO}(defKX{kCommand})	= fNorm.*(cParam{kO}(defKX{kCommand}) - xMin) + offsetX;
			cParam{kO}(defKY{kCommand})	= fNorm.*(cParam{kO}(defKY{kCommand}) - yMin) + offsetY;
		end
	end

%restore implicit operations
	if opt.allowimplicit
		kO=1;
		
		while kO < numel(cCommand)
			cmdCheck	= conditional(strcmp(cCommand{kO},'M'),'L',cCommand{kO});
			
			for kOCheck=kO:nOp
				if kOCheck==nOp || ~strcmp(cCommand{kOCheck+1},cmdCheck)
					break;
				end
			end
			
			if kOCheck>kO
				kImplicit	= kO+1:kOCheck;
				paramAdd	= cat(1,cParam{kImplicit});
				
				cCommand(kImplicit)	= [];
				cParam(kImplicit)	= [];
				
				cParam{kO}	= [cParam{kO}; paramAdd];
			end
			
			kO	= kO + 1;
		end
	end

%set the precision
	cParam	= cellfun(@(x) roundn(x,-opt.precision),cParam,'uni',false);

sPath	= struct('command',cCommand,'param',cParam);
