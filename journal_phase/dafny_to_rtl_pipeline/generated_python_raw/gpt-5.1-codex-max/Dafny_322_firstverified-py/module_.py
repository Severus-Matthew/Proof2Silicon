import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_


class CubeUtil:
    def  __init__(self):
        pass

    def __dafnystr__(self) -> str:
        return "_module.CubeUtil"
    def CubeSurfaceArea(self, edge):
        area: int = int(0)
        area = ((6) * (edge)) * (edge)
        return area

