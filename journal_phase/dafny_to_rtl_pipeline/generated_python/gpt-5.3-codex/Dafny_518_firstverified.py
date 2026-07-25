import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import GeneratedStepsProgram as GeneratedStepsProgram

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: GeneratedStepsProgram.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: GeneratedStepsProgram

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def ApplyStep(s, step):
        (s).value = (s.value) + (step)
        (s).stepsCompleted = step

    @staticmethod
    def ExecuteAllSteps():
        finalValue: int = int(0)
        completed: int = int(0)
        d_0_s_: StepState
        nw0_ = StepState()
        nw0_.ctor__()
        d_0_s_ = nw0_
        default__.ApplyStep(d_0_s_, 1)
        default__.ApplyStep(d_0_s_, 2)
        default__.ApplyStep(d_0_s_, 3)
        default__.ApplyStep(d_0_s_, 4)
        default__.ApplyStep(d_0_s_, 5)
        default__.ApplyStep(d_0_s_, 6)
        default__.ApplyStep(d_0_s_, 7)
        default__.ApplyStep(d_0_s_, 8)
        default__.ApplyStep(d_0_s_, 9)
        default__.ApplyStep(d_0_s_, 10)
        default__.ApplyStep(d_0_s_, 11)
        default__.ApplyStep(d_0_s_, 12)
        default__.ApplyStep(d_0_s_, 13)
        default__.ApplyStep(d_0_s_, 14)
        default__.ApplyStep(d_0_s_, 15)
        completed = d_0_s_.stepsCompleted
        finalValue = d_0_s_.value
        return finalValue, completed


class StepState:
    def  __init__(self):
        self.value: int = int(0)
        self.stepsCompleted: int = int(0)
        pass

    def __dafnystr__(self) -> str:
        return "GeneratedStepsProgram.StepState"
    def ctor__(self):
        (self).value = 0
        (self).stepsCompleted = 0

    def Valid(self):
        return ((0) <= (self.stepsCompleted)) and ((self.stepsCompleted) <= (15))
