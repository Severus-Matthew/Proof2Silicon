function PentagonPerimeter(side: int): int
    requires side >= 0
    ensures PentagonPerimeter(side) == 5 * side
{
    5 * side
}
