const PI: real := 3.14159265358979323846

method SphereVolume(radius: real) returns (volume: real)
  requires radius > 0.0
  ensures volume == 4.0 / 3.0 * PI * radius * radius * radius
{
  volume := 4.0 / 3.0 * PI * radius * radius * radius;
}
