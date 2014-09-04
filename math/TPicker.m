function varargout = TPicker(varargin)
% TPicker
% 
% Description:	use to construct a t parameter vector
% 
% Syntax:	[t,f,p] = TPicker(t) OR
%			[t,f,p] = TPicker(n,[f]='linear',[p1,...,pN]=0) OR
%			[t,f,p] = GetTParameter([n]=10,[f]='linear',p) OR
%			[t,f,p1,...,pN] = ...
% 
% In:
% 	t		- a t parameter vector
%	n		- the number of steps
% 	[f]		- an inline function of 'x' with domain [0,1] and range [0,1], or
%			  one of the following strings denoting a built-in function:
%				'linear':	linear (p1*x+p2)
%				'exp':		exponential (p2*exp(p1*x)+p3)
%				'poly':		polynomial (sum(p(2K)*x^p(2K-1)))
%				'interp':	interpolate from control points. p(2K-1) is the 
%							position and p(2K) is the value
%	[pK]	- the value of the Kth parameter to the chosen function
%	p		- a cell of parameters of f
% 
% Out:
% 	t	- the t parameter vector specified, or [] if the user clicked "Cancel"
% 
% Updated:	2009-01-06
% Copyright 2009 Alex Schlegel (schlegel@gmail.com).  All Rights Reserved.
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
	                   'gui_Singleton',  gui_Singleton, ...
	                   'gui_OpeningFcn', @TPicker_OpeningFcn, ...
	                   'gui_OutputFcn',  @TPicker_OutputFcn, ...
	                   'gui_LayoutFcn',  [] , ...
	                   'gui_Callback',   []);
	if nargin && ischar(varargin{1})
	    gui_State.gui_Callback = str2func(varargin{1});
	end
	
	if nargout
	    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
	    gui_mainfcn(gui_State, varargin{:});
	end
%------------------------------------------------------------------------------%
function handles = TPicker_OpeningFcn(hObject, eventdata, handles, varargin)
	%parse the inputs
		handles	= ParseInputs(handles,varargin);
	
	%initialize stuff
		handles	= GUIInit(handles);
	
	%update the GUI
		handles	= GUIUpdate(handles);
	
	%Update handles structure
		guidata(hObject, handles);
	
	%UIWAIT makes TPicker wait for user response (see UIRESUME)
		uiwait(handles.figMain);
%------------------------------------------------------------------------------%
function varargout = TPicker_OutputFcn(hObject, eventdata, handles) 
	varargout{1} = handles.output;
	
	delete(hObject);
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function tp_closerequest(hObject,eventdata,handles)
	uiresume(hObject);
%------------------------------------------------------------------------------%
function tp_ParameterInsertBefore(hObject,eventdata,handles)
	k	= get(handles.lstParameter,'Value');
	
	strFunction	= GetFunctionPopup(handles);
	
	switch strFunction
		case 'interp'
			x	= reshape(handles.out.f.p.breaks,[],1);
			y	= feval(handles.out.f,x);
			
			if k>1
				xNew	= mean(x(k-1:k));
				yNew	= feval(handles.out.f,xNew);
			elseif x(1)>0
				xNew	= x(1)/2;
				yNew	= feval(handles.out.f,xNew);
			else
				xNew	= x(1);
				yNew	= y(1);
				
				x(1)	= x(2)/2;
			end
			
			x	= [x(1:k-1); xNew; x(k:end)];
			y	= [y(1:k-1); yNew; y(k:end)];
			
			handles.in.f	= fit(x,y,'pchipinterp');
	end
	
	handles	= GUIUpdate(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function tp_ParameterInsertAfter(hObject,eventdata,handles)
	k	= get(handles.lstParameter,'Value');
	
	strFunction	= GetFunctionPopup(handles);
	
	switch strFunction
		case 'interp'
			x	= reshape(handles.out.f.p.breaks,[],1);
			y	= feval(handles.out.f,x);
			
			if k<numel(x)
				xNew	= mean(x(k:k+1));
				yNew	= feval(handles.out.f,xNew);
			elseif x(end)<1
				xNew	= (x(end)+1)/2;
				yNew	= feval(handles.out.f,xNew);
			else
				xNew	= x(end);
				yNew	= y(end);
				
				x(end)	= (x(end-1)+1)/2;
			end
			
			x	= [x(1:k-1); xNew; x(k:end)];
			y	= [y(1:k-1); yNew; y(k:end)];
			
			handles.in.f	= fit(x,y,'pchipinterp');
	end
	
	handles	= GUIUpdate(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function tp_ParameterDelete(hObject,eventdata,handles)
	k	= get(handles.lstParameter,'Value');
	
	strFunction	= GetFunctionPopup(handles);
	
	switch strFunction
		case 'interp'
			x	= reshape(handles.out.f.p.breaks,[],1);
			y	= feval(handles.out.f,x);
			
			x	= [x(1:k-1); x(k+1:end)];
			y	= [y(1:k-1); y(k+1:end)];
			
			handles.in.f	= fit(x,y,'pchipinterp');
	end
	
	handles	= GUIUpdate(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%



%------------------------------------------------------------------------------%
function butCancel_Callback(hObject, eventdata, handles)
	tp_closerequest(handles.figMain,eventdata,handles);
%------------------------------------------------------------------------------%
function butOK_Callback(hObject, eventdata, handles)
	handles.output	= handles.out.t;
	
	guidata(hObject,handles);
	
	tp_closerequest(handles.figMain,eventdata,handles);
%------------------------------------------------------------------------------%
function popFunction_Callback(hObject, eventdata, handles)
	strFunction	= GetFunctionPopup(handles);
	
	switch strFunction
		case 'interp'
			if handles.out.n==1
				handles.out.n	= 2;
				
				if handles.out.t>0.5
					handles.out.t	= [handles.out.t/2;1];
				else
					handles.out.t	= [0;2*handles.out.t];
				end
			end
			
			x	= reshape(GetInterval(0,1,handles.out.n),[],1);
			
			handles.in.f	= fit(x,handles.out.t,'pchipinterp');
			handles.in.p	= {};
			
			handles.in.t	= [];
		case 'custom'
			handles.in.t	= handles.out.t;
			
			handles.in.f	= [];
			handles.in.p	= {};
		otherwise
			p.linear	= {1;0};
			p.exp		= {1;1/(exp(1)-1);-1/(exp(1)-1)};
			p.poly		= {1;1};
	
			handles.in.t	= [];
			handles.in.f	= strFunction;
			handles.in.p	= p.(strFunction);
	end
	
	handles	= GUIUpdate(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function lstParameter_Callback(hObject, eventdata, handles)
	k		= get(hObject,'Value');
	if isempty(k)
		k	= 1;
		set(hObject,'Value',k);
	end
	
	handles	= SetParameterEdit(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtT_Callback(hObject, eventdata, handles)
	t	= str2num(get(hObject,'String'));
	
	tTest	= str2num(num2str(handles.out.t,handles.param.nDigit));
	
	if numel(t)~=numel(handles.out.t) || max(abs(tTest-t))>eps
		handles.in		= struct('t',t,'n',numel(t),'f',[],'p',{{}});
		
		handles	= GUIUpdate(handles);
	end
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtFunction_Callback(hObject, eventdata, handles)
	strFunction	= get(handles.edtFunction,'String');
	
	if isempty(strFunction)
		%user wants custom definition
			handles.in	= struct('t',handles.out.t,'n',numel(handles.out.t),'f',[],'p',{{}});
	else
		%get the number of parameters
			cP						= symvar(strFunction);
			cP(ismember(cP,'x'))	= [];
			nP						= numel(cP);
		%get the new inline function
			p	= repmat({1},[nP 1]);
			f	= inline(strFunction,nP);
			
			%rename parameters
				bK	= false(1,nP);
				r	= 'P(?<k>\d+)';
				%get the Pk parameters alrady specified
					for k=1:nP
						sK	= regexp(cP{k},r,'names');
						if ~isempty(sK)
							bK(str2num(sK.k))	= true;
						end
					end
				%rename parameters that don't match Pk
					for k=1:nP
						sK	= regexp(cP{k},r,'names');
						if isempty(sK) || str2num(sK.k)>nP
							kCur		= find(~bK,1,'first');
							pNew		= ['P' num2str(kCur)];
							f			= subs(f,cP{k},pNew);
							cP{k}		= pNew;
							bK(kCur)	= true;
						end
					end
			%transfer parameters if we previously had an inline
				if isa(handles.out.f,'inline')
					cPOld						= symvar(handles.out.f);
					cPOld(ismember(cPOld,'x'))	= [];
					nPOld						= numel(cPOld);
					
					for k=1:nPOld
						p(FindCell(cP,cPOld{k}))	= {handles.out.p{k}};
					end
				end
			%vectorize the function
				f	= vectorize(inline(char(f),nP));
		%test to see if the function is correctly formatted
			bGood	= false;
			try
				y		= feval(f,1,p{:});
				bGood	= true;
			catch
			end
		%update the function
			if bGood
				handles.in	= struct('t',[],'n',handles.out.n,'f',f,'p',{p});
			end
	end	
		
	
	handles	= GUIUpdate(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtParameter_Callback(hObject, eventdata, handles)
	kP	= get(handles.lstParameter,'Value');
	
	strFunction	= GetFunctionPopup(handles);
	
	switch strFunction
		case 'interp'
			strXY	= get(hObject,'String');
			
			%parse the (x,y) string
				r	= '\((?<x>[-.\d]+),(?<y>[-.\d]+)\)';
				xy	= regexp(strXY,r,'names');
				
			if ~isempty(xy)
				xNew	= str2num(xy.x);
				yNew	= str2num(xy.y);
				
				x		= reshape(handles.out.f.p.breaks,[],1);
				x(kP)	= xNew;
				
				y				= feval(handles.out.f,x);
				y(kP)			= yNew;
				
				handles.in.f	= fit(x,y,'pchipinterp');
			end
		otherwise
			v					= str2num(get(hObject,'String'));
			handles.in.p{kP}	= v;
	end
	
	handles				= GUIUpdate(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%
function edtN_Callback(hObject, eventdata, handles)
	n	= str2num(get(hObject,'String'));
	
	handles.in.n	= n;
	
	handles	= GUIUpdate(handles);
	
	guidata(hObject,handles);
%------------------------------------------------------------------------------%

%------------------------------------------------------------------------------%
function handles = ParseInputs(handles,v)
	nV	= numel(v);
	
	%was t passed?
		if nV==1 && numel(v{1})>1
			handles.orig	= struct('f',[],'p',{{}});
			handles.orig.t	= reshape(v{1},[],1);
			handles.orig.n	= numel(handles.orig.t);
			
			handles.in	= handles.orig;
	%n,f,p was passed
		else
			[n,f,p]	= ParseArgs(v,10,'linear');
			
			[t,fDummy,p]	= GetTParameter(n,f,p);
			
			handles.orig	= struct('t',[],'n',n,'f',f,'p',{p});
			handles.in		= handles.orig;
		end
%------------------------------------------------------------------------------%
function handles = GUIInit(handles)
	handles.output = [];
	
	%fill the function popup
		handles	= SetFunctionPopup(handles);
		
	%create the parameter list context menu
		handles	= SetParameterConextMenu(handles);
%------------------------------------------------------------------------------%
	function handles = SetFunctionPopup(handles,varargin)
		cTypes	= {'linear','exp','poly','interp','custom'};
		
		if numel(varargin)==0
			set(handles.popFunction,'String',char(cTypes));
		else
			k	= find(ismember(cTypes,varargin{1}));
			
			if isempty(k)
				error('TPicker:unrecognized_builtin_function',['''' handles.f.in ''' is not a recognized built-in function.']);
			end
			
			set(handles.popFunction,'Value',k);
		end
%------------------------------------------------------------------------------%
	function strFunction = GetFunctionPopup(handles)
		k			= get(handles.popFunction,'Value');
		cFunction	= cellstr(get(handles.popFunction,'String'));
		
		strFunction	= cFunction{k};
%------------------------------------------------------------------------------%
	function handles = SetFunctionEdit(handles,strFormula);
		if isempty(strFormula)
			set(handles.edtFunction,'String','');
			
			strFunction	= GetFunctionPopup(handles);
			
			switch strFunction
				case 'custom'
					set(handles.edtFunction,'Enable','on');
				otherwise
					set(handles.edtFunction,'Enable','off');
			end
		else
			set(handles.edtFunction,'String',strFormula);
			set(handles.edtFunction,'Enable','on');
		end
%------------------------------------------------------------------------------%
	function handles = SetParameterConextMenu(handles)
		%create the menu
			handles.mnu.parameter	= uicontextmenu('Parent',handles.figMain);
		
		%fill it
			handles.mnu.paramInsertBefore	= uimenu(handles.mnu.parameter,'Label','Insert Before','Callback','TPicker(''tp_ParameterInsertBefore'',gcbo,[],guidata(gcbo));');
			handles.mnu.paramInsertAfter	= uimenu(handles.mnu.parameter,'Label','Insert After','Callback','TPicker(''tp_ParameterInsertAfter'',gcbo,[],guidata(gcbo));');
			handles.mnu.paramDelete			= uimenu(handles.mnu.parameter,'Label','Delete','Callback','TPicker(''tp_ParameterDelete'',gcbo,[],guidata(gcbo));');			
%------------------------------------------------------------------------------%
function handles = GUIUpdate(handles)
	%update t
		handles	= TUpdate(handles);
		
	%update the function section
		if isa(handles.in.f,'char')
			handles	= SetFunctionPopup(handles,handles.in.f);
			handles	= SetFunctionEdit(handles,formula(handles.out.f));
		elseif isa(handles.out.f,'cfit') && isequal(formula(handles.out.f),'piecewise polynomial')
			handles	= SetFunctionPopup(handles,'interp');
			handles	= SetFunctionEdit(handles,[]);
		else
			handles	= SetFunctionPopup(handles,'custom');
			
			if ~isempty(handles.out.f)
				handles	= SetFunctionEdit(handles,formula(handles.out.f));
			else
				handles	= SetFunctionEdit(handles,[]);
			end
		end
		
	%update the parameters
		handles	= FillParameters(handles);
		
	%update t
		set(handles.edtT,'String',num2str(handles.out.t,handles.param.nDigit));
		
	%update the plot
		handles	= SetPlot(handles,handles.out.t);
		
	%n
		set(handles.edtN,'String',num2str(handles.out.n));
%------------------------------------------------------------------------------%
	function handles = TUpdate(handles)
		if ~isempty(handles.in.t)
			nT	= numel(handles.in.t);
			
			if ~isempty(handles.in.n) && handles.in.n~=nT
				n	= handles.in.n;
				
				handles.out		= struct('n',n,'f',[],'p',{{}});
				
				x				= reshape(GetInterval(0,1,nT),[],1);
				handles.out.f	= fit(x,handles.in.t,'pchipinterp');
				
				x				= reshape(GetInterval(0,1,n),[],1);
				
				handles.in.t	= [];
				handles.out.t	= feval(handles.out.f,x);
			else
				n	= numel(handles.in.t);
				
				handles.out		= struct('n',n,'f',[],'p',{{}});
				handles.out.t	= handles.in.t;
			end
		else
			[t,f,p]		= GetTParameter(handles.in.n,handles.in.f,handles.in.p);
			
			%were parameters added to make it fit?
				if numel(p)~=numel(handles.in.p)
					handles.in.f	= f;
					handles.in.p	= p;
				end
			
			handles.out	= struct('t',t,'n',handles.in.n,'f',f,'p',{p});
		end
		
		mnT	= min(handles.out.t);
		if mnT<0
			handles.out.t	= handles.out.t - mnT;
		end
		
		mxT	= max(handles.out.t);
		if mxT>1
			handles.out.t	= handles.out.t./mxT;
		end
%------------------------------------------------------------------------------%
	function handles = FillParameters(handles)
		%miscellaneous parameters
			handles.param.nDigit	= 10;
		
		%get the function parameters
			strFunction	= GetFunctionPopup(handles);
			if isequal(strFunction,'interp')
				x	= reshape(handles.out.f.p.breaks,[],1);
				t	= feval(handles.out.f,x);
				
				nP	= numel(t);
				p	= [repmat('(',[nP 1]) num2str(x,handles.param.nDigit) repmat(',',[nP 1]) num2str(t,handles.param.nDigit) repmat(')',[nP 1])];
				p	= cellstr(p);
			else
				p	= handles.out.p;
			end
		
		%set the parameter listbox
			nP	= numel(p);
			
			strPLbl	= [repmat('P',[nP 1]) num2str((1:nP)') repmat(': ',[nP 1])];
			strPVal	= num2str(cell2mat(p),handles.param.nDigit);
			strP	= [strPLbl strPVal];
			
			set(handles.lstParameter,'String',strP);
		%set the parameter edit box
			k		= get(handles.lstParameter,'Value');
			if isempty(k)
				k	= 1;
				set(handles.lstParameter,'Value',k);
			end
			
			handles	= SetParameterEdit(handles);
		%set the parameter context menu
			switch strFunction
				case 'interp'
					set(handles.lstParameter,'uicontextmenu',handles.mnu.parameter);
				otherwise
					set(handles.lstParameter,'uicontextmenu',[]);
			end
%------------------------------------------------------------------------------%
	function handles = SetParameterEdit(handles)
		k	= get(handles.lstParameter,'Value');
		
		strFunction	= GetFunctionPopup(handles);
		switch strFunction
			case 'interp'
				x	= handles.out.f.p.breaks(k);
				y	= feval(handles.out.f,x);
				
				p	= ['(' num2str(x,handles.param.nDigit) ',' num2str(y,handles.param.nDigit) ')'];
			otherwise
				if isempty(handles.out.p)
					p	= [];
				else
					p	= num2str(handles.out.p{k},handles.param.nDigit);
				end
		end
		
		if isempty(p)
			set(handles.txtParameter,'String','');
			set(handles.edtParameter,'String','');
			set(handles.edtParameter,'Enable','off');
		else
			strK	= ['P' num2str(k) ':'];
			
			set(handles.txtParameter,'String',strK);
			set(handles.edtParameter,'String',p);
			set(handles.edtParameter,'Enable','on');
		end
%------------------------------------------------------------------------------%
	function handles = SetPlot(handles,t)
		n	= numel(t);
		
		x	= GetInterval(0,1,n);
		
		plot(handles.axT,x,t,'-r','LineWidth',2);
		set(handles.axT,'XLim',[0 1]);
		set(handles.axT,'YLim',[0 1]);
		set(handles.axT,'XTick',0:0.1:1);
		set(handles.axT,'XGrid','on');
		set(handles.axT,'YTick',0:0.1:1);
		set(handles.axT,'YGrid','on');
%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%
function edtT_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
function popFunction_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
function edtFunction_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
function lstParameter_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
function edtParameter_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
function edtN_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%------------------------------------------------------------------------------%
