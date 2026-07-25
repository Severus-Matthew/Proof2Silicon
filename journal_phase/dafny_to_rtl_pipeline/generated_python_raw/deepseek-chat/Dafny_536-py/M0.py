import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: M0

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def is__empty(s):
        return (s) == (_dafny.Set({}))

    @staticmethod
    def contains(s, x):
        return (x) in (s)

    @staticmethod
    def add(s, x, s_k):
        return (s_k) == ((s) | (_dafny.Set({x})))

    @staticmethod
    def remove(s, x, s_k):
        return (s_k) == ((s) - (_dafny.Set({x})))

