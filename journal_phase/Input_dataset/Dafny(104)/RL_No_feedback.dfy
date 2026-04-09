// Basic linear search without caching
method LinearSearch2(arr: array<int>, key: int) returns (index: int)
  requires arr != null
  ensures 0 <= index <= arr.Length
  ensures index < arr.Length ==> arr[index] == key
  ensures forall i :: 0 <= i < index ==> arr[i] != key
  decreases arr.Length - index
{
  index := 0;
  while index < arr.Length
    invariant 0 <= index <= arr.Length
    invariant forall i :: 0 <= i < index ==> arr[i] != key
  {
    if arr[index] == key {
      return;
    }
    index := index + 1;
  }
}

// Linear search with sequence input
method LinearSearch3(seq: seq<int>, key: int) returns (index: int)
  ensures 0 <= index <= |seq|
  ensures index < |seq| ==> seq[index] == key
  ensures forall i :: 0 <= i < index ==> seq[i] != key
  decreases |seq| - index
{
  index := 0;
  while index < |seq|
    invariant 0 <= index <= |seq|
    invariant forall i :: 0 <= i < index ==> seq[i] != key
  {
    if seq[index] == key {
      return;
    }
    index := index + 1;
  }
}

// Cache structure for caching search results
class Cache<T> {
  var map: map<int, T>;
  var count: int;
  
  ghost predicate Valid()
    reads this
  {
    count == |map| &&
    forall i :: i in map ==> 0 <= i
  }
  
  constructor()
    ensures Valid()
  {
    map := map[];
    count := 0;
  }
}

// Cache result structure
datatype CacheResult = CacheResult(
  cache_hits: int,
  cache_misses: int,
  cache_rejects: int,
  found: bool,
  index: int
)

// Linear search with caching
method TrySearchLinearWithCache(cache: Cache<int>, arr: array<int>, key: int) returns (info: CacheResult)
  requires arr != null && cache != null && cache.Valid()
  requires cache.count == |cache.map|
  ensures cache.Valid()
  ensures info.cache_hits + info.cache_misses + info.cache_rejects == old(cache.count)
  ensures info.found ==> (0 <= info.index < arr.Length && arr[info.index] == key)
  ensures !info.found ==> info.index == arr.Length
  ensures forall i :: 0 <= i < info.index ==> arr[i] != key
{
  var idx: int := 0;
  var hits: int := 0;
  var misses: int := 0;
  var rejects: int := 0;
  
  while idx < arr.Length
    invariant 0 <= idx <= arr.Length
    invariant hits + misses + rejects == old(cache.count)
    invariant forall i :: 0 <= i < idx ==> arr[i] != key
    invariant cache.Valid()
  {
    // Check cache first
    if idx in cache.map {
      if cache.map[idx] == key {
        hits := hits + 1;
        info := CacheResult(hits, misses, rejects, true, idx);
        return;
      } else {
        rejects := rejects + 1;
      }
    } else {
      misses := misses + 1;
      // Add to cache
      cache.map := cache.map[idx := key];
      cache.count := cache.count + 1;
    }
    
    // Check current element
    if arr[idx] == key {
      info := CacheResult(hits, misses, rejects, true, idx);
      return;
    }
    
    idx := idx + 1;
  }
  
  info := CacheResult(hits, misses, rejects, false, arr.Length);
}

// Lemma to verify cache count consistency
lemma CacheCountConsistent(cache: Cache<int>)
  requires cache != null && cache.Valid()
  ensures cache.count == |cache.map|
{
  // The Valid predicate already ensures this
}

// Another version with strengthened preconditions
method FindKeyLinearWithCache(cache: Cache<int>, arr: array<int>, key: int) returns (info: CacheResult)
  requires arr != null && cache != null && cache.Valid()
  requires cache.count > 0
  requires exists i :: 0 <= i < arr.Length && i in cache.map
  ensures cache.Valid()
  ensures info.found ==> (0 <= info.index < arr.Length && arr[info.index] == key)
  ensures !info.found ==> info.index == arr.Length
  ensures forall i :: 0 <= i < info.index ==> arr[i] != key
{
  var idx: int := 0;
  var hits: int := 0;
  var misses: int := 0;
  var rejects: int := 0;
  
  while idx < arr.Length
    invariant 0 <= idx <= arr.Length
    invariant forall i :: 0 <= i < idx ==> arr[i] != key
    invariant cache.Valid()
  {
    // Check cache
    if idx in cache.map {
      if cache.map[idx] == key {
        hits := hits + 1;
        info := CacheResult(hits, misses, rejects, true, idx);
        return;
      } else {
        rejects := rejects + 1;
      }
    } else {
      misses := misses + 1;
    }
    
    // Check array element
    if arr[idx] == key {
      info := CacheResult(hits, misses, rejects, true, idx);
      return;
    }
    
    idx := idx + 1;
  }
  
  info := CacheResult(hits, misses, rejects, false, arr.Length);
}