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
import M3 as M3
import Client as Client
import ClientCached as ClientCached

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Client.py
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
import M2 as M2
import M3 as M3

# Module: Client

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


# ============================================================
# Appended from Dafny-generated file: ClientCached.py
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
import M2 as M2
import M3 as M3
import Client as Client

# Module: ClientCached

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


# ============================================================
# Appended from Dafny-generated file: M3.py
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
import M2 as M2

# Module: M3

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
