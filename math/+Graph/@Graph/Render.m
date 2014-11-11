function hF = Render(g,varargin)
% Render
% 
% Description:	render an image of the graph g
% 
% Syntax:	hF = g.Render(<options>)
% 
% In:
%	<options>:
%		col_back:	([1 1 1]) the background color
%		t_node:		(3) the node thickness, in pixels
%		t_edge:		(2) the edge thickness, in pixels
%		w:			(500) the image width, in pixels
%		h:			(<w>) the image height, in pixels
% 
% Out:
% 	hF	- the handle of the rendered graph
% 
% Updated: 2012-01-02
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
opt	= ParseArgs(varargin,...
		'col_back'	, [1 1 1]	, ...
		't_node'	, 3			, ...
		't_edge'	, 2			, ...
		'w'			, 500		, ...
		'h'			, []		  ...
		);
opt.h	= unless(opt.h,opt.w);

pCenter	= [opt.w/2 opt.h/2];
lSpace	= min(opt.w/10,opt.h/10);
rNode	= min(opt.w/40,opt.h/40);

dt			= 0.01;
CEdge		= 2e0;
CSeparate	= 2e4;
CDampen		= 3e0;
aMax		= 100;
aJitter		= 1;

rate	= 30;

%create the figure
	[hA,hF]	= canvas('color',opt.col_back,'w',opt.w,'h',opt.h);
%get the initial node positions
	nNode	= numel(g.node);
	
	if nNode==0
		return;
	end
	
	bPlaced	= false(nNode,1);
	
	PlaceNodes(g.node(1),pCenter);
%reposition until we're stable
	[fNode,aNode,vNode]	= deal(zeros(nNode,2));
	
	w	= reshape([g.node.weight],[],1);
	
	%get the nodes for each edge
		nEdge	= numel(g.edge);
		
		[kEdgeNode1,kEdgeNode2]	= deal(zeros(nNode,1));
		
		for kE=1:nEdge
			kEdgeNode1(kE)	= find(g.node==g.edge(kE).node(1),1);
			kEdgeNode2(kE)	= find(g.node==g.edge(kE).node(2),1);
		end
	%get the attractors and repulsors for each node
		[kAttract,kRepulse]	= deal(cell(nNode,1));
		[nAttract,nRepulse]	= deal(zeros(nNode,1));
		
		for kN=1:nNode
			[bAttract,kAttract{kN}]	= ismember(setdiff([g.node(kN).edge.node],g.node(kN)),g.node);
			nAttract(kN)				= numel(kAttract{kN});
			
			kRepulse{kN}	= [1:kN-1 kN+1:nNode];
			nRepulse(kN)	= numel(kRepulse{kN});
		end
	
	tStart	= nowms;
	tNext	= tStart;
	for kS=1:10000
		StepPositions;
		
		if nowms>=tNext
			DrawGraph;
			tNext	= tNext + 1000/rate;
		end
	end


%------------------------------------------------------------------------------%
function PlaceNodes(nd,p)
	kNode			= find(g.node==nd);
	
	if ~isnan(nd.x) && ~isnan(nd.y)
		p	= [nd.x nd.y];
	else
		nd.x	= p(1);
		nd.y	= p(2);
	end
	
	bPlaced(kNode)	= true;
	
	ndChild			= setdiff([nd.edge.node],nd);
	nChild			= numel(ndChild);
	[bChild,kChild]	= ismember(ndChild,g.node);
	kPlace			= kChild(~bPlaced(kChild));
	nPlace			= numel(kPlace);
	
	pPlace	= zeros(0,2);
	
	rCur	= lSpace;
	while size(pPlace,1)<nPlace
		nEdge	= numel(nd.edge);
		aEdge	= 2*pi*(0:nEdge-1)'/nEdge;
		rEdge	= repmat(rCur,[nEdge 1]);
		xEdge	= p(1) + rEdge.*cos(aEdge);
		yEdge	= p(2) + rEdge.*sin(aEdge);
		pEdge	= [xEdge yEdge];
		
		pPlace	= [pPlace; randomize(setdiff(pEdge,NodePositions,'rows'))];
		
		rCur	= rCur + lSpace;
	end
	pPlace	= pPlace(1:nPlace,:);
	
	for kP=1:nPlace
		kPlaceCur	= kPlace(kP);
		
		if ~bPlaced(kPlaceCur)
			PlaceNodes(g.node(kPlaceCur),pPlace(kP,:));
		end
	end
end
%------------------------------------------------------------------------------%
function pNode = NodePositions(varargin)
	if nargin>0
		pNode	= [reshape([g.node(varargin{1}).x],[],1) reshape([g.node(varargin{1}).y],[],1)];
	else
		pNode	= [reshape([g.node.x],[],1) reshape([g.node.y],[],1)];
	end
end
%------------------------------------------------------------------------------%
function StepPositions
	%get the force on each node
		for kN=1:nNode
			%edge force
				%position of each pair
					p1	= repmat(NodePositions(kN),[nAttract(kN) 1]);
					p2	= NodePositions(kAttract{kN});
				%vector pointing from node to attractors
					v	= p2 - p1;
				%square of the distance between them
					d2	= sum(v.^2,2);
				%distance squared from node edges
					d	= max(eps,sqrt(d2) - 2*rNode);
				%normalized vector
					v	= v./max(eps,repmat(sqrt(sum(v.^2,2)),[1 2]));
				%attractive force vectors
					fAttract	= v.*repmat(w(kAttract{kN}).*(CEdge.*d),[1 2]);
			%node force
				%position of each pair
					p1	= repmat(NodePositions(kN),[nRepulse(kN) 1]);
					p2	= NodePositions(kRepulse{kN});
				%vector pointing from node to repulsors
					v			= p2 - p1;
				%square of the distance between them
					d2			= sum(v.^2,2);
				%distance from node edges
					d	= max(1,sqrt(d2) - 2*rNode);
					d2	= max(1,d.^2);
				%normalized vector
					v	= v./max(eps,repmat(sqrt(sum(v.^2,2)),[1 2]));
				%repulsive force vectors
					fRepulse	= v.*repmat(-w(kRepulse{kN}).*CSeparate./d2,[1 2]);
			%damping force
				%fDampen	= -CDampen*vNode(kN,:);
			%overall force vector
				%fNode(kN,:)	= sum([fAttract; fRepulse; fDampen],1);
				fNode(kN,:)	= sum([fAttract; fRepulse],1);
				
				%disp([sum(fAttract,1) sum(fRepulse,1)]);
% 				if isequal(g.node(kN).name,'3') && sum(fRepulse(:))>10e10
% 					disp([fNode(kN,:) sum(fAttract,1) sum(fRepulse,1)]);
% 				end
		end
	%set the acceleration based on the forces
		aNode	= fNode ./ repmat(reshape([g.node.weight],[],1),[1 2]) + aJitter*rand(nNode,2);
		%aNode	= sign(aNode).*min(aMax,abs(aNode));
	%damping force
		aNode	= aNode + -CDampen*(vNode + dt*aNode);
	%update the velocities
		vNode	= vNode + dt*aNode;
	%update the positions
		x	= num2cell(reshape([g.node.x],[],1) + dt*vNode(:,1));
		y	= num2cell(reshape([g.node.y],[],1) + dt*vNode(:,2));
		
		[g.node.x]	= deal(x{:});
		[g.node.y]	= deal(y{:});
end
%------------------------------------------------------------------------------%
function DrawGraph
	cla;
	
	%get the drawing positions
		pDraw	= NodePositions;
		pDraw	= pDraw - repmat(min(pDraw,[],1),[nNode 1]);
		
		rW		= (opt.w-1-2*rNode)./max(pDraw(:,1));
		rH		= (opt.h-1-2*rNode)./max(pDraw(:,2));
		r		= min(rW,rH);
		pDraw	= r.*pDraw;
		pDraw	= pDraw + repmat(pCenter-(max(pDraw)-min(pDraw))/2,[nNode 1]);
	%draw each node
		for kN=1:nNode
			circle(pDraw(kN,1),pDraw(kN,2),rNode,hA,'LineWidth',opt.t_node,'Color',g.node(kN).color);
			
			text(pDraw(kN,1),pDraw(kN,2),g.node(kN).name,'HorizontalAlignment','center','VerticalAlignment','middle');
		end
	%draw the edges
		nEdge	= numel(g.edge);
		
		for kE=1:nEdge
			pNode1	= pDraw(kEdgeNode1(kE),:);
			pNode2	= pDraw(kEdgeNode2(kE),:);
			aEdge	= atan2(pNode2(2)-pNode1(2),pNode2(1)-pNode1(1));
			
			xOff	= rNode*cos(aEdge);
			yOff	= rNode*sin(aEdge);
			pLine1	= pNode1 + [xOff yOff];
			pLine2	= pNode2 - [xOff yOff];
			
			line([pLine1(1) pLine2(1)],[pLine1(2) pLine2(2)],'LineWidth',opt.t_edge,'Color',g.edge(kE).color);
		end
	
	drawnow;
end
%------------------------------------------------------------------------------%

end
