method ComputeVolume(size: int) returns (volume: int)
  requires size > 0
  ensures volume == size * size * size
{
  var i := 0;
  volume := 0;
  var square := size * size;

  while i < size
    invariant 0 <= i <= size
    invariant square == size * size
    invariant volume == i * square
    decreases size - i
  {
    volume := volume + square;
    i := i + 1;
  }

  assert i == size;
  assert volume == size * square;
  assert volume == size * size * size;
}
