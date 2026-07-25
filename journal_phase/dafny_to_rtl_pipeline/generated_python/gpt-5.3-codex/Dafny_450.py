import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_


class A:
    def  __init__(self):
        self.value: int = int(0)
        pass

    def __dafnystr__(self) -> str:
        return "_module.A"
    def ctor__(self):
        (self).value = 10


class B:
    def  __init__(self):
        self.a: A = None
        pass

    def __dafnystr__(self) -> str:
        return "_module.B"
    def ctor__(self):
        nw0_ = A()
        nw0_.ctor__()
        (self).a = nw0_

    def m(self):
        obj0_ = self.a
        obj0_.value = 20
        obj1_ = self.a
        obj1_.value = 10
        obj2_ = self.a
        obj2_.value = 20
        obj3_ = self.a
        obj3_.value = 10

