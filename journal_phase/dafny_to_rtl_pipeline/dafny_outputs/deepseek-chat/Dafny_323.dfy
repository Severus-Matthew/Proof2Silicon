method MultiplyMatrices(A: array2<int>, B: array2<int>) returns (C: array2<int>)
    requires A.Length0 > 0 && A.Length1 > 0 && B.Length0 > 0 && B.Length1 > 0
    requires A.Length1 == B.Length0
    ensures C.Length0 == A.Length0 && C.Length1 == B.Length1
    ensures forall i: int, j: int :: 0 <= i < A.Length0 && 0 <= j < B.Length1 ==> 
        C[i, j] == Sum(A, B, i, j)
{
    var rows := A.Length0;
    var cols := B.Length1;
    var common := A.Length1;
    C := new int[rows, cols];

    for i := 0 to rows
        invariant 0 <= i <= rows
        invariant forall i0: int, j0: int :: 0 <= i0 < i && 0 <= j0 < cols ==> 
            C[i0, j0] == Sum(A, B, i0, j0)
    {
        for j := 0 to cols
            invariant 0 <= j <= cols
            invariant forall i0: int, j0: int :: 0 <= i0 < i && 0 <= j0 < cols ==> 
                C[i0, j0] == Sum(A, B, i0, j0)
            invariant forall j0: int :: 0 <= j0 < j ==> C[i, j0] == Sum(A, B, i, j0)
        {
            var sum := 0;
            for k := 0 to common
                invariant 0 <= k <= common
                invariant sum == SumK(A, B, i, j, k)
            {
                sum := sum + A[i, k] * B[k, j];
            }
            C[i, j] := sum;
        }
    }
}

function Sum(A: array2<int>, B: array2<int>, i: int, j: int): int
    requires 0 <= i < A.Length0 && 0 <= j < B.Length1
    requires A.Length1 == B.Length0
    reads A, B
{
    if A.Length1 == 0 then 0 else SumK(A, B, i, j, A.Length1)
}

function SumK(A: array2<int>, B: array2<int>, i: int, j: int, k: int): int
    requires 0 <= i < A.Length0 && 0 <= j < B.Length1
    requires A.Length1 == B.Length0
    requires 0 <= k <= A.Length1
    reads A, B
{
    if k == 0 then 0 else SumK(A, B, i, j, k - 1) + A[i, k - 1] * B[k - 1, j]
}
