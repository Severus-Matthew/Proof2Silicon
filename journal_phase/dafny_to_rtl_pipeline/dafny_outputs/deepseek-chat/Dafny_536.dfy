module M0 {
    predicate is_empty(s: set<int>)
    {
        s == {}
    }

    predicate contains(s: set<int>, x: int)
    {
        x in s
    }

    predicate add(s: set<int>, x: int, s': set<int>)
    {
        s' == s + {x}
    }

    predicate remove(s: set<int>, x: int, s': set<int>)
    {
        s' == s - {x}
    }
}

module M1 {
    predicate is_empty(s: set<int>)
    {
        s == {}
    }

    predicate contains(s: set<int>, x: int)
    {
        x in s
    }

    predicate add(s: set<int>, x: int, s': set<int>)
    {
        s' == s + {x}
    }

    predicate remove(s: set<int>, x: int, s': set<int>)
    {
        s' == s - {x}
    }
}

module M2 {
    predicate is_empty(s: set<int>)
    {
        s == {}
    }

    predicate contains(s: set<int>, x: int)
    {
        x in s
    }

    predicate add(s: set<int>, x: int, s': set<int>)
    {
        s' == s + {x}
    }

    predicate remove(s: set<int>, x: int, s': set<int>)
    {
        s' == s - {x}
    }
}

module M3 {
    predicate is_empty(s: set<int>)
    {
        s == {}
    }

    predicate contains(s: set<int>, x: int)
    {
        x in s
    }

    predicate add(s: set<int>, x: int, s': set<int>)
    {
        s' == s + {x}
    }

    predicate remove(s: set<int>, x: int, s': set<int>)
    {
        s' == s - {x}
    }
}

module Client {
    predicate is_empty(s: set<int>)
    {
        s == {}
    }

    predicate contains(s: set<int>, x: int)
    {
        x in s
    }

    predicate add(s: set<int>, x: int, s': set<int>)
    {
        s' == s + {x}
    }

    predicate remove(s: set<int>, x: int, s': set<int>)
    {
        s' == s - {x}
    }
}

module ClientCached {
    predicate is_empty(s: set<int>)
    {
        s == {}
    }

    predicate contains(s: set<int>, x: int)
    {
        x in s
    }

    predicate add(s: set<int>, x: int, s': set<int>)
    {
        s' == s + {x}
    }

    predicate remove(s: set<int>, x: int, s': set<int>)
    {
        s' == s - {x}
    }
}
