function fig = zoomgui
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

% CVS ID and authorship of this code
% CVSId = '$Id: zoomgui.m,v 1.3 2005/02/03 16:58:45 michelich Exp $';
% CVSRevision = '$Revision: 1.3 $';
% CVSDate = '$Date: 2005/02/03 16:58:45 $';
% CVSRCSFile = '$RCSfile: zoomgui.m,v $';

load zoomgui

h0 = figure('Units','points', ...
	'Color',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Interruptible','off', ...
	'KeyPressFcn','set(gcbf,''UserData'',''KeyPress'');', ...
	'MenuBar','none', ...
	'Name','Series Zoom Parameters', ...
	'NumberTitle','off', ...
	'PointerShapeCData',mat0, ...
	'Position',[333.75 172.5 187.5 165], ...
	'Resize','off', ...
	'Tag','GetZoomWin');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[28.5 14.25 47.25 17.25], ...
	'String','Cancel', ...
	'Style','frame', ...
	'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[45 67.5 22.5 15], ...
	'String','Size', ...
	'Style','text', ...
	'Tag','StaticText5');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[22.5 82.5 45 15], ...
	'String','Upper Left', ...
	'Style','text', ...
	'Tag','StaticText4');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[105 97.5 30 15], ...
	'String','Y', ...
	'Style','text', ...
	'Tag','StaticText3');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[75 97.5 30 15], ...
	'String','X', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[135 97.5 30 15], ...
	'String','Z', ...
	'Style','text', ...
	'Tag','ZString', ...
  'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'ListboxTop',0, ...
	'Position',[165 97.5 30 15], ...
	'String','t', ...
	'Style','text', ...
	'Tag','tString', ...
	'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'FontSize',10, ...
	'HorizontalAlignment','left', ...
	'ListboxTop',0, ...
	'Position',[15 120 165 30], ...
	'String','You may zoom in on this series by changing the following parameters:', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''XPos'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[75 82.5 30 15], ...
	'Style','edit', ...
	'Tag','XPos');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''YPos'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[105 82.5 30 15], ...
	'Style','edit', ...
	'Tag','YPos');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''ZPos'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[135 82.5 30 15], ...
	'Style','edit', ...
	'Tag','ZPos', ...
  'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''tPos'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[165 82.5 30 15], ...
	'Style','edit', ...
	'Tag','tPos', ...
	'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''XSize'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[75 67.5 30 15], ...
	'Style','edit', ...
	'Tag','XSize');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''YSize'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[105 67.5 30 15], ...
	'Style','edit', ...
	'Tag','YSize');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''ZSize'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[135 67.5 30 15], ...
	'Style','edit', ...
	'Tag','ZSize', ...
  'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','set(gcbf,''UserData'',''tSize'');', ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[165 67.5 30 15], ...
	'Style','edit', ...
	'Tag','tSize', ...
	'Visible','off');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
	'Callback','set(gcbf,''UserData'',''FullSize'');', ...
	'ListboxTop',0, ...
	'Position',[82.5 45 45 15], ...
	'String','Full Size', ...
	'Style','checkbox', ...
	'Tag','FullSizeCheckbox');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'Callback','set(gcbf,''UserData'',''OK'');', ...
	'FontWeight','bold', ...
	'ListboxTop',0, ...
	'Position',[30 15 45 15], ...
	'String','OK', ...
	'Tag','OKButton');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'Callback','set(gcbf,''UserData'',''Cancel'');', ...
	'ListboxTop',0, ...
	'Position',[112.5 15 45 15], ...
	'String','Cancel', ...
	'Tag','CancelButton');
if nargout > 0, fig = h0; end

% Modification History:
%
% $Log: zoomgui.m,v $
% Revision 1.3  2005/02/03 16:58:45  michelich
% Changes based on M-lint:
% Make unused CVS variables comments for increased efficiency.
% Remove unnecessary semicolon after function declarations.
% Remove unnecessary commas after try, catch, and else statements.
%
% Revision 1.2  2003/10/22 15:54:40  gadde
% Make some CVS info accessible through variables
%
% Revision 1.1  2002/08/27 22:24:27  michelich
% Initial CVS Import
%
