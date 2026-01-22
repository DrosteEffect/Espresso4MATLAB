classdef TempFileCleanup < handle
	% Automatic cleanup of temporary files.
	%
	%%% Syntax:
	% obj = TempFileCleanup(fid, filename)
	% obj = TempFileCleanup(fid, filename, oldrcyc)
	%
	% Creates a handle object that deletes the specified temporary file
	% when the object is destroyed. This is intended to be used as a guard
	% object to ensure temporary files are removed even if execution exits
	% early due to an error, ctrl+c, etc. The cleanup occurs when the
	% object is cleared from memory or goes out of scope.
	%
	% First the <fid> file is closed, then <filename> is deleted.
	% If <oldrcyc> is provided the RECYCLE() state will be restored.
	%
	% See also FOPEN FCLOSE DELETE RECYCLE
	properties (Access = private)
		FilePath = '';
		FileId   = -1;
		ReCycle  = -1;
	end
	methods
		function obj = TempFileCleanup(fid, fnm, oldrcyc)
			assert(isnumeric(fid) && isscalar(fid));
			obj.FileId = fid;
			obj.FilePath = toCharVec(fnm);
			if nargin>2
				obj.ReCycle = toCharVec(oldrcyc);
			end
		end
		function delete(obj)  % Destructor must never throw an error!
			try %#ok<TRYNC>
				fclose(obj.FileId);
			end
			try %#ok<TRYNC>
				delete(obj.FilePath);
			end
			try %#ok<TRYNC>
				recycle(obj.ReCycle);
			end
		end
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TempFileGuard
function txt = toCharVec(txt)
if isa(txt,'string') && isscalar(txt)
	txt = txt{1};
end
assert(ischar(txt) && ndims(txt)<3 && size(txt,1)==1); %#ok<ISMAT>
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%toCharVec
% Copyright (c) 2023-2026 Stephen Cobeldick
%
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%license