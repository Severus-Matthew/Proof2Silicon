import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import M0 as M0
import M1 as M1
import M2 as M2

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: M0.py
# ============================================================
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
    def Demo(x):
        result: bool = False
        d_0_p_: Container
        nw0_ = Container()
        nw0_.ctor__()
        d_0_p_ = nw0_
        (d_0_p_).Add(x)
        d_1_c_: bool
        out0_: bool
        out0_ = (d_0_p_).Contains(x)
        d_1_c_ = out0_
        (d_0_p_).Remove(x)
        d_2_c2_: bool
        out1_: bool
        out1_ = (d_0_p_).Contains(x)
        d_2_c2_ = out1_
        (d_0_p_).Add(x)
        d_3_c3_: bool
        out2_: bool
        out2_ = (d_0_p_).Contains(x)
        d_3_c3_ = out2_
        result = d_3_c3_
        return result


class Container:
    def  __init__(self):
        self.s: _dafny.Set = _dafny.Set({})
        pass

    def __dafnystr__(self) -> str:
        return "M0.Container"
    def ctor__(self):
        (self).s = _dafny.Set({})

    def Add(self, x):
        (self).s = (self.s) | (_dafny.Set({x}))

    def Remove(self, x):
        (self).s = (self.s) - (_dafny.Set({x}))

    def Contains(self, x):
        b: bool = False
        b = (x) in (self.s)
        return b


# ============================================================
# Appended from Dafny-generated file: M1.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import M0 as M0

# Module: M1

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Demo(x):
        result: bool = False
        d_0_p_: M0.Container
        nw0_ = M0.Container()
        nw0_.ctor__()
        d_0_p_ = nw0_
        (d_0_p_).Add(x)
        d_1_c_: bool
        out0_: bool
        out0_ = (d_0_p_).Contains(x)
        d_1_c_ = out0_
        (d_0_p_).Remove(x)
        d_2_c2_: bool
        out1_: bool
        out1_ = (d_0_p_).Contains(x)
        d_2_c2_ = out1_
        result = d_1_c_
        return result


# ============================================================
# Appended from Dafny-generated file: M2.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import M0 as M0
import M1 as M1

# Module: M2

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Demo(x):
        result: bool = False
        d_0_p_: M0.Container
        nw0_ = M0.Container()
        nw0_.ctor__()
        d_0_p_ = nw0_
        (d_0_p_).Add(x)
        d_1_c_: bool
        out0_: bool
        out0_ = (d_0_p_).Contains(x)
        d_1_c_ = out0_
        (d_0_p_).Remove(x)
        d_2_c2_: bool
        out1_: bool
        out1_ = (d_0_p_).Contains(x)
        d_2_c2_ = out1_
        (d_0_p_).Add(x)
        d_3_c3_: bool
        out2_: bool
        out2_ = (d_0_p_).Contains(x)
        d_3_c3_ = out2_
        result = d_3_c3_
        return result
