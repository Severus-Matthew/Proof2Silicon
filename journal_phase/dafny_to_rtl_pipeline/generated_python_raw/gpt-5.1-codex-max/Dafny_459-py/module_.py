import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_


class MutableMap:
    def  __init__(self):
        self.m: _dafny.Map = _dafny.Map({})
        pass

    def __dafnystr__(self) -> str:
        return "_module.MutableMap"
    def ctor__(self):
        (self).m = _dafny.Map({})

    def Add(self, k, v):
        (self).m = (self.m).set(k, v)

    def Remove(self, k):
        (self).m = (self.m) - (_dafny.Set({k}))

    def Get(self, k):
        return (self.m)[k]

    def Contains(self, k):
        return (k) in (self.m)

    def Size(self):
        return len(self.m)

    def Select(self, k):
        return (self.m)[k]

    def Keys(self):
        def iife0_():
            coll0_ = _dafny.Set()
            compr_0_: TypeVar('K')
            for compr_0_ in (self.m).keys.Elements:
                d_0_k_: TypeVar('K') = compr_0_
                if (d_0_k_) in (self.m):
                    coll0_ = coll0_.union(_dafny.Set([d_0_k_]))
            return _dafny.Set(coll0_)
        return iife0_()
        

    def Demo(self):
        d_0_mm_: MutableMap
        nw0_ = MutableMap()
        nw0_.ctor__()
        d_0_mm_ = nw0_
        (d_0_mm_).Add(1, 10)
        (d_0_mm_).Add(2, 20)
        d_1_val1_: int
        d_1_val1_ = (d_0_mm_).Select(1)
        d_2_present_: bool
        d_2_present_ = (d_0_mm_).Contains(2)
        d_3_ks_: _dafny.Set
        d_3_ks_ = (d_0_mm_).Keys()
        (d_0_mm_).Remove(1)

