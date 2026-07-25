module SphereVolume {
  // Computes the volume of a sphere using:
  // V = (4/3) * pi * r^3
  method SphereVolume(radius: real) returns (volume: real)
    requires radius > 0.0
    ensures volume == (4.0 / 3.0) * 3.141592653589793 * radius * radius * radius
    ensures volume > 0.0
  {
    var pi: real := 3.141592653589793;
    volume := (4.0 / 3.0) * pi * radius * radius * radius;

    assert volume == (4.0 / 3.0) * pi * radius * radius * radius;
    assert volume > 0.0;
  }
}
