# valbasic
syntactic sugar wrapper for most dialects of MS-BASIC

standard rules of BASIC apply, adds a few comfort features

-labels

  labels are named points that the code can be jumped to or called as subroutines
  
  labels are declared by appending the label name with a colon
  
    i.e. my_label:
  
  labels can be jumped to like line numbers in vanilla BASIC
  
    i.e. GOTO my_label

-variables
 
  this wrapper allows variable names to be of arbitrary length, must be without whitespace
  
  variables are declared with a type qualifier followed by the name
  
    i.e. INTEGER my_int (compiles to %XX where XX is the next available variable name)
    i.e. FLOAT my_real (compiles to XX)
    i.e. STRING my_string (compiles to $XX)
  
  variables must be declared with a type qualifier even in scenarios where LET is syntactically invalid
  
    i.e. even in FOR loops
    this is so the transpiler knows what identifier to give the variable
  
  transpiler knows when to use LET and DIM on the fly
  
    i.e. FLOAT my_real = 42 will compile to LET XX = 42
    i.e. FLOAT my_real_arr(42) will compile to DIM XX(42)

-line numbers
  
  do not add line numbers manually, the transpiler will generate them at compile time
  
  labels will automatically replace themselves with the correct line number at compile time
  
    due to the implementation GOTO <line_number> is still valid but not recommended
