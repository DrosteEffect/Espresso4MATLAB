Espresso4MATLAB
===============

[![View Espresso4MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/183127)
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=DrosteEffect/Espresso4MATLAB)

`matEspresso` and `vecEspresso` are MATLAB interfaces to the classic [Espresso heuristic logic minimizer](https://en.wikipedia.org/wiki/Espresso_heuristic_logic_minimizer), enabling efficient Boolean logic minimization directly from MATLAB data structures such as matrices, tables, and truth vectors. The toolbox removes the need for manual PLA file construction and textual post-processing, providing a streamlined, MATLAB-native workflow.

## Espresso ##

The **Espresso heuristic logic minimizer** is a foundational tool in digital logic synthesis. It was originally designed to minimize Boolean functions representing [Programmable Logic Arrays (PLA)](https://en.wikipedia.org/wiki/Programmable_logic_array) (i.e. a canonical hardware representation consisting of AND and OR planes derived from truth tables). Espresso applies powerful heuristics to reduce logic complexity efficiently, making it a long-standing standard in logic optimization and PLA/VLSI design.

This project exposes Espresso's minimization capabilities to MATLAB users while preserving a data-centric, programmatic interface.

## Features ##

- MATLAB wrappers for the `Espresso` executable
- Boolean minimization from truth tables, matrices, or vectors
- Support for _don’t care_ conditions
- Automatic generation of minimized Boolean expressions
- Optional inspection and debugging support
- No manual PLA or temporary file handling required by the user

## Included Files ##

- `matEspresso.m`: core MATLAB wrapper for Espresso. Accepts independent/dependent-variable tables or matrices and returns minimized results.

- `matEspressoGUI.m`: interactive GUI for exploring truth-table minimization using MATLAB `uitable` components.

- `vecEspresso.m`: truth-vector interface built on top of `matEspresso`, providing drop-in compatibility with `minTruthtable` while scaling better to larger problems.

- `matEspresso_doc.m` & `vecEspresso_doc.m`: MATLAB `publish` documentation

- `TempFileCleanup.m`: utility class for robust cleanup of temporary files created during `Espresso` execution.

## Requirements ##

- MATLAB R2009b or later
- An installed **Espresso** executable available on the system path
  - Reference implementation: <https://github.com/Gigantua/Espresso>

## Terminology ##

To avoid confusing conflicts with existing MATLAB terminology we define:

- *independent-variable* aka input, variable, argument, premise, predicate, condition, domain variable, input signal, etc.
- *dependent-variable* aka output, function, function value, consequent, result, response, target variable, output signal, etc.

## Notes ##

- Espresso is a heuristic algorithm: results are typically near-optimal but not guaranteed to be globally minimal.
- Results may differ from exhaustive methods (e.g. Quine–McCluskey, Karnaugh maps or exact minimizers), particularly for small problems.

## Examples `matEspresso` ##

Minimize one dependent-variable with three independent-variables:

    >> indIn = [0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1];
    >> [indOut,depOut,expr] = matEspresso(indIn)
    indOut =
          1     2     2
          2     1     2
    depOut =
          1
          1
    expr =
         'Z = A | B'
    
Minimize two dependent-variables with two independent-variables:

    >> indIn = [0 0; 0 1; 1 0; 1 1];
    >> depIn = [0 0; 0 1; 1 0; 1 1];
    >> [indOut,depOut,expr] = matEspresso(indIn, depIn, 'depNames',{'hello','world'})
    indOut =
          1     2
          2     1
    depOut =
          1     0
          0     1
    expr =
         'hello = A
          world = B'
    
Simplify/factorize one dependent-variable with three independent-variables:

    >> indIn = [1 1 0; 1 0 1; 0 1 1];
    >> [~,~,expr] = matEspresso(indIn)
    expr =
         'Z = (A & B & ~C) | (A & ~B & C) | (~A & B & C)'
    >> [~,~,expr] = matEspresso(indIn, 'simplify',true)
    expr =
         'Z = A & (~B | ~C) & (B | C) | ~A & B & C'

## Examples `vecEspresso` ##

Basic minimization:

    >> Bins = vecEspresso('00111100')
    Bins =
        '10-'
        '01-'

With exact minimization (`matEspresso` options):

    >> [Bins,inps,Nums] = vecEspresso('1-11-000', 'Dexact',true)
    Bins =
        '01-'
        '0-0'
    inps =
        6
    Nums =
        {[2,3]
         [0,2]}

Don't-cares in output:

    >> [~,~,~,ott] = vecEspresso('----1111')
    ott = '00001111'
    >> [~,~,~,ott] = vecEspresso('----1111', 'preserveDC',true)
    ott = '----1111'

String input/output:

    >> [Bins,~,~,ott,expr] = vecEspresso("1--01100")
    Bins = 
        "-00"
        "10-"
    ott = 
        "10001100"
    expr =
        "Z = (~B & ~C) | (A & ~B)"