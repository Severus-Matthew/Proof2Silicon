You are an Expert in Dafny programming, The following code gave an error followed by the code. Please resolve the error and regenrate the correct code:
method ToArray<T>(xs: seq<T>) returns (a: array<T>) {
    a := array<T>(xs.Length);
    for i in 0 ..< xs.Length {
        a[i] := xs[i];
    }
    return a;
}
 The error is: 
D:\UIUC_PROJ_2\dataset\Dafny\Dafny(55)\generated_gemini1Pro_2_3.dfy(2,9): Error: invalid Rhs (ID: p_generic_syntax_error)
This "invalid something" message where the something is typically
the name of an internal parser non-terminal means that the text being parsed
is a badly malformed instance of whatever parser entity was being parsed.
This is an automatically generated message by the CoCo parser generator
for a situation in which no specific recovery or a
more informative error message has been implemented.

The only advice we can give is to carefully scrutinize the location of the
error to see what might be wrong with the text. If you think this is a
common or confusing enough occurrence to warrant special error handling,
please suggest the improvement, with this sample code, to the Dafny team.
1 parse errors detected in generated_gemini1Pro_2_3.dfy
Make sure that the generated code is free from Out-of-bound error, logic error, syntax error, undefined variable or input type errorYou must return the method in the following Form:
```dafny
//Dafny Code
```