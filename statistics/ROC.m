function [tp,fp,varargout] = ROC(bClass,vScore,varargin)
% ROC
% 
% Description:	perform an ROC analysis on the given data
%				
%				taken from roc.m and auroc.m by Dr. Gavin C. Cawley, written
%				2005-06-09 and distributed under the GNU GPL.
% 
% Syntax:	[tp,fp,auc,aSig,hF] = ROC(bClass,vScore,[pSig]=95,[bPlot]=false)
% 
% In:
% 	bClass	- an N-length logical array of class-specifiers for each data point
%	vScore	- an N-length array of the value given to each data point
%	[pSig]	- the significance cutoff
%	[bPlot]	- true to plot the results
% 
% Out:
% 	tp		- the true-positive rate
%	fp		- the false-positive rate
%	auc		- the area under the ROC curve
%	aSig	- the auc value that represents the pSig-percentile of areas, given
%			  random classes assigned to the given vScore data
%	hF		- the handle to the ROC plot
% 
% Updated: 2015-04-08
% Copyright 2015 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
[pSig,bPlot]	= ParseArgs(varargin,95,false);

nPoint	= numel(bClass);

%reshape the data
	bClass	= reshape(bClass,[],1);
	vScore	= reshape(vScore,[],1);

%calculate tp/fp
	[tp,fp,vScore]	= GetROCCurve(bClass,vScore,true);
		
%optionally calculate the auc
	if nargout>2
		varargout{1}	= GetAUC(tp,fp);
	end
	
%optionally get the significance cutoff
	if nargout>3
		nRand	= 1000;
		aucRand	= zeros(nRand,1);
		progress('action','init','total',nRand,'label','rand for AUC');
		for kR=1:nRand
			bClass	= rand(nPoint,1)>=0.5;
			
			[tpRand,fpRand]	= GetROCCurve(bClass,vScore,false);
			aucRand(kR)		= GetAUC(tpRand,fpRand);
			
			progress;
		end
		
		varargout{2}	= prctile(aucRand,pSig);
	end

%optionally plot
	if bPlot
		hF	= figure;
		hA	= axes;
		
		plot(hA,fp,tp,'r-','linewidth',3);
		set(hF,'Color',[1 1 1]);
		set(hA,'box','off');
		
		hT	= title('ROC Curve');
		hX	= xlabel('False positive');
		hY	= ylabel('Hit');
		
		set(hT,'FontSize',18);
		set(hT,'FontWeight','bold');
		set(hX,'FontSize',12);
		set(hY,'FontSize',12);
		
		varargout{3}	= hF;
	else
		if nargout>4
			varargout{3}	= 0;
		end
	end

%------------------------------------------------------------------------------%
function [tp,fp,vScore] = GetROCCurve(bClass,vScore,bSort)
	[nPoint,nRep]	= size(bClass);
	
	%optionally sort the classes by descending vScore
		if bSort
			[vScore,kSortR]	= sort(vScore,1,'descend');
			kSortC			= repmat(1:nRep,[nPoint 1]);
			kSort			= sub2ind([nPoint,nRep],kSortR,kSortC);
			bClass(:)		= bClass(kSort);
		end
	%calculate the rates
		nClass1	= repmat(sum(bClass,1),[nPoint,1]);
		nClass2	= nPoint - nClass1;
		tp	= cumsum(bClass,1)./max(1,nClass1);
		fp	= cumsum(~bClass,1)./max(1,nClass2);
	%add the endpoints
		padZero	= zeros(1,nRep);
		padOne	= ones(1,nRep);
		
		tp	= [padZero ; tp ; padOne];
		fp	= [padZero ; fp ; padOne];
%------------------------------------------------------------------------------%
function auc = GetAUC(tp,fp)
	dX	= fp(2:end,:) - fp(1:end-1,:);
	y	= (tp(2:end,:) + tp(1:end-1,:))/2;
	
	auc	= sum(dX.*y,1);
	
	bLess		= auc<0.5;
	auc(bLess)	= 1-auc(bLess);
%------------------------------------------------------------------------------%
