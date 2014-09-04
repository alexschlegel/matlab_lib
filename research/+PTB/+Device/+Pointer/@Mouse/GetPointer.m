function x = GetPointer(mou)
% PTB.Device.Pointer.Mouse.GetPointer
% 
% Description:	get some mouse info
% 
% Syntax:	x = GetPointer(mou)
% 
% Updated: 2012-11-26
% Copyright 2012 Alex Schlegel (schlegel@gmail.com).  This work is licensed
% under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported
% License.
x	= GetPointer@PTB.Device.Pointer(mou);

[px,py,but,focus,v,vInfo]	= GetMouse([],mou.deviceid);

x(mou.IDX_XPOS)	= (v(1)-vInfo(1).min)./(vInfo(1).max-vInfo(1).min);
x(mou.IDX_YPOS)	= (v(2)-vInfo(2).min)./(vInfo(2).max-vInfo(2).min);

x([mou.IDX_DRAW mou.IDX_MIDDLE mou.IDX_ERASE])		= but(1:3);
