import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: SeqSumGuide

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def PrintSeqSumInstructions():
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "1. Initialize an accumulator variable 'sum' to 0 using 'var sum := 0;'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "2. Initialize an index variable 'i' to 0 using 'var i := 0;'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "3. Use a while loop to traverse the sequence 's':\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "   while i < |s|\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "     invariant 0 <= i <= |s|\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "     invariant sum == (if i == 0 then 0 else the accumulated sum of s[0..i-1])\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "   {\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "     // Add the current element to the running total\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "     sum := sum + s[i];\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "     // Move to the next index\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "     i := i + 1;\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "   }\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "4. After the loop, 'sum' holds the sum of all elements in 's', so return 'sum'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "5. Avoid recursion in the code to implement 'seq_sum'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "6. Avoid recursion in the code to implement 'seq_sum'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "7. Avoid recursion in the code to implement 'seq_sum'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "8. Avoid recursion in the code to implement 'seq_sum'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "9. Avoid recursion in the code to implement 'seq_sum'.\n"))).VerbatimString(False))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "10. Avoid recursion in the code to implement 'seq_sum'.\n"))).VerbatimString(False))

