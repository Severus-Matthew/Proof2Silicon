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
    def ExecuteSteps():
        result: int = int(0)
        d_0_step1_: int
        d_0_step1_ = 1
        d_1_step2_: int
        d_1_step2_ = (d_0_step1_) + (1)
        d_2_step3_: int
        d_2_step3_ = (d_1_step2_) + (1)
        d_3_step4_: int
        d_3_step4_ = (d_2_step3_) + (1)
        d_4_step5_: int
        d_4_step5_ = (d_3_step4_) + (1)
        d_5_step6_: int
        d_5_step6_ = (d_4_step5_) + (1)
        d_6_step7_: int
        d_6_step7_ = (d_5_step6_) + (1)
        d_7_step8_: int
        d_7_step8_ = (d_6_step7_) + (1)
        d_8_step9_: int
        d_8_step9_ = (d_7_step8_) + (1)
        d_9_step10_: int
        d_9_step10_ = (d_8_step9_) + (1)
        d_10_step11_: int
        d_10_step11_ = (d_9_step10_) + (1)
        d_11_step12_: int
        d_11_step12_ = (d_10_step11_) + (1)
        d_12_step13_: int
        d_12_step13_ = (d_11_step12_) + (1)
        d_13_step14_: int
        d_13_step14_ = (d_12_step13_) + (1)
        d_14_step15_: int
        d_14_step15_ = (d_13_step14_) + (1)
        result = d_14_step15_
        return result

    @staticmethod
    def ExecuteStepsWithLoop():
        result: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        d_1_acc_: int
        d_1_acc_ = 0
        while (d_0_i_) < (15):
            d_1_acc_ = (d_1_acc_) + (1)
            d_0_i_ = (d_0_i_) + (1)
        result = d_1_acc_
        return result

