function vecEspresso_Test()
% Testcases for the function vecEspresso.
%
%% Dependencies %%
% * MATLAB R2009b or later.
% * vecEspresso.m and test_flb_fun.m
%
% See also VECESPRESSO TEST_FLB_FUN
obj = test_flb_fun(@vecEspresso);
mainfun(obj) % count
obj.start()
mainfun(obj) % check
obj.finish()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%vecEspresso_Test
function mainfun(chk)
%
%% Pure Wrapper: Scalar Numeric and Logical Inputs %%
%
chk.i(0).o(zeros(0,0,'int8'),0,cell(0,1),int8(0),'Z = 0') % Numeric constant false.
chk.i(1).o(zeros(1,0,'int8'),0,{0},int8(1),'Z = 1') % Numeric constant true.
chk.i(2).o(zeros(0,0,'int8'),0,cell(0,1),int8(0),'Z = 0') % Numeric DC defaults to false.
chk.i(2,'preserveDC',true).o(zeros(0,0,'int8'),0,cell(0,1),int8(2),'Z = 0') % Numeric DC is preserved.
chk.i(false).o(zeros(0,0,'int8'),0,cell(0,1),int8(0),'Z = 0') % Logical constant false.
chk.i(true).o(zeros(1,0,'int8'),0,{0},int8(1),'Z = 1') % Logical constant true.
chk.i(single(0)).o(zeros(0,0,'int8'),0,cell(0,1),int8(0),'Z = 0') % Single constant false.
chk.i(uint8(1)).o(zeros(1,0,'int8'),0,{0},int8(1),'Z = 1') % Unsigned integer constant true.
%
%% Pure Wrapper: Scalar Character and String Inputs %%
%
chk.i('0').o(char(zeros(0,0)),0,cell(0,1),'0','Z = 0') % Character constant false.
chk.i('1').o(char(zeros(1,0)),0,{0},'1','Z = 1') % Character constant true.
chk.i('2').o(char(zeros(0,0)),0,cell(0,1),'0','Z = 0') % Character DC alias 2 defaults to false.
chk.i('-').o(char(zeros(0,0)),0,cell(0,1),'0','Z = 0') % Character DC alias hyphen defaults to false.
chk.i('?').o(char(zeros(0,0)),0,cell(0,1),'0','Z = 0') % Character DC alias question-mark defaults to false.
chk.i('-','preserveDC',true).o(char(zeros(0,0)),0,cell(0,1),'-','Z = 0') % Character DC is preserved.
chk.i("0").o(string.empty(0,1),0,cell(0,1),"0","Z = 0") % String constant false.
chk.i("1").o("",0,{0},"1","Z = 1") % String constant true.
chk.i("-",'preserveDC',true).o(string.empty(0,1),0,cell(0,1),"-","Z = 0") % String DC is preserved.
%
%% End-to-End: One Independent Variable %%
%
chk.i([0;0]).o(zeros(0,1,'int8'),0,cell(0,1),int8([0;0]),'Z = 0') % Numeric constant false.
chk.i([1;1]).o(int8(2),0,{[0,1]},int8([1;1]),'Z = 1') % Numeric constant true.
chk.i([0;1]).o(int8(1),0,{1},int8([0;1]),'Z = A') % Numeric identity.
chk.i([1;0]).o(int8(0),0,{0},int8([1;0]),'Z = ~A') % Numeric complement.
chk.i(logical([0;1])).o(int8(1),0,{1},int8([0;1]),'Z = A') % Logical identity returns int8 outputs.
chk.i(single([0;1])).o(int8(1),0,{1},int8([0;1]),'Z = A') % Single identity returns int8 outputs.
chk.i(uint8([0;1])).o(int8(1),0,{1},int8([0;1]),'Z = A') % Integer identity returns int8 outputs.
chk.i('00').o(char(zeros(0,1)),0,cell(0,1),'00','Z = 0') % Character constant false.
chk.i('11').o('-',0,{[0,1]},'11','Z = 1') % Character constant true.
chk.i('01').o('1',0,{1},'01','Z = A') % Character identity.
chk.i('10').o('0',0,{0},'10','Z = ~A') % Character complement.
chk.i('0-').o(char(zeros(0,1)),0,cell(0,1),'00','Z = 0') % Character DC consumed by default.
chk.i('0-','preserveDC',true).o(char(zeros(0,1)),0,cell(0,1),'0-','Z = 0') % Character DC preserved.
chk.i([0;2]).o(zeros(0,1,'int8'),0,cell(0,1),int8([0;0]),'Z = 0') % Numeric DC consumed by default.
chk.i([0;2],'preserveDC',true).o(zeros(0,1,'int8'),0,cell(0,1),int8([0;2]),'Z = 0') % Numeric DC preserved.
chk.i("01").o("1",0,{1},"01","Z = A") % String identity returns string outputs.
chk.i("0-",'preserveDC',true).o(string.empty(0,1),0,cell(0,1),"0-","Z = 0") % String DC preserved.
%
%% End-to-End: Two Independent Variables %%
%
chk.i([0;0;0;1]).o(int8([1,1]),2,{3},int8([0;0;0;1]),'Z = (A & B)') % Numeric conjunction.
chk.i([0;1;0;0]).o(int8([0,1]),2,{1},int8([0;1;0;0]),'Z = (~A & B)') % Numeric complemented minterm.
chk.i('0001').o('11',2,{3},'0001','Z = (A & B)') % Character conjunction.
chk.i('0100').o('01',2,{1},'0100','Z = (~A & B)') % Character complemented minterm.
chk.i([0,0,0,1]).o(int8([1,1]),2,{3},int8([0,0,0,1]),'Z = (A & B)') % Row-vector orientation is preserved by ott.
chk.i('0001',struct('Dexact',true)).o('11',2,{3},'0001','Z = (A & B)') % Scalar option structure is forwarded.
chk.i('0001','Dexact',true).o('11',2,{3},'0001','Z = (A & B)') % Name-value option is forwarded.
chk.i('0001','DEXACT',1).o('11',2,{3},'0001','Z = (A & B)') % Forwarded option names are case-insensitive.
%
%% Pure Wrapper: preserveDC Option %%
%
chk.i('-',struct('preserveDC',true)).o(char(zeros(0,0)),0,cell(0,1),'-','Z = 0') % Scalar structure option.
chk.i('-','preserveDC',1).o(char(zeros(0,0)),0,cell(0,1),'-','Z = 0') % Numeric true option.
chk.i('-','PRESERVEDC',true).o(char(zeros(0,0)),0,cell(0,1),'-','Z = 0') % Case-insensitive option name.
chk.i('-','preserveDC',false).o(char(zeros(0,0)),0,cell(0,1),'0','Z = 0') % Logical false option.
chk.i('-','preserveDC',0).o(char(zeros(0,0)),0,cell(0,1),'0','Z = 0') % Numeric false option.
%
%% Error Handling: Truth Vector %%
%
chk.i().e('SC:vecEspresso:TooFewInputs') % No input arguments.
chk.i([]).e('SC:vecEspresso:tt:Empty') % Empty numeric input.
chk.i('').e('SC:vecEspresso:tt:Empty') % Empty character input.
chk.i("").e('SC:vecEspresso:tt:Empty') % Empty string scalar.
chk.i(zeros(2,2)).e('SC:vecEspresso:tt:NotVector') % Numeric matrix input.
chk.i(['00';'11']).e('SC:vecEspresso:tt:NotVector') % Character matrix input.
chk.i(zeros(2,2,2)).e('SC:vecEspresso:tt:NotVector') % Numeric array input.
chk.i([0;1;0]).e('SC:vecEspresso:tt:NotPowerTwo') % Numeric length is not a power of two.
chk.i('010').e('SC:vecEspresso:tt:NotPowerTwo') % Character length is not a power of two.
chk.i({0,1}).e('SC:vecEspresso:tt:InvalidType') % Cell input has invalid type.
chk.i(["0","1"]).e('SC:vecEspresso:tt:InvalidType') % Non-scalar string input has invalid type.
chk.i([0;3]).e('SC:vecEspresso:tt:InvalidValues') % Numeric value is too large.
chk.i([0;-1]).e('SC:vecEspresso:tt:InvalidValues') % Numeric value is negative.
chk.i([0;0.5]).e('SC:vecEspresso:tt:InvalidValues') % Numeric value is fractional.
chk.i([0;NaN]).e('SC:vecEspresso:tt:InvalidValues') % Numeric value is NaN.
chk.i([0;Inf]).e('SC:vecEspresso:tt:InvalidValues') % Numeric value is infinite.
chk.i('0X').e('SC:vecEspresso:tt:InvalidCharacters') % Character value is unsupported.
chk.i("0X").e('SC:vecEspresso:tt:InvalidCharacters') % String character is unsupported.
%
%% Error Handling: Options %%
%
chk.i('0','Eout','f').e('SC:vecEspresso:Eout:NotSupported') % Eout name-value option is not supported.
chk.i('0',struct('Eout','f')).e('SC:vecEspresso:Eout:NotSupported') % Eout structure option is not supported.
chk.i('0','eOUT','f').e('SC:vecEspresso:Eout:NotSupported') % Eout rejection is case-insensitive.
chk.i('0','preserveDC',2).e('SC:vecEspresso:preserveDC:NotScalarLogical') % preserveDC value is not logical.
chk.i('0','preserveDC',[]).e('SC:vecEspresso:preserveDC:NotScalarLogical') % preserveDC value is empty.
chk.i('0','preserveDC',[false,true]).e('SC:vecEspresso:preserveDC:NotScalarLogical') % preserveDC value is nonscalar.
chk.i('0','preserveDC','true').e('SC:vecEspresso:preserveDC:NotScalarLogical') % preserveDC value is text.
chk.i('0',struct('preserveDC',true,'PRESERVEDC',false)).e('SC:vecEspresso:preserveDC:DuplicateOptionNames') % Duplicate preserveDC names differ only by case.
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mainfun