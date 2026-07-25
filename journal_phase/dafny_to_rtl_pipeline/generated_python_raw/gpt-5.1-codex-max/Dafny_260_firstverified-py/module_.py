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

    @staticmethod
    def SphereVolume(radius):
        volume: _dafny.BigRational = _dafny.BigRational()
        volume = (((((_dafny.BigRational('4e0')) / (_dafny.BigRational('3e0'))) * (default__.PI)) * (radius)) * (radius)) * (radius)
        return volume

    @_dafny.classproperty
    def PI(instance):
        return _dafny.BigRational('314159265358979323846e-20')
