function [indOut,depOut,expr,debug] = matEspressoGUI(indIn,depIn,varargin)
% Interactive demonstration of MATESPRESSO truth-table minimization.
%
% Interactive GUI for demonstrating MATESPRESSO truth-table minimization.
% UITABLEs allow interactive input of independent/dependet-variable values,
% which triggers updates of the output tables and boolean expression display.
%
%%% Syntax %%%
%
%   matEspressoGUI()
%   matEspressoGUI(indIn)
%   matEspressoGUI(indIn,depIn)
%   matEspressoGUI(indIn,depIn,<options>)
%   [indOut,depOut,expr,debug] = matEspressoGUI(...)
%
%% Input Arguments %%
%
% As per MATESPRESSO. Note that <indIn> and <depIn> must be numeric/table.
%
%% Output Arguments %%
%
% As per MATESPRESSO: <indOut>, <depOut>, <expr>, <debug>.
%
%% Dependencies %%
%
% * MATLAB R2019b or later.
% * matEspresso.m from <>
%
% See also MATESPRESSO VECESPRESSO
persistent uif uit uis uot uoe fgc ddm fgp
%% Input Wrangling %%
%
switch nargin
	case 0
		args = {[0,0,0;0,0,1;0,1,0;0,1,1;1,0,0;1,0,1;1,1,0;1,1,1],[0,0;0,1;0,1;1,0;0,1;1,0;1,0;1,1]};
		%args = {[0,0;0,1;1,0;1,1],[0;0;0;1]};
	case 1
		args = {indIn,ones(size(indIn,1),1)};
	otherwise
		args = {indIn,depIn};
end
%
args{1} = megArr2uint8('ind',args{1});
args{2} = megArr2uint8('dep',args{2});
%
% This does input checking, we get the normalized options structure:
[indOut,depOut,expr,debug] = matEspresso(nan(1,0),[],varargin{:});
%
opts = debug.options.user;
stpo = debug.options.used;
fnop = fieldnames(opts);
opts = rmfield(opts,fnop(strcmpi(fnop,'Eout')));
opts.Eout = stpo.Eout;
%
if isempty(uif) || ~ishghandle(uif)
	[uif,uit,uis,uot,uoe,ddm] = megNewFig(opts,@megTableClBk,@megSpinClBk,@megUpDate);
	fgc = uoe.FontColor;
	fgp = get(uif, 'Pointer');
end
%
set(uis,{'Value'},{size(args{1},1);size(args{1},2);size(args{2},2)})
%
megUpDate()
%
%% Callback Functions %%
%
	function megTableClBk(src,evt,idx)
		idr = evt.Indices(1);
		idc = evt.Indices(2);
		tmp = char(src.Data{idr,idc});
		switch tmp
			case '-'
				one = 2;
			case '~'
				one = 5;
			otherwise
				one = str2double(tmp);
		end
		if istable(args{idx})
			args{idx}{idr,idc} = one;
		else % numeric
			args{idx}(idr,idc) = one;
		end
		megUpDate()
	end
%
	function megSpinClBk(src,~)
		switch src.Tag
			case 'rows'
				args{1}(src.Value+1:end,:) = [];
				args{2}(src.Value+1:end,:) = [];
				args{1}(end+1:src.Value,:) = 2;
				args{2}(end+1:src.Value,:) = 2;
			case 'indC'
				args{1}(:,src.Value+1:end) = [];
				args{1}(:,end+1:src.Value) = 2;
			case 'depC'
				args{2}(:,src.Value+1:end) = [];
				args{2}(:,end+1:src.Value) = 2;
			otherwise
				error('SC:matEspressoGUI:UnknownSpinnerTag',...
					'Please report this error: unknown spinner tag.')
		end
		megUpDate()
	end
%
	function megUpDate(~,~)
		msg = '';
		uif.Pointer = 'watch';
		opts.Eout = ddm.Value;
		drawnow()
		try
			[indOut,depOut,expr,debug] = matEspresso(args{1},args{2},opts);
		catch ME
			if startsWith(ME.identifier,'SC:matEspresso:')
				msg = ME.message;
			else
				rethrow(ME)
			end
		end
		uif.Pointer = fgp;
		if numel(msg)
			uoe.FontColor = [1,0,0];
			uoe.Value = msg;
			return
		end
		%
		uoe.FontColor = fgc;
		uoe.Value = expr;
		%
		iOM = debug.raw.indOut;
		dOM = debug.raw.depOut;
		iIM = debug.raw.indIn;
		dIM = debug.raw.depIn;
		%
		iOut = megMat2Table(2, debug.options.used.indNames, iOM);
		dOut = megMat2Table(5, debug.options.used.depNames, dOM);
		iInp = megMat2Table(2, debug.options.used.indNames, iIM);
		dInp = megMat2Table(5, debug.options.used.depNames, dIM);
		%
		set([uit,uot],{'Data'},{iInp;dInp;iOut;dOut})
		%
		if (fgc*[0.298936;0.587043;0.114021])<0.54 % lightmode
			rSty = uistyle('BackgroundColor',[0.95,0.85,0.85]);
			fSty = uistyle('BackgroundColor',[0.85,0.95,0.85]);
			dSty = uistyle('BackgroundColor',[0.95,0.95,0.80]);
		else % darkmode
			rSty = uistyle('BackgroundColor',[0.25,0.15,0.15]);
			fSty = uistyle('BackgroundColor',[0.15,0.25,0.15]);
			dSty = uistyle('BackgroundColor',[0.25,0.25,0.12]);
		end
		%
		uiC = {uit(1),uit(2),uot(1),uot(2)};
		xxM = {   iIM,   dIM,   iOM,   dOM};
		for kk = 1:4
			removeStyle(uiC{kk})
			megGuiStyle(uiC{kk},rSty,xxM{kk}==0)
			megGuiStyle(uiC{kk},fSty,xxM{kk}==1)
			megGuiStyle(uiC{kk},dSty,xxM{kk}==2)
		end
		drawnow()
	end
%
if nargout
	waitfor(uif)
else
	clear indOut
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%matEspressoGUI
function out = megArr2uint8(pfx,arr)
% Convert from numeric/logical to UINT8. Applies to array or table columns.
if isnumeric(arr)||islogical(arr)
	out = uint8(arr);
elseif istable(arr)
	assert(all(varfun(@(x)isnumeric(x)||islogical(x), arr, 'OutputFormat','uniform')),...
		sprintf('SC:matEspressoGUI:%sIn:ColumnNotNumericNorLogical',pfx),...
		'Table variable has wrong type.\nAll variables of table <%sIn> must be numeric or logical',pfx);
	out = table2array(varfun(@uint8, arr, 'OutputFormat','table'));
else
	error(sprintf('SC:matEspressoGUI:%sIn:NotNumericNorTable',pfx),...
		'Input <%sIn> must be numeric, logical, or table type.',pfx)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%megArr2uint8
function megGuiStyle(obj,style,idx)
if any(idx(:))
	[rx,cx] = find(idx);
	addStyle(obj,style,'cell',[rx(:),cx(:)]);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%megGuiStyle
function tbl = megMat2Table(mxi,vnm,mat)
scs = {'0','1','-','0','1','~'};
tmp = categorical(mat, 0:mxi, scs(1:1+mxi), 'Protected',true);
tbl = array2table(tmp,'VariableNames',vnm);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%megMat2Table
function [uif,uit,uis,uot,uoe,ddm] = megNewFig(stpo,tblClBk,spnClBk,ddmClBk)
% Create the GUI figure and all components
%
uif = uifigure();
uif.Name = 'Interactive Truth-Table Minimization Demo';
uif.Tag = mfilename;
uif.HandleVisibility = 'off';
uif.IntegerHandle = 'off';
%
uig = uigridlayout(uif, [6,6]);
uig.RowHeight = {'fit','1x','fit','fit','fit','fit'};
uig.ColumnWidth = {'3x','3x','3x','2x','2x','2x'};
%
uit = gobjects(1,2);
uis = gobjects(1,3);
uot = gobjects(1,2);
%
%%% Input Tables
%
tmp = uilabel(uig);
tmp.Text = 'indIn';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 1;
tmp.Layout.Column = [1,2];
%
uit(1) = uitable(uig);
uit(1).Tag = 'indIn';
uit(1).ColumnWidth = 'fit';
uit(1).ColumnEditable = true;
uit(1).CellEditCallback = {tblClBk,1};
uit(1).Layout.Row = [2,4];
uit(1).Layout.Column = [1,2];
uit(1).Tooltip = 'Independent variables';
%
tmp = uilabel(uig);
tmp.Text = 'depIn';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 1;
tmp.Layout.Column = 3;
%
uit(2) = uitable(uig);
uit(2).Tag = 'depIn';
uit(2).ColumnWidth = 'fit';
uit(2).ColumnEditable = true;
uit(2).CellEditCallback = {tblClBk,2};
uit(2).Layout.Row = [2,4];
uit(2).Layout.Column = 3;
uit(2).Tooltip = 'Dependent variables';
%
%%% Input Spinners
%
tmp = uilabel(uig);
tmp.Text = 'Rows';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 5;
tmp.Layout.Column = 2;
%
tmp = uilabel(uig);
tmp.Text = 'Columns (indIn)';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 5;
tmp.Layout.Column = 1;
%
tmp = uilabel(uig);
tmp.Text = 'Columns (depIn)';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 5;
tmp.Layout.Column = 3;
%
uis(1) = uispinner(uig);
uis(1).Tag = 'rows';
uis(1).Value = 1;
uis(1).Limits = [1,Inf];
uis(1).Step = 1;
uis(1).ValueChangedFcn = spnClBk;
uis(1).Layout.Row = 6;
uis(1).Layout.Column = 2;
uis(1).Tooltip = 'Number of rows for indIn & depIn';
%
uis(2) = uispinner(uig);
uis(2).Tag = 'indC';
uis(2).Value = 1;
uis(2).Limits = [1,Inf];
uis(2).Step = 1;
uis(2).ValueChangedFcn = spnClBk;
uis(2).Layout.Row = 6;
uis(2).Layout.Column = 1;
uis(2).Tooltip = 'Number of columns for indIn';
%
uis(3) = uispinner(uig);
uis(3).Tag = 'depC';
uis(3).Value = 1;
uis(3).Limits = [1,Inf];
uis(3).Step = 1;
uis(3).ValueChangedFcn = spnClBk;
uis(3).Layout.Row = 6;
uis(3).Layout.Column = 3;
uis(3).Tooltip = 'Number of columns for depIn';
%
%%% Output Tables
%
tmp = uilabel(uig);
tmp.Text = 'indOut';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 1;
tmp.Layout.Column = [4,5];
%
uot(1) = uitable(uig);
uot(1).Tag = 'indOut';
uot(1).ColumnWidth = 'fit';
uot(1).ColumnEditable = false;
uot(1).Layout.Row = 2;
uot(1).Layout.Column = [4,5];
uot(1).Tooltip = 'Minimized independent variables';
%
tmp = uilabel(uig);
tmp.Text = 'depOut';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 1;
tmp.Layout.Column = 6;
%
uot(2) = uitable(uig);
uot(2).Tag = 'depOut';
uot(2).ColumnWidth = 'fit';
uot(2).ColumnEditable = false;
uot(2).Layout.Row = 2;
uot(2).Layout.Column = 6;
uot(2).Tooltip = 'Minimized dependent variables';
%
%%% Expression text area
%
tmp = uilabel(uig);
tmp.Text = 'Expression';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 3;
tmp.Layout.Column = [4,6];
%
uoe = uitextarea(uig);
uoe.Layout.Row = 4;
uoe.Layout.Column = [4,6];
uoe.Editable = false;
uoe.WordWrap = 'on';
uoe.Tooltip = 'Minimized boolean expressions in MATLAB syntax';
%
%%% Output Sets
%
tmp = uilabel(uig);
tmp.Text = 'Output Set (depOut)';
tmp.HorizontalAlignment = 'center';
tmp.Layout.Row = 5;
tmp.Layout.Column = [4,6];
%
fdr = {'f', 'd', 'r', 'fd', 'fr', 'dr', 'fdr'};
ddm = uidropdown(uig);
ddm.Items = megItemsData(fdr);
ddm.ItemsData = fdr;
ddm.ValueIndex = find(strcmpi(stpo.Eout,fdr));
ddm.Layout.Row = 6;
ddm.Layout.Column = [4,6];
ddm.Tooltip = 'Select which cases to return from Espresso';
ddm.ValueChangedFcn = ddmClBk;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%megNewFig
function out = megItemsData(fdr)
rpl = {'TRUE(1)','DC(-)','FALSE(0)'};
fnh = @(v)join(rpl(interp1(+'fdr',1:3,+v)),' + ');
out = strcat(cellfun(fnh,fdr),' cases');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%megItemsData
% Copyright (c) 2023-2026 Stephen Cobeldick
%
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%license