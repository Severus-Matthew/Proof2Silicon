import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import SphereVolume as SphereVolume

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: SphereVolume.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: SphereVolume

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def SphereVolume(radius):
        volume: _dafny.BigRational = _dafny.BigRational()
        d_0_pi_: _dafny.BigRational
        d_0_pi_ = _dafny.BigRational('3141592653589793e-15')
        volume = (((((_dafny.BigRational('4e0')) / (_dafny.BigRational('3e0'))) * (d_0_pi_)) * (radius)) * (radius)) * (radius)
        return volume
