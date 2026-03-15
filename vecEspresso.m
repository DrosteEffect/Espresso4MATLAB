function [Bins,inps,Nums,ott,expr,debug] = vecEspresso(tt,opts,varargin)
% Truth-vector Boolean minimization using Espresso (via matEspresso).
%
% vecEspresso provides a truth-vector interface to matEspresso, offering
% drop-in compatibility with minTruthtable while using the Espresso
% heuristic logic minimizer for superior performance on large problems.
%
%%% Syntax %%%
%
%   vecEspresso(tt)
%   vecEspresso(tt,<options>)
%   [Bins,inps,Nums,ott,expr,debug] = vecEspresso(...)
%
% vecEspresso minimizes a Boolean function given as a truth-vector,
% returning covering patterns and a minimized truth-vector. It provides
% drop-in compatibility with minTruthtable's core functionality while
% leveraging Espresso's efficient algorithms. However, results may differ!
%
%% Terminology %%
%
% To avoid confusing conflicts with existing MATLAB terminology we define:
% * independent-variable aka input, variable, argument, premise, predicate, condition, domain variable, input signal, etc.
% * dependent-variable aka output, function, function value, consequent, result, response, target variable, output signal, etc.
%
%% |minTruthtable| Compatibility %%
%
% Generally drop-in replacement but some important differences:
%
% - Uses Espresso instead of Quine-McCluskey algorithm,
% - <tt> not limited to 2^15 elements,
% - Espresso minimization options,
% - Generally faster for problems with 10+ independent-variables,
% - Accepts char/string/numeric input, returns char/string/numeric outputs.
% - Numeric/logical <tt> returns int8 <Bins> and <ott>, not char as minTruthtable does.
% - DCs in numeric/logical <tt> must be exactly value 2, not any non-zero/non-one value.
%
% You can compare minTruthtable's demo too:
%
%   vecEspresso 0000100-1-1110-1
%
%% Examples %%
%
%   % Basic minimization:
%   >> Bins = vecEspresso('00111100')
%   Bins =
%       '10-'
%       '01-'
%
%   % With exact minimization (matEspresso option):
%   >> [Bins,inps,Nums] = vecEspresso('1-11-000', 'Dexact',true)
%   Bins =
%       '01-'
%       '0-0'
%   inps =
%       6
%   Nums =
%       {[2,3]
%        [0,2]}
%
%   % Don't-cares in output:
%   >> [~,~,~,ott] = vecEspresso('----1111')
%   ott = '00001111'
%   >> [~,~,~,ott] = vecEspresso('----1111', 'preserveDC',true)
%   ott = '----1111'
%
%   % String input/output:
%   >> [Bins,~,~,ott,expr] = vecEspresso("1--01100")
%   Bins =
%       "-00"
%       "10-"
%   ott =
%       "10001100"
%   expr =
%       "Z = (~B & ~C) | (A & ~B)"
%
%% Input Arguments (**==default) %%
%
%   tt = Truth-vector (row vector of length 2^N) representing a Boolean
%        function over N independent-variables. The input <tt> can be:
%        - Char vector or string scalar, which contains only the following
%          characters: '0' (false), '1' (true), '2'/'-'/'?' (don't-care,DC).
%        - Numeric/logical vector: 0/false, 1/true, 2 (don't-care,DC).
%        Length must be a power of 2, representing all 2^N combinations
%        of N boolean independent-variables in binary counting order.
%   <options> = Name-value pairs controlling minimization behavior:
%        'preserveDC' = logical scalar where:
%        - false**: DCs are consumed (output contains only true & false)
%        - true   : DCs preserved in output where input had them
%        All other options are passed to matEspresso.
%
%% Output Arguments %%
%
%   Bins = Covering patterns, size nTerms-by-N, the class depends on <tt>:
%          - <tt> = char            -> char matrix  (values '0', '1', '-')
%          - <tt> = string          -> string array (values '0', '1', '-')
%          - <tt> = numeric/logical -> int8 matrix  (values 0, 1, 2)
%          Each row of <Bins> represents one product term.
%          nTerms = number of product terms in the minimized expression,
%          note that nTerms is 0 when the function is constant false.
%   inps = Double scalar, the gate complexity of the minimized function.
%          Counts literals in multi-literal product terms (AND gate-inputs)
%          plus one gate-input per product term for the OR gate (if there
%          are 2 or more terms). Single-literal and constant functions
%          contribute 0. Lower values indicate simpler logic circuits.
%          Example: <tt>='0110' returns Z=(A&~B)|(~A&B) which has
%          2+2 AND gate-inputs + 2 OR gate-inputs thus giving <inps>=6.
%   Nums = nTerms-by-1 cell array of covered truth-table row indices.
%          Each cell contains a 1-by-K double row vector of 0-based indices
%          of the truth-table rows covered by the corresponding pattern.
%          Example: {[2,3]} means the pattern covers rows 2 and 3 (0-indexed).
%   ott  = Minimized truth-vector, the class depends on <tt>:
%          - <tt> = char            -> char vector   (values '0', '1')
%          - <tt> = string          -> string scalar (values '0', '1')
%          - <tt> = numeric/logical -> int8 vector   (values 0, 1)
%          With preserveDC=true <ott> also retains DCs from the input.
%   expr = Char vector (or string scalar if <tt> is string) containing one
%          boolean expression per dependent-variable, separated by newlines.
%          Uses MATLAB syntax (~, &, |) with parenthesized product terms.
%   debug = ScalarStruct containing detailed information about the run,
%          including timing, raw PLA data, statistics, and options used.
%          Note: for 0-independent-variable functions only the timing
%          field is present: PLA data, statistics, and options are absent.
%
%% Dependencies %%
%
% * MATLAB R2009b or later.
% * matEspresso.m from <https://www.mathworks.com/matlabcentral/fileexchange/183127>
%
% See also MATESPRESSO MATESPRESSOGUI MINTRUTHTABLE DEC2BIN BIN2DEC
ticH = tic();
fErr = @(v)sprintf('%sand ''%c''',sprintf('''%c'', ',v(1:end-1)),v(end));
% Release | Feature
% --------|--------
% R2008a  | assert(cond, msgID, msg, printf format string)
% R2008b  | id=tic(); ... toc(id);
% R2009b  | tilde argument placeholder
% R2016b  | string class, string curly-brace indexing    [only if supplied]
%
%% Input Wrangling %%
%
% Set up default options
stpo = struct('preserveDC',false);
%
switch nargin
	case 0 % We need something to work with!
		error('SC:vecEspresso:TooFewInputs','At least one input argument is required.')
	case 1 % nothing to do.
		opts = struct();
	case 2
		opts = structfun(@ve1s2c,opts,'UniformOutput',false);
	otherwise
		temp = cellfun(@ve1s2c,[{opts},varargin],'UniformOutput',false);
		opts = cell2struct(temp(2:2:end),temp(1:2:end),2);
end
%
fnmC = fieldnames(opts);
idx1 = strcmpi(fnmC,'preserveDC');
switch nnz(idx1)
	case 0 % nothing to do
	case 1 %
		fnm1 = fnmC{idx1};
		arg1 = opts.(fnm1);
		assert(isequal(arg1,0)||isequal(arg1,1),...
			'SC:vecEspresso:preserveDC:NotScalarLogical',...
			'The <preserveDC> value must be a scalar logical.')
		stpo.preserveDC = logical(arg1);
		opts = rmfield(opts,fnm1);
	otherwise
		error('SC:vecEspresso:preserveDC:DuplicateOptionNames',...
			'The option <preserveDC> may be specified only once.')
end
%
ttInp = ve1s2c(tt);
ttLen = numel(ttInp);
ttPwr = round(log2(ttLen));
assert(ttLen>0,...
	'SC:vecEspresso:tt:Empty',...
	'Input <tt> must not be empty.')
assert(nnz(size(ttInp)~=1)<2,...
	'SC:vecEspresso:tt:NotVector',...
	'Input <tt> must be a string scalar, or a char/numeric/logical vector (not a matrix nor an array).')
assert(2^ttPwr==ttLen,...
	'SC:vecEspresso:tt:NotPowerTwo',...
	'Length of <tt> must be a power of 2. Provided length: %d',ttLen)
assert(ttPwr<=52,...
	'SC:vecEspresso:tt:TooLong',...
	'Input <tt> must not be longer than 2^52 elements. Provided length: %d',ttLen)
%
if ischar(ttInp)
	assert(all(ismember(ttInp,'012-?')),...
		'SC:vecEspresso:tt:InvalidCharacters',...
		'Input <tt> must only contain %s characters.',fErr('012-?'))
	ttNum = int8(ttInp)-int8('0');
	ttNum(~ismember(ttNum,0:2)) = 2;
	ttTxt = ttInp;
else
	assert(isnumeric(ttInp)||islogical(ttInp),...
		'SC:vecEspresso:tt:InvalidType',...
		'Input <tt> must be a scalar string or a char/numeric/logical vector.')
	assert(all(ismember(ttInp,0:2)),'SC:vecEspresso:tt:InvalidValues',...
		'Input <tt> must contain only these values: 0/false, 1/true, and 2 (don''t-care).')
	ttNum = int8(ttInp);
	ttTxt = char(ttNum+'0');
end
%
ttTxt(ttNum==2) = '-';
%
%% Generate Results
%
if ttLen>1
	%
	[~,~,expr,debug] = matEspresso(dec2bin(0:ttLen-1,ttPwr), ttTxt(:), opts);
	%
	indOut = debug.raw.indOut;
	nTerms = size(indOut,1);
else
	switch ttNum
		case 0 % tt='0': constant false function
			indOut = zeros(0,0,'int8');
			nTerms = 0;
			expr = 'Z = 0';
		case 1 % tt='1': constant true function
			indOut = zeros(1,0,'int8');
			nTerms = 1;
			expr = 'Z = 1';
		case 2 % tt='-': don't-care function
			indOut = zeros(0,0,'int8');
			nTerms = 0; % treated conservatively as constant false
			expr = 'Z = 0';
		otherwise
			error('This should never happen')
	end
	debug = struct(); % Minimal debug info
end
%
%% Convert Results to minTruthtable Format
%
% Calculate cnts (non-DC literals per term) and derive inps (gate complexity)
cnts = sum(indOut~=2,2);
inps = sum(cnts(cnts>1)) + (numel(cnts)>1)*numel(cnts);
%
% Build Nums: Find covered indices for each pattern
Nums = cell(nTerms,1);
if ttPwr>0 && nTerms>0
	rVec = 0:ttLen-1;
	tVec = uint64(rVec(:));
	allX = zeros(ttLen,ttPwr,'int8');
	for bit = ttPwr:-1:1 % (LSB):-1:(MSB)
		allX(:,bit) = bitand(tVec,1)~=0;
		tVec = bitshift(tVec,-1);
	end
	for ii = 1:nTerms
		indRow = indOut(ii,:);
		tmpVec = true(ttLen,1);
		for jj = 1:ttPwr
			if indRow(jj)~=2
				tmpVec = tmpVec & allX(:,jj)==indRow(jj);
			end
		end
		idx = find(tmpVec)-1;
		Nums{ii} = idx.';
	end
else
	for ii = 1:nTerms
		Nums{ii} = 0;
	end
end
%
%% Build Outputs %%
%
if ischar(ttInp) || ~nargout
	dcv = '-';
	ott = ttTxt;
	ott(:) = '0';
	for ii = 1:nTerms
		ott(Nums{ii}+1) = '1';
	end
else % numeric/logical
	dcv = 2;
	ott = ttNum;
	ott(:) = 0;
	for ii = 1:nTerms
		ott(Nums{ii}+1) = 1;
	end
end
%
if stpo.preserveDC % restore DCs
	ott(ttNum==2) = dcv;
end
%
if ~nargout
	veDisplayResults(expr,indOut,inps,Nums,ttTxt,ott,ttPwr);
	return
end
%
if ischar(ttInp)
	Bins = char('0'+indOut);
	Bins(indOut==2) = '-';
	if isa(tt,'string')
		if nTerms>0
			Bins = string(cellstr(Bins));
		else
			Bins = string.empty(0,1);
		end
		ott  = string(ott);
		expr = string(expr);
	end
else % numeric/logical
	Bins = int8(indOut);
end
%
debug.time.(mfilename) = toc(ticH);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vecEspresso
function arr = ve1s2c(arr)
% If string scalar then extract the character vector,
% Otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ve1s2c
function veDisplayResults(expr,indOut,inps,Nums,ttTxt,ttOut,N)
% Display results in minTruthtable format
%
% Karnaugh Map for 3 or 4 variables
if ismember(N,3:4)
	mat = [0,1,3,2;4,5,7,6;12,13,15,14;8,9,11,10];
	head = '/||\';
	if N==3
		head = '/\';
		mat = mat(1:2,1:4);
	end
	fprintf('| Karnaugh map (index to left, -:unused don''t-care, =:used don''t-care):\n')
	for y = 1:2^(N-2)
		fprintf('|  %c %2d %2d %2d %2d %c ', head(y), mat(y,:), head(end+1-y));
		kmaptt = ttOut;
		kmaptt(ttTxt=='0') = '.';
		kmaptt(ttTxt=='-' & ttOut=='0') = '-';
		kmaptt(ttTxt=='-' & ttOut=='1') = '=';
		fprintf('|  %c %c %c %c %c %c\n', head(y), kmaptt(1+mat(y,:)), head(end+1-y));
	end
end
%
Bins = char('0'+indOut);
Bins(indOut==2) = '-';
% List all terms
fprintf('| All terms:\n');
nTerms = size(Bins,1);
for k = 1:nTerms
	fprintf('| * T(%2d): "%s" <-> {', k, Bins(k,:))
	if ~isempty(Nums{k})
		fprintf('%d', Nums{k}(1));
		if numel(Nums{k}) > 1
			fprintf(' %d', Nums{k}(2:end));
		end
	end
	fprintf('}\n');
end
%
% Boolean expression
fprintf('|\n| %s;\n|\n',expr)
%
% Summary statistics
fprintf('| Logical complexity: %d inputs\n|\n',inps);
fprintf('|  Input tt: "%s"\n',ttTxt);
fprintf('| Output tt: "%s"\n',ttOut);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%veDisplayResults
% Copyright (c) 2023-2026 Stephen Cobeldick
%
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%license