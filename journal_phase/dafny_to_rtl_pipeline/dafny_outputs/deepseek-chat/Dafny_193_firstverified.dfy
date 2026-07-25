method mfirstNegative(a: array<int>) returns (index: int)
    requires a.Length > 0
    ensures -1 <= index < a.Length
    ensures index == -1 ==> forall i :: 0 <= i < a.Length ==> a[i] >= 0
    ensures index >= 0 ==> a[index] < 0 && forall i :: 0 <= i < index ==> a[i] >= 0
{
    var i := 0;
    index := -1;
    while i < a.Length
        invariant 0 <= i <= a.Length
        invariant index == -1 ==> forall j :: 0 <= j < i ==> a[j] >= 0
        invariant index >= 0 ==> index < i && a[index] < 0 && forall j :: 0 <= j < index ==> a[j] >= 0
        decreases a.Length - i
    {
        if a[i] < 0 {
            index := i;
            return;
        }
        i := i + 1;
    }
}
