function matEspresso_Test()
% Testcases for the function matEspresso.
%
%% Dependencies %%
% * MATLAB R2009b or later.
% * matEspresso.m and test_flb_fun.m
%
% See also MATESPRESSO TEST_FLB_FUN
obj = test_flb_fun(@matEspresso);
mainfun(obj) % count
obj.start()
mainfun(obj) % check
obj.finish()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%matEspresso_Test
function mainfun(chk)
%
%% End-to-End: Numeric Input %%
%
chk.i([0;1],[0;0],'indNames',{'X'},'depNames',{'Y'}).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Y = 0') % Constant false.
chk.i([0;1],[1;1],'indNames',{'X'},'depNames',{'Y'}).o(int8(2),int8(1),'Y = 1') % Constant true.
chk.i([0;1],[0;1],'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Identity.
chk.i([0;1],[1;0],'indNames',{'X'},'depNames',{'Y'}).o(int8(0),int8(1),'Y = ~X') % Complement.
chk.i([0,0;0,1;1,0;1,1],[0;0;0;1],'indNames',{'A','B'},'depNames',{'Z'}).o(int8([1,1]),int8(1),'Z = (A & B)') % One two-variable minterm.
chk.i([0,0;0,1;1,0;1,1],[0;1;0;0],'indNames',{'A','B'},'depNames',{'Z'}).o(int8([0,1]),int8(1),'Z = (~A & B)') % One complemented two-variable minterm.
chk.i([1,0;1,1],[],'indNames',{'A','B'},'depNames',{'Z'}).o(int8([1,2]),int8(1),'Z = A') % Empty depIn means implicit true cases.
chk.i([0,1;1,1],[],'indNames',{'A','B'},'depNames',{'Z'}).o(int8([2,1]),int8(1),'Z = B') % Empty depIn means implicit true cases.
chk.i([0;1],[3;1],'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % False alias 3.
chk.i([0;1],[0;4],'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % True alias 4.
%
%% End-to-End: Numeric Classes %%
%
chk.i(logical([0;1]),logical([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Logical.
chk.i(single([0;1]),single([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Single.
chk.i(int8([0;1]),int8([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Int8.
chk.i(uint8([0;1]),uint8([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Uint8.
chk.i(int16([0;1]),int16([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Int16.
chk.i(uint16([0;1]),uint16([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Uint16.
chk.i(int32([0;1]),int32([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Int32.
chk.i(uint32([0;1]),uint32([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Uint32.
chk.i(int64([0;1]),int64([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Int64.
chk.i(uint64([0;1]),uint64([0;1]),'indNames',{'X'},'depNames',{'Y'}).o(int8(1),int8(1),'Y = X') % Uint64.
%
%% End-to-End: Character Input %%
%
chk.i(['0';'1'],['0';'1'],'indNames',{'X'},'depNames',{'Y'}).o('1','1','Y = X') % Basic character input and output.
chk.i(['0';'2'],['0';'1'],'indNames',{'X'},'depNames',{'Y'}).o('-','1','Y = 1') % Numeric DC character.
chk.i(['0';'-'],['0';'1'],'indNames',{'X'},'depNames',{'Y'}).o('-','1','Y = 1') % Hyphen DC character.
chk.i(['0';'?'],['0';'1'],'indNames',{'X'},'depNames',{'Y'}).o('-','1','Y = 1') % Question-mark DC character.
chk.i(['0';'1'],['3';'1'],'indNames',{'X'},'depNames',{'Y'}).o('1','1','Y = X') % Character false alias 3.
chk.i(['0';'1'],['0';'4'],'indNames',{'X'},'depNames',{'Y'}).o('1','1','Y = X') % Character true alias 4.
%
%% End-to-End: Table Input %%
%
indT = array2table([0;1],'VariableNames',{'Input'});
depT = array2table([0;1],'VariableNames',{'Output'});
indE = array2table(int8(1),'VariableNames',{'Input'});
depE = array2table(int8(1),'VariableNames',{'Output'});
chk.i(indT,depT).o(indE,depE,'Output = Input') % Table input preserves variable names.
indE = array2table(int8(1),'VariableNames',{'X'});
depE = array2table(int8(1),'VariableNames',{'Y'});
chk.i(indT,depT,'indNames',{'X'},'depNames',{'Y'}).o(indE,depE,'Y = X') % Table names can be replaced by options.
indT = table(logical([0;1]),uint8([0;1]),'VariableNames',{'A','B'});
depT = table(logical([0;1]),'VariableNames',{'Z'});
indE = array2table(int8([1,1]),'VariableNames',{'A','B'});
depE = array2table(int8(1),'VariableNames',{'Z'});
chk.i(indT,depT).o(indE,depE,'Z = (A & B)') % Table with mixed numeric and logical variables.
%
%% End-to-End: Categorical Input %%
%
indC = categorical({'off';'on'});
depC = categorical({'off';'on'});
indE = categorical(int8(1),0:2,{'off','on','DC'},'Protected',true);
depE = categorical(int8(1),[0:2,5],{'off','on','DC','NA'},'Protected',true);
chk.i(indC,depC,'indNames',{'X'},'depNames',{'Y'}).o(indE,depE,'Y = X') % Default output categories.
indC = categorical({'false';'true'});
depC = categorical({'no';'yes'});
chk.i(indC,depC,'indNames',{'X'},'depNames',{'Y'}).o(indE,depE,'Y = X') % Alternative categorical aliases.
indE = categorical(int8(1),0:2,{'zero','one','either'},'Protected',true);
depE = categorical(int8(1),[0:2,5],{'zero','one','either','NA'},'Protected',true);
chk.i(indC,depC,'indNames',{'X'},'depNames',{'Y'},'outCats',{'zero','one','either'}).o(indE,depE,'Y = X') % Custom output categories.
%
%% Pure Wrapper: All-NA Short Circuit %%
%
chk.i([0,0;0,1;1,0;1,1],5*ones(4,1),'indNames',{'A','B'},'depNames',{'Z'}).o(zeros(0,2,'int8'),zeros(0,1,'int8'),'Z = 0') % Numeric all-NA with one dependent-variable.
chk.i([0,0;0,1;1,0;1,1],5*ones(4,3),'indNames',{'A','B'},'depNames',{'X','Y','Z'}).o(zeros(0,2,'int8'),zeros(0,3,'int8'),sprintf('X = 0\nY = 0\nZ = 0')) % Numeric all-NA with multiple dependent-variables.
chk.i(['00';'01';'10';'11'],repmat('~',4,1),'indNames',{'A','B'},'depNames',{'Z'}).o(char(zeros(0,2)),char(zeros(0,1)),'Z = 0') % Character all-NA.
chk.i(['00';'01';'10';'11'],repmat('5',4,1),'indNames',{'A','B'},'depNames',{'Z'}).o(char(zeros(0,2)),char(zeros(0,1)),'Z = 0') % Character numeric NA alias.
indT = array2table([0,0;0,1;1,0;1,1],'VariableNames',{'A','B'});
depT = array2table(5*ones(4,1),'VariableNames',{'Z'});
indE = array2table(zeros(0,2,'int8'),'VariableNames',{'A','B'});
depE = array2table(zeros(0,1,'int8'),'VariableNames',{'Z'});
chk.i(indT,depT).o(indE,depE,'Z = 0') % Table all-NA.
indC = categorical({'off','off';'off','on';'on','off';'on','on'});
depC = categorical({'NA';'NA';'NA';'NA'});
indE = categorical(zeros(0,2,'int8'),0:2,{'off','on','DC'},'Protected',true);
depE = categorical(zeros(0,1,'int8'),[0:2,5],{'off','on','DC','NA'},'Protected',true);
chk.i(indC,depC,'indNames',{'A','B'},'depNames',{'Z'}).o(indE,depE,'Z = 0') % Categorical all-NA.
chk.i([0,0;0,1;1,0;1,1],5*ones(4,2)).o(zeros(0,2,'int8'),zeros(0,2,'int8'),sprintf('Y = 0\nZ = 0')) % Automatic variable names.
chk.i([0,0;0,1],5*ones(2,1),'indNames',{'X','Y'}).o(zeros(0,2,'int8'),zeros(0,1,'int8'),'Z = 0') % User independent names with automatic dependent name.
chk.i([0,0;0,1],5*ones(2,1),'depNames',{'Result'}).o(zeros(0,2,'int8'),zeros(0,1,'int8'),'Result = 0') % Automatic independent names with user dependent name.
%
%% Pure Wrapper: Option Input Forms %%
%
chk.i([0;1],5*ones(2,1),struct('indNames',{{'X'}},'depNames',{{'Y'}})).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Y = 0') % Scalar option structure.
chk.i([0;1],5*ones(2,1),'INDNAMES',{'X'},'DEPNAMES',{'Y'}).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Y = 0') % Case-insensitive option names.
chk.i([0,0;0,1],5*ones(2,1),'indNames',['X';'Y'],'depNames','Z').o(zeros(0,2,'int8'),zeros(0,1,'int8'),'Z = 0') % Character-matrix names.
chk.i([0;1],5*ones(2,1),'Dcheck',false).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Logical option false.
chk.i([0;1],5*ones(2,1),'Dcheck',0).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Numeric logical option zero.
chk.i([0;1],5*ones(2,1),'Dcheck',true).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Logical option true.
chk.i([0;1],5*ones(2,1),'Dcheck',1).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Numeric logical option one.
chk.i([0;1],5*ones(2,1),'rmTemp',false,'Dcheck',true,'Dexact',true,'Dopo',true,'Dpair',true).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % All Boolean options accepted.
chk.i([0;1],5*ones(2,1),'Efast',true).o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Efast accepted.
chk.i([0;1],5*ones(2,1),'Eout','f').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout true-set.
chk.i([0;1],5*ones(2,1),'Eout','d').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout DC-set.
chk.i([0;1],5*ones(2,1),'Eout','r').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout false-set.
chk.i([0;1],5*ones(2,1),'Eout','fd').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout true and DC sets.
chk.i([0;1],5*ones(2,1),'Eout','fr').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout true and false sets.
chk.i([0;1],5*ones(2,1),'Eout','dr').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout DC and false sets.
chk.i([0;1],5*ones(2,1),'Eout','fdr').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout all sets.
chk.i([0;1],5*ones(2,1),'Eout','FDR').o(zeros(0,1,'int8'),zeros(0,1,'int8'),'Z = 0') % Eout is case-insensitive.
%
%% Error Handling: Inputs %%
%
chk.i().e('SC:matEspresso:TooFewInputs') % No input arguments.
chk.i([]).e('SC:matEspresso:indIn:EmptyMatrix') % Empty independent-variable matrix.
chk.i(zeros(0,2)).e('SC:matEspresso:indIn:EmptyMatrix') % Empty independent-variable matrix with columns.
chk.i(zeros(2,1),zeros(3,1)).e('SC:matEspresso:RowCountMismatch') % Mismatched row counts.
chk.i(zeros(2,2,2),ones(2,1)).e('SC:matEspresso:indIn:NotMatrix') % Independent-variable input is not a matrix.
chk.i(zeros(2,1),zeros(2,1,2)).e('SC:matEspresso:depIn:NotMatrix') % Dependent-variable input is not a matrix.
chk.i({0;1},[0;1]).e('SC:matEspresso:indIn:NotNumericNorLogical') % Independent-variable input has unsupported type.
chk.i([0;1],{0;1}).e('SC:matEspresso:depIn:NotNumericNorLogical') % Dependent-variable input has unsupported type.
chk.i([-1;0],[0;1]).e('SC:matEspresso:indIn:InvalidValues') % Independent-variable negative value.
chk.i([0;3],[0;1]).e('SC:matEspresso:indIn:InvalidValues') % Independent-variable value too large.
chk.i([0;0.5],[0;1]).e('SC:matEspresso:indIn:InvalidValues') % Independent-variable fractional value.
chk.i([0;NaN],[0;1]).e('SC:matEspresso:indIn:InvalidValues') % Independent-variable NaN.
chk.i([0;Inf],[0;1]).e('SC:matEspresso:indIn:InvalidValues') % Independent-variable Inf.
chk.i([0;1],[-1;0]).e('SC:matEspresso:depIn:InvalidValues') % Dependent-variable negative value.
chk.i([0;1],[0;6]).e('SC:matEspresso:depIn:InvalidValues') % Dependent-variable value too large.
chk.i([0;1],[0;0.5]).e('SC:matEspresso:depIn:InvalidValues') % Dependent-variable fractional value.
chk.i([0;1],[0;NaN]).e('SC:matEspresso:depIn:InvalidValues') % Dependent-variable NaN.
chk.i([0;1],[0;Inf]).e('SC:matEspresso:depIn:InvalidValues') % Dependent-variable Inf.
chk.i(['0';'X'],['0';'1']).e('SC:matEspresso:indIn:InvalidCharacters') % Invalid independent-variable character.
chk.i(['0';'1'],['0';'X']).e('SC:matEspresso:depIn:InvalidCharacters') % Invalid dependent-variable character.
%
%% Error Handling: Tables %%
%
chk.i(table(['0';'1'],'VariableNames',{'A'}),array2table([0;1],'VariableNames',{'Z'})).e('SC:matEspresso:indIn:ColumnNotNumericNorLogical') % Independent-variable table contains character data.
chk.i(array2table([0;1],'VariableNames',{'A'}),table(['0';'1'],'VariableNames',{'Z'})).e('SC:matEspresso:depIn:ColumnNotNumericNorLogical') % Dependent-variable table contains character data.
chk.i(table([0,1;1,0],'VariableNames',{'A'}),array2table([0;1],'VariableNames',{'Z'})).e('SC:matEspresso:indIn:TableVariableNotColumn') % Independent-variable table variable is not a column.
chk.i(array2table([0;1],'VariableNames',{'A'}),table([0,1;1,0],'VariableNames',{'Z'})).e('SC:matEspresso:depIn:TableVariableNotColumn') % Dependent-variable table variable is not a column.
chk.i(array2table([0;0.5],'VariableNames',{'A'}),array2table([0;1],'VariableNames',{'Z'})).e('SC:matEspresso:indIn:ColumnNotWholeNumbers') % Independent-variable table contains fractional data.
chk.i(array2table([0;1],'VariableNames',{'A'}),array2table([0;0.5],'VariableNames',{'Z'})).e('SC:matEspresso:depIn:ColumnNotWholeNumbers') % Dependent-variable table contains fractional data.
chk.i(array2table([0,0;0,1],'VariableNames',{'A','B'}),array2table([5;5],'VariableNames',{'Z'}),'indNames',{'X'}).e('SC:matEspresso:indNames:WrongLength') % Independent-variable table names option has wrong length.
chk.i(array2table([0;1],'VariableNames',{'A'}),array2table([5,5;5,5],'VariableNames',{'Y','Z'}),'depNames',{'Q'}).e('SC:matEspresso:depNames:WrongLength') % Dependent-variable table names option has wrong length.
%
%% Error Handling: Categoricals %%
%
chk.i(categorical({'off';''}),categorical({'off';'on'})).e('SC:matEspresso:indIn:UndefinedCategory') % Undefined independent-variable category.
chk.i(categorical({'off';'on'}),categorical({'off';''})).e('SC:matEspresso:depIn:UndefinedCategory') % Undefined dependent-variable category.
chk.i(categorical({'off';'invalid'}),categorical({'off';'on'})).e('SC:matEspresso:indIn:UnsupportedCategory') % Unsupported independent-variable category.
chk.i(categorical({'off';'on'}),categorical({'off';'invalid'})).e('SC:matEspresso:depIn:UnsupportedCategory') % Unsupported dependent-variable category.
chk.i(categorical({'off';'NA'}),categorical({'off';'on'})).e('SC:matEspresso:indIn:UnsupportedCategory') % NA is not supported for independent variables.
chk.i(categorical({'0';'3'}),categorical({'0';'1'})).e('SC:matEspresso:indIn:UnsupportedCategory') % False alias 3 is not supported for independent variables.
%
%% Error Handling: Variable Names %%
%
chk.i([0,0;0,1],5*ones(2,1),'indNames',{'A'}).e('SC:matEspresso:indNames:WrongLength') % Independent-variable names have wrong length.
chk.i([0;1],5*ones(2,2),'depNames',{'Z'}).e('SC:matEspresso:depNames:WrongLength') % Dependent-variable names have wrong length.
chk.i([0,0;0,1],5*ones(2,1),'indNames',{'A','A'}).e('SC:matEspresso:VariableNames:NotUnique') % Duplicate independent-variable names.
chk.i([0;1],5*ones(2,2),'depNames',{'Z','Z'}).e('SC:matEspresso:VariableNames:NotUnique') % Duplicate dependent-variable names.
chk.i([0;1],5*ones(2,1),'indNames',{'X'},'depNames',{'X'}).e('SC:matEspresso:VariableNames:NotUnique') % Name shared by independent and dependent variables.
chk.i([0;1],5*ones(2,1),'indNames',{''}).e('SC:matEspresso:VariableNames:EmptyName') % Empty independent-variable name.
chk.i([0;1],5*ones(2,1),'depNames',{''}).e('SC:matEspresso:VariableNames:EmptyName') % Empty dependent-variable name.
chk.i([0;1],5*ones(2,1),'indNames',{'1X'}).e('SC:matEspresso:VariableNames:InvalidName') % Invalid independent-variable name.
chk.i([0;1],5*ones(2,1),'depNames',{'Y Z'}).e('SC:matEspresso:VariableNames:InvalidName') % Invalid dependent-variable name.
%
%% Error Handling: Options %%
%
chk.i([0;1],5*ones(2,1),'UnknownOption',true).e('SC:matEspresso:options:UnknownOptionName') % Unknown option name.
chk.i([0;1],5*ones(2,1),struct('Dexact',true,'DEXACT',false)).e('SC:matEspresso:options:DuplicateOptionNames') % Duplicate case-insensitive option names.
chk.i([0;1],5*ones(2,1),'Dexact',true,'Efast',true).e('SC:matEspresso:BothDexactAndEfast') % Dexact and Efast cannot both be true.
chk.i([0;1],5*ones(2,1),'Dcheck',[false,true]).e('SC:matEspresso:Dcheck:NotScalarLogical') % Dcheck must be scalar logical.
chk.i([0;1],5*ones(2,1),'Dexact',2).e('SC:matEspresso:Dexact:NotScalarLogical') % Dexact must be scalar logical.
chk.i([0;1],5*ones(2,1),'Dopo',[]).e('SC:matEspresso:Dopo:NotScalarLogical') % Dopo must be scalar logical.
chk.i([0;1],5*ones(2,1),'Dpair','true').e('SC:matEspresso:Dpair:NotScalarLogical') % Dpair must be scalar logical.
chk.i([0;1],5*ones(2,1),'Efast',NaN).e('SC:matEspresso:Efast:NotScalarLogical') % Efast must be scalar logical.
chk.i([0;1],5*ones(2,1),'rmTemp',[1,0]).e('SC:matEspresso:rmTemp:NotScalarLogical') % rmTemp must be scalar logical.
chk.i([0;1],5*ones(2,1),'simplify',2).e('SC:matEspresso:simplify:NotScalarLogical') % simplify must be scalar logical.
chk.i([0;1],5*ones(2,1),'Eout',['f';'r']).e('SC:matEspresso:Eout:NotSingleText') % Eout must be single text.
chk.i([0;1],5*ones(2,1),'Eout','').e('SC:matEspresso:Eout:InvalidOrderOrCharacters') % Eout cannot be empty.
chk.i([0;1],5*ones(2,1),'Eout','x').e('SC:matEspresso:Eout:InvalidOrderOrCharacters') % Eout contains invalid character.
chk.i([0;1],5*ones(2,1),'Eout','rf').e('SC:matEspresso:Eout:InvalidOrderOrCharacters') % Eout characters have invalid order.
chk.i([0;1],5*ones(2,1),'Eout','ff').e('SC:matEspresso:Eout:InvalidOrderOrCharacters') % Eout contains duplicate character.
chk.i([0;1],5*ones(2,1),'outCats',{'off','on'}).e('SC:matEspresso:outCats:NotThreeCategories') % outCats must contain three names.
chk.i([0;1],5*ones(2,1),'outCats',{'off','on','NA'}).e('SC:matEspresso:outCats:ForbiddenCategoryNA') % outCats cannot contain NA.
chk.i([0;1],5*ones(2,1),'outCats',reshape({'off','on','DC','x'},1,1,4)).e('SC:matEspresso:outCats:TooManyDimensions') % outCats cannot have too many dimensions.
chk.i([0;1],5*ones(2,1),'indNames',reshape({'X','Y'},1,1,2)).e('SC:matEspresso:indNames:TooManyDimensions') % indNames cannot have too many dimensions.
chk.i([0;1],5*ones(2,1),'depNames',reshape({'X','Y'},1,1,2)).e('SC:matEspresso:depNames:TooManyDimensions') % depNames cannot have too many dimensions.
chk.i([0;1],5*ones(2,1),'exePath',['A';'B']).e('SC:matEspresso:exePath:NotSingleText') % exePath must be single text.
chk.i([0;1],[0;1],'exePath','bad"path').e('SC:matEspresso:exePath:UnsafeCharacter') % Unsafe double quote in executable path.
chk.i([0;1],[0;1],'exePath','bad`path').e('SC:matEspresso:exePath:UnsafeCharacter') % Unsafe backtick in executable path.
chk.i([0;1],[0;1],'exePath','bad$path').e('SC:matEspresso:exePath:UnsafeCharacter') % Unsafe dollar sign in executable path.
chk.i([0;1],[0;1],'exePath','bad%path').e('SC:matEspresso:exePath:UnsafeCharacter') % Unsafe percent sign in executable path.
chk.i([0;1],[0;1],'exePath','bad!path').e('SC:matEspresso:exePath:UnsafeCharacter') % Unsafe exclamation mark in executable path.
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mainfun