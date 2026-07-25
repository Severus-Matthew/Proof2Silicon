import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_

class default__:
    def  __init__(self):
        pass

    @_dafny.classproperty
    def charSet(instance):
        return _dafny.Set({_dafny.CodePoint('a'), _dafny.CodePoint('b'), _dafny.CodePoint('c')})
    @_dafny.classproperty
    def intSet(instance):
        return _dafny.Set({1, 2, 3})
    @_dafny.classproperty
    def stringSet(instance):
        return _dafny.Set({_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "abc")), _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "def"))})
