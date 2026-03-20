module GhostTest {

  const A := 10

  ghost const B := 20

  function F(x:int):int {
    x + A
  }

  predicate P(x:int)
  {
    x > 0
  }

  lemma L()
  {
  }

  method M()
  {
    ghost var g := 0;
  }

}
