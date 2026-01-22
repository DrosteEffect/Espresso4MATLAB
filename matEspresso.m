function [indOut,depOut,expr,debug] = matEspresso(indIn,depIn,opts,varargin)
% MATLAB wrapper of the Espresso executable for Boolean truth-table minimization.
%
% matEspresso minimizes Boolean functions using the Espresso heuristic
% logic minimizer. Provides a MATLAB-native interface for truth table
% minimization over the independent-variables and dependent-variables.
% Espresso is available here: <https://github.com/Gigantua/Espresso>
%
%%% Syntax %%%
%
%   matEspresso(indIn)
%   matEspresso(indIn,depIn)
%   matEspresso(indIn,depIn,<options>)
%   [indOut,depOut,expr,debug] = matEspresso(...)
%
% When called with one argument, indIn is interpreted as the true cases
% for a single dependent-variable - each listed row represents a true case,
% any other (not provided) row combinations are implicitly false cases.
%
% When called with two arguments, indIn contains all independent-
% variables and depIn contains all dependent-variables for the truth table.
%
%% Terminology %%
%
% To avoid confusing conflicts with existing MATLAB terminology we define:
% * "independent-variable" aka input, variable, argument, premise, predicate, condition, domain variable, input signal, etc.
% * "dependent-variable" aka output, function, function value, consequent, result, response, target variable, output signal, etc.
%
%% Options %%
%
% The options may be supplied either
% 1) in a scalar structure, or
% 2) as a comma-separated list of name-value pairs.
%
% Field names are case-insensitive. Text values preserve their case.
% The following options are supported (**=default value):
%
% Field    | Permitted | Description
% Name:    | Values:   | (cmd -EspressoCommand)
% ---------|-----------|--------------------------------------------------------
% exePath  | []**      | Path to the Espresso executable, char vector or
%          | path text | string scalar (automagic detection if empty).
% ---------|-----------|--------------------------------------------------------
% indNames | []**      | independent-variable names, must have one element for
%          | See Note0 | each column of <indIn> (automagic names if empty).
% ---------|-----------|--------------------------------------------------------
% depNames | []**      | dependent-variable names, must have one element for
%          | See Note0 | each column of <depIn> (automagic names if empty).
% ---------|-----------|--------------------------------------------------------
% outCats  | See Note0 | Three category names corresponding to false, true, DC.
%          |           | By default these are {'off','on','DC'}.
% ---------|-----------|--------------------------------------------------------
% rmTemp   | false     | Leaves the temp .PLA file (faster, OS/user must delete).
%          | true**    | Deletes the temp .PLA file (slower).
% ---------|-----------|--------------------------------------------------------
% simplify | false**   | Return Espresso's sum-of-products <expr> directly.
%          | true      | Return <expr> after symbolic simplification
%          |           | (requires the Symbolic Math Toolbox).
% ---------|-----------|--------------------------------------------------------
% Dcheck   | false**   | No consistency check.
%          | true      | Use -Dcheck command for consistency checking.
% ---------|-----------|--------------------------------------------------------
% Dexact   | false**   | Use heuristic minimization (faster).
%          | true      | Use exact minimization (cmd -Dexact, slower but optimal).
% ---------|-----------|--------------------------------------------------------
% Dopo     | false**   | Disable phase assignment optimization.
%          | true      | Enable phase assignment optimization (cmd -Dopo).
% ---------|-----------|--------------------------------------------------------
% Dpair    | false**   | Disable pair minimization.
%          | true      | Enable pair minimization (cmd -Dpair).
% ---------|-----------|--------------------------------------------------------
% Efast    | false**   | Use normal speed.
%          | true      | Use fast mode (cmd -efast, conflicts with Dexact=true).
% ---------|-----------|--------------------------------------------------------
% Eout     | 'f'**     | Output set (cmd -o): 'f' (true-set), 'd' (DC-set),
%          | 'd', 'fr',| 'r' (false-set), or any combination in that order.
%          | 'fdr', etc| Controls which covering patterns are returned.
% ---------|-----------|--------------------------------------------------------
%
% Note0: these may be string array or cell array of char vectors or char matrix.
%
%% Examples %%
%
%   % Minimize one dependent-variable with three independent-variables:
%   >> indIn = [0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1];
%   >> [indOut,depOut,expr] = matEspresso(indIn)
%   indOut =
%         1     2     2
%         2     1     2
%   depOut =
%         1
%         1
%   expr =
%        'Z = A | B'
%
%   % Minimize two dependent-variables with two independent-variables:
%   >> indIn = [0 0; 0 1; 1 0; 1 1];
%   >> depIn = [0 0; 0 1; 1 0; 1 1];
%   >> [indOut,depOut,expr] = matEspresso(indIn, depIn, 'depNames',{'hello','world'})
%   indOut =
%         1     2
%         2     1
%   depOut =
%         1     0
%         0     1
%   expr =
%        'hello = A
%         world = B'
%
%   % Simplify/factorize one dependent-variable with three independent-variables:
%   >> indIn = [1 1 0; 1 0 1; 0 1 1];
%   >> [~,~,expr] = matEspresso(indIn)
%   expr =
%        'Z = (A & B & ~C) | (A & ~B & C) | (~A & B & C)'
%   >> [~,~,expr] = matEspresso(indIn, 'simplify',true)
%   expr =
%        'Z = A & (~B | ~C) & (B | C) | ~A & B & C'
%
%% Input Arguments %%
%
%   indIn = Matrix (numeric/logical/categorical/char) or table (numeric
%           columns/variables only) with independent-variable data.
%           Values must be: 0/false/off/no, 1/true/on/yes, 2/DC/-/? (don't-care).
%   depIn = Matrix (numeric/logical/categorical/char) or table (numeric
%           columns/variables only) with dependent-variable data.
%           Values must be: 0/false/off/no, 1/true/on/yes, 2/DC/-/? (don't-care).
%           3 is an alias for 0, 4 is an alias for 1, 5/~ is ignored.
%           If omitted or [] then <depIn> implicitly consists of 1's only.
%   options = ScalarStructure or name-value optional arguments as per the
%           table shown in the Options section above.
%
%% Output Arguments %%
%
%   indOut = Matrix (uint8/categorical/char) or table (uint8 variables)
%            of simplified patterns over the independent-variables.
%            Each row is a covering pattern with values 0/false, 1/true, 2/DC/-.
%   depOut = Matrix (uitn8/categorical/char) or table (uint8 variables)
%            showing which patterns cover which dependent-variables.
%            Each row is a covering pattern with values 0/false, 1/true, 2/DC/-.
%   expr   = CharacterVector containing minimal Boolean expressions, one
%            per dependent-variable, separated by newlines. Uses MATLAB
%            syntax (~, &, |) with parenthesized product terms.
%   debug  = ScalarStruct containing detailed information about the run,
%            including timing, raw PLA data, statistics, and options used.
%
%% Dependencies %%
%
% * MATLAB R2009b or later.
% * Symbolic Math Toolbox iff using the <simplify> option.
% * Espresso executable is on the MATLAB search path, or on the
%   system PATH, or its location is specified via <exePath> option.
% * TempFileCleanup.m from <>
%
% See also MATESPRESSOGUI VECESPRESSO TEMPFILECLEANUP SIMPLIFY SYSTEM
tFun = tic();
%% Input Wrangling %%
%
% Set up default options
otyp = 'uint8';
stpo = struct('rmTemp',true,... delete .PLA file saved in TEMPDIR
	'Dcheck',false, 'Dexact',false, 'Dopo',false, 'Dpair',false,... debug
	'Efast',false, 'Eout','f', 'indNames',{{}}, 'depNames',{{}}, ...
	'exePath',[], 'outCats',{{'off','on','DC'}}, 'simplify',false);
%
switch nargin
	case 0 % We need something to work with!
		error('SC:matEspresso:TooFewInputs','At least one input argument is required.')
	case 1 % dependent-variables not provided
		depIn = [];
		opts = struct();
	case 2 % nothing to do
		opts = struct();
	case 3 % options in a struct
		opts = structfun(@meNs2c,opts,'UniformOutput',false);
		stpo = meOptions(stpo,opts);
	otherwise % options as <name-value> pairs
		temp = cellfun(@meNs2c,[{opts},varargin],'UniformOutput',false);
		opts = cell2struct(temp(2:2:end),temp(1:2:end),2);
		stpo = meOptions(stpo,opts);
end
%
assert(nnz([stpo.Dexact,stpo.Efast])<2,...
	'SC:matEspresso:BothDexactAndEfast',...
	'Options <Dexact> and <Efast> cannot both be true.');
%
if isa(indIn,'categorical')
	otyp = 'cat';
	indIn = meCategorical2Matrix('ind',indIn,false);
elseif isa(indIn,'table')
	otyp = 'tbl';
	[indIn,stpo.indNames] = meTable2Matrix('ind',indIn,stpo.indNames);
elseif ischar(indIn)
	otyp = 'char';
	assert(all(ismember(indIn(:),'012-?')),...
		'SC:matEspresso:indIn:InvalidCharacters',...
		'Input <indIn> must only contain ''0'', ''1'', ''2'', ''-'', and ''?'' characters.')
	indIn = uint8(indIn)-uint8('0');
	indIn(~ismember(indIn,0:2)) = 2;
end
%
if isa(depIn,'categorical')
	otyp = 'cat';
	depIn = meCategorical2Matrix('dep',depIn,true);
elseif isa(depIn,'table')
	otyp = 'tbl';
	[depIn,stpo.depNames] = meTable2Matrix('dep',depIn,stpo.depNames);
elseif ischar(depIn)
	otyp = 'char';
	assert(all(ismember(depIn(:),'012345-?~')),...
		'SC:matEspresso:depIn:InvalidCharacters',...
		'Input <depIn> must only contain ''0'', ''1'', ''2'', ''3'', ''4'', ''5'', ''~'', ''-'', and ''?'' characters.')
	depIn(depIn=='~') = '5';
	depIn = uint8(depIn)-uint8('0');
	depIn(~ismember(depIn,0:5)) = 2;
elseif isnumeric(depIn) && isequal(depIn,[])
	depIn = ones(size(indIn,1),1,'uint8');
end
%
assert(size(indIn,1)>0,...
	'SC:matEspresso:indIn:EmptyMatrix',...
	'Input <indIn> must contain at least one row.');
assert(size(indIn,1)==size(depIn,1),...
	'SC:matEspresso:RowCountMismatch',...
	'Inputs <indIn> and <depIn> must have the same number of rows.')
%
indIn = meMatrix2uint8('ind',indIn,2);
depIn = meMatrix2uint8('dep',depIn,5);
%
depIn(depIn==3) = 0; % Espresso alias 3->0
depIn(depIn==4) = 1; % Espresso alias 4->1
%
indCnt = size(indIn,2);
depCnt = size(depIn,2);
%
stpo = meMakeNames(stpo, indCnt, depCnt);
%
stpo.Eout = lower(stpo.Eout);
assert(isequal(1,regexp(stpo.Eout,'^f?d?r?$','once')),...
	'SC:matEspresso:Eout:InvalidOrderOrCharacters',...
	['The option <Eout> must be a string scalar or character vector.'...
	'\nIt must contain any of ''f'', ''d'', ''r'', in that order.'])
oCmd = sprintf('-o %s',stpo.Eout);
%
debug.options.user = opts;
debug.options.used = stpo;
%
%% PLA File %%
%
fnm = [tempname(),'.pla'];
[fid,msg] = fopen(fnm,'wt');
assert(fid>2,'SC:matEspresso:fopen:message','%s',msg)
%
if stpo.rmTemp
	obj = TempFileCleanup(fid,fnm,recycle()); %#ok<NASGU>
	recycle off
end
%
% Generate input PLA format string:
indChars = char(indIn+'0');
depChars = char(depIn+'0');
depChars(depIn==5) = '~';
%
fprintf(fid,'.i %d\n', size(indIn,2));
fprintf(fid,'.o %d\n', size(depIn,2));
fprintf(fid,'.ilb%s\n',sprintf(' %s',stpo.indNames{:}));
fprintf(fid, '.ob%s\n',sprintf(' %s',stpo.depNames{:}));
mPrintf(fid,'.p %d\n','1',indChars,depChars); % ON
mPrintf(fid,'.d %d\n','2',indChars,depChars); % DC
mPrintf(fid,'.r %d\n','0',indChars,depChars); % OFF
fprintf(fid,'.e');
%
fclose(fid);
%
%% Espresso Execution %%
%
rawOpt = {oCmd,   '-Dcheck',  '-Dexact',  '-Dopo',  '-Dpair',  '-efast'};
idxOpt = [true,stpo.Dcheck,stpo.Dexact,stpo.Dopo,stpo.Dpair,stpo.Efast];
useOpt = sprintf(' %s',rawOpt{idxOpt});
exPath = meFindEspresso(stpo.exePath);
espCmd = sprintf('"%s" %s < "%s"', exPath, useOpt, fnm);
exTime = tic();
%
[status,result] = system(espCmd);
%
debug.time.Espresso = toc(exTime);
debug.system.tempPLA = fnm;
debug.system.command = espCmd;
debug.system.status = status;
debug.system.result = result;
%
switch status
	case -1 % System error (rare):
		error('SC:matEspresso:system:SystemError',...
			'System call to Espresso failed (status -1). Check system resources.');
	case 0 % No error but empty result:
		assert(numel(result)>0,...
			'SC:matEspresso:system:EmptyResult',...
			'Espresso executed successfully but returned no output.')
	case 1 % General error:
		error('SC:matEspresso:system:GeneralError',...
			'Espresso input/logic error (status 1): %s', strtrim(result));
	case 2 % File not found, permission denied, or bad arguments
		error('SC:matEspresso:system:FileAccessError',...
			'Espresso file access error (status 2). Check file permissions and arguments.');
	case 9 % Process killed/interrupted (SIGKILL on Unix, Ctrl+C)
		error('SC:matEspresso:system:ProcessKilled',...
			'Espresso process was interrupted or killed (status 9).');
	case 126 % Command found but not executable (Unix permissions)
		error('SC:matEspresso:system:FileNotExecutable',...
			'Espresso found but not executable (status 126). Check file permissions.');
	case 127 % Command not found (Unix/Linux/macOS)
		error('SC:matEspresso:system:CommandNotFound',...
			'Espresso executable not found (status 127). Check PATH and installation.');
	case 128 % Invalid exit argument or out of range
		error('SC:matEspresso:system:InvalidExitArgument',...
			'Espresso returned invalid exit code (status 128).');
	case 130 % Process terminated by SIGINT (Ctrl+C on Unix)
		error('SC:matEspresso:system:ProcessInterrupted',...
			'Espresso was interrupted by user (status 130).');
	case 137 % Process killed by SIGKILL (out of memory, etc.)
		error('SC:matEspresso:system:KilledByMemory',...
			'Espresso was killed, possibly due to memory issues (status 137).');
	case 139 % Segmentation fault (SIGSEGV)
		error('SC:matEspresso:system:SegmentationFault',...
			'Espresso crashed with segmentation fault (status 139). Possible bug or corrupted data.');
	otherwise % Any other non-zero status
		error('SC:matEspresso:system:UnknownError',...
			'Espresso failed with unknown status %d: %s',status,strtrim(result));
end
%
%% Parse Results %%
%
allRows = regexp(result,'[\n\r]+','split');
booRows = regexp(allRows,'^[-012?]+\s+[-~012345]+$','match','once');
idyRows = cellfun('isempty',booRows);
if all(idyRows)
	indOut = zeros(0,indCnt,'uint8');
	depOut = zeros(0,depCnt,'uint8');
else
	booChar = vertcat(booRows{~idyRows});
	booData = uint8(booChar)-uint8('0');
	booData(booChar=='-') = 2;
	booData(booChar=='~') = 5;
	%
	indOut = booData(:,1:indCnt);
	depOut = booData(:,end-depCnt+1:end);
end
%
debug.raw.indIn = indIn;
debug.raw.depIn = depIn;
debug.raw.indOut = indOut;
debug.raw.depOut = depOut;
%
if nargout>2
	expr = meMakeExpr(indOut, depOut, stpo.indNames, stpo.depNames);
	if stpo.simplify
		expr = meSymSimpler(expr, stpo.indNames);
	end
end
%
switch otyp
	case 'cat'
		stpo.outCats{4} = 'ignored';
		indOut = categorical(indOut,[0:2,5],stpo.outCats, 'Protected',true);
		depOut = categorical(depOut,[0:2,5],stpo.outCats, 'Protected',true);
	case 'tbl'
		indOut = array2table(indOut, 'VariableNames',stpo.indNames);
		depOut = array2table(depOut, 'VariableNames',stpo.depNames);
	case 'char'
		indOut = char('0'+indOut); indOut(~ismember(indOut,'01')) = '-';
		depOut = char('0'+depOut); depOut(~ismember(depOut,'01')) = '-';
end
%
if depCnt>1 && nargout<2
	warning('SC:matEspresso:depOut:MultipleDependentYetSingleOutput',...
		'Multiple dependent-variables detected (%d) but only one output requested.\nReturning only <indOut>. Request two outputs to also obtain <depOut>.',depCnt);
end
%
debug.time.(mfilename) = toc(tFun);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%matEspresso
function arr = meNs2c(arr)
% If string scalar then extract the character vector,
% If string array then convert to cell array of char vectors,
% Otherwise data is unchanged.
if isa(arr,'string')
	if isscalar(arr)
		arr = arr{1};
	else
		arr = cellstr(arr);
	end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meNs2c
function mPrintf(fid,fmt,one,indC,depC)
idx = any(depC==one,2);
if any(idx)
	fprintf(fid,fmt,nnz(idx));
	for k = reshape(find(idx),1,[])
		fprintf(fid,'%s %s\n',indC(k,:),depC(k,:));
	end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mePrint
function out = meCategorical2Matrix(pfx,inp,isx)
two = {'2','-','?','dc','dontcare','maybe'};
c01 = {'0','off','no','false','1','on','yes','true','3','4','5','~'};
v01 = [  0,    0,   0,      0,  1,   1,    1,     1,  3,  4,  5,  5];
idx = v01<=(1+9*isx);
cci = categories(inp);
txt = sprintf(', %s',c01{idx},two{:});
assert(all(ismember(lower(cci),[c01(idx),two])),...
	sprintf('SC:matEspresso:%sIn:UnsupportedCategory',pfx),...
	'Input <%sIn> must contain only supported categories:\n%s',pfx,txt(2:end))
out = 1+ones(size(inp),'uint8');
for kk = 1:numel(cci)
	[~,vdx] = ismember(lower(cci{kk}),c01);
	if vdx
		odx = cci{kk}==inp;
		out(odx) = v01(vdx);
	end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meCategorical2Matrix
function [out,tvn] = meTable2Matrix(pfx,tbl,tvn)
% Extract variable names, check variable size & type, convert to matrix.
pvn = tbl.Properties.VariableNames;
if isempty(tvn)
	tvn = cellstr(pvn);
end
assert(numel(tvn)==numel(pvn),...
	sprintf('SC:matEspresso:%sNames:WrongLength',pfx),...
	'Names array has wrong length.\nOption <%sNames> must have one name for each column of <%sIn>.',pfx,pfx)
assert(all(varfun(@iscolumn, tbl, 'OutputFormat','uniform')),...
	sprintf('SC:matEspresso:%sIn:TableVariableNotColumn',pfx),...
	'Table variable has wrong size.\nAll variables of table <%sIn> must be column vectors.',pfx);
assert(all(varfun(@(x)isnumeric(x)||islogical(x), tbl, 'OutputFormat','uniform')),...
	sprintf('SC:matEspresso:%sIn:ColumnNotNumericNorLogical',pfx),...
	'Table variable has wrong type.\nAll variables of table <%sIn> must be numeric or logical',pfx);
out = table2array(varfun(@uint8, tbl, 'OutputFormat','table'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meTable2Matrix
function out = meMatrix2uint8(pfx,arr,mxv)
% Convert from numeric/logical matrix to UINT8 matrix.
assert(ndims(arr)<3,...
	sprintf('SC:matEspresso:%sIn:NotMatrix',pfx),...
	'Input <%sIn> must be a matrix or a table.',pfx) %#ok<ISMAT>
assert(isnumeric(arr)||islogical(arr),...
	sprintf('SC:matEspresso:%sIn:NotNumericNorLogical',pfx),...
	'Input <%sIn> must be numeric or logical type.',pfx)
assert(all(ismember(arr(:),0:mxv)),...
	sprintf('SC:matEspresso:%sIn:InvalidValues',pfx),...
	'Input <%sIn> must contain only values from 0 to %d.',pfx,mxv)
out = uint8(arr);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meMatrix2uint8
function stpo = meOptions(stpo,opts)
% Options check: only supported fieldnames with suitable option values.
%
dfc = fieldnames(stpo);
ofc = fieldnames(opts);
%
for k = 1:numel(ofc)
	ofn = ofc{k};
	dix = strcmpi(ofn,dfc);
	oix = strcmpi(ofn,ofc);
	if ~any(dix)
		dfs = sort(dfc);
		ont = sprintf(', <%s>',dfs{:});
		error('SC:matEspresso:options:UnknownOptionName',...
			'Unknown option: <%s>.\nOptions are:%s.',ofn,ont(2:end))
	elseif nnz(oix)>1
		dnt = sprintf(', <%s>',ofc{oix});
		error('SC:matEspresso:options:DuplicateOptionNames',...
			'Duplicate option names:%s.',dnt(2:end))
	end
	arg = opts.(ofn);
	dfn = dfc{dix};
	switch dfn
		case {'Dcheck','Dexact','Dopo','Dpair','Efast','simplify','rmTemp'}
			meLogical()
		case 'Eout'
			meCharVec()
		case 'exePath'
			meCharVec()
		case {'indNames','depNames'}
			meCellStr()
		case 'outCats'
			meCellStr()
			assert(numel(arg)==3,...
				'SC:matEspresso:outCats:NotThreeCategories',...
				'Please provide three category names corresponding to [false,true,don''t-care].')
		otherwise
			error('SC:matEspresso:options:MissingCase','Please report this bug.')
	end
	stpo.(dfn) = arg;
end
%
%% Nested Functions %%
%
	function meLogical()
		assert(isequal(arg,0)||isequal(arg,1),...
			sprintf('SC:matEspresso:%s:NotScalarLogical',dfn),...
			'The <%s> value must be a scalar logical.',dfn)
		arg = logical(arg);
	end
	function meCharVec()
		if isnumeric(arg)&&isequal(arg,[])
			arg = [];
		else
			assert(ischar(arg)&&(ndims(arg)<3)&&(size(arg,1)<2),...
				sprintf('SC:matEspresso:%s:NotCharVectorNorStringScalar',dfn),...
				'Option <%s> must be a character vector or string scalar.',dfn); %#ok<ISMAT>
		end
	end
	function meCellStr()
		assert(ndims(arg)<3,...
			sprintf('SC:matEspresso:%s:TooManyDimensions',dfn),...
			'Option <%s> must be a matrix or vector.',dfn); %#ok<ISMAT>
		if isnumeric(arg)&&isequal(arg,[])
			arg = {};
		elseif ischar(arg)
			arg = strtrim(cellstr(arg));
		else
			arg = cellstr(arg(:));
		end
		arg = reshape(arg,1,[]);
	end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meOptions
function stpo = meMakeNames(stpo,indCnt,depCnt)
% Default name generator. Either letters A..Z or numbered X1,X2,..&F1,F2,..
used = [stpo.indNames(:);stpo.depNames(:)];
assert(numel(unique(used))==numel(used),...
	'SC:matEspresso:VariableNames:NotUnique',...
	'The variable names defined by <indIn>, <depIn>, <indNames>, & <depNames> must be unique.')
assert(~any(cellfun(@isempty,used)),...
	'SC:matEspresso:VariableNames:EmptyName',...
	'The variable names defined by <indIn>, <depIn>, <indNames>, & <depNames> cannot be empty.')
assert(all(cellfun(@isvarname,used)),...
	'SC:matEspresso:VariableNames:InvalidName',...
	'The variable names defined by <indIn>, <depIn>, <indNames>, & <depNames> must be valid MATLAB variable names.')
iind = isempty(stpo.indNames);
idep = isempty(stpo.depNames);
icnt = iind*indCnt;
dcnt = idep*depCnt;
need = icnt + dcnt;
if need>0
	abcd = num2cell('A':'Z');
	fidx = ismember(abcd,upper(used));
	free = abcd(~fidx);
	if numel(free)>=need
		if icnt>0
			stpo.indNames = free(1:icnt);
		end
		if dcnt>0
			%stpo.depNames = free(end:-1:end-dcnt+1);
			stpo.depNames = free(end-dcnt+1:end);
		end
	else % numbered
		if icnt>0
			stpo.indNames = meNumbNames(icnt,used,'X');
		end
		if dcnt>0
			stpo.depNames = meNumbNames(dcnt,used,'F');
		end
	end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meMakeNames
function out = meNumbNames(cnt,used,pfx)
tmp = strcat(pfx,arrayfun(@num2str,1:(cnt+2*numel(used)), 'UniformOutput',0));
out = tmp(find(~ismember(lower(tmp),lower(used)),cnt));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meNumbNames
function exe = meFindEspresso(exe)
% Locate the Espresso executable on System Path or MATLAB Search Path.
if ispc()
	fnm = 'Espresso.exe';
else % Linux and MacOS
	fnm = 'Espresso';
end
if isempty(exe) % Search the MATLAB Search Path
	tmp = which(fnm,'-all');
	if numel(tmp)
		exe = tmp{1};
		if numel(tmp)>1
			warning('SC:matEspresso:Executable:MultipleMatches',...
				['Multiple matches for "%s" found on the MATLAB search path.',...
				'\nThe first matching executable will be used:\n%s'],fnm,exe)
		end
	else % Assume executable is on the System Path
		exe = fnm;
	end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meFindEspresso
function expr = meMakeExpr(indOut,depOut,indNames,depNames)
indCnt = size(indOut,2);
depCnt = size(depOut,2);
allExp = cell(depCnt,1);
for ii = 1:depCnt
	prdIdx = find(depOut(:,ii)==1);
	prdCnt = numel(prdIdx);
	if prdCnt
		prdStr = cell(prdCnt,1);
		for jj = 1:prdCnt
			indVec = indOut(prdIdx(jj),:);
			litCnt = 0;
			litStr = cell(1,indCnt);
			for kk = 1:indCnt
				switch indVec(kk)
					case 0
						litCnt = litCnt+1;
						litStr{litCnt} = ['~',indNames{kk}];
					case 1
						litCnt = litCnt+1;
						litStr{litCnt} = indNames{kk};
				end
			end
			switch litCnt
				case 0 % Always true
					prdStr{jj} = '1';
				case 1
					prdStr{jj} = litStr{1};
				otherwise
					tmpStr     = sprintf(' & %s', litStr{1:litCnt});
					prdStr{jj} = ['(',tmpStr(4:end),')'];
			end
		end
		tmpStr = sprintf(' | %s',prdStr{:});
		tmpExp = tmpStr(4:end);
	else % No covering patterns -> always false
		tmpExp = '0';
	end
	allExp{ii} = sprintf('%s = %s',depNames{ii},tmpExp);
end
expr = sprintf('\n%s',allExp{:});
expr = expr(2:end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meMakeExpr
function expr = meSymSimpler(expr,indNames)
% Attempt simplification of the expression. Requires the Symbolic Toolbox.
spl = regexp(expr, '[\r\n]+', 'split');
spl = spl(~cellfun('isempty', spl));
out = cell(size(spl));
syms(indNames{:}, 'logical'); %#ok<NASGU>
for k = 1:numel(spl)
	tkn = regexp(spl{k}, '^\s*(\w+)\s*=\s*(.+)$', 'tokens', 'once');
	if numel(tkn)==2
		tmp = simplify(eval(tkn{2}), 'Steps',1234);
		out{k} = sprintf('%s = %s', tkn{1}, char(tmp));
	else
		out{k} = spl{k};
	end
end
expr = sprintf('\n%s', out{:});
expr = expr(2:end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%meSymSimpler
% Copyright (c) 2023-2026 Stephen Cobeldick
%
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%license