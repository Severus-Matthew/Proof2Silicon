import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_


class Stream:
    @classmethod
    def default(cls, default_T):
        return lambda: Stream__Lazy(lambda: Stream_Cons(default_T(), Stream.default(default_T)()))
    def __ne__(self, __o: object) -> bool:
        return not self.__eq__(__o)
    @property
    def is_Cons(self) -> bool:
        return isinstance(self, Stream_Cons)

class Stream__Lazy(Stream):
    def __init__(self, _c):
        self._c = _c
        self._d = None
    def _get(self):
        if self._c is not None:
            self._d = self._c()
            self._c = None
        return self._d
    def __dafnystr__(self) -> str:
        return _dafny.string_of(self._get())
    @property
    def head(self):
        return self._get().head
    @property
    def tail(self):
        return self._get().tail
class Stream_Cons(Stream, NamedTuple('Cons', [('head', Any), ('tail', Any)])):
    def __dafnystr__(self) -> str:
        return f'Stream.Cons'
    def __eq__(self, __o: object) -> bool:
        return isinstance(__o, Stream_Cons) and self.head == __o.head and self.tail == __o.tail
    def __hash__(self) -> int:
        return super().__hash__()

