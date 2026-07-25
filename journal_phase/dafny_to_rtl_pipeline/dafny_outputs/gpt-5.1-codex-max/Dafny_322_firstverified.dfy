class CubeUtil {
  method CubeSurfaceArea(edge: nat) returns (area: nat)
    ensures area == 6 * edge * edge
    ensures area >= 0
  {
    // Surface area of a cube is 6 times the square of its edge length
    area := 6 * edge * edge;
    assert area == 6 * edge * edge;
  }
}
