// dafny 4.11.0.0
// Command Line Options: /print:output.bpl /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy

const $$Language$Dafny: bool
uses {
axiom $$Language$Dafny;
}

type Ty;

type Bv0 = int;

const unique TBool: Ty
uses {
axiom Tag(TBool) == TagBool;
}

const unique TChar: Ty
uses {
axiom Tag(TChar) == TagChar;
}

const unique TInt: Ty
uses {
axiom Tag(TInt) == TagInt;
}

const unique TField: Ty
uses {
axiom Tag(TField) == TagField;
}

const unique TReal: Ty
uses {
axiom Tag(TReal) == TagReal;
}

const unique TORDINAL: Ty
uses {
axiom Tag(TORDINAL) == TagORDINAL;
}

revealed function TBitvector(int) : Ty;

axiom (forall w: int :: { TBitvector(w) } Inv0_TBitvector(TBitvector(w)) == w);

revealed function TSet(Ty) : Ty;

axiom (forall t: Ty :: { TSet(t) } Inv0_TSet(TSet(t)) == t);

axiom (forall t: Ty :: { TSet(t) } Tag(TSet(t)) == TagSet);

revealed function TISet(Ty) : Ty;

axiom (forall t: Ty :: { TISet(t) } Inv0_TISet(TISet(t)) == t);

axiom (forall t: Ty :: { TISet(t) } Tag(TISet(t)) == TagISet);

revealed function TMultiSet(Ty) : Ty;

axiom (forall t: Ty :: { TMultiSet(t) } Inv0_TMultiSet(TMultiSet(t)) == t);

axiom (forall t: Ty :: { TMultiSet(t) } Tag(TMultiSet(t)) == TagMultiSet);

revealed function TSeq(Ty) : Ty;

axiom (forall t: Ty :: { TSeq(t) } Inv0_TSeq(TSeq(t)) == t);

axiom (forall t: Ty :: { TSeq(t) } Tag(TSeq(t)) == TagSeq);

revealed function TMap(Ty, Ty) : Ty;

axiom (forall t: Ty, u: Ty :: { TMap(t, u) } Inv0_TMap(TMap(t, u)) == t);

axiom (forall t: Ty, u: Ty :: { TMap(t, u) } Inv1_TMap(TMap(t, u)) == u);

axiom (forall t: Ty, u: Ty :: { TMap(t, u) } Tag(TMap(t, u)) == TagMap);

revealed function TIMap(Ty, Ty) : Ty;

axiom (forall t: Ty, u: Ty :: { TIMap(t, u) } Inv0_TIMap(TIMap(t, u)) == t);

axiom (forall t: Ty, u: Ty :: { TIMap(t, u) } Inv1_TIMap(TIMap(t, u)) == u);

axiom (forall t: Ty, u: Ty :: { TIMap(t, u) } Tag(TIMap(t, u)) == TagIMap);

revealed function Inv0_TBitvector(Ty) : int;

revealed function Inv0_TSet(Ty) : Ty;

revealed function Inv0_TISet(Ty) : Ty;

revealed function Inv0_TSeq(Ty) : Ty;

revealed function Inv0_TMultiSet(Ty) : Ty;

revealed function Inv0_TMap(Ty) : Ty;

revealed function Inv1_TMap(Ty) : Ty;

revealed function Inv0_TIMap(Ty) : Ty;

revealed function Inv1_TIMap(Ty) : Ty;

type TyTag;

revealed function Tag(Ty) : TyTag;

const unique TagBool: TyTag;

const unique TagChar: TyTag;

const unique TagInt: TyTag;

const unique TagField: TyTag;

const unique TagReal: TyTag;

const unique TagORDINAL: TyTag;

const unique TagSet: TyTag;

const unique TagISet: TyTag;

const unique TagMultiSet: TyTag;

const unique TagSeq: TyTag;

const unique TagMap: TyTag;

const unique TagIMap: TyTag;

const unique TagClass: TyTag;

type TyTagFamily;

revealed function TagFamily(Ty) : TyTagFamily;

revealed function {:identity} Lit<T>(x: T) : T
uses {
axiom (forall<T> x: T :: {:identity} { Lit(x): T } Lit(x): T == x);
}

axiom (forall<T> x: T :: { $Box(Lit(x)) } $Box(Lit(x)) == Lit($Box(x)));

revealed function {:identity} LitInt(x: int) : int
uses {
axiom (forall x: int :: {:identity} { LitInt(x): int } LitInt(x): int == x);
}

axiom (forall x: int :: { $Box(LitInt(x)) } $Box(LitInt(x)) == Lit($Box(x)));

revealed function {:identity} LitReal(x: real) : real
uses {
axiom (forall x: real :: {:identity} { LitReal(x): real } LitReal(x): real == x);
}

axiom (forall x: real :: { $Box(LitReal(x)) } $Box(LitReal(x)) == Lit($Box(x)));

revealed function {:inline} char#IsChar(n: int) : bool
{
  (0 <= n && n < 55296) || (57344 <= n && n < 1114112)
}

type char;

revealed function char#FromInt(int) : char;

axiom (forall n: int :: 
  { char#FromInt(n) } 
  char#IsChar(n) ==> char#ToInt(char#FromInt(n)) == n);

revealed function char#ToInt(char) : int;

axiom (forall ch: char :: 
  { char#ToInt(ch) } 
  char#FromInt(char#ToInt(ch)) == ch && char#IsChar(char#ToInt(ch)));

revealed function char#Plus(char, char) : char;

axiom (forall a: char, b: char :: 
  { char#Plus(a, b) } 
  char#Plus(a, b) == char#FromInt(char#ToInt(a) + char#ToInt(b)));

revealed function char#Minus(char, char) : char;

axiom (forall a: char, b: char :: 
  { char#Minus(a, b) } 
  char#Minus(a, b) == char#FromInt(char#ToInt(a) - char#ToInt(b)));

type ref;

const null: ref;

const locals: ref;

type FieldFamily;

const unique object_field: FieldFamily;

revealed function field_depth(f: Field) : int;

revealed function field_family(f: Field) : FieldFamily;

revealed function local_field(ff: FieldFamily, depth: int) : Field
uses {
axiom (forall ff: FieldFamily, depth: int :: 
  {:trigger local_field(ff, depth)} 
  field_depth(local_field(ff, depth)) == depth
     && field_family(local_field(ff, depth)) == ff);
}

type Box;

const $ArbitraryBoxValue: Box;

revealed function $Box<T>(T) : Box;

revealed function $Unbox<T>(Box) : T;

axiom (forall<T> x: T :: {:weight 3} { $Box(x) } $Unbox($Box(x)) == x);

axiom (forall<T> x: Box :: { $Unbox(x): T } $Box($Unbox(x): T) == x);

revealed function $IsBox(Box, Ty) : bool;

revealed function $IsAllocBox(Box, Ty, Heap) : bool;

axiom (forall bx: Box :: 
  { $IsBox(bx, TInt) } 
  $IsBox(bx, TInt) ==> $Box($Unbox(bx): int) == bx && $Is($Unbox(bx): int, TInt));

axiom (forall bx: Box :: 
  { $IsBox(bx, TReal) } 
  $IsBox(bx, TReal)
     ==> $Box($Unbox(bx): real) == bx && $Is($Unbox(bx): real, TReal));

axiom (forall bx: Box :: 
  { $IsBox(bx, TBool) } 
  $IsBox(bx, TBool)
     ==> $Box($Unbox(bx): bool) == bx && $Is($Unbox(bx): bool, TBool));

axiom (forall bx: Box :: 
  { $IsBox(bx, TChar) } 
  $IsBox(bx, TChar)
     ==> $Box($Unbox(bx): char) == bx && $Is($Unbox(bx): char, TChar));

axiom (forall bx: Box :: 
  { $IsBox(bx, TBitvector(0)) } 
  $IsBox(bx, TBitvector(0))
     ==> $Box($Unbox(bx): Bv0) == bx && $Is($Unbox(bx): Bv0, TBitvector(0)));

axiom (forall bx: Box, t: Ty :: 
  { $IsBox(bx, TSet(t)) } 
  $IsBox(bx, TSet(t))
     ==> $Box($Unbox(bx): Set) == bx && $Is($Unbox(bx): Set, TSet(t)));

axiom (forall bx: Box, t: Ty :: 
  { $IsBox(bx, TISet(t)) } 
  $IsBox(bx, TISet(t))
     ==> $Box($Unbox(bx): ISet) == bx && $Is($Unbox(bx): ISet, TISet(t)));

axiom (forall bx: Box, t: Ty :: 
  { $IsBox(bx, TMultiSet(t)) } 
  $IsBox(bx, TMultiSet(t))
     ==> $Box($Unbox(bx): MultiSet) == bx && $Is($Unbox(bx): MultiSet, TMultiSet(t)));

axiom (forall bx: Box, t: Ty :: 
  { $IsBox(bx, TSeq(t)) } 
  $IsBox(bx, TSeq(t))
     ==> $Box($Unbox(bx): Seq) == bx && $Is($Unbox(bx): Seq, TSeq(t)));

axiom (forall bx: Box, s: Ty, t: Ty :: 
  { $IsBox(bx, TMap(s, t)) } 
  $IsBox(bx, TMap(s, t))
     ==> $Box($Unbox(bx): Map) == bx && $Is($Unbox(bx): Map, TMap(s, t)));

axiom (forall bx: Box, s: Ty, t: Ty :: 
  { $IsBox(bx, TIMap(s, t)) } 
  $IsBox(bx, TIMap(s, t))
     ==> $Box($Unbox(bx): IMap) == bx && $Is($Unbox(bx): IMap, TIMap(s, t)));

axiom (forall<T> v: T, t: Ty :: 
  { $IsBox($Box(v), t) } 
  $IsBox($Box(v), t) <==> $Is(v, t));

axiom (forall<T> v: T, t: Ty, h: Heap :: 
  { $IsAllocBox($Box(v), t, h) } 
  $IsAllocBox($Box(v), t, h) <==> $IsAlloc(v, t, h));

revealed function $Is<T>(T, Ty) : bool;

axiom (forall v: int :: { $Is(v, TInt) } $Is(v, TInt));

axiom (forall v: real :: { $Is(v, TReal) } $Is(v, TReal));

axiom (forall v: bool :: { $Is(v, TBool) } $Is(v, TBool));

axiom (forall v: char :: { $Is(v, TChar) } $Is(v, TChar));

axiom (forall v: Field :: { $Is(v, TField) } $Is(v, TField));

axiom (forall v: ORDINAL :: { $Is(v, TORDINAL) } $Is(v, TORDINAL));

axiom (forall v: Bv0 :: { $Is(v, TBitvector(0)) } $Is(v, TBitvector(0)));

axiom (forall v: Set, t0: Ty :: 
  { $Is(v, TSet(t0)) } 
  $Is(v, TSet(t0))
     <==> (forall bx: Box :: 
      { Set#IsMember(v, bx) } 
      Set#IsMember(v, bx) ==> $IsBox(bx, t0)));

axiom (forall v: ISet, t0: Ty :: 
  { $Is(v, TISet(t0)) } 
  $Is(v, TISet(t0)) <==> (forall bx: Box :: { v[bx] } v[bx] ==> $IsBox(bx, t0)));

axiom (forall v: MultiSet, t0: Ty :: 
  { $Is(v, TMultiSet(t0)) } 
  $Is(v, TMultiSet(t0))
     <==> (forall bx: Box :: 
      { MultiSet#Multiplicity(v, bx) } 
      0 < MultiSet#Multiplicity(v, bx) ==> $IsBox(bx, t0)));

axiom (forall v: MultiSet, t0: Ty :: 
  { $Is(v, TMultiSet(t0)) } 
  $Is(v, TMultiSet(t0)) ==> $IsGoodMultiSet(v));

axiom (forall v: Seq, t0: Ty :: 
  { $Is(v, TSeq(t0)) } 
  $Is(v, TSeq(t0))
     <==> (forall i: int :: 
      { Seq#Index(v, i) } 
      0 <= i && i < Seq#Length(v) ==> $IsBox(Seq#Index(v, i), t0)));

axiom (forall v: Map, t0: Ty, t1: Ty :: 
  { $Is(v, TMap(t0, t1)) } 
  $Is(v, TMap(t0, t1))
     <==> (forall bx: Box :: 
      { Map#Elements(v)[bx] } { Set#IsMember(Map#Domain(v), bx) } 
      Set#IsMember(Map#Domain(v), bx)
         ==> $IsBox(Map#Elements(v)[bx], t1) && $IsBox(bx, t0)));

axiom (forall v: Map, t0: Ty, t1: Ty :: 
  { $Is(v, TMap(t0, t1)) } 
  $Is(v, TMap(t0, t1))
     ==> $Is(Map#Domain(v), TSet(t0))
       && $Is(Map#Values(v), TSet(t1))
       && $Is(Map#Items(v), TSet(Tclass._System.Tuple2(t0, t1))));

axiom (forall v: IMap, t0: Ty, t1: Ty :: 
  { $Is(v, TIMap(t0, t1)) } 
  $Is(v, TIMap(t0, t1))
     <==> (forall bx: Box :: 
      { IMap#Elements(v)[bx] } { IMap#Domain(v)[bx] } 
      IMap#Domain(v)[bx] ==> $IsBox(IMap#Elements(v)[bx], t1) && $IsBox(bx, t0)));

axiom (forall v: IMap, t0: Ty, t1: Ty :: 
  { $Is(v, TIMap(t0, t1)) } 
  $Is(v, TIMap(t0, t1))
     ==> $Is(IMap#Domain(v), TISet(t0))
       && $Is(IMap#Values(v), TISet(t1))
       && $Is(IMap#Items(v), TISet(Tclass._System.Tuple2(t0, t1))));

revealed function $IsAlloc<T>(T, Ty, Heap) : bool;

axiom (forall h: Heap, v: int :: { $IsAlloc(v, TInt, h) } $IsAlloc(v, TInt, h));

axiom (forall h: Heap, v: real :: { $IsAlloc(v, TReal, h) } $IsAlloc(v, TReal, h));

axiom (forall h: Heap, v: bool :: { $IsAlloc(v, TBool, h) } $IsAlloc(v, TBool, h));

axiom (forall h: Heap, v: char :: { $IsAlloc(v, TChar, h) } $IsAlloc(v, TChar, h));

axiom (forall h: Heap, v: ORDINAL :: 
  { $IsAlloc(v, TORDINAL, h) } 
  $IsAlloc(v, TORDINAL, h));

axiom (forall v: Bv0, h: Heap :: 
  { $IsAlloc(v, TBitvector(0), h) } 
  $IsAlloc(v, TBitvector(0), h));

axiom (forall v: Set, t0: Ty, h: Heap :: 
  { $IsAlloc(v, TSet(t0), h) } 
  $IsAlloc(v, TSet(t0), h)
     <==> (forall bx: Box :: 
      { Set#IsMember(v, bx) } 
      Set#IsMember(v, bx) ==> $IsAllocBox(bx, t0, h)));

axiom (forall v: ISet, t0: Ty, h: Heap :: 
  { $IsAlloc(v, TISet(t0), h) } 
  $IsAlloc(v, TISet(t0), h)
     <==> (forall bx: Box :: { v[bx] } v[bx] ==> $IsAllocBox(bx, t0, h)));

axiom (forall v: MultiSet, t0: Ty, h: Heap :: 
  { $IsAlloc(v, TMultiSet(t0), h) } 
  $IsAlloc(v, TMultiSet(t0), h)
     <==> (forall bx: Box :: 
      { MultiSet#Multiplicity(v, bx) } 
      0 < MultiSet#Multiplicity(v, bx) ==> $IsAllocBox(bx, t0, h)));

axiom (forall v: Seq, t0: Ty, h: Heap :: 
  { $IsAlloc(v, TSeq(t0), h) } 
  $IsAlloc(v, TSeq(t0), h)
     <==> (forall i: int :: 
      { Seq#Index(v, i) } 
      0 <= i && i < Seq#Length(v) ==> $IsAllocBox(Seq#Index(v, i), t0, h)));

axiom (forall v: Map, t0: Ty, t1: Ty, h: Heap :: 
  { $IsAlloc(v, TMap(t0, t1), h) } 
  $IsAlloc(v, TMap(t0, t1), h)
     <==> (forall bx: Box :: 
      { Map#Elements(v)[bx] } { Set#IsMember(Map#Domain(v), bx) } 
      Set#IsMember(Map#Domain(v), bx)
         ==> $IsAllocBox(Map#Elements(v)[bx], t1, h) && $IsAllocBox(bx, t0, h)));

axiom (forall v: IMap, t0: Ty, t1: Ty, h: Heap :: 
  { $IsAlloc(v, TIMap(t0, t1), h) } 
  $IsAlloc(v, TIMap(t0, t1), h)
     <==> (forall bx: Box :: 
      { IMap#Elements(v)[bx] } { IMap#Domain(v)[bx] } 
      IMap#Domain(v)[bx]
         ==> $IsAllocBox(IMap#Elements(v)[bx], t1, h) && $IsAllocBox(bx, t0, h)));

revealed function $AlwaysAllocated(Ty) : bool;

axiom (forall ty: Ty :: 
  { $AlwaysAllocated(ty) } 
  $AlwaysAllocated(ty)
     ==> (forall h: Heap, v: Box :: 
      { $IsAllocBox(v, ty, h) } 
      $IsBox(v, ty) ==> $IsAllocBox(v, ty, h)));

revealed function $OlderTag(Heap) : bool;

type ClassName;

const unique class._System.int: ClassName;

const unique class._System.bool: ClassName;

const unique class._System.set: ClassName;

const unique class._System.seq: ClassName;

const unique class._System.multiset: ClassName;

revealed function Tclass._System.object?() : Ty
uses {
// Tclass._System.object? Tag
axiom Tag(Tclass._System.object?()) == Tagclass._System.object?
   && TagFamily(Tclass._System.object?()) == tytagFamily$object;
}

revealed function Tclass._System.Tuple2(Ty, Ty) : Ty;

revealed function dtype(ref) : Ty;

revealed function TypeTuple(a: ClassName, b: ClassName) : ClassName;

revealed function TypeTupleCar(ClassName) : ClassName;

revealed function TypeTupleCdr(ClassName) : ClassName;

axiom (forall a: ClassName, b: ClassName :: 
  { TypeTuple(a, b) } 
  TypeTupleCar(TypeTuple(a, b)) == a && TypeTupleCdr(TypeTuple(a, b)) == b);

type HandleType;

revealed function SetRef_to_SetBox(s: [ref]bool) : Set;

axiom (forall s: [ref]bool, bx: Box :: 
  { Set#IsMember(SetRef_to_SetBox(s), bx) } 
  Set#IsMember(SetRef_to_SetBox(s), bx) == s[$Unbox(bx): ref]);

axiom (forall s: [ref]bool :: 
  { SetRef_to_SetBox(s) } 
  $Is(SetRef_to_SetBox(s), TSet(Tclass._System.object?())));

revealed function Apply1(Ty, Ty, Heap, HandleType, Box) : Box;

type DatatypeType;

type DtCtorId;

revealed function DatatypeCtorId(DatatypeType) : DtCtorId;

revealed function DtRank(DatatypeType) : int;

revealed function BoxRank(Box) : int;

axiom (forall d: DatatypeType :: { BoxRank($Box(d)) } BoxRank($Box(d)) == DtRank(d));

type ORDINAL = Box;

revealed function ORD#IsNat(ORDINAL) : bool;

revealed function ORD#Offset(ORDINAL) : int;

axiom (forall o: ORDINAL :: { ORD#Offset(o) } 0 <= ORD#Offset(o));

revealed function {:inline} ORD#IsLimit(o: ORDINAL) : bool
{
  ORD#Offset(o) == 0
}

revealed function {:inline} ORD#IsSucc(o: ORDINAL) : bool
{
  0 < ORD#Offset(o)
}

revealed function ORD#FromNat(int) : ORDINAL;

axiom (forall n: int :: 
  { ORD#FromNat(n) } 
  0 <= n ==> ORD#IsNat(ORD#FromNat(n)) && ORD#Offset(ORD#FromNat(n)) == n);

axiom (forall o: ORDINAL :: 
  { ORD#Offset(o) } { ORD#IsNat(o) } 
  ORD#IsNat(o) ==> o == ORD#FromNat(ORD#Offset(o)));

revealed function ORD#Less(ORDINAL, ORDINAL) : bool;

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#Less(o, p) } 
  (ORD#Less(o, p) ==> o != p)
     && (ORD#IsNat(o) && !ORD#IsNat(p) ==> ORD#Less(o, p))
     && (ORD#IsNat(o) && ORD#IsNat(p)
       ==> ORD#Less(o, p) == (ORD#Offset(o) < ORD#Offset(p)))
     && (ORD#Less(o, p) && ORD#IsNat(p) ==> ORD#IsNat(o)));

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#Less(o, p), ORD#Less(p, o) } 
  ORD#Less(o, p) || o == p || ORD#Less(p, o));

axiom (forall o: ORDINAL, p: ORDINAL, r: ORDINAL :: 
  { ORD#Less(o, p), ORD#Less(p, r) } { ORD#Less(o, p), ORD#Less(o, r) } 
  ORD#Less(o, p) && ORD#Less(p, r) ==> ORD#Less(o, r));

revealed function ORD#LessThanLimit(ORDINAL, ORDINAL) : bool;

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#LessThanLimit(o, p) } 
  ORD#LessThanLimit(o, p) == ORD#Less(o, p));

revealed function ORD#Plus(ORDINAL, ORDINAL) : ORDINAL;

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#Plus(o, p) } 
  (ORD#IsNat(ORD#Plus(o, p)) ==> ORD#IsNat(o) && ORD#IsNat(p))
     && (ORD#IsNat(p)
       ==> ORD#IsNat(ORD#Plus(o, p)) == ORD#IsNat(o)
         && ORD#Offset(ORD#Plus(o, p)) == ORD#Offset(o) + ORD#Offset(p)));

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#Plus(o, p) } 
  (o == ORD#Plus(o, p) || ORD#Less(o, ORD#Plus(o, p)))
     && (p == ORD#Plus(o, p) || ORD#Less(p, ORD#Plus(o, p))));

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#Plus(o, p) } 
  (o == ORD#FromNat(0) ==> ORD#Plus(o, p) == p)
     && (p == ORD#FromNat(0) ==> ORD#Plus(o, p) == o));

revealed function ORD#Minus(ORDINAL, ORDINAL) : ORDINAL;

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#Minus(o, p) } 
  ORD#IsNat(p) && ORD#Offset(p) <= ORD#Offset(o)
     ==> ORD#IsNat(ORD#Minus(o, p)) == ORD#IsNat(o)
       && ORD#Offset(ORD#Minus(o, p)) == ORD#Offset(o) - ORD#Offset(p));

axiom (forall o: ORDINAL, p: ORDINAL :: 
  { ORD#Minus(o, p) } 
  ORD#IsNat(p) && ORD#Offset(p) <= ORD#Offset(o)
     ==> (p == ORD#FromNat(0) && ORD#Minus(o, p) == o)
       || (p != ORD#FromNat(0) && ORD#Less(ORD#Minus(o, p), o)));

axiom (forall o: ORDINAL, m: int, n: int :: 
  { ORD#Plus(ORD#Plus(o, ORD#FromNat(m)), ORD#FromNat(n)) } 
  0 <= m && 0 <= n
     ==> ORD#Plus(ORD#Plus(o, ORD#FromNat(m)), ORD#FromNat(n))
       == ORD#Plus(o, ORD#FromNat(m + n)));

axiom (forall o: ORDINAL, m: int, n: int :: 
  { ORD#Minus(ORD#Minus(o, ORD#FromNat(m)), ORD#FromNat(n)) } 
  0 <= m && 0 <= n && m + n <= ORD#Offset(o)
     ==> ORD#Minus(ORD#Minus(o, ORD#FromNat(m)), ORD#FromNat(n))
       == ORD#Minus(o, ORD#FromNat(m + n)));

axiom (forall o: ORDINAL, m: int, n: int :: 
  { ORD#Minus(ORD#Plus(o, ORD#FromNat(m)), ORD#FromNat(n)) } 
  0 <= m && 0 <= n && n <= ORD#Offset(o) + m
     ==> (0 <= m - n
         ==> ORD#Minus(ORD#Plus(o, ORD#FromNat(m)), ORD#FromNat(n))
           == ORD#Plus(o, ORD#FromNat(m - n)))
       && (m - n <= 0
         ==> ORD#Minus(ORD#Plus(o, ORD#FromNat(m)), ORD#FromNat(n))
           == ORD#Minus(o, ORD#FromNat(n - m))));

axiom (forall o: ORDINAL, m: int, n: int :: 
  { ORD#Plus(ORD#Minus(o, ORD#FromNat(m)), ORD#FromNat(n)) } 
  0 <= m && 0 <= n && n <= ORD#Offset(o) + m
     ==> (0 <= m - n
         ==> ORD#Plus(ORD#Minus(o, ORD#FromNat(m)), ORD#FromNat(n))
           == ORD#Minus(o, ORD#FromNat(m - n)))
       && (m - n <= 0
         ==> ORD#Plus(ORD#Minus(o, ORD#FromNat(m)), ORD#FromNat(n))
           == ORD#Plus(o, ORD#FromNat(n - m))));

type LayerType;

const $LZ: LayerType;

revealed function $LS(LayerType) : LayerType;

revealed function AsFuelBottom(LayerType) : LayerType;

revealed function AtLayer<A>([LayerType]A, LayerType) : A;

axiom (forall<A> f: [LayerType]A, ly: LayerType :: 
  { AtLayer(f, ly) } 
  AtLayer(f, ly) == f[ly]);

axiom (forall<A> f: [LayerType]A, ly: LayerType :: 
  { AtLayer(f, $LS(ly)) } 
  AtLayer(f, $LS(ly)) == AtLayer(f, ly));

type Field;

revealed function FDim(Field) : int
uses {
axiom FDim(alloc) == 0;
}

revealed function IndexField(int) : Field;

axiom (forall i: int :: { IndexField(i) } FDim(IndexField(i)) == 1);

revealed function IndexField_Inverse(Field) : int;

axiom (forall i: int :: { IndexField(i) } IndexField_Inverse(IndexField(i)) == i);

revealed function MultiIndexField(Field, int) : Field;

axiom (forall f: Field, i: int :: 
  { MultiIndexField(f, i) } 
  FDim(MultiIndexField(f, i)) == FDim(f) + 1);

revealed function MultiIndexField_Inverse0(Field) : Field;

revealed function MultiIndexField_Inverse1(Field) : int;

axiom (forall f: Field, i: int :: 
  { MultiIndexField(f, i) } 
  MultiIndexField_Inverse0(MultiIndexField(f, i)) == f
     && MultiIndexField_Inverse1(MultiIndexField(f, i)) == i);

revealed function DeclType(Field) : ClassName;

type NameFamily;

revealed function DeclName(Field) : NameFamily
uses {
axiom DeclName(alloc) == allocName;
}

revealed function FieldOfDecl(ClassName, NameFamily) : Field;

axiom (forall cl: ClassName, nm: NameFamily :: 
  { FieldOfDecl(cl, nm): Field } 
  DeclType(FieldOfDecl(cl, nm): Field) == cl
     && DeclName(FieldOfDecl(cl, nm): Field) == nm);

revealed function $IsGhostField(Field) : bool
uses {
axiom $IsGhostField(alloc);
}

axiom (forall h: Heap, k: Heap :: 
  { $HeapSuccGhost(h, k) } 
  $HeapSuccGhost(h, k)
     ==> $HeapSucc(h, k)
       && (forall o: ref, f: Field :: 
        { read(k, o, f) } 
        !$IsGhostField(f) ==> read(h, o, f) == read(k, o, f)));

axiom (forall<T> h: Heap, k: Heap, v: T, t: Ty :: 
  { $HeapSucc(h, k), $IsAlloc(v, t, h) } 
  $HeapSucc(h, k) ==> $IsAlloc(v, t, h) ==> $IsAlloc(v, t, k));

axiom (forall h: Heap, k: Heap, bx: Box, t: Ty :: 
  { $HeapSucc(h, k), $IsAllocBox(bx, t, h) } 
  $HeapSucc(h, k) ==> $IsAllocBox(bx, t, h) ==> $IsAllocBox(bx, t, k));

const unique alloc: Field;

const unique allocName: NameFamily;

revealed function _System.array.Length(a: ref) : int;

axiom (forall o: ref :: { _System.array.Length(o) } 0 <= _System.array.Length(o));

revealed function Int(x: real) : int
uses {
axiom (forall x: real :: { Int(x): int } Int(x): int == int(x));
}

revealed function Real(x: int) : real
uses {
axiom (forall x: int :: { Real(x): real } Real(x): real == real(x));
}

axiom (forall i: int :: { Int(Real(i)) } Int(Real(i)) == i);

revealed function {:inline} _System.real.Floor(x: real) : int
{
  Int(x)
}

type Heap = [ref][Field]Box;

revealed function {:inline} read(H: Heap, r: ref, f: Field) : Box
{
  H[r][f]
}

revealed function {:inline} update(H: Heap, r: ref, f: Field, v: Box) : Heap
{
  H[r := H[r][f := v]]
}

revealed function $IsGoodHeap(Heap) : bool;

revealed function $IsHeapAnchor(Heap) : bool;

var $Heap: Heap where $IsGoodHeap($Heap) && $IsHeapAnchor($Heap);

const $OneHeap: Heap
uses {
axiom $IsGoodHeap($OneHeap);
}

revealed function $HeapSucc(Heap, Heap) : bool;

axiom (forall h: Heap, r: ref, f: Field, x: Box :: 
  { update(h, r, f, x) } 
  $IsGoodHeap(update(h, r, f, x)) ==> $HeapSucc(h, update(h, r, f, x)));

axiom (forall a: Heap, b: Heap, c: Heap :: 
  { $HeapSucc(a, b), $HeapSucc(b, c) } 
  a != c ==> $HeapSucc(a, b) && $HeapSucc(b, c) ==> $HeapSucc(a, c));

axiom (forall h: Heap, k: Heap :: 
  { $HeapSucc(h, k) } 
  $HeapSucc(h, k)
     ==> (forall o: ref :: 
      { read(k, o, alloc) } 
      $Unbox(read(h, o, alloc)) ==> $Unbox(read(k, o, alloc))));

revealed function $HeapSuccGhost(Heap, Heap) : bool;

procedure $YieldHavoc(this: ref, rds: Set, nw: Set);
  modifies $Heap;
  ensures (forall $o: ref, $f: Field :: 
    { read($Heap, $o, $f) } 
    $o != null && $Unbox(read(old($Heap), $o, alloc))
       ==> 
      $o == this || Set#IsMember(rds, $Box($o)) || Set#IsMember(nw, $Box($o))
       ==> read($Heap, $o, $f) == read(old($Heap), $o, $f));
  ensures $HeapSucc(old($Heap), $Heap);



procedure $IterHavoc0(this: ref, rds: Set, modi: Set);
  modifies $Heap;
  ensures (forall $o: ref, $f: Field :: 
    { read($Heap, $o, $f) } 
    $o != null && $Unbox(read(old($Heap), $o, alloc))
       ==> 
      Set#IsMember(rds, $Box($o)) && !Set#IsMember(modi, $Box($o)) && $o != this
       ==> read($Heap, $o, $f) == read(old($Heap), $o, $f));
  ensures $HeapSucc(old($Heap), $Heap);



procedure $IterHavoc1(this: ref, modi: Set, nw: Set);
  modifies $Heap;
  ensures (forall $o: ref, $f: Field :: 
    { read($Heap, $o, $f) } 
    $o != null && $Unbox(read(old($Heap), $o, alloc))
       ==> read($Heap, $o, $f) == read(old($Heap), $o, $f)
         || $o == this
         || Set#IsMember(modi, $Box($o))
         || Set#IsMember(nw, $Box($o)));
  ensures $HeapSucc(old($Heap), $Heap);



procedure $IterCollectNewObjects(prevHeap: Heap, newHeap: Heap, this: ref, NW: Field) returns (s: Set);
  ensures (forall bx: Box :: 
    { Set#IsMember(s, bx) } 
    Set#IsMember(s, bx)
       <==> Set#IsMember($Unbox(read(newHeap, this, NW)): Set, bx)
         || (
          $Unbox(bx) != null
           && !$Unbox(read(prevHeap, $Unbox(bx): ref, alloc))
           && $Unbox(read(newHeap, $Unbox(bx): ref, alloc))));



type Set;

revealed function Set#Card(s: Set) : int;

axiom (forall s: Set :: { Set#Card(s) } 0 <= Set#Card(s));

revealed function Set#Empty() : Set;

revealed function Set#IsMember(s: Set, o: Box) : bool;

axiom (forall o: Box :: 
  { Set#IsMember(Set#Empty(), o) } 
  !Set#IsMember(Set#Empty(), o));

axiom (forall s: Set :: 
  { Set#Card(s) } 
  (Set#Card(s) == 0 <==> s == Set#Empty())
     && (Set#Card(s) != 0
       ==> (exists x: Box :: { Set#IsMember(s, x) } Set#IsMember(s, x))));

revealed function Set#UnionOne(s: Set, o: Box) : Set;

axiom (forall a: Set, x: Box, o: Box :: 
  { Set#IsMember(Set#UnionOne(a, x), o) } 
  Set#IsMember(Set#UnionOne(a, x), o) <==> o == x || Set#IsMember(a, o));

axiom (forall a: Set, x: Box :: 
  { Set#UnionOne(a, x) } 
  Set#IsMember(Set#UnionOne(a, x), x));

axiom (forall a: Set, x: Box, y: Box :: 
  { Set#UnionOne(a, x), Set#IsMember(a, y) } 
  Set#IsMember(a, y) ==> Set#IsMember(Set#UnionOne(a, x), y));

axiom (forall a: Set, x: Box :: 
  { Set#Card(Set#UnionOne(a, x)) } 
  Set#IsMember(a, x) ==> Set#Card(Set#UnionOne(a, x)) == Set#Card(a));

axiom (forall a: Set, x: Box :: 
  { Set#Card(Set#UnionOne(a, x)) } 
  !Set#IsMember(a, x) ==> Set#Card(Set#UnionOne(a, x)) == Set#Card(a) + 1);

revealed function Set#Union(a: Set, b: Set) : Set;

axiom (forall a: Set, b: Set, o: Box :: 
  { Set#IsMember(Set#Union(a, b), o) } 
  Set#IsMember(Set#Union(a, b), o) <==> Set#IsMember(a, o) || Set#IsMember(b, o));

axiom (forall a: Set, b: Set, y: Box :: 
  { Set#Union(a, b), Set#IsMember(a, y) } 
  Set#IsMember(a, y) ==> Set#IsMember(Set#Union(a, b), y));

axiom (forall a: Set, b: Set, y: Box :: 
  { Set#Union(a, b), Set#IsMember(b, y) } 
  Set#IsMember(b, y) ==> Set#IsMember(Set#Union(a, b), y));

axiom (forall a: Set, b: Set :: 
  { Set#Union(a, b) } 
  Set#Disjoint(a, b)
     ==> Set#Difference(Set#Union(a, b), a) == b
       && Set#Difference(Set#Union(a, b), b) == a);

revealed function Set#Intersection(a: Set, b: Set) : Set;

axiom (forall a: Set, b: Set, o: Box :: 
  { Set#IsMember(Set#Intersection(a, b), o) } 
  Set#IsMember(Set#Intersection(a, b), o)
     <==> Set#IsMember(a, o) && Set#IsMember(b, o));

axiom (forall a: Set, b: Set :: 
  { Set#Union(Set#Union(a, b), b) } 
  Set#Union(Set#Union(a, b), b) == Set#Union(a, b));

axiom (forall a: Set, b: Set :: 
  { Set#Union(a, Set#Union(a, b)) } 
  Set#Union(a, Set#Union(a, b)) == Set#Union(a, b));

axiom (forall a: Set, b: Set :: 
  { Set#Intersection(Set#Intersection(a, b), b) } 
  Set#Intersection(Set#Intersection(a, b), b) == Set#Intersection(a, b));

axiom (forall a: Set, b: Set :: 
  { Set#Intersection(a, Set#Intersection(a, b)) } 
  Set#Intersection(a, Set#Intersection(a, b)) == Set#Intersection(a, b));

axiom (forall a: Set, b: Set :: 
  { Set#Card(Set#Union(a, b)) } { Set#Card(Set#Intersection(a, b)) } 
  Set#Card(Set#Union(a, b)) + Set#Card(Set#Intersection(a, b))
     == Set#Card(a) + Set#Card(b));

revealed function Set#Difference(a: Set, b: Set) : Set;

axiom (forall a: Set, b: Set, o: Box :: 
  { Set#IsMember(Set#Difference(a, b), o) } 
  Set#IsMember(Set#Difference(a, b), o)
     <==> Set#IsMember(a, o) && !Set#IsMember(b, o));

axiom (forall a: Set, b: Set, y: Box :: 
  { Set#Difference(a, b), Set#IsMember(b, y) } 
  Set#IsMember(b, y) ==> !Set#IsMember(Set#Difference(a, b), y));

axiom (forall a: Set, b: Set :: 
  { Set#Card(Set#Difference(a, b)) } 
  Set#Card(Set#Difference(a, b))
         + Set#Card(Set#Difference(b, a))
         + Set#Card(Set#Intersection(a, b))
       == Set#Card(Set#Union(a, b))
     && Set#Card(Set#Difference(a, b)) == Set#Card(a) - Set#Card(Set#Intersection(a, b)));

revealed function Set#Subset(a: Set, b: Set) : bool;

axiom (forall a: Set, b: Set :: 
  { Set#Subset(a, b) } 
  Set#Subset(a, b)
     <==> (forall o: Box :: 
      { Set#IsMember(a, o) } { Set#IsMember(b, o) } 
      Set#IsMember(a, o) ==> Set#IsMember(b, o)));

revealed function Set#Equal(a: Set, b: Set) : bool;

axiom (forall a: Set, b: Set :: 
  { Set#Equal(a, b) } 
  Set#Equal(a, b)
     <==> (forall o: Box :: 
      { Set#IsMember(a, o) } { Set#IsMember(b, o) } 
      Set#IsMember(a, o) <==> Set#IsMember(b, o)));

axiom (forall a: Set, b: Set :: { Set#Equal(a, b) } Set#Equal(a, b) ==> a == b);

revealed function Set#Disjoint(a: Set, b: Set) : bool;

axiom (forall a: Set, b: Set :: 
  { Set#Disjoint(a, b) } 
  Set#Disjoint(a, b)
     <==> (forall o: Box :: 
      { Set#IsMember(a, o) } { Set#IsMember(b, o) } 
      !Set#IsMember(a, o) || !Set#IsMember(b, o)));

revealed function Set#FromBoogieMap([Box]bool) : Set;

axiom (forall m: [Box]bool, bx: Box :: 
  { Set#IsMember(Set#FromBoogieMap(m), bx) } 
  Set#IsMember(Set#FromBoogieMap(m), bx) == m[bx]);

type ISet = [Box]bool;

revealed function ISet#Empty() : ISet;

axiom (forall o: Box :: { ISet#Empty()[o] } !ISet#Empty()[o]);

revealed function ISet#FromSet(Set) : ISet;

axiom (forall s: Set, bx: Box :: 
  { ISet#FromSet(s)[bx] } 
  ISet#FromSet(s)[bx] == Set#IsMember(s, bx));

revealed function ISet#UnionOne(ISet, Box) : ISet;

axiom (forall a: ISet, x: Box, o: Box :: 
  { ISet#UnionOne(a, x)[o] } 
  ISet#UnionOne(a, x)[o] <==> o == x || a[o]);

axiom (forall a: ISet, x: Box :: { ISet#UnionOne(a, x) } ISet#UnionOne(a, x)[x]);

axiom (forall a: ISet, x: Box, y: Box :: 
  { ISet#UnionOne(a, x), a[y] } 
  a[y] ==> ISet#UnionOne(a, x)[y]);

revealed function ISet#Union(ISet, ISet) : ISet;

axiom (forall a: ISet, b: ISet, o: Box :: 
  { ISet#Union(a, b)[o] } 
  ISet#Union(a, b)[o] <==> a[o] || b[o]);

axiom (forall a: ISet, b: ISet, y: Box :: 
  { ISet#Union(a, b), a[y] } 
  a[y] ==> ISet#Union(a, b)[y]);

axiom (forall a: ISet, b: ISet, y: Box :: 
  { ISet#Union(a, b), b[y] } 
  b[y] ==> ISet#Union(a, b)[y]);

axiom (forall a: ISet, b: ISet :: 
  { ISet#Union(a, b) } 
  ISet#Disjoint(a, b)
     ==> ISet#Difference(ISet#Union(a, b), a) == b
       && ISet#Difference(ISet#Union(a, b), b) == a);

revealed function ISet#Intersection(ISet, ISet) : ISet;

axiom (forall a: ISet, b: ISet, o: Box :: 
  { ISet#Intersection(a, b)[o] } 
  ISet#Intersection(a, b)[o] <==> a[o] && b[o]);

axiom (forall a: ISet, b: ISet :: 
  { ISet#Union(ISet#Union(a, b), b) } 
  ISet#Union(ISet#Union(a, b), b) == ISet#Union(a, b));

axiom (forall a: ISet, b: ISet :: 
  { ISet#Union(a, ISet#Union(a, b)) } 
  ISet#Union(a, ISet#Union(a, b)) == ISet#Union(a, b));

axiom (forall a: ISet, b: ISet :: 
  { ISet#Intersection(ISet#Intersection(a, b), b) } 
  ISet#Intersection(ISet#Intersection(a, b), b) == ISet#Intersection(a, b));

axiom (forall a: ISet, b: ISet :: 
  { ISet#Intersection(a, ISet#Intersection(a, b)) } 
  ISet#Intersection(a, ISet#Intersection(a, b)) == ISet#Intersection(a, b));

revealed function ISet#Difference(ISet, ISet) : ISet;

axiom (forall a: ISet, b: ISet, o: Box :: 
  { ISet#Difference(a, b)[o] } 
  ISet#Difference(a, b)[o] <==> a[o] && !b[o]);

axiom (forall a: ISet, b: ISet, y: Box :: 
  { ISet#Difference(a, b), b[y] } 
  b[y] ==> !ISet#Difference(a, b)[y]);

revealed function ISet#Subset(ISet, ISet) : bool;

axiom (forall a: ISet, b: ISet :: 
  { ISet#Subset(a, b) } 
  ISet#Subset(a, b) <==> (forall o: Box :: { a[o] } { b[o] } a[o] ==> b[o]));

revealed function ISet#Equal(ISet, ISet) : bool;

axiom (forall a: ISet, b: ISet :: 
  { ISet#Equal(a, b) } 
  ISet#Equal(a, b) <==> (forall o: Box :: { a[o] } { b[o] } a[o] <==> b[o]));

axiom (forall a: ISet, b: ISet :: { ISet#Equal(a, b) } ISet#Equal(a, b) ==> a == b);

revealed function ISet#Disjoint(ISet, ISet) : bool;

axiom (forall a: ISet, b: ISet :: 
  { ISet#Disjoint(a, b) } 
  ISet#Disjoint(a, b) <==> (forall o: Box :: { a[o] } { b[o] } !a[o] || !b[o]));

revealed function Math#min(a: int, b: int) : int;

axiom (forall a: int, b: int :: { Math#min(a, b) } a <= b <==> Math#min(a, b) == a);

axiom (forall a: int, b: int :: { Math#min(a, b) } b <= a <==> Math#min(a, b) == b);

axiom (forall a: int, b: int :: 
  { Math#min(a, b) } 
  Math#min(a, b) == a || Math#min(a, b) == b);

revealed function Math#clip(a: int) : int;

axiom (forall a: int :: { Math#clip(a) } 0 <= a ==> Math#clip(a) == a);

axiom (forall a: int :: { Math#clip(a) } a < 0 ==> Math#clip(a) == 0);

type MultiSet;

revealed function MultiSet#Multiplicity(m: MultiSet, o: Box) : int;

revealed function MultiSet#UpdateMultiplicity(m: MultiSet, o: Box, n: int) : MultiSet;

axiom (forall m: MultiSet, o: Box, n: int, p: Box :: 
  { MultiSet#Multiplicity(MultiSet#UpdateMultiplicity(m, o, n), p) } 
  0 <= n
     ==> (o == p ==> MultiSet#Multiplicity(MultiSet#UpdateMultiplicity(m, o, n), p) == n)
       && (o != p
         ==> MultiSet#Multiplicity(MultiSet#UpdateMultiplicity(m, o, n), p)
           == MultiSet#Multiplicity(m, p)));

revealed function $IsGoodMultiSet(ms: MultiSet) : bool;

axiom (forall ms: MultiSet :: 
  { $IsGoodMultiSet(ms) } 
  $IsGoodMultiSet(ms)
     <==> (forall bx: Box :: 
      { MultiSet#Multiplicity(ms, bx) } 
      0 <= MultiSet#Multiplicity(ms, bx)
         && MultiSet#Multiplicity(ms, bx) <= MultiSet#Card(ms)));

revealed function MultiSet#Card(m: MultiSet) : int;

axiom (forall s: MultiSet :: { MultiSet#Card(s) } 0 <= MultiSet#Card(s));

axiom (forall s: MultiSet, x: Box, n: int :: 
  { MultiSet#Card(MultiSet#UpdateMultiplicity(s, x, n)) } 
  0 <= n
     ==> MultiSet#Card(MultiSet#UpdateMultiplicity(s, x, n))
       == MultiSet#Card(s) - MultiSet#Multiplicity(s, x) + n);

revealed function MultiSet#Empty() : MultiSet;

axiom (forall o: Box :: 
  { MultiSet#Multiplicity(MultiSet#Empty(), o) } 
  MultiSet#Multiplicity(MultiSet#Empty(), o) == 0);

axiom (forall s: MultiSet :: 
  { MultiSet#Card(s) } 
  (MultiSet#Card(s) == 0 <==> s == MultiSet#Empty())
     && (MultiSet#Card(s) != 0
       ==> (exists x: Box :: 
        { MultiSet#Multiplicity(s, x) } 
        0 < MultiSet#Multiplicity(s, x))));

revealed function MultiSet#Singleton(o: Box) : MultiSet;

axiom (forall r: Box, o: Box :: 
  { MultiSet#Multiplicity(MultiSet#Singleton(r), o) } 
  (MultiSet#Multiplicity(MultiSet#Singleton(r), o) == 1 <==> r == o)
     && (MultiSet#Multiplicity(MultiSet#Singleton(r), o) == 0 <==> r != o));

axiom (forall r: Box :: 
  { MultiSet#Singleton(r) } 
  MultiSet#Singleton(r) == MultiSet#UnionOne(MultiSet#Empty(), r));

revealed function MultiSet#UnionOne(m: MultiSet, o: Box) : MultiSet;

axiom (forall a: MultiSet, x: Box, o: Box :: 
  { MultiSet#Multiplicity(MultiSet#UnionOne(a, x), o) } 
  0 < MultiSet#Multiplicity(MultiSet#UnionOne(a, x), o)
     <==> o == x || 0 < MultiSet#Multiplicity(a, o));

axiom (forall a: MultiSet, x: Box :: 
  { MultiSet#UnionOne(a, x) } 
  MultiSet#Multiplicity(MultiSet#UnionOne(a, x), x)
     == MultiSet#Multiplicity(a, x) + 1);

axiom (forall a: MultiSet, x: Box, y: Box :: 
  { MultiSet#UnionOne(a, x), MultiSet#Multiplicity(a, y) } 
  0 < MultiSet#Multiplicity(a, y)
     ==> 0 < MultiSet#Multiplicity(MultiSet#UnionOne(a, x), y));

axiom (forall a: MultiSet, x: Box, y: Box :: 
  { MultiSet#UnionOne(a, x), MultiSet#Multiplicity(a, y) } 
  x != y
     ==> MultiSet#Multiplicity(a, y) == MultiSet#Multiplicity(MultiSet#UnionOne(a, x), y));

axiom (forall a: MultiSet, x: Box :: 
  { MultiSet#Card(MultiSet#UnionOne(a, x)) } 
  MultiSet#Card(MultiSet#UnionOne(a, x)) == MultiSet#Card(a) + 1);

revealed function MultiSet#Union(a: MultiSet, b: MultiSet) : MultiSet;

axiom (forall a: MultiSet, b: MultiSet, o: Box :: 
  { MultiSet#Multiplicity(MultiSet#Union(a, b), o) } 
  MultiSet#Multiplicity(MultiSet#Union(a, b), o)
     == MultiSet#Multiplicity(a, o) + MultiSet#Multiplicity(b, o));

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Card(MultiSet#Union(a, b)) } 
  MultiSet#Card(MultiSet#Union(a, b)) == MultiSet#Card(a) + MultiSet#Card(b));

revealed function MultiSet#Intersection(a: MultiSet, b: MultiSet) : MultiSet;

axiom (forall a: MultiSet, b: MultiSet, o: Box :: 
  { MultiSet#Multiplicity(MultiSet#Intersection(a, b), o) } 
  MultiSet#Multiplicity(MultiSet#Intersection(a, b), o)
     == Math#min(MultiSet#Multiplicity(a, o), MultiSet#Multiplicity(b, o)));

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Intersection(MultiSet#Intersection(a, b), b) } 
  MultiSet#Intersection(MultiSet#Intersection(a, b), b)
     == MultiSet#Intersection(a, b));

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Intersection(a, MultiSet#Intersection(a, b)) } 
  MultiSet#Intersection(a, MultiSet#Intersection(a, b))
     == MultiSet#Intersection(a, b));

revealed function MultiSet#Difference(a: MultiSet, b: MultiSet) : MultiSet;

axiom (forall a: MultiSet, b: MultiSet, o: Box :: 
  { MultiSet#Multiplicity(MultiSet#Difference(a, b), o) } 
  MultiSet#Multiplicity(MultiSet#Difference(a, b), o)
     == Math#clip(MultiSet#Multiplicity(a, o) - MultiSet#Multiplicity(b, o)));

axiom (forall a: MultiSet, b: MultiSet, y: Box :: 
  { MultiSet#Difference(a, b), MultiSet#Multiplicity(b, y), MultiSet#Multiplicity(a, y) } 
  MultiSet#Multiplicity(a, y) <= MultiSet#Multiplicity(b, y)
     ==> MultiSet#Multiplicity(MultiSet#Difference(a, b), y) == 0);

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Card(MultiSet#Difference(a, b)) } 
  MultiSet#Card(MultiSet#Difference(a, b))
         + MultiSet#Card(MultiSet#Difference(b, a))
         + 2 * MultiSet#Card(MultiSet#Intersection(a, b))
       == MultiSet#Card(MultiSet#Union(a, b))
     && MultiSet#Card(MultiSet#Difference(a, b))
       == MultiSet#Card(a) - MultiSet#Card(MultiSet#Intersection(a, b)));

revealed function MultiSet#Subset(a: MultiSet, b: MultiSet) : bool;

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Subset(a, b) } 
  MultiSet#Subset(a, b)
     <==> (forall o: Box :: 
      { MultiSet#Multiplicity(a, o) } { MultiSet#Multiplicity(b, o) } 
      MultiSet#Multiplicity(a, o) <= MultiSet#Multiplicity(b, o)));

revealed function MultiSet#Equal(a: MultiSet, b: MultiSet) : bool;

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Equal(a, b) } 
  MultiSet#Equal(a, b)
     <==> (forall o: Box :: 
      { MultiSet#Multiplicity(a, o) } { MultiSet#Multiplicity(b, o) } 
      MultiSet#Multiplicity(a, o) == MultiSet#Multiplicity(b, o)));

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Equal(a, b) } 
  MultiSet#Equal(a, b) ==> a == b);

revealed function MultiSet#Disjoint(a: MultiSet, b: MultiSet) : bool;

axiom (forall a: MultiSet, b: MultiSet :: 
  { MultiSet#Disjoint(a, b) } 
  MultiSet#Disjoint(a, b)
     <==> (forall o: Box :: 
      { MultiSet#Multiplicity(a, o) } { MultiSet#Multiplicity(b, o) } 
      MultiSet#Multiplicity(a, o) == 0 || MultiSet#Multiplicity(b, o) == 0));

revealed function MultiSet#FromSet(s: Set) : MultiSet;

axiom (forall s: Set, a: Box :: 
  { MultiSet#Multiplicity(MultiSet#FromSet(s), a) } 
  (MultiSet#Multiplicity(MultiSet#FromSet(s), a) == 0 <==> !Set#IsMember(s, a))
     && (MultiSet#Multiplicity(MultiSet#FromSet(s), a) == 1 <==> Set#IsMember(s, a)));

axiom (forall s: Set :: 
  { MultiSet#Card(MultiSet#FromSet(s)) } 
  MultiSet#Card(MultiSet#FromSet(s)) == Set#Card(s));

revealed function MultiSet#FromSeq(s: Seq) : MultiSet
uses {
axiom MultiSet#FromSeq(Seq#Empty()) == MultiSet#Empty();
}

axiom (forall s: Seq :: { MultiSet#FromSeq(s) } $IsGoodMultiSet(MultiSet#FromSeq(s)));

axiom (forall s: Seq :: 
  { MultiSet#Card(MultiSet#FromSeq(s)) } 
  MultiSet#Card(MultiSet#FromSeq(s)) == Seq#Length(s));

axiom (forall s: Seq, v: Box :: 
  { MultiSet#FromSeq(Seq#Build(s, v)) } 
  MultiSet#FromSeq(Seq#Build(s, v)) == MultiSet#UnionOne(MultiSet#FromSeq(s), v));

axiom (forall a: Seq, b: Seq :: 
  { MultiSet#FromSeq(Seq#Append(a, b)) } 
  MultiSet#FromSeq(Seq#Append(a, b))
     == MultiSet#Union(MultiSet#FromSeq(a), MultiSet#FromSeq(b)));

axiom (forall s: Seq, i: int, v: Box, x: Box :: 
  { MultiSet#Multiplicity(MultiSet#FromSeq(Seq#Update(s, i, v)), x) } 
  0 <= i && i < Seq#Length(s)
     ==> MultiSet#Multiplicity(MultiSet#FromSeq(Seq#Update(s, i, v)), x)
       == MultiSet#Multiplicity(MultiSet#Union(MultiSet#Difference(MultiSet#FromSeq(s), MultiSet#Singleton(Seq#Index(s, i))), 
          MultiSet#Singleton(v)), 
        x));

axiom (forall s: Seq, x: Box :: 
  { MultiSet#Multiplicity(MultiSet#FromSeq(s), x) } 
  (exists i: int :: 
      { Seq#Index(s, i) } 
      0 <= i && i < Seq#Length(s) && x == Seq#Index(s, i))
     <==> 0 < MultiSet#Multiplicity(MultiSet#FromSeq(s), x));

type Seq;

revealed function Seq#Length(s: Seq) : int;

axiom (forall s: Seq :: { Seq#Length(s) } 0 <= Seq#Length(s));

revealed function Seq#Empty() : Seq
uses {
axiom Seq#Length(Seq#Empty()) == 0;
}

axiom (forall s: Seq :: { Seq#Length(s) } Seq#Length(s) == 0 ==> s == Seq#Empty());

revealed function Seq#Build(s: Seq, val: Box) : Seq;

revealed function Seq#Build_inv0(s: Seq) : Seq;

revealed function Seq#Build_inv1(s: Seq) : Box;

axiom (forall s: Seq, val: Box :: 
  { Seq#Build(s, val) } 
  Seq#Build_inv0(Seq#Build(s, val)) == s
     && Seq#Build_inv1(Seq#Build(s, val)) == val);

axiom (forall s: Seq, v: Box :: 
  { Seq#Build(s, v) } 
  Seq#Length(Seq#Build(s, v)) == 1 + Seq#Length(s));

axiom (forall s: Seq, i: int, v: Box :: 
  { Seq#Index(Seq#Build(s, v), i) } 
  (i == Seq#Length(s) ==> Seq#Index(Seq#Build(s, v), i) == v)
     && (i != Seq#Length(s) ==> Seq#Index(Seq#Build(s, v), i) == Seq#Index(s, i)));

axiom (forall s0: Seq, s1: Seq :: 
  { Seq#Length(Seq#Append(s0, s1)) } 
  Seq#Length(Seq#Append(s0, s1)) == Seq#Length(s0) + Seq#Length(s1));

revealed function Seq#Index(s: Seq, i: int) : Box;

axiom (forall s0: Seq, s1: Seq, n: int :: 
  { Seq#Index(Seq#Append(s0, s1), n) } 
  (n < Seq#Length(s0) ==> Seq#Index(Seq#Append(s0, s1), n) == Seq#Index(s0, n))
     && (Seq#Length(s0) <= n
       ==> Seq#Index(Seq#Append(s0, s1), n) == Seq#Index(s1, n - Seq#Length(s0))));

revealed function Seq#Update(s: Seq, i: int, val: Box) : Seq;

axiom (forall s: Seq, i: int, v: Box :: 
  { Seq#Length(Seq#Update(s, i, v)) } 
  0 <= i && i < Seq#Length(s) ==> Seq#Length(Seq#Update(s, i, v)) == Seq#Length(s));

axiom (forall s: Seq, i: int, v: Box, n: int :: 
  { Seq#Index(Seq#Update(s, i, v), n) } 
  0 <= n && n < Seq#Length(s)
     ==> (i == n ==> Seq#Index(Seq#Update(s, i, v), n) == v)
       && (i != n ==> Seq#Index(Seq#Update(s, i, v), n) == Seq#Index(s, n)));

revealed function Seq#Append(s0: Seq, s1: Seq) : Seq;

revealed function Seq#Contains(s: Seq, val: Box) : bool;

axiom (forall s: Seq, x: Box :: 
  { Seq#Contains(s, x) } 
  Seq#Contains(s, x)
     <==> (exists i: int :: 
      { Seq#Index(s, i) } 
      0 <= i && i < Seq#Length(s) && Seq#Index(s, i) == x));

axiom (forall x: Box :: 
  { Seq#Contains(Seq#Empty(), x) } 
  !Seq#Contains(Seq#Empty(), x));

axiom (forall s0: Seq, s1: Seq, x: Box :: 
  { Seq#Contains(Seq#Append(s0, s1), x) } 
  Seq#Contains(Seq#Append(s0, s1), x)
     <==> Seq#Contains(s0, x) || Seq#Contains(s1, x));

axiom (forall s: Seq, v: Box, x: Box :: 
  { Seq#Contains(Seq#Build(s, v), x) } 
  Seq#Contains(Seq#Build(s, v), x) <==> v == x || Seq#Contains(s, x));

axiom (forall s: Seq, n: int, x: Box :: 
  { Seq#Contains(Seq#Take(s, n), x) } 
  Seq#Contains(Seq#Take(s, n), x)
     <==> (exists i: int :: 
      { Seq#Index(s, i) } 
      0 <= i && i < n && i < Seq#Length(s) && Seq#Index(s, i) == x));

axiom (forall s: Seq, n: int, x: Box :: 
  { Seq#Contains(Seq#Drop(s, n), x) } 
  Seq#Contains(Seq#Drop(s, n), x)
     <==> (exists i: int :: 
      { Seq#Index(s, i) } 
      0 <= n && n <= i && i < Seq#Length(s) && Seq#Index(s, i) == x));

revealed function Seq#Equal(s0: Seq, s1: Seq) : bool;

axiom (forall s0: Seq, s1: Seq :: 
  { Seq#Equal(s0, s1) } 
  Seq#Equal(s0, s1)
     <==> Seq#Length(s0) == Seq#Length(s1)
       && (forall j: int :: 
        { Seq#Index(s0, j) } { Seq#Index(s1, j) } 
        0 <= j && j < Seq#Length(s0) ==> Seq#Index(s0, j) == Seq#Index(s1, j)));

axiom (forall a: Seq, b: Seq :: { Seq#Equal(a, b) } Seq#Equal(a, b) ==> a == b);

revealed function Seq#SameUntil(s0: Seq, s1: Seq, n: int) : bool;

axiom (forall s0: Seq, s1: Seq, n: int :: 
  { Seq#SameUntil(s0, s1, n) } 
  Seq#SameUntil(s0, s1, n)
     <==> (forall j: int :: 
      { Seq#Index(s0, j) } { Seq#Index(s1, j) } 
      0 <= j && j < n ==> Seq#Index(s0, j) == Seq#Index(s1, j)));

revealed function Seq#Take(s: Seq, howMany: int) : Seq;

axiom (forall s: Seq, n: int :: 
  { Seq#Length(Seq#Take(s, n)) } 
  0 <= n && n <= Seq#Length(s) ==> Seq#Length(Seq#Take(s, n)) == n);

axiom (forall s: Seq, n: int, j: int :: 
  {:weight 11} { Seq#Index(Seq#Take(s, n), j) } { Seq#Index(s, j), Seq#Take(s, n) } 
  0 <= j && j < n && j < Seq#Length(s)
     ==> Seq#Index(Seq#Take(s, n), j) == Seq#Index(s, j));

revealed function Seq#Drop(s: Seq, howMany: int) : Seq;

axiom (forall s: Seq, n: int :: 
  { Seq#Length(Seq#Drop(s, n)) } 
  0 <= n && n <= Seq#Length(s) ==> Seq#Length(Seq#Drop(s, n)) == Seq#Length(s) - n);

axiom (forall s: Seq, n: int, j: int :: 
  {:weight 11} { Seq#Index(Seq#Drop(s, n), j) } 
  0 <= n && 0 <= j && j < Seq#Length(s) - n
     ==> Seq#Index(Seq#Drop(s, n), j) == Seq#Index(s, j + n));

axiom (forall s: Seq, n: int, k: int :: 
  {:weight 11} { Seq#Index(s, k), Seq#Drop(s, n) } 
  0 <= n && n <= k && k < Seq#Length(s)
     ==> Seq#Index(Seq#Drop(s, n), k - n) == Seq#Index(s, k));

axiom (forall s: Seq, t: Seq, n: int :: 
  { Seq#Take(Seq#Append(s, t), n) } { Seq#Drop(Seq#Append(s, t), n) } 
  n == Seq#Length(s)
     ==> Seq#Take(Seq#Append(s, t), n) == s && Seq#Drop(Seq#Append(s, t), n) == t);

axiom (forall s: Seq, i: int, v: Box, n: int :: 
  { Seq#Take(Seq#Update(s, i, v), n) } 
  0 <= i && i < n && n <= Seq#Length(s)
     ==> Seq#Take(Seq#Update(s, i, v), n) == Seq#Update(Seq#Take(s, n), i, v));

axiom (forall s: Seq, i: int, v: Box, n: int :: 
  { Seq#Take(Seq#Update(s, i, v), n) } 
  n <= i && i < Seq#Length(s)
     ==> Seq#Take(Seq#Update(s, i, v), n) == Seq#Take(s, n));

axiom (forall s: Seq, i: int, v: Box, n: int :: 
  { Seq#Drop(Seq#Update(s, i, v), n) } 
  0 <= n && n <= i && i < Seq#Length(s)
     ==> Seq#Drop(Seq#Update(s, i, v), n) == Seq#Update(Seq#Drop(s, n), i - n, v));

axiom (forall s: Seq, i: int, v: Box, n: int :: 
  { Seq#Drop(Seq#Update(s, i, v), n) } 
  0 <= i && i < n && n <= Seq#Length(s)
     ==> Seq#Drop(Seq#Update(s, i, v), n) == Seq#Drop(s, n));

axiom (forall s: Seq, v: Box, n: int :: 
  { Seq#Drop(Seq#Build(s, v), n) } 
  0 <= n && n <= Seq#Length(s)
     ==> Seq#Drop(Seq#Build(s, v), n) == Seq#Build(Seq#Drop(s, n), v));

axiom (forall s: Seq, n: int :: { Seq#Drop(s, n) } n == 0 ==> Seq#Drop(s, n) == s);

axiom (forall s: Seq, n: int :: 
  { Seq#Take(s, n) } 
  n == 0 ==> Seq#Take(s, n) == Seq#Empty());

axiom (forall s: Seq, m: int, n: int :: 
  { Seq#Drop(Seq#Drop(s, m), n) } 
  0 <= m && 0 <= n && m + n <= Seq#Length(s)
     ==> Seq#Drop(Seq#Drop(s, m), n) == Seq#Drop(s, m + n));

axiom (forall s: Seq, bx: Box, t: Ty :: 
  { $Is(Seq#Build(s, bx), TSeq(t)) } 
  $Is(s, TSeq(t)) && $IsBox(bx, t) ==> $Is(Seq#Build(s, bx), TSeq(t)));

revealed function Seq#Create(ty: Ty, heap: Heap, len: int, init: HandleType) : Seq;

axiom (forall ty: Ty, heap: Heap, len: int, init: HandleType :: 
  { Seq#Length(Seq#Create(ty, heap, len, init): Seq) } 
  $IsGoodHeap(heap) && 0 <= len
     ==> Seq#Length(Seq#Create(ty, heap, len, init): Seq) == len);

axiom (forall ty: Ty, heap: Heap, len: int, init: HandleType, i: int :: 
  { Seq#Index(Seq#Create(ty, heap, len, init), i) } 
  $IsGoodHeap(heap) && 0 <= i && i < len
     ==> Seq#Index(Seq#Create(ty, heap, len, init), i)
       == Apply1(TInt, ty, heap, init, $Box(i)));

revealed function Seq#FromArray(h: Heap, a: ref) : Seq;

axiom (forall h: Heap, a: ref :: 
  { Seq#Length(Seq#FromArray(h, a)) } 
  Seq#Length(Seq#FromArray(h, a)) == _System.array.Length(a));

axiom (forall h: Heap, a: ref :: 
  { Seq#FromArray(h, a) } 
  (forall i: int :: 
    { read(h, a, IndexField(i)) } { Seq#Index(Seq#FromArray(h, a): Seq, i) } 
    0 <= i && i < Seq#Length(Seq#FromArray(h, a))
       ==> Seq#Index(Seq#FromArray(h, a), i) == read(h, a, IndexField(i))));

axiom (forall h0: Heap, h1: Heap, a: ref :: 
  { Seq#FromArray(h1, a), $HeapSucc(h0, h1) } 
  $IsGoodHeap(h0) && $IsGoodHeap(h1) && $HeapSucc(h0, h1) && h0[a] == h1[a]
     ==> Seq#FromArray(h0, a) == Seq#FromArray(h1, a));

axiom (forall h: Heap, i: int, v: Box, a: ref :: 
  { Seq#FromArray(update(h, a, IndexField(i), v), a) } 
  0 <= i && i < _System.array.Length(a)
     ==> Seq#FromArray(update(h, a, IndexField(i), v), a)
       == Seq#Update(Seq#FromArray(h, a), i, v));

axiom (forall h: Heap, a: ref, n0: int, n1: int :: 
  { Seq#Take(Seq#FromArray(h, a), n0), Seq#Take(Seq#FromArray(h, a), n1) } 
  n0 + 1 == n1 && 0 <= n0 && n1 <= _System.array.Length(a)
     ==> Seq#Take(Seq#FromArray(h, a), n1)
       == Seq#Build(Seq#Take(Seq#FromArray(h, a), n0), read(h, a, IndexField(n0): Field)));

revealed function Seq#Rank(Seq) : int;

axiom (forall s: Seq, i: int :: 
  { DtRank($Unbox(Seq#Index(s, i)): DatatypeType) } 
  0 <= i && i < Seq#Length(s)
     ==> DtRank($Unbox(Seq#Index(s, i)): DatatypeType) < Seq#Rank(s));

axiom (forall s: Seq, i: int :: 
  { Seq#Rank(Seq#Drop(s, i)) } 
  0 < i && i <= Seq#Length(s) ==> Seq#Rank(Seq#Drop(s, i)) < Seq#Rank(s));

axiom (forall s: Seq, i: int :: 
  { Seq#Rank(Seq#Take(s, i)) } 
  0 <= i && i < Seq#Length(s) ==> Seq#Rank(Seq#Take(s, i)) < Seq#Rank(s));

axiom (forall s: Seq, i: int, j: int :: 
  { Seq#Rank(Seq#Append(Seq#Take(s, i), Seq#Drop(s, j))) } 
  0 <= i && i < j && j <= Seq#Length(s)
     ==> Seq#Rank(Seq#Append(Seq#Take(s, i), Seq#Drop(s, j))) < Seq#Rank(s));

type Map;

revealed function Map#Domain(Map) : Set;

revealed function Map#Elements(Map) : [Box]Box;

revealed function Map#Card(Map) : int;

axiom (forall m: Map :: { Map#Card(m) } 0 <= Map#Card(m));

axiom (forall m: Map :: { Map#Card(m) } Map#Card(m) == 0 <==> m == Map#Empty());

axiom (forall m: Map :: 
  { Map#Domain(m) } 
  m == Map#Empty() || (exists k: Box :: Set#IsMember(Map#Domain(m), k)));

axiom (forall m: Map :: 
  { Map#Values(m) } 
  m == Map#Empty() || (exists v: Box :: Set#IsMember(Map#Values(m), v)));

axiom (forall m: Map :: 
  { Map#Items(m) } 
  m == Map#Empty()
     || (exists k: Box, v: Box :: 
      Set#IsMember(Map#Items(m), $Box(#_System._tuple#2._#Make2(k, v)))));

axiom (forall m: Map :: 
  { Set#Card(Map#Domain(m)) } { Map#Card(m) } 
  Set#Card(Map#Domain(m)) == Map#Card(m));

axiom (forall m: Map :: 
  { Set#Card(Map#Values(m)) } { Map#Card(m) } 
  Set#Card(Map#Values(m)) <= Map#Card(m));

axiom (forall m: Map :: 
  { Set#Card(Map#Items(m)) } { Map#Card(m) } 
  Set#Card(Map#Items(m)) == Map#Card(m));

revealed function Map#Values(Map) : Set;

axiom (forall m: Map, v: Box :: 
  { Set#IsMember(Map#Values(m), v) } 
  Set#IsMember(Map#Values(m), v)
     == (exists u: Box :: 
      { Set#IsMember(Map#Domain(m), u) } { Map#Elements(m)[u] } 
      Set#IsMember(Map#Domain(m), u) && v == Map#Elements(m)[u]));

revealed function Map#Items(Map) : Set;

revealed function #_System._tuple#2._#Make2(Box, Box) : DatatypeType;

revealed function _System.Tuple2._0(DatatypeType) : Box;

revealed function _System.Tuple2._1(DatatypeType) : Box;

axiom (forall m: Map, item: Box :: 
  { Set#IsMember(Map#Items(m), item) } 
  Set#IsMember(Map#Items(m), item)
     <==> Set#IsMember(Map#Domain(m), _System.Tuple2._0($Unbox(item)))
       && Map#Elements(m)[_System.Tuple2._0($Unbox(item))]
         == _System.Tuple2._1($Unbox(item)));

revealed function Map#Empty() : Map;

axiom (forall u: Box :: 
  { Set#IsMember(Map#Domain(Map#Empty(): Map), u) } 
  !Set#IsMember(Map#Domain(Map#Empty(): Map), u));

revealed function Map#Glue(Set, [Box]Box, Ty) : Map;

axiom (forall a: Set, b: [Box]Box, t: Ty :: 
  { Map#Domain(Map#Glue(a, b, t)) } 
  Map#Domain(Map#Glue(a, b, t)) == a);

axiom (forall a: Set, b: [Box]Box, t: Ty :: 
  { Map#Elements(Map#Glue(a, b, t)) } 
  Map#Elements(Map#Glue(a, b, t)) == b);

axiom (forall a: Set, b: [Box]Box, t0: Ty, t1: Ty :: 
  { Map#Glue(a, b, TMap(t0, t1)) } 
  (forall bx: Box :: Set#IsMember(a, bx) ==> $IsBox(bx, t0) && $IsBox(b[bx], t1))
     ==> $Is(Map#Glue(a, b, TMap(t0, t1)), TMap(t0, t1)));

revealed function Map#Build(Map, Box, Box) : Map;

axiom (forall m: Map, u: Box, u': Box, v: Box :: 
  { Set#IsMember(Map#Domain(Map#Build(m, u, v)), u') } 
    { Map#Elements(Map#Build(m, u, v))[u'] } 
  (u' == u
       ==> Set#IsMember(Map#Domain(Map#Build(m, u, v)), u')
         && Map#Elements(Map#Build(m, u, v))[u'] == v)
     && (u' != u
       ==> Set#IsMember(Map#Domain(Map#Build(m, u, v)), u')
           == Set#IsMember(Map#Domain(m), u')
         && Map#Elements(Map#Build(m, u, v))[u'] == Map#Elements(m)[u']));

axiom (forall m: Map, u: Box, v: Box :: 
  { Map#Card(Map#Build(m, u, v)) } 
  Set#IsMember(Map#Domain(m), u) ==> Map#Card(Map#Build(m, u, v)) == Map#Card(m));

axiom (forall m: Map, u: Box, v: Box :: 
  { Map#Card(Map#Build(m, u, v)) } 
  !Set#IsMember(Map#Domain(m), u)
     ==> Map#Card(Map#Build(m, u, v)) == Map#Card(m) + 1);

revealed function Map#Merge(Map, Map) : Map;

axiom (forall m: Map, n: Map :: 
  { Map#Domain(Map#Merge(m, n)) } 
  Map#Domain(Map#Merge(m, n)) == Set#Union(Map#Domain(m), Map#Domain(n)));

axiom (forall m: Map, n: Map, u: Box :: 
  { Map#Elements(Map#Merge(m, n))[u] } 
  Set#IsMember(Map#Domain(Map#Merge(m, n)), u)
     ==> (!Set#IsMember(Map#Domain(n), u)
         ==> Map#Elements(Map#Merge(m, n))[u] == Map#Elements(m)[u])
       && (Set#IsMember(Map#Domain(n), u)
         ==> Map#Elements(Map#Merge(m, n))[u] == Map#Elements(n)[u]));

revealed function Map#Subtract(Map, Set) : Map;

axiom (forall m: Map, s: Set :: 
  { Map#Domain(Map#Subtract(m, s)) } 
  Map#Domain(Map#Subtract(m, s)) == Set#Difference(Map#Domain(m), s));

axiom (forall m: Map, s: Set, u: Box :: 
  { Map#Elements(Map#Subtract(m, s))[u] } 
  Set#IsMember(Map#Domain(Map#Subtract(m, s)), u)
     ==> Map#Elements(Map#Subtract(m, s))[u] == Map#Elements(m)[u]);

revealed function Map#Equal(Map, Map) : bool;

axiom (forall m: Map, m': Map :: 
  { Map#Equal(m, m') } 
  Map#Equal(m, m')
     <==> (forall u: Box :: 
        Set#IsMember(Map#Domain(m), u) == Set#IsMember(Map#Domain(m'), u))
       && (forall u: Box :: 
        Set#IsMember(Map#Domain(m), u) ==> Map#Elements(m)[u] == Map#Elements(m')[u]));

axiom (forall m: Map, m': Map :: { Map#Equal(m, m') } Map#Equal(m, m') ==> m == m');

revealed function Map#Disjoint(Map, Map) : bool;

axiom (forall m: Map, m': Map :: 
  { Map#Disjoint(m, m') } 
  Map#Disjoint(m, m')
     <==> (forall o: Box :: 
      { Set#IsMember(Map#Domain(m), o) } { Set#IsMember(Map#Domain(m'), o) } 
      !Set#IsMember(Map#Domain(m), o) || !Set#IsMember(Map#Domain(m'), o)));

type IMap;

revealed function IMap#Domain(IMap) : ISet;

revealed function IMap#Elements(IMap) : [Box]Box;

axiom (forall m: IMap :: 
  { IMap#Domain(m) } 
  m == IMap#Empty() || (exists k: Box :: IMap#Domain(m)[k]));

axiom (forall m: IMap :: 
  { IMap#Values(m) } 
  m == IMap#Empty() || (exists v: Box :: IMap#Values(m)[v]));

axiom (forall m: IMap :: 
  { IMap#Items(m) } 
  m == IMap#Empty()
     || (exists k: Box, v: Box :: IMap#Items(m)[$Box(#_System._tuple#2._#Make2(k, v))]));

axiom (forall m: IMap :: 
  { IMap#Domain(m) } 
  m == IMap#Empty() <==> IMap#Domain(m) == ISet#Empty());

axiom (forall m: IMap :: 
  { IMap#Values(m) } 
  m == IMap#Empty() <==> IMap#Values(m) == ISet#Empty());

axiom (forall m: IMap :: 
  { IMap#Items(m) } 
  m == IMap#Empty() <==> IMap#Items(m) == ISet#Empty());

revealed function IMap#Values(IMap) : ISet;

axiom (forall m: IMap, v: Box :: 
  { IMap#Values(m)[v] } 
  IMap#Values(m)[v]
     == (exists u: Box :: 
      { IMap#Domain(m)[u] } { IMap#Elements(m)[u] } 
      IMap#Domain(m)[u] && v == IMap#Elements(m)[u]));

revealed function IMap#Items(IMap) : ISet;

axiom (forall m: IMap, item: Box :: 
  { IMap#Items(m)[item] } 
  IMap#Items(m)[item]
     <==> IMap#Domain(m)[_System.Tuple2._0($Unbox(item))]
       && IMap#Elements(m)[_System.Tuple2._0($Unbox(item))]
         == _System.Tuple2._1($Unbox(item)));

revealed function IMap#Empty() : IMap;

axiom (forall u: Box :: 
  { IMap#Domain(IMap#Empty(): IMap)[u] } 
  !IMap#Domain(IMap#Empty(): IMap)[u]);

revealed function IMap#Glue([Box]bool, [Box]Box, Ty) : IMap;

axiom (forall a: [Box]bool, b: [Box]Box, t: Ty :: 
  { IMap#Domain(IMap#Glue(a, b, t)) } 
  IMap#Domain(IMap#Glue(a, b, t)) == a);

axiom (forall a: [Box]bool, b: [Box]Box, t: Ty :: 
  { IMap#Elements(IMap#Glue(a, b, t)) } 
  IMap#Elements(IMap#Glue(a, b, t)) == b);

axiom (forall a: [Box]bool, b: [Box]Box, t0: Ty, t1: Ty :: 
  { IMap#Glue(a, b, TIMap(t0, t1)) } 
  (forall bx: Box :: a[bx] ==> $IsBox(bx, t0) && $IsBox(b[bx], t1))
     ==> $Is(IMap#Glue(a, b, TIMap(t0, t1)), TIMap(t0, t1)));

revealed function IMap#Build(IMap, Box, Box) : IMap;

axiom (forall m: IMap, u: Box, u': Box, v: Box :: 
  { IMap#Domain(IMap#Build(m, u, v))[u'] } 
    { IMap#Elements(IMap#Build(m, u, v))[u'] } 
  (u' == u
       ==> IMap#Domain(IMap#Build(m, u, v))[u']
         && IMap#Elements(IMap#Build(m, u, v))[u'] == v)
     && (u' != u
       ==> IMap#Domain(IMap#Build(m, u, v))[u'] == IMap#Domain(m)[u']
         && IMap#Elements(IMap#Build(m, u, v))[u'] == IMap#Elements(m)[u']));

revealed function IMap#Equal(IMap, IMap) : bool;

axiom (forall m: IMap, m': IMap :: 
  { IMap#Equal(m, m') } 
  IMap#Equal(m, m')
     <==> (forall u: Box :: IMap#Domain(m)[u] == IMap#Domain(m')[u])
       && (forall u: Box :: 
        IMap#Domain(m)[u] ==> IMap#Elements(m)[u] == IMap#Elements(m')[u]));

axiom (forall m: IMap, m': IMap :: 
  { IMap#Equal(m, m') } 
  IMap#Equal(m, m') ==> m == m');

revealed function IMap#Merge(IMap, IMap) : IMap;

axiom (forall m: IMap, n: IMap :: 
  { IMap#Domain(IMap#Merge(m, n)) } 
  IMap#Domain(IMap#Merge(m, n)) == ISet#Union(IMap#Domain(m), IMap#Domain(n)));

axiom (forall m: IMap, n: IMap, u: Box :: 
  { IMap#Elements(IMap#Merge(m, n))[u] } 
  IMap#Domain(IMap#Merge(m, n))[u]
     ==> (!IMap#Domain(n)[u]
         ==> IMap#Elements(IMap#Merge(m, n))[u] == IMap#Elements(m)[u])
       && (IMap#Domain(n)[u]
         ==> IMap#Elements(IMap#Merge(m, n))[u] == IMap#Elements(n)[u]));

revealed function IMap#Subtract(IMap, Set) : IMap;

axiom (forall m: IMap, s: Set :: 
  { IMap#Domain(IMap#Subtract(m, s)) } 
  IMap#Domain(IMap#Subtract(m, s))
     == ISet#Difference(IMap#Domain(m), ISet#FromSet(s)));

axiom (forall m: IMap, s: Set, u: Box :: 
  { IMap#Elements(IMap#Subtract(m, s))[u] } 
  IMap#Domain(IMap#Subtract(m, s))[u]
     ==> IMap#Elements(IMap#Subtract(m, s))[u] == IMap#Elements(m)[u]);

revealed function INTERNAL_add_boogie(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: 
  { INTERNAL_add_boogie(x, y): int } 
  INTERNAL_add_boogie(x, y): int == x + y);
}

revealed function INTERNAL_sub_boogie(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: 
  { INTERNAL_sub_boogie(x, y): int } 
  INTERNAL_sub_boogie(x, y): int == x - y);
}

revealed function INTERNAL_mul_boogie(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: 
  { INTERNAL_mul_boogie(x, y): int } 
  INTERNAL_mul_boogie(x, y): int == x * y);
}

revealed function INTERNAL_div_boogie(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: 
  { INTERNAL_div_boogie(x, y): int } 
  INTERNAL_div_boogie(x, y): int == x div y);
}

revealed function INTERNAL_mod_boogie(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: 
  { INTERNAL_mod_boogie(x, y): int } 
  INTERNAL_mod_boogie(x, y): int == x mod y);
}

revealed function {:never_pattern true} INTERNAL_lt_boogie(x: int, y: int) : bool
uses {
axiom (forall x: int, y: int :: 
  {:never_pattern true} { INTERNAL_lt_boogie(x, y): bool } 
  INTERNAL_lt_boogie(x, y): bool == (x < y));
}

revealed function {:never_pattern true} INTERNAL_le_boogie(x: int, y: int) : bool
uses {
axiom (forall x: int, y: int :: 
  {:never_pattern true} { INTERNAL_le_boogie(x, y): bool } 
  INTERNAL_le_boogie(x, y): bool == (x <= y));
}

revealed function {:never_pattern true} INTERNAL_gt_boogie(x: int, y: int) : bool
uses {
axiom (forall x: int, y: int :: 
  {:never_pattern true} { INTERNAL_gt_boogie(x, y): bool } 
  INTERNAL_gt_boogie(x, y): bool == (x > y));
}

revealed function {:never_pattern true} INTERNAL_ge_boogie(x: int, y: int) : bool
uses {
axiom (forall x: int, y: int :: 
  {:never_pattern true} { INTERNAL_ge_boogie(x, y): bool } 
  INTERNAL_ge_boogie(x, y): bool == (x >= y));
}

revealed function Mul(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: { Mul(x, y): int } Mul(x, y): int == x * y);
}

revealed function Div(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: { Div(x, y): int } Div(x, y): int == x div y);
}

revealed function Mod(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: { Mod(x, y): int } Mod(x, y): int == x mod y);
}

revealed function Add(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: { Add(x, y): int } Add(x, y): int == x + y);
}

revealed function Sub(x: int, y: int) : int
uses {
axiom (forall x: int, y: int :: { Sub(x, y): int } Sub(x, y): int == x - y);
}

function Tclass._System.nat() : Ty
uses {
// Tclass._System.nat Tag
axiom Tag(Tclass._System.nat()) == Tagclass._System.nat
   && TagFamily(Tclass._System.nat()) == tytagFamily$nat;
}

const unique Tagclass._System.nat: TyTag;

// Box/unbox axiom for Tclass._System.nat
axiom (forall bx: Box :: 
  { $IsBox(bx, Tclass._System.nat()) } 
  $IsBox(bx, Tclass._System.nat())
     ==> $Box($Unbox(bx): int) == bx && $Is($Unbox(bx): int, Tclass._System.nat()));

// $Is axiom for subset type _System.nat
axiom (forall x#0: int :: 
  { $Is(x#0, Tclass._System.nat()) } 
  $Is(x#0, Tclass._System.nat()) <==> LitInt(0) <= x#0);

// $IsAlloc axiom for subset type _System.nat
axiom (forall x#0: int, $h: Heap :: 
  { $IsAlloc(x#0, Tclass._System.nat(), $h) } 
  $IsAlloc(x#0, Tclass._System.nat(), $h));

const unique class._System.object?: ClassName;

const unique Tagclass._System.object?: TyTag;

// Box/unbox axiom for Tclass._System.object?
axiom (forall bx: Box :: 
  { $IsBox(bx, Tclass._System.object?()) } 
  $IsBox(bx, Tclass._System.object?())
     ==> $Box($Unbox(bx): ref) == bx && $Is($Unbox(bx): ref, Tclass._System.object?()));

// $Is axiom for trait object
axiom (forall $o: ref :: 
  { $Is($o, Tclass._System.object?()) } 
  $Is($o, Tclass._System.object?()));

// $IsAlloc axiom for trait object
axiom (forall $o: ref, $h: Heap :: 
  { $IsAlloc($o, Tclass._System.object?(), $h) } 
  $IsAlloc($o, Tclass._System.object?(), $h)
     <==> $o == null || $Unbox(read($h, $o, alloc)): bool);

function implements$_System.object(ty: Ty) : bool;

function Tclass._System.object() : Ty
uses {
// Tclass._System.object Tag
axiom Tag(Tclass._System.object()) == Tagclass._System.object
   && TagFamily(Tclass._System.object()) == tytagFamily$object;
}

const unique Tagclass._System.object: TyTag;

// Box/unbox axiom for Tclass._System.object
axiom (forall bx: Box :: 
  { $IsBox(bx, Tclass._System.object()) } 
  $IsBox(bx, Tclass._System.object())
     ==> $Box($Unbox(bx): ref) == bx && $Is($Unbox(bx): ref, Tclass._System.object()));

// $Is axiom for non-null type _System.object
axiom (forall c#0: ref :: 
  { $Is(c#0, Tclass._System.object()) } { $Is(c#0, Tclass._System.object?()) } 
  $Is(c#0, Tclass._System.object())
     <==> $Is(c#0, Tclass._System.object?()) && c#0 != null);

// $IsAlloc axiom for non-null type _System.object
axiom (forall c#0: ref, $h: Heap :: 
  { $IsAlloc(c#0, Tclass._System.object(), $h) } 
  $IsAlloc(c#0, Tclass._System.object(), $h)
     <==> $IsAlloc(c#0, Tclass._System.object?(), $h));

const unique class._System.array?: ClassName;

function Tclass._System.array?(Ty) : Ty;

const unique Tagclass._System.array?: TyTag;

// Tclass._System.array? Tag
axiom (forall _System.array$arg: Ty :: 
  { Tclass._System.array?(_System.array$arg) } 
  Tag(Tclass._System.array?(_System.array$arg)) == Tagclass._System.array?
     && TagFamily(Tclass._System.array?(_System.array$arg)) == tytagFamily$array);

function Tclass._System.array?_0(Ty) : Ty;

// Tclass._System.array? injectivity 0
axiom (forall _System.array$arg: Ty :: 
  { Tclass._System.array?(_System.array$arg) } 
  Tclass._System.array?_0(Tclass._System.array?(_System.array$arg))
     == _System.array$arg);

// Box/unbox axiom for Tclass._System.array?
axiom (forall _System.array$arg: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.array?(_System.array$arg)) } 
  $IsBox(bx, Tclass._System.array?(_System.array$arg))
     ==> $Box($Unbox(bx): ref) == bx
       && $Is($Unbox(bx): ref, Tclass._System.array?(_System.array$arg)));

// array.: Type axiom
axiom (forall _System.array$arg: Ty, $h: Heap, $o: ref, $i0: int :: 
  { read($h, $o, IndexField($i0)), Tclass._System.array?(_System.array$arg) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._System.array?(_System.array$arg)
       && 
      0 <= $i0
       && $i0 < _System.array.Length($o)
     ==> $IsBox(read($h, $o, IndexField($i0)), _System.array$arg));

// array.: Allocation axiom
axiom (forall _System.array$arg: Ty, $h: Heap, $o: ref, $i0: int :: 
  { read($h, $o, IndexField($i0)), Tclass._System.array?(_System.array$arg) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._System.array?(_System.array$arg)
       && 
      0 <= $i0
       && $i0 < _System.array.Length($o)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAllocBox(read($h, $o, IndexField($i0)), _System.array$arg, $h));

// $Is axiom for array type array
axiom (forall _System.array$arg: Ty, $o: ref :: 
  { $Is($o, Tclass._System.array?(_System.array$arg)) } 
  $Is($o, Tclass._System.array?(_System.array$arg))
     <==> $o == null || dtype($o) == Tclass._System.array?(_System.array$arg));

// $IsAlloc axiom for array type array
axiom (forall _System.array$arg: Ty, $o: ref, $h: Heap :: 
  { $IsAlloc($o, Tclass._System.array?(_System.array$arg), $h) } 
  $IsAlloc($o, Tclass._System.array?(_System.array$arg), $h)
     <==> $o == null || $Unbox(read($h, $o, alloc)): bool);

// array.Length: Type axiom
axiom (forall _System.array$arg: Ty, $o: ref :: 
  { _System.array.Length($o), Tclass._System.array?(_System.array$arg) } 
  $o != null && dtype($o) == Tclass._System.array?(_System.array$arg)
     ==> $Is(_System.array.Length($o), TInt));

// array.Length: Allocation axiom
axiom (forall _System.array$arg: Ty, $h: Heap, $o: ref :: 
  { _System.array.Length($o), $Unbox(read($h, $o, alloc)): bool, Tclass._System.array?(_System.array$arg) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._System.array?(_System.array$arg)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc(_System.array.Length($o), TInt, $h));

function Tclass._System.array(Ty) : Ty;

const unique Tagclass._System.array: TyTag;

// Tclass._System.array Tag
axiom (forall _System.array$arg: Ty :: 
  { Tclass._System.array(_System.array$arg) } 
  Tag(Tclass._System.array(_System.array$arg)) == Tagclass._System.array
     && TagFamily(Tclass._System.array(_System.array$arg)) == tytagFamily$array);

function Tclass._System.array_0(Ty) : Ty;

// Tclass._System.array injectivity 0
axiom (forall _System.array$arg: Ty :: 
  { Tclass._System.array(_System.array$arg) } 
  Tclass._System.array_0(Tclass._System.array(_System.array$arg))
     == _System.array$arg);

// Box/unbox axiom for Tclass._System.array
axiom (forall _System.array$arg: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.array(_System.array$arg)) } 
  $IsBox(bx, Tclass._System.array(_System.array$arg))
     ==> $Box($Unbox(bx): ref) == bx
       && $Is($Unbox(bx): ref, Tclass._System.array(_System.array$arg)));

// $Is axiom for non-null type _System.array
axiom (forall _System.array$arg: Ty, c#0: ref :: 
  { $Is(c#0, Tclass._System.array(_System.array$arg)) } 
    { $Is(c#0, Tclass._System.array?(_System.array$arg)) } 
  $Is(c#0, Tclass._System.array(_System.array$arg))
     <==> $Is(c#0, Tclass._System.array?(_System.array$arg)) && c#0 != null);

// $IsAlloc axiom for non-null type _System.array
axiom (forall _System.array$arg: Ty, c#0: ref, $h: Heap :: 
  { $IsAlloc(c#0, Tclass._System.array(_System.array$arg), $h) } 
  $IsAlloc(c#0, Tclass._System.array(_System.array$arg), $h)
     <==> $IsAlloc(c#0, Tclass._System.array?(_System.array$arg), $h));

function Tclass._System.___hFunc1(Ty, Ty) : Ty;

const unique Tagclass._System.___hFunc1: TyTag;

// Tclass._System.___hFunc1 Tag
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hFunc1(#$T0, #$R) } 
  Tag(Tclass._System.___hFunc1(#$T0, #$R)) == Tagclass._System.___hFunc1
     && TagFamily(Tclass._System.___hFunc1(#$T0, #$R)) == tytagFamily$_#Func1);

function Tclass._System.___hFunc1_0(Ty) : Ty;

// Tclass._System.___hFunc1 injectivity 0
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hFunc1(#$T0, #$R) } 
  Tclass._System.___hFunc1_0(Tclass._System.___hFunc1(#$T0, #$R)) == #$T0);

function Tclass._System.___hFunc1_1(Ty) : Ty;

// Tclass._System.___hFunc1 injectivity 1
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hFunc1(#$T0, #$R) } 
  Tclass._System.___hFunc1_1(Tclass._System.___hFunc1(#$T0, #$R)) == #$R);

// Box/unbox axiom for Tclass._System.___hFunc1
axiom (forall #$T0: Ty, #$R: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.___hFunc1(#$T0, #$R)) } 
  $IsBox(bx, Tclass._System.___hFunc1(#$T0, #$R))
     ==> $Box($Unbox(bx): HandleType) == bx
       && $Is($Unbox(bx): HandleType, Tclass._System.___hFunc1(#$T0, #$R)));

function Handle1([Heap,Box]Box, [Heap,Box]bool, [Heap,Box]Set) : HandleType;

function Requires1(Ty, Ty, Heap, HandleType, Box) : bool;

function Reads1(Ty, Ty, Heap, HandleType, Box) : Set;

axiom (forall t0: Ty, 
    t1: Ty, 
    heap: Heap, 
    h: [Heap,Box]Box, 
    r: [Heap,Box]bool, 
    rd: [Heap,Box]Set, 
    bx0: Box :: 
  { Apply1(t0, t1, heap, Handle1(h, r, rd), bx0) } 
  Apply1(t0, t1, heap, Handle1(h, r, rd), bx0) == h[heap, bx0]);

axiom (forall t0: Ty, 
    t1: Ty, 
    heap: Heap, 
    h: [Heap,Box]Box, 
    r: [Heap,Box]bool, 
    rd: [Heap,Box]Set, 
    bx0: Box :: 
  { Requires1(t0, t1, heap, Handle1(h, r, rd), bx0) } 
  r[heap, bx0] ==> Requires1(t0, t1, heap, Handle1(h, r, rd), bx0));

axiom (forall t0: Ty, 
    t1: Ty, 
    heap: Heap, 
    h: [Heap,Box]Box, 
    r: [Heap,Box]bool, 
    rd: [Heap,Box]Set, 
    bx0: Box, 
    bx: Box :: 
  { Set#IsMember(Reads1(t0, t1, heap, Handle1(h, r, rd), bx0), bx) } 
  Set#IsMember(Reads1(t0, t1, heap, Handle1(h, r, rd), bx0), bx)
     == Set#IsMember(rd[heap, bx0], bx));

function {:inline} Requires1#canCall(t0: Ty, t1: Ty, heap: Heap, f: HandleType, bx0: Box) : bool
{
  true
}

function {:inline} Reads1#canCall(t0: Ty, t1: Ty, heap: Heap, f: HandleType, bx0: Box) : bool
{
  true
}

// frame axiom for Reads1
axiom (forall t0: Ty, t1: Ty, h0: Heap, h1: Heap, f: HandleType, bx0: Box :: 
  { $HeapSucc(h0, h1), Reads1(t0, t1, h1, f, bx0) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && 
      $IsBox(bx0, t0)
       && $Is(f, Tclass._System.___hFunc1(t0, t1))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads1(t0, t1, h0, f, bx0), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Reads1(t0, t1, h0, f, bx0) == Reads1(t0, t1, h1, f, bx0));

// frame axiom for Reads1
axiom (forall t0: Ty, t1: Ty, h0: Heap, h1: Heap, f: HandleType, bx0: Box :: 
  { $HeapSucc(h0, h1), Reads1(t0, t1, h1, f, bx0) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && 
      $IsBox(bx0, t0)
       && $Is(f, Tclass._System.___hFunc1(t0, t1))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads1(t0, t1, h1, f, bx0), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Reads1(t0, t1, h0, f, bx0) == Reads1(t0, t1, h1, f, bx0));

// frame axiom for Requires1
axiom (forall t0: Ty, t1: Ty, h0: Heap, h1: Heap, f: HandleType, bx0: Box :: 
  { $HeapSucc(h0, h1), Requires1(t0, t1, h1, f, bx0) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && 
      $IsBox(bx0, t0)
       && $Is(f, Tclass._System.___hFunc1(t0, t1))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads1(t0, t1, h0, f, bx0), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Requires1(t0, t1, h0, f, bx0) == Requires1(t0, t1, h1, f, bx0));

// frame axiom for Requires1
axiom (forall t0: Ty, t1: Ty, h0: Heap, h1: Heap, f: HandleType, bx0: Box :: 
  { $HeapSucc(h0, h1), Requires1(t0, t1, h1, f, bx0) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && 
      $IsBox(bx0, t0)
       && $Is(f, Tclass._System.___hFunc1(t0, t1))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads1(t0, t1, h1, f, bx0), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Requires1(t0, t1, h0, f, bx0) == Requires1(t0, t1, h1, f, bx0));

// frame axiom for Apply1
axiom (forall t0: Ty, t1: Ty, h0: Heap, h1: Heap, f: HandleType, bx0: Box :: 
  { $HeapSucc(h0, h1), Apply1(t0, t1, h1, f, bx0) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && 
      $IsBox(bx0, t0)
       && $Is(f, Tclass._System.___hFunc1(t0, t1))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads1(t0, t1, h0, f, bx0), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Apply1(t0, t1, h0, f, bx0) == Apply1(t0, t1, h1, f, bx0));

// frame axiom for Apply1
axiom (forall t0: Ty, t1: Ty, h0: Heap, h1: Heap, f: HandleType, bx0: Box :: 
  { $HeapSucc(h0, h1), Apply1(t0, t1, h1, f, bx0) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && 
      $IsBox(bx0, t0)
       && $Is(f, Tclass._System.___hFunc1(t0, t1))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads1(t0, t1, h1, f, bx0), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Apply1(t0, t1, h0, f, bx0) == Apply1(t0, t1, h1, f, bx0));

// empty-reads property for Reads1 
axiom (forall t0: Ty, t1: Ty, heap: Heap, f: HandleType, bx0: Box :: 
  { Reads1(t0, t1, $OneHeap, f, bx0), $IsGoodHeap(heap) } 
    { Reads1(t0, t1, heap, f, bx0) } 
  $IsGoodHeap(heap) && $IsBox(bx0, t0) && $Is(f, Tclass._System.___hFunc1(t0, t1))
     ==> (Set#Equal(Reads1(t0, t1, $OneHeap, f, bx0), Set#Empty(): Set)
       <==> Set#Equal(Reads1(t0, t1, heap, f, bx0), Set#Empty(): Set)));

// empty-reads property for Requires1
axiom (forall t0: Ty, t1: Ty, heap: Heap, f: HandleType, bx0: Box :: 
  { Requires1(t0, t1, $OneHeap, f, bx0), $IsGoodHeap(heap) } 
    { Requires1(t0, t1, heap, f, bx0) } 
  $IsGoodHeap(heap)
       && 
      $IsBox(bx0, t0)
       && $Is(f, Tclass._System.___hFunc1(t0, t1))
       && Set#Equal(Reads1(t0, t1, $OneHeap, f, bx0), Set#Empty(): Set)
     ==> Requires1(t0, t1, $OneHeap, f, bx0) == Requires1(t0, t1, heap, f, bx0));

axiom (forall f: HandleType, t0: Ty, t1: Ty :: 
  { $Is(f, Tclass._System.___hFunc1(t0, t1)) } 
  $Is(f, Tclass._System.___hFunc1(t0, t1))
     <==> (forall h: Heap, bx0: Box :: 
      { Apply1(t0, t1, h, f, bx0) } 
      $IsGoodHeap(h) && $IsBox(bx0, t0) && Requires1(t0, t1, h, f, bx0)
         ==> $IsBox(Apply1(t0, t1, h, f, bx0), t1)));

axiom (forall f: HandleType, t0: Ty, t1: Ty, u0: Ty, u1: Ty :: 
  { $Is(f, Tclass._System.___hFunc1(t0, t1)), $Is(f, Tclass._System.___hFunc1(u0, u1)) } 
  $Is(f, Tclass._System.___hFunc1(t0, t1))
       && (forall bx: Box :: 
        { $IsBox(bx, u0) } { $IsBox(bx, t0) } 
        $IsBox(bx, u0) ==> $IsBox(bx, t0))
       && (forall bx: Box :: 
        { $IsBox(bx, t1) } { $IsBox(bx, u1) } 
        $IsBox(bx, t1) ==> $IsBox(bx, u1))
     ==> $Is(f, Tclass._System.___hFunc1(u0, u1)));

axiom (forall f: HandleType, t0: Ty, t1: Ty, h: Heap :: 
  { $IsAlloc(f, Tclass._System.___hFunc1(t0, t1), h) } 
  $IsGoodHeap(h)
     ==> ($IsAlloc(f, Tclass._System.___hFunc1(t0, t1), h)
       <==> (forall bx0: Box :: 
        { Apply1(t0, t1, h, f, bx0) } { Reads1(t0, t1, h, f, bx0) } 
        $IsBox(bx0, t0) && $IsAllocBox(bx0, t0, h) && Requires1(t0, t1, h, f, bx0)
           ==> (forall r: ref :: 
            { Set#IsMember(Reads1(t0, t1, h, f, bx0), $Box(r)) } 
            r != null && Set#IsMember(Reads1(t0, t1, h, f, bx0), $Box(r))
               ==> $Unbox(read(h, r, alloc)): bool))));

axiom (forall f: HandleType, t0: Ty, t1: Ty, h: Heap :: 
  { $IsAlloc(f, Tclass._System.___hFunc1(t0, t1), h) } 
  $IsGoodHeap(h) && $IsAlloc(f, Tclass._System.___hFunc1(t0, t1), h)
     ==> (forall bx0: Box :: 
      { Apply1(t0, t1, h, f, bx0) } 
      $IsAllocBox(bx0, t0, h) && Requires1(t0, t1, h, f, bx0)
         ==> $IsAllocBox(Apply1(t0, t1, h, f, bx0), t1, h)));

function Tclass._System.___hPartialFunc1(Ty, Ty) : Ty;

const unique Tagclass._System.___hPartialFunc1: TyTag;

// Tclass._System.___hPartialFunc1 Tag
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hPartialFunc1(#$T0, #$R) } 
  Tag(Tclass._System.___hPartialFunc1(#$T0, #$R))
       == Tagclass._System.___hPartialFunc1
     && TagFamily(Tclass._System.___hPartialFunc1(#$T0, #$R))
       == tytagFamily$_#PartialFunc1);

function Tclass._System.___hPartialFunc1_0(Ty) : Ty;

// Tclass._System.___hPartialFunc1 injectivity 0
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hPartialFunc1(#$T0, #$R) } 
  Tclass._System.___hPartialFunc1_0(Tclass._System.___hPartialFunc1(#$T0, #$R))
     == #$T0);

function Tclass._System.___hPartialFunc1_1(Ty) : Ty;

// Tclass._System.___hPartialFunc1 injectivity 1
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hPartialFunc1(#$T0, #$R) } 
  Tclass._System.___hPartialFunc1_1(Tclass._System.___hPartialFunc1(#$T0, #$R))
     == #$R);

// Box/unbox axiom for Tclass._System.___hPartialFunc1
axiom (forall #$T0: Ty, #$R: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.___hPartialFunc1(#$T0, #$R)) } 
  $IsBox(bx, Tclass._System.___hPartialFunc1(#$T0, #$R))
     ==> $Box($Unbox(bx): HandleType) == bx
       && $Is($Unbox(bx): HandleType, Tclass._System.___hPartialFunc1(#$T0, #$R)));

// $Is axiom for subset type _System._#PartialFunc1
axiom (forall #$T0: Ty, #$R: Ty, f#0: HandleType :: 
  { $Is(f#0, Tclass._System.___hPartialFunc1(#$T0, #$R)) } 
  $Is(f#0, Tclass._System.___hPartialFunc1(#$T0, #$R))
     <==> $Is(f#0, Tclass._System.___hFunc1(#$T0, #$R))
       && (forall x0#0: Box :: 
        $IsBox(x0#0, #$T0)
           ==> Set#Equal(Reads1(#$T0, #$R, $OneHeap, f#0, x0#0), Set#Empty(): Set)));

// $IsAlloc axiom for subset type _System._#PartialFunc1
axiom (forall #$T0: Ty, #$R: Ty, f#0: HandleType, $h: Heap :: 
  { $IsAlloc(f#0, Tclass._System.___hPartialFunc1(#$T0, #$R), $h) } 
  $IsAlloc(f#0, Tclass._System.___hPartialFunc1(#$T0, #$R), $h)
     <==> $IsAlloc(f#0, Tclass._System.___hFunc1(#$T0, #$R), $h));

function Tclass._System.___hTotalFunc1(Ty, Ty) : Ty;

const unique Tagclass._System.___hTotalFunc1: TyTag;

// Tclass._System.___hTotalFunc1 Tag
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hTotalFunc1(#$T0, #$R) } 
  Tag(Tclass._System.___hTotalFunc1(#$T0, #$R)) == Tagclass._System.___hTotalFunc1
     && TagFamily(Tclass._System.___hTotalFunc1(#$T0, #$R)) == tytagFamily$_#TotalFunc1);

function Tclass._System.___hTotalFunc1_0(Ty) : Ty;

// Tclass._System.___hTotalFunc1 injectivity 0
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hTotalFunc1(#$T0, #$R) } 
  Tclass._System.___hTotalFunc1_0(Tclass._System.___hTotalFunc1(#$T0, #$R))
     == #$T0);

function Tclass._System.___hTotalFunc1_1(Ty) : Ty;

// Tclass._System.___hTotalFunc1 injectivity 1
axiom (forall #$T0: Ty, #$R: Ty :: 
  { Tclass._System.___hTotalFunc1(#$T0, #$R) } 
  Tclass._System.___hTotalFunc1_1(Tclass._System.___hTotalFunc1(#$T0, #$R)) == #$R);

// Box/unbox axiom for Tclass._System.___hTotalFunc1
axiom (forall #$T0: Ty, #$R: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.___hTotalFunc1(#$T0, #$R)) } 
  $IsBox(bx, Tclass._System.___hTotalFunc1(#$T0, #$R))
     ==> $Box($Unbox(bx): HandleType) == bx
       && $Is($Unbox(bx): HandleType, Tclass._System.___hTotalFunc1(#$T0, #$R)));

// $Is axioms for subset type _System._#TotalFunc1
axiom (forall #$T0: Ty, #$R: Ty, f#0: HandleType :: 
  { $Is(f#0, Tclass._System.___hTotalFunc1(#$T0, #$R)) } 
  $Is(f#0, Tclass._System.___hTotalFunc1(#$T0, #$R))
     ==> $Is(f#0, Tclass._System.___hPartialFunc1(#$T0, #$R))
       && 
      (forall x0#0: Box :: 
        $IsBox(x0#0, #$T0) ==> Requires1#canCall(#$T0, #$R, $OneHeap, f#0, x0#0))
       && (forall x0#0: Box :: 
        $IsBox(x0#0, #$T0) ==> Requires1(#$T0, #$R, $OneHeap, f#0, x0#0)));

axiom (forall #$T0: Ty, #$R: Ty, f#0: HandleType :: 
  { $Is(f#0, Tclass._System.___hTotalFunc1(#$T0, #$R)) } 
  $Is(f#0, Tclass._System.___hPartialFunc1(#$T0, #$R))
       && ((forall x0#0: Box :: 
          $IsBox(x0#0, #$T0) ==> Requires1#canCall(#$T0, #$R, $OneHeap, f#0, x0#0))
         ==> (forall x0#0: Box :: 
          $IsBox(x0#0, #$T0) ==> Requires1(#$T0, #$R, $OneHeap, f#0, x0#0)))
     ==> $Is(f#0, Tclass._System.___hTotalFunc1(#$T0, #$R)));

// $IsAlloc axiom for subset type _System._#TotalFunc1
axiom (forall #$T0: Ty, #$R: Ty, f#0: HandleType, $h: Heap :: 
  { $IsAlloc(f#0, Tclass._System.___hTotalFunc1(#$T0, #$R), $h) } 
  $IsAlloc(f#0, Tclass._System.___hTotalFunc1(#$T0, #$R), $h)
     <==> $IsAlloc(f#0, Tclass._System.___hPartialFunc1(#$T0, #$R), $h));

function Tclass._System.___hFunc0(Ty) : Ty;

const unique Tagclass._System.___hFunc0: TyTag;

// Tclass._System.___hFunc0 Tag
axiom (forall #$R: Ty :: 
  { Tclass._System.___hFunc0(#$R) } 
  Tag(Tclass._System.___hFunc0(#$R)) == Tagclass._System.___hFunc0
     && TagFamily(Tclass._System.___hFunc0(#$R)) == tytagFamily$_#Func0);

function Tclass._System.___hFunc0_0(Ty) : Ty;

// Tclass._System.___hFunc0 injectivity 0
axiom (forall #$R: Ty :: 
  { Tclass._System.___hFunc0(#$R) } 
  Tclass._System.___hFunc0_0(Tclass._System.___hFunc0(#$R)) == #$R);

// Box/unbox axiom for Tclass._System.___hFunc0
axiom (forall #$R: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.___hFunc0(#$R)) } 
  $IsBox(bx, Tclass._System.___hFunc0(#$R))
     ==> $Box($Unbox(bx): HandleType) == bx
       && $Is($Unbox(bx): HandleType, Tclass._System.___hFunc0(#$R)));

function Handle0([Heap]Box, [Heap]bool, [Heap]Set) : HandleType;

function Apply0(Ty, Heap, HandleType) : Box;

function Requires0(Ty, Heap, HandleType) : bool;

function Reads0(Ty, Heap, HandleType) : Set;

axiom (forall t0: Ty, heap: Heap, h: [Heap]Box, r: [Heap]bool, rd: [Heap]Set :: 
  { Apply0(t0, heap, Handle0(h, r, rd)) } 
  Apply0(t0, heap, Handle0(h, r, rd)) == h[heap]);

axiom (forall t0: Ty, heap: Heap, h: [Heap]Box, r: [Heap]bool, rd: [Heap]Set :: 
  { Requires0(t0, heap, Handle0(h, r, rd)) } 
  r[heap] ==> Requires0(t0, heap, Handle0(h, r, rd)));

axiom (forall t0: Ty, heap: Heap, h: [Heap]Box, r: [Heap]bool, rd: [Heap]Set, bx: Box :: 
  { Set#IsMember(Reads0(t0, heap, Handle0(h, r, rd)), bx) } 
  Set#IsMember(Reads0(t0, heap, Handle0(h, r, rd)), bx)
     == Set#IsMember(rd[heap], bx));

function {:inline} Requires0#canCall(t0: Ty, heap: Heap, f: HandleType) : bool
{
  true
}

function {:inline} Reads0#canCall(t0: Ty, heap: Heap, f: HandleType) : bool
{
  true
}

// frame axiom for Reads0
axiom (forall t0: Ty, h0: Heap, h1: Heap, f: HandleType :: 
  { $HeapSucc(h0, h1), Reads0(t0, h1, f) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && $Is(f, Tclass._System.___hFunc0(t0))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads0(t0, h0, f), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Reads0(t0, h0, f) == Reads0(t0, h1, f));

// frame axiom for Reads0
axiom (forall t0: Ty, h0: Heap, h1: Heap, f: HandleType :: 
  { $HeapSucc(h0, h1), Reads0(t0, h1, f) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && $Is(f, Tclass._System.___hFunc0(t0))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads0(t0, h1, f), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Reads0(t0, h0, f) == Reads0(t0, h1, f));

// frame axiom for Requires0
axiom (forall t0: Ty, h0: Heap, h1: Heap, f: HandleType :: 
  { $HeapSucc(h0, h1), Requires0(t0, h1, f) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && $Is(f, Tclass._System.___hFunc0(t0))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads0(t0, h0, f), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Requires0(t0, h0, f) == Requires0(t0, h1, f));

// frame axiom for Requires0
axiom (forall t0: Ty, h0: Heap, h1: Heap, f: HandleType :: 
  { $HeapSucc(h0, h1), Requires0(t0, h1, f) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && $Is(f, Tclass._System.___hFunc0(t0))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads0(t0, h1, f), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Requires0(t0, h0, f) == Requires0(t0, h1, f));

// frame axiom for Apply0
axiom (forall t0: Ty, h0: Heap, h1: Heap, f: HandleType :: 
  { $HeapSucc(h0, h1), Apply0(t0, h1, f) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && $Is(f, Tclass._System.___hFunc0(t0))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads0(t0, h0, f), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Apply0(t0, h0, f) == Apply0(t0, h1, f));

// frame axiom for Apply0
axiom (forall t0: Ty, h0: Heap, h1: Heap, f: HandleType :: 
  { $HeapSucc(h0, h1), Apply0(t0, h1, f) } 
  $HeapSucc(h0, h1)
       && 
      $IsGoodHeap(h0)
       && $IsGoodHeap(h1)
       && $Is(f, Tclass._System.___hFunc0(t0))
       && (forall o: ref, fld: Field :: 
        o != null && Set#IsMember(Reads0(t0, h1, f), $Box(o))
           ==> read(h0, o, fld) == read(h1, o, fld))
     ==> Apply0(t0, h0, f) == Apply0(t0, h1, f));

// empty-reads property for Reads0 
axiom (forall t0: Ty, heap: Heap, f: HandleType :: 
  { Reads0(t0, $OneHeap, f), $IsGoodHeap(heap) } { Reads0(t0, heap, f) } 
  $IsGoodHeap(heap) && $Is(f, Tclass._System.___hFunc0(t0))
     ==> (Set#Equal(Reads0(t0, $OneHeap, f), Set#Empty(): Set)
       <==> Set#Equal(Reads0(t0, heap, f), Set#Empty(): Set)));

// empty-reads property for Requires0
axiom (forall t0: Ty, heap: Heap, f: HandleType :: 
  { Requires0(t0, $OneHeap, f), $IsGoodHeap(heap) } { Requires0(t0, heap, f) } 
  $IsGoodHeap(heap)
       && $Is(f, Tclass._System.___hFunc0(t0))
       && Set#Equal(Reads0(t0, $OneHeap, f), Set#Empty(): Set)
     ==> Requires0(t0, $OneHeap, f) == Requires0(t0, heap, f));

axiom (forall f: HandleType, t0: Ty :: 
  { $Is(f, Tclass._System.___hFunc0(t0)) } 
  $Is(f, Tclass._System.___hFunc0(t0))
     <==> (forall h: Heap :: 
      { Apply0(t0, h, f) } 
      $IsGoodHeap(h) && Requires0(t0, h, f) ==> $IsBox(Apply0(t0, h, f), t0)));

axiom (forall f: HandleType, t0: Ty, u0: Ty :: 
  { $Is(f, Tclass._System.___hFunc0(t0)), $Is(f, Tclass._System.___hFunc0(u0)) } 
  $Is(f, Tclass._System.___hFunc0(t0))
       && (forall bx: Box :: 
        { $IsBox(bx, t0) } { $IsBox(bx, u0) } 
        $IsBox(bx, t0) ==> $IsBox(bx, u0))
     ==> $Is(f, Tclass._System.___hFunc0(u0)));

axiom (forall f: HandleType, t0: Ty, h: Heap :: 
  { $IsAlloc(f, Tclass._System.___hFunc0(t0), h) } 
  $IsGoodHeap(h)
     ==> ($IsAlloc(f, Tclass._System.___hFunc0(t0), h)
       <==> Requires0(t0, h, f)
         ==> (forall r: ref :: 
          { Set#IsMember(Reads0(t0, h, f), $Box(r)) } 
          r != null && Set#IsMember(Reads0(t0, h, f), $Box(r))
             ==> $Unbox(read(h, r, alloc)): bool)));

axiom (forall f: HandleType, t0: Ty, h: Heap :: 
  { $IsAlloc(f, Tclass._System.___hFunc0(t0), h) } 
  $IsGoodHeap(h) && $IsAlloc(f, Tclass._System.___hFunc0(t0), h)
     ==> 
    Requires0(t0, h, f)
     ==> $IsAllocBox(Apply0(t0, h, f), t0, h));

function Tclass._System.___hPartialFunc0(Ty) : Ty;

const unique Tagclass._System.___hPartialFunc0: TyTag;

// Tclass._System.___hPartialFunc0 Tag
axiom (forall #$R: Ty :: 
  { Tclass._System.___hPartialFunc0(#$R) } 
  Tag(Tclass._System.___hPartialFunc0(#$R)) == Tagclass._System.___hPartialFunc0
     && TagFamily(Tclass._System.___hPartialFunc0(#$R)) == tytagFamily$_#PartialFunc0);

function Tclass._System.___hPartialFunc0_0(Ty) : Ty;

// Tclass._System.___hPartialFunc0 injectivity 0
axiom (forall #$R: Ty :: 
  { Tclass._System.___hPartialFunc0(#$R) } 
  Tclass._System.___hPartialFunc0_0(Tclass._System.___hPartialFunc0(#$R)) == #$R);

// Box/unbox axiom for Tclass._System.___hPartialFunc0
axiom (forall #$R: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.___hPartialFunc0(#$R)) } 
  $IsBox(bx, Tclass._System.___hPartialFunc0(#$R))
     ==> $Box($Unbox(bx): HandleType) == bx
       && $Is($Unbox(bx): HandleType, Tclass._System.___hPartialFunc0(#$R)));

// $Is axiom for subset type _System._#PartialFunc0
axiom (forall #$R: Ty, f#0: HandleType :: 
  { $Is(f#0, Tclass._System.___hPartialFunc0(#$R)) } 
  $Is(f#0, Tclass._System.___hPartialFunc0(#$R))
     <==> $Is(f#0, Tclass._System.___hFunc0(#$R))
       && Set#Equal(Reads0(#$R, $OneHeap, f#0), Set#Empty(): Set));

// $IsAlloc axiom for subset type _System._#PartialFunc0
axiom (forall #$R: Ty, f#0: HandleType, $h: Heap :: 
  { $IsAlloc(f#0, Tclass._System.___hPartialFunc0(#$R), $h) } 
  $IsAlloc(f#0, Tclass._System.___hPartialFunc0(#$R), $h)
     <==> $IsAlloc(f#0, Tclass._System.___hFunc0(#$R), $h));

function Tclass._System.___hTotalFunc0(Ty) : Ty;

const unique Tagclass._System.___hTotalFunc0: TyTag;

// Tclass._System.___hTotalFunc0 Tag
axiom (forall #$R: Ty :: 
  { Tclass._System.___hTotalFunc0(#$R) } 
  Tag(Tclass._System.___hTotalFunc0(#$R)) == Tagclass._System.___hTotalFunc0
     && TagFamily(Tclass._System.___hTotalFunc0(#$R)) == tytagFamily$_#TotalFunc0);

function Tclass._System.___hTotalFunc0_0(Ty) : Ty;

// Tclass._System.___hTotalFunc0 injectivity 0
axiom (forall #$R: Ty :: 
  { Tclass._System.___hTotalFunc0(#$R) } 
  Tclass._System.___hTotalFunc0_0(Tclass._System.___hTotalFunc0(#$R)) == #$R);

// Box/unbox axiom for Tclass._System.___hTotalFunc0
axiom (forall #$R: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.___hTotalFunc0(#$R)) } 
  $IsBox(bx, Tclass._System.___hTotalFunc0(#$R))
     ==> $Box($Unbox(bx): HandleType) == bx
       && $Is($Unbox(bx): HandleType, Tclass._System.___hTotalFunc0(#$R)));

// $Is axioms for subset type _System._#TotalFunc0
axiom (forall #$R: Ty, f#0: HandleType :: 
  { $Is(f#0, Tclass._System.___hTotalFunc0(#$R)) } 
  $Is(f#0, Tclass._System.___hTotalFunc0(#$R))
     ==> $Is(f#0, Tclass._System.___hPartialFunc0(#$R))
       && 
      Requires0#canCall(#$R, $OneHeap, f#0)
       && Requires0(#$R, $OneHeap, f#0));

axiom (forall #$R: Ty, f#0: HandleType :: 
  { $Is(f#0, Tclass._System.___hTotalFunc0(#$R)) } 
  $Is(f#0, Tclass._System.___hPartialFunc0(#$R))
       && (Requires0#canCall(#$R, $OneHeap, f#0) ==> Requires0(#$R, $OneHeap, f#0))
     ==> $Is(f#0, Tclass._System.___hTotalFunc0(#$R)));

// $IsAlloc axiom for subset type _System._#TotalFunc0
axiom (forall #$R: Ty, f#0: HandleType, $h: Heap :: 
  { $IsAlloc(f#0, Tclass._System.___hTotalFunc0(#$R), $h) } 
  $IsAlloc(f#0, Tclass._System.___hTotalFunc0(#$R), $h)
     <==> $IsAlloc(f#0, Tclass._System.___hPartialFunc0(#$R), $h));

const unique ##_System._tuple#2._#Make2: DtCtorId
uses {
// Constructor identifier
axiom (forall a#0#0#0: Box, a#0#1#0: Box :: 
  { #_System._tuple#2._#Make2(a#0#0#0, a#0#1#0) } 
  DatatypeCtorId(#_System._tuple#2._#Make2(a#0#0#0, a#0#1#0))
     == ##_System._tuple#2._#Make2);
}

function _System.Tuple2.___hMake2_q(DatatypeType) : bool;

// Questionmark and identifier
axiom (forall d: DatatypeType :: 
  { _System.Tuple2.___hMake2_q(d) } 
  _System.Tuple2.___hMake2_q(d)
     <==> DatatypeCtorId(d) == ##_System._tuple#2._#Make2);

// Constructor questionmark has arguments
axiom (forall d: DatatypeType :: 
  { _System.Tuple2.___hMake2_q(d) } 
  _System.Tuple2.___hMake2_q(d)
     ==> (exists a#1#0#0: Box, a#1#1#0: Box :: 
      d == #_System._tuple#2._#Make2(a#1#0#0, a#1#1#0)));

const unique Tagclass._System.Tuple2: TyTag;

// Tclass._System.Tuple2 Tag
axiom (forall _System._tuple#2$T0: Ty, _System._tuple#2$T1: Ty :: 
  { Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1) } 
  Tag(Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1))
       == Tagclass._System.Tuple2
     && TagFamily(Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1))
       == tytagFamily$_tuple#2);

function Tclass._System.Tuple2_0(Ty) : Ty;

// Tclass._System.Tuple2 injectivity 0
axiom (forall _System._tuple#2$T0: Ty, _System._tuple#2$T1: Ty :: 
  { Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1) } 
  Tclass._System.Tuple2_0(Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1))
     == _System._tuple#2$T0);

function Tclass._System.Tuple2_1(Ty) : Ty;

// Tclass._System.Tuple2 injectivity 1
axiom (forall _System._tuple#2$T0: Ty, _System._tuple#2$T1: Ty :: 
  { Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1) } 
  Tclass._System.Tuple2_1(Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1))
     == _System._tuple#2$T1);

// Box/unbox axiom for Tclass._System.Tuple2
axiom (forall _System._tuple#2$T0: Ty, _System._tuple#2$T1: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1)) } 
  $IsBox(bx, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1))
     ==> $Box($Unbox(bx): DatatypeType) == bx
       && $Is($Unbox(bx): DatatypeType, 
        Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1)));

// Constructor $Is
axiom (forall _System._tuple#2$T0: Ty, _System._tuple#2$T1: Ty, a#2#0#0: Box, a#2#1#0: Box :: 
  { $Is(#_System._tuple#2._#Make2(a#2#0#0, a#2#1#0), 
      Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1)) } 
  $Is(#_System._tuple#2._#Make2(a#2#0#0, a#2#1#0), 
      Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1))
     <==> $IsBox(a#2#0#0, _System._tuple#2$T0) && $IsBox(a#2#1#0, _System._tuple#2$T1));

// Constructor $IsAlloc
axiom (forall _System._tuple#2$T0: Ty, 
    _System._tuple#2$T1: Ty, 
    a#2#0#0: Box, 
    a#2#1#0: Box, 
    $h: Heap :: 
  { $IsAlloc(#_System._tuple#2._#Make2(a#2#0#0, a#2#1#0), 
      Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1), 
      $h) } 
  $IsGoodHeap($h)
     ==> ($IsAlloc(#_System._tuple#2._#Make2(a#2#0#0, a#2#1#0), 
        Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1), 
        $h)
       <==> $IsAllocBox(a#2#0#0, _System._tuple#2$T0, $h)
         && $IsAllocBox(a#2#1#0, _System._tuple#2$T1, $h)));

// Destructor $IsAlloc
axiom (forall d: DatatypeType, _System._tuple#2$T0: Ty, $h: Heap :: 
  { $IsAllocBox(_System.Tuple2._0(d), _System._tuple#2$T0, $h) } 
  $IsGoodHeap($h)
       && 
      _System.Tuple2.___hMake2_q(d)
       && (exists _System._tuple#2$T1: Ty :: 
        { $IsAlloc(d, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1), $h) } 
        $IsAlloc(d, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1), $h))
     ==> $IsAllocBox(_System.Tuple2._0(d), _System._tuple#2$T0, $h));

// Destructor $IsAlloc
axiom (forall d: DatatypeType, _System._tuple#2$T1: Ty, $h: Heap :: 
  { $IsAllocBox(_System.Tuple2._1(d), _System._tuple#2$T1, $h) } 
  $IsGoodHeap($h)
       && 
      _System.Tuple2.___hMake2_q(d)
       && (exists _System._tuple#2$T0: Ty :: 
        { $IsAlloc(d, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1), $h) } 
        $IsAlloc(d, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1), $h))
     ==> $IsAllocBox(_System.Tuple2._1(d), _System._tuple#2$T1, $h));

// Constructor literal
axiom (forall a#3#0#0: Box, a#3#1#0: Box :: 
  { #_System._tuple#2._#Make2(Lit(a#3#0#0), Lit(a#3#1#0)) } 
  #_System._tuple#2._#Make2(Lit(a#3#0#0), Lit(a#3#1#0))
     == Lit(#_System._tuple#2._#Make2(a#3#0#0, a#3#1#0)));

// Constructor injectivity
axiom (forall a#4#0#0: Box, a#4#1#0: Box :: 
  { #_System._tuple#2._#Make2(a#4#0#0, a#4#1#0) } 
  _System.Tuple2._0(#_System._tuple#2._#Make2(a#4#0#0, a#4#1#0)) == a#4#0#0);

// Inductive rank
axiom (forall a#5#0#0: Box, a#5#1#0: Box :: 
  { DtRank(#_System._tuple#2._#Make2(a#5#0#0, a#5#1#0)) } 
  BoxRank(a#5#0#0) < DtRank(#_System._tuple#2._#Make2(a#5#0#0, a#5#1#0)));

// Constructor injectivity
axiom (forall a#6#0#0: Box, a#6#1#0: Box :: 
  { #_System._tuple#2._#Make2(a#6#0#0, a#6#1#0) } 
  _System.Tuple2._1(#_System._tuple#2._#Make2(a#6#0#0, a#6#1#0)) == a#6#1#0);

// Inductive rank
axiom (forall a#7#0#0: Box, a#7#1#0: Box :: 
  { DtRank(#_System._tuple#2._#Make2(a#7#0#0, a#7#1#0)) } 
  BoxRank(a#7#1#0) < DtRank(#_System._tuple#2._#Make2(a#7#0#0, a#7#1#0)));

// Depth-one case-split function
function $IsA#_System.Tuple2(DatatypeType) : bool;

// Depth-one case-split axiom
axiom (forall d: DatatypeType :: 
  { $IsA#_System.Tuple2(d) } 
  $IsA#_System.Tuple2(d) ==> _System.Tuple2.___hMake2_q(d));

// Questionmark data type disjunctivity
axiom (forall _System._tuple#2$T0: Ty, _System._tuple#2$T1: Ty, d: DatatypeType :: 
  { _System.Tuple2.___hMake2_q(d), $Is(d, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1)) } 
  $Is(d, Tclass._System.Tuple2(_System._tuple#2$T0, _System._tuple#2$T1))
     ==> _System.Tuple2.___hMake2_q(d));

// Datatype extensional equality declaration
function _System.Tuple2#Equal(DatatypeType, DatatypeType) : bool;

// Datatype extensional equality definition: #_System._tuple#2._#Make2
axiom (forall a: DatatypeType, b: DatatypeType :: 
  { _System.Tuple2#Equal(a, b) } 
  _System.Tuple2#Equal(a, b)
     <==> _System.Tuple2._0(a) == _System.Tuple2._0(b)
       && _System.Tuple2._1(a) == _System.Tuple2._1(b));

// Datatype extensionality axiom: _System._tuple#2
axiom (forall a: DatatypeType, b: DatatypeType :: 
  { _System.Tuple2#Equal(a, b) } 
  _System.Tuple2#Equal(a, b) <==> a == b);

const unique class._System.Tuple2: ClassName;

// Constructor function declaration
function #_System._tuple#0._#Make0() : DatatypeType
uses {
// Constructor identifier
axiom DatatypeCtorId(#_System._tuple#0._#Make0()) == ##_System._tuple#0._#Make0;
// Constructor $Is
axiom $Is(#_System._tuple#0._#Make0(), Tclass._System.Tuple0());
// Constructor literal
axiom #_System._tuple#0._#Make0() == Lit(#_System._tuple#0._#Make0());
}

const unique ##_System._tuple#0._#Make0: DtCtorId
uses {
// Constructor identifier
axiom DatatypeCtorId(#_System._tuple#0._#Make0()) == ##_System._tuple#0._#Make0;
}

function _System.Tuple0.___hMake0_q(DatatypeType) : bool;

// Questionmark and identifier
axiom (forall d: DatatypeType :: 
  { _System.Tuple0.___hMake0_q(d) } 
  _System.Tuple0.___hMake0_q(d)
     <==> DatatypeCtorId(d) == ##_System._tuple#0._#Make0);

// Constructor questionmark has arguments
axiom (forall d: DatatypeType :: 
  { _System.Tuple0.___hMake0_q(d) } 
  _System.Tuple0.___hMake0_q(d) ==> d == #_System._tuple#0._#Make0());

function Tclass._System.Tuple0() : Ty
uses {
// Tclass._System.Tuple0 Tag
axiom Tag(Tclass._System.Tuple0()) == Tagclass._System.Tuple0
   && TagFamily(Tclass._System.Tuple0()) == tytagFamily$_tuple#0;
}

const unique Tagclass._System.Tuple0: TyTag;

// Box/unbox axiom for Tclass._System.Tuple0
axiom (forall bx: Box :: 
  { $IsBox(bx, Tclass._System.Tuple0()) } 
  $IsBox(bx, Tclass._System.Tuple0())
     ==> $Box($Unbox(bx): DatatypeType) == bx
       && $Is($Unbox(bx): DatatypeType, Tclass._System.Tuple0()));

// Datatype $IsAlloc
axiom (forall d: DatatypeType, $h: Heap :: 
  { $IsAlloc(d, Tclass._System.Tuple0(), $h) } 
  $IsGoodHeap($h) && $Is(d, Tclass._System.Tuple0())
     ==> $IsAlloc(d, Tclass._System.Tuple0(), $h));

// Depth-one case-split function
function $IsA#_System.Tuple0(DatatypeType) : bool;

// Depth-one case-split axiom
axiom (forall d: DatatypeType :: 
  { $IsA#_System.Tuple0(d) } 
  $IsA#_System.Tuple0(d) ==> _System.Tuple0.___hMake0_q(d));

// Questionmark data type disjunctivity
axiom (forall d: DatatypeType :: 
  { _System.Tuple0.___hMake0_q(d), $Is(d, Tclass._System.Tuple0()) } 
  $Is(d, Tclass._System.Tuple0()) ==> _System.Tuple0.___hMake0_q(d));

// Datatype extensional equality declaration
function _System.Tuple0#Equal(DatatypeType, DatatypeType) : bool;

// Datatype extensional equality definition: #_System._tuple#0._#Make0
axiom (forall a: DatatypeType, b: DatatypeType :: 
  { _System.Tuple0#Equal(a, b) } 
  _System.Tuple0#Equal(a, b));

// Datatype extensionality axiom: _System._tuple#0
axiom (forall a: DatatypeType, b: DatatypeType :: 
  { _System.Tuple0#Equal(a, b) } 
  _System.Tuple0#Equal(a, b) <==> a == b);

const unique class._System.Tuple0: ClassName;

const unique class._module.__default: ClassName;

const unique class._module.TwoStacks?: ClassName;

function Tclass._module.TwoStacks?(Ty) : Ty;

const unique Tagclass._module.TwoStacks?: TyTag;

// Tclass._module.TwoStacks? Tag
axiom (forall _module.TwoStacks$T: Ty :: 
  { Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  Tag(Tclass._module.TwoStacks?(_module.TwoStacks$T))
       == Tagclass._module.TwoStacks?
     && TagFamily(Tclass._module.TwoStacks?(_module.TwoStacks$T))
       == tytagFamily$TwoStacks);

function Tclass._module.TwoStacks?_0(Ty) : Ty;

// Tclass._module.TwoStacks? injectivity 0
axiom (forall _module.TwoStacks$T: Ty :: 
  { Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  Tclass._module.TwoStacks?_0(Tclass._module.TwoStacks?(_module.TwoStacks$T))
     == _module.TwoStacks$T);

// Box/unbox axiom for Tclass._module.TwoStacks?
axiom (forall _module.TwoStacks$T: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._module.TwoStacks?(_module.TwoStacks$T)) } 
  $IsBox(bx, Tclass._module.TwoStacks?(_module.TwoStacks$T))
     ==> $Box($Unbox(bx): ref) == bx
       && $Is($Unbox(bx): ref, Tclass._module.TwoStacks?(_module.TwoStacks$T)));

// $Is axiom for class TwoStacks
axiom (forall _module.TwoStacks$T: Ty, $o: ref :: 
  { $Is($o, Tclass._module.TwoStacks?(_module.TwoStacks$T)) } 
  $Is($o, Tclass._module.TwoStacks?(_module.TwoStacks$T))
     <==> $o == null || dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T));

// $IsAlloc axiom for class TwoStacks
axiom (forall _module.TwoStacks$T: Ty, $o: ref, $h: Heap :: 
  { $IsAlloc($o, Tclass._module.TwoStacks?(_module.TwoStacks$T), $h) } 
  $IsAlloc($o, Tclass._module.TwoStacks?(_module.TwoStacks$T), $h)
     <==> $o == null || $Unbox(read($h, $o, alloc)): bool);

const _module.TwoStacks.s1: Field
uses {
axiom FDim(_module.TwoStacks.s1) == 0
   && FieldOfDecl(class._module.TwoStacks?, field$s1) == _module.TwoStacks.s1
   && $IsGhostField(_module.TwoStacks.s1);
}

// TwoStacks.s1: Type axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.s1)): Seq, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
     ==> $Is($Unbox(read($h, $o, _module.TwoStacks.s1)): Seq, TSeq(_module.TwoStacks$T)));

// TwoStacks.s1: Allocation axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.s1)): Seq, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc($Unbox(read($h, $o, _module.TwoStacks.s1)): Seq, TSeq(_module.TwoStacks$T), $h));

const _module.TwoStacks.s2: Field
uses {
axiom FDim(_module.TwoStacks.s2) == 0
   && FieldOfDecl(class._module.TwoStacks?, field$s2) == _module.TwoStacks.s2
   && $IsGhostField(_module.TwoStacks.s2);
}

// TwoStacks.s2: Type axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.s2)): Seq, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
     ==> $Is($Unbox(read($h, $o, _module.TwoStacks.s2)): Seq, TSeq(_module.TwoStacks$T)));

// TwoStacks.s2: Allocation axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.s2)): Seq, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc($Unbox(read($h, $o, _module.TwoStacks.s2)): Seq, TSeq(_module.TwoStacks$T), $h));

function _module.TwoStacks.N(_module.TwoStacks$T: Ty, this: ref) : int;

// TwoStacks.N: Type axiom
axiom (forall _module.TwoStacks$T: Ty, $o: ref :: 
  { _module.TwoStacks.N(_module.TwoStacks$T, $o) } 
  $o != null && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
     ==> $Is(_module.TwoStacks.N(_module.TwoStacks$T, $o), Tclass._System.nat()));

// TwoStacks.N: Allocation axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { _module.TwoStacks.N(_module.TwoStacks$T, $o), $Unbox(read($h, $o, alloc)): bool } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc(_module.TwoStacks.N(_module.TwoStacks$T, $o), Tclass._System.nat(), $h));

const _module.TwoStacks.Repr: Field
uses {
axiom FDim(_module.TwoStacks.Repr) == 0
   && FieldOfDecl(class._module.TwoStacks?, field$Repr) == _module.TwoStacks.Repr
   && $IsGhostField(_module.TwoStacks.Repr);
}

// TwoStacks.Repr: Type axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.Repr)): Set, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
     ==> $Is($Unbox(read($h, $o, _module.TwoStacks.Repr)): Set, TSet(Tclass._System.object())));

// TwoStacks.Repr: Allocation axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.Repr)): Set, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc($Unbox(read($h, $o, _module.TwoStacks.Repr)): Set, 
      TSet(Tclass._System.object()), 
      $h));

const _module.TwoStacks.data: Field
uses {
axiom FDim(_module.TwoStacks.data) == 0
   && FieldOfDecl(class._module.TwoStacks?, field$data) == _module.TwoStacks.data
   && !$IsGhostField(_module.TwoStacks.data);
}

// TwoStacks.data: Type axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.data)): ref, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
     ==> $Is($Unbox(read($h, $o, _module.TwoStacks.data)): ref, 
      Tclass._System.array(_module.TwoStacks$T)));

// TwoStacks.data: Allocation axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.data)): ref, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc($Unbox(read($h, $o, _module.TwoStacks.data)): ref, 
      Tclass._System.array(_module.TwoStacks$T), 
      $h));

const _module.TwoStacks.n1: Field
uses {
axiom FDim(_module.TwoStacks.n1) == 0
   && FieldOfDecl(class._module.TwoStacks?, field$n1) == _module.TwoStacks.n1
   && !$IsGhostField(_module.TwoStacks.n1);
}

// TwoStacks.n1: Type axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.n1)): int, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
     ==> $Is($Unbox(read($h, $o, _module.TwoStacks.n1)): int, Tclass._System.nat()));

// TwoStacks.n1: Allocation axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.n1)): int, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc($Unbox(read($h, $o, _module.TwoStacks.n1)): int, Tclass._System.nat(), $h));

const _module.TwoStacks.n2: Field
uses {
axiom FDim(_module.TwoStacks.n2) == 0
   && FieldOfDecl(class._module.TwoStacks?, field$n2) == _module.TwoStacks.n2
   && !$IsGhostField(_module.TwoStacks.n2);
}

// TwoStacks.n2: Type axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.n2)): int, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
     ==> $Is($Unbox(read($h, $o, _module.TwoStacks.n2)): int, Tclass._System.nat()));

// TwoStacks.n2: Allocation axiom
axiom (forall _module.TwoStacks$T: Ty, $h: Heap, $o: ref :: 
  { $Unbox(read($h, $o, _module.TwoStacks.n2)): int, Tclass._module.TwoStacks?(_module.TwoStacks$T) } 
  $IsGoodHeap($h)
       && 
      $o != null
       && dtype($o) == Tclass._module.TwoStacks?(_module.TwoStacks$T)
       && $Unbox(read($h, $o, alloc)): bool
     ==> $IsAlloc($Unbox(read($h, $o, _module.TwoStacks.n2)): int, Tclass._System.nat(), $h));

// function declaration for _module.TwoStacks.Valid
function _module.TwoStacks.Valid(_module.TwoStacks$T: Ty, $heap: Heap, this: ref) : bool;

function _module.TwoStacks.Valid#canCall(_module.TwoStacks$T: Ty, $heap: Heap, this: ref) : bool;

function Tclass._module.TwoStacks(Ty) : Ty;

const unique Tagclass._module.TwoStacks: TyTag;

// Tclass._module.TwoStacks Tag
axiom (forall _module.TwoStacks$T: Ty :: 
  { Tclass._module.TwoStacks(_module.TwoStacks$T) } 
  Tag(Tclass._module.TwoStacks(_module.TwoStacks$T)) == Tagclass._module.TwoStacks
     && TagFamily(Tclass._module.TwoStacks(_module.TwoStacks$T))
       == tytagFamily$TwoStacks);

function Tclass._module.TwoStacks_0(Ty) : Ty;

// Tclass._module.TwoStacks injectivity 0
axiom (forall _module.TwoStacks$T: Ty :: 
  { Tclass._module.TwoStacks(_module.TwoStacks$T) } 
  Tclass._module.TwoStacks_0(Tclass._module.TwoStacks(_module.TwoStacks$T))
     == _module.TwoStacks$T);

// Box/unbox axiom for Tclass._module.TwoStacks
axiom (forall _module.TwoStacks$T: Ty, bx: Box :: 
  { $IsBox(bx, Tclass._module.TwoStacks(_module.TwoStacks$T)) } 
  $IsBox(bx, Tclass._module.TwoStacks(_module.TwoStacks$T))
     ==> $Box($Unbox(bx): ref) == bx
       && $Is($Unbox(bx): ref, Tclass._module.TwoStacks(_module.TwoStacks$T)));

// frame axiom for _module.TwoStacks.Valid
axiom (forall _module.TwoStacks$T: Ty, $h0: Heap, $h1: Heap, this: ref :: 
  { $IsHeapAnchor($h0), $HeapSucc($h0, $h1), _module.TwoStacks.Valid(_module.TwoStacks$T, $h1, this) } 
  $IsGoodHeap($h0)
       && $IsGoodHeap($h1)
       && 
      this != null
       && $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
       && 
      $IsHeapAnchor($h0)
       && $HeapSucc($h0, $h1)
     ==> 
    (forall $o: ref, $f: Field :: 
      $o != null
           && ($o == this
             || Set#IsMember($Unbox(read($h0, this, _module.TwoStacks.Repr)): Set, $Box($o)))
         ==> read($h0, $o, $f) == read($h1, $o, $f))
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $h0, this)
         == _module.TwoStacks.Valid(_module.TwoStacks$T, $h1, this)
       && _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $h0, this)
         == _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $h1, this));

// consequence axiom for _module.TwoStacks.Valid
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this) } 
  _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
       && (_module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)));

function _module.TwoStacks.Valid#requires(Ty, Heap, ref) : bool;

// #requires axiom for _module.TwoStacks.Valid
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Valid#requires(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  $IsGoodHeap($Heap)
       && 
      this != null
       && 
      $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
       && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap)
     ==> _module.TwoStacks.Valid#requires(_module.TwoStacks$T, $Heap, this) == true);

// #requires ==> #canCall for _module.TwoStacks.Valid
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Valid#requires(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  _module.TwoStacks.Valid#requires(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this));

// definition axiom for _module.TwoStacks.Valid (revealed)
axiom {:id "id0"} (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       == (
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
         && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
          read($Heap, this, _module.TwoStacks.data))
         && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
           == _module.TwoStacks.N(_module.TwoStacks$T, this)
         && 
        LitInt(0)
           <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           <= _module.TwoStacks.N(_module.TwoStacks$T, this)
         && 
        LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           <= _module.TwoStacks.N(_module.TwoStacks$T, this)
         && 
        LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           <= _module.TwoStacks.N(_module.TwoStacks$T, this)
         && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
           ==> (forall i#0: int :: 
            { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
            LitInt(0) <= i#0
                 && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
                 == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))))
         && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
           ==> (forall i#1: int :: 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
            LitInt(0) <= i#1
                 && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
                 == read($Heap, 
                  $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                  IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - 1
                       - i#1))))
         && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
           == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
           == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)));

procedure {:verboseName "TwoStacks.Valid (well-formedness)"} CheckWellformed$$_module.TwoStacks.Valid(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap));
  modifies $Heap;
  free ensures {:always_assume} this == this
     || _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id1"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id2"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id3"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     ==> LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id4"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id5"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     ==> LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id6"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.Valid (well-formedness)"} CheckWellformed$$_module.TwoStacks.Valid(_module.TwoStacks$T: Ty, this: ref)
{
  var $_ReadsFrame: [ref,Field]bool;
  var b$reqreads#0: bool;
  var i#2: int;
  var i#4: int;
  var b$reqreads#1: bool;
  var b$reqreads#2: bool;
  var b$reqreads#3: bool;
  var b$reqreads#4: bool;
  var b$reqreads#5: bool;
  var b$reqreads#6: bool;
  var b$reqreads#7: bool;
  var b$reqreads#8: bool;
  var b$reqreads#9: bool;
  var b$reqreads#10: bool;
  var b$reqreads#11: bool;
  var b$reqreads#12: bool;
  var b$reqreads#13: bool;
  var b$reqreads#14: bool;
  var b$reqreads#15: bool;
  var b$reqreads#16: bool;
  var b$reqreads#17: bool;
  var b$reqreads#18: bool;
  var b$reqreads#19: bool;
  var b$reqreads#20: bool;
  var b$reqreads#21: bool;
  var b$reqreads#22: bool;
  var b$reqreads#23: bool;
  var b$reqreads#24: bool;
  var b$reqreads#25: bool;
  var b$reqreads#26: bool;
  var b$reqreads#27: bool;

    b$reqreads#0 := true;
    b$reqreads#1 := true;
    b$reqreads#2 := true;
    b$reqreads#3 := true;
    b$reqreads#4 := true;
    b$reqreads#5 := true;
    b$reqreads#6 := true;
    b$reqreads#7 := true;
    b$reqreads#8 := true;
    b$reqreads#9 := true;
    b$reqreads#10 := true;
    b$reqreads#11 := true;
    b$reqreads#12 := true;
    b$reqreads#13 := true;
    b$reqreads#14 := true;
    b$reqreads#15 := true;
    b$reqreads#16 := true;
    b$reqreads#17 := true;
    b$reqreads#18 := true;
    b$reqreads#19 := true;
    b$reqreads#20 := true;
    b$reqreads#21 := true;
    b$reqreads#22 := true;
    b$reqreads#23 := true;
    b$reqreads#24 := true;
    b$reqreads#25 := true;
    b$reqreads#26 := true;
    b$reqreads#27 := true;

    $_ReadsFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> $o == this
           || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    // Check well-formedness of preconditions, and then assume them
    // Check well-formedness of the reads clause
    b$reqreads#0 := $_ReadsFrame[this, _module.TwoStacks.Repr];
    assume true;
    assert {:id "id7"} b$reqreads#0;
    // Check well-formedness of the decreases clause
    assume true;
    // Check body and ensures clauses
    if (*)
    {
        // Check well-formedness of postcondition and assume false
        if (*)
        {
            // assume allocatedness for receiver argument to function
            assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
            assume true;
            assert {:id "id8"} this == this
               || (Set#Subset(Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this))), 
                  Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this))))
                 && !Set#Subset(Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this))), 
                  Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this)))));
            assume this == this
               || _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id9"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
            assume true;
            assume {:id "id10"} Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
            assume true;
            assume true;
            assume true;
            assume {:id "id11"} Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
            assume true;
            if (LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq))
            {
                assume true;
                assume true;
            }

            assume {:id "id12"} LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 <= _module.TwoStacks.N(_module.TwoStacks$T, this);
            assume true;
            if (LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
            {
                assume true;
                assume true;
            }

            assume {:id "id13"} LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        }
        else
        {
            assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id14"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
               ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
                 && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                     + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   <= _module.TwoStacks.N(_module.TwoStacks$T, this)
                 && 
                LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                   <= _module.TwoStacks.N(_module.TwoStacks$T, this)
                 && 
                LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        }

        assume false;
    }
    else
    {
        // Check well-formedness of body and result subset type constraint
        b$reqreads#1 := $_ReadsFrame[this, _module.TwoStacks.Repr];
        assume true;
        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this)))
        {
            b$reqreads#2 := $_ReadsFrame[this, _module.TwoStacks.data];
            assume true;
            b$reqreads#3 := $_ReadsFrame[this, _module.TwoStacks.Repr];
            assume true;
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data)))
        {
            b$reqreads#4 := $_ReadsFrame[this, _module.TwoStacks.data];
            assume true;
            assert {:id "id15"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assume true;
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this))
        {
            b$reqreads#5 := $_ReadsFrame[this, _module.TwoStacks.s1];
            assume true;
            b$reqreads#6 := $_ReadsFrame[this, _module.TwoStacks.s2];
            assume true;
            if (LitInt(0)
               <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
            {
                b$reqreads#7 := $_ReadsFrame[this, _module.TwoStacks.s1];
                assume true;
                b$reqreads#8 := $_ReadsFrame[this, _module.TwoStacks.s2];
                assume true;
                assume true;
            }
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this))
        {
            b$reqreads#9 := $_ReadsFrame[this, _module.TwoStacks.s1];
            assume true;
            if (LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq))
            {
                b$reqreads#10 := $_ReadsFrame[this, _module.TwoStacks.s1];
                assume true;
                assume true;
            }
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this))
        {
            b$reqreads#11 := $_ReadsFrame[this, _module.TwoStacks.s2];
            assume true;
            if (LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
            {
                b$reqreads#12 := $_ReadsFrame[this, _module.TwoStacks.s2];
                assume true;
                assume true;
            }
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this))
        {
            b$reqreads#13 := $_ReadsFrame[this, _module.TwoStacks.s1];
            assume true;
            if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0)
            {
                // Begin Comprehension WF check
                havoc i#2;
                if (true)
                {
                    if (LitInt(0) <= i#2)
                    {
                        b$reqreads#14 := $_ReadsFrame[this, _module.TwoStacks.s1];
                        assume true;
                    }

                    if (LitInt(0) <= i#2
                       && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq))
                    {
                        b$reqreads#15 := $_ReadsFrame[this, _module.TwoStacks.s1];
                        assume true;
                        assert {:id "id16"} 0 <= i#2
                           && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
                        b$reqreads#16 := $_ReadsFrame[this, _module.TwoStacks.data];
                        assume true;
                        assert {:id "id17"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                        assert {:id "id18"} 0 <= i#2
                           && i#2
                             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
                        b$reqreads#17 := $_ReadsFrame[$Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)];
                    }
                }

                // End Comprehension WF check
                assume true;
            }
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
             ==> (forall i#3: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3)) } 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
              LitInt(0) <= i#3
                   && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
                   == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3)))))
        {
            b$reqreads#18 := $_ReadsFrame[this, _module.TwoStacks.s2];
            assume true;
            if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0)
            {
                // Begin Comprehension WF check
                havoc i#4;
                if (true)
                {
                    if (LitInt(0) <= i#4)
                    {
                        b$reqreads#19 := $_ReadsFrame[this, _module.TwoStacks.s2];
                        assume true;
                    }

                    if (LitInt(0) <= i#4
                       && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
                    {
                        b$reqreads#20 := $_ReadsFrame[this, _module.TwoStacks.s2];
                        assume true;
                        assert {:id "id19"} 0 <= i#4
                           && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                        b$reqreads#21 := $_ReadsFrame[this, _module.TwoStacks.data];
                        assume true;
                        assert {:id "id20"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                        b$reqreads#22 := $_ReadsFrame[this, _module.TwoStacks.data];
                        assume true;
                        assert {:id "id21"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                        assume true;
                        assert {:id "id22"} 0
                             <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                               - 1
                               - i#4
                           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                               - 1
                               - i#4
                             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
                        b$reqreads#23 := $_ReadsFrame[$Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                             - 1
                             - i#4)];
                    }
                }

                // End Comprehension WF check
                assume true;
            }
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
             ==> (forall i#3: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3)) } 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
              LitInt(0) <= i#3
                   && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
                   == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3))))
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
             ==> (forall i#5: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
              LitInt(0) <= i#5
                   && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
                   == read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - 1
                         - i#5)))))
        {
            b$reqreads#24 := $_ReadsFrame[this, _module.TwoStacks.n1];
            assume true;
            b$reqreads#25 := $_ReadsFrame[this, _module.TwoStacks.s1];
            assume true;
        }

        if (Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
             ==> (forall i#3: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3)) } 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
              LitInt(0) <= i#3
                   && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
                   == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3))))
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
             ==> (forall i#5: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
              LitInt(0) <= i#5
                   && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
                   == read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - 1
                         - i#5))))
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq))
        {
            b$reqreads#26 := $_ReadsFrame[this, _module.TwoStacks.n2];
            assume true;
            b$reqreads#27 := $_ReadsFrame[this, _module.TwoStacks.s2];
            assume true;
        }

        assume true;
        assume {:id "id23"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           == (
            Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
             && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
              read($Heap, this, _module.TwoStacks.data))
             && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               == _module.TwoStacks.N(_module.TwoStacks$T, this)
             && 
            LitInt(0)
               <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this)
             && 
            LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this)
             && 
            LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this)
             && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
               ==> (forall i#3: int :: 
                { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3)) } 
                  { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
                LitInt(0) <= i#3
                     && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
                     == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#3))))
             && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
               ==> (forall i#5: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
                LitInt(0) <= i#5
                     && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
                     == read($Heap, 
                      $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                      IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - 1
                           - i#5))))
             && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq));
        // CheckWellformedWithResult: any expression
        assume $Is(_module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this), TBool);
        assert {:id "id24"} b$reqreads#1;
        assert {:id "id25"} b$reqreads#2;
        assert {:id "id26"} b$reqreads#3;
        assert {:id "id27"} b$reqreads#4;
        assert {:id "id28"} b$reqreads#5;
        assert {:id "id29"} b$reqreads#6;
        assert {:id "id30"} b$reqreads#7;
        assert {:id "id31"} b$reqreads#8;
        assert {:id "id32"} b$reqreads#9;
        assert {:id "id33"} b$reqreads#10;
        assert {:id "id34"} b$reqreads#11;
        assert {:id "id35"} b$reqreads#12;
        assert {:id "id36"} b$reqreads#13;
        assert {:id "id37"} b$reqreads#14;
        assert {:id "id38"} b$reqreads#15;
        assert {:id "id39"} b$reqreads#16;
        assert {:id "id40"} b$reqreads#17;
        assert {:id "id41"} b$reqreads#18;
        assert {:id "id42"} b$reqreads#19;
        assert {:id "id43"} b$reqreads#20;
        assert {:id "id44"} b$reqreads#21;
        assert {:id "id45"} b$reqreads#22;
        assert {:id "id46"} b$reqreads#23;
        assert {:id "id47"} b$reqreads#24;
        assert {:id "id48"} b$reqreads#25;
        assert {:id "id49"} b$reqreads#26;
        assert {:id "id50"} b$reqreads#27;
        return;

        assume false;
    }
}



procedure {:verboseName "TwoStacks._ctor (well-formedness)"} CheckWellFormed$$_module.TwoStacks.__ctor(_module.TwoStacks$T: Ty, N#0: int where LitInt(0) <= N#0) returns (this: ref);
  modifies $Heap;



procedure {:verboseName "TwoStacks._ctor (call)"} Call$$_module.TwoStacks.__ctor(_module.TwoStacks$T: Ty, N#0: int where LitInt(0) <= N#0)
   returns (this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap));
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id55"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#0: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
        LitInt(0) <= i#0
             && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#1: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
        LitInt(0) <= i#1
             && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#1))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id56"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)) } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  free ensures {:always_assume} true;
  ensures {:id "id57"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
    $Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id58"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, Seq#Empty(): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id59"} _module.TwoStacks.N(_module.TwoStacks$T, this) == N#0;
  // constructor allocates the object
  ensures !$Unbox(read(old($Heap), this, alloc)): bool;
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks._ctor (correctness)"} Impl$$_module.TwoStacks.__ctor(_module.TwoStacks$T: Ty, N#0: int where LitInt(0) <= N#0)
   returns (this: ref, $_reverifyPost: bool);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id60"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id61"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id62"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id63"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id64"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id65"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id66"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id67"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id68"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id69"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#2: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
          LitInt(0) <= i#2
               && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))));
  ensures {:id "id70"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#3: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
          LitInt(0) <= i#3
               && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#3))));
  ensures {:id "id71"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id72"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id73"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)) } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  free ensures {:always_assume} true;
  ensures {:id "id74"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
    $Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id75"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, Seq#Empty(): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id76"} _module.TwoStacks.N(_module.TwoStacks$T, this) == N#0;
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks._ctor (correctness)"} Impl$$_module.TwoStacks.__ctor(_module.TwoStacks$T: Ty, N#0: int) returns (this: ref, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var this.s1: Seq;
  var this.s2: Seq;
  var this.N: int;
  var this.Repr: Set;
  var this.data: ref;
  var this.n1: int;
  var this.n2: int;
  var $obj0: ref;
  var $obj1: ref;
  var $obj2: ref;
  var $rhs#0: Seq;
  var $rhs#1: Seq;
  var $rhs#2: int;
  var $nw: ref;
  var $rhs#3: int;
  var $rhs#4: int;

    // AddMethodImpl: _ctor, Impl$$_module.TwoStacks.__ctor
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    $_reverifyPost := false;
    // ----- divided block before new; ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(27,5)
    // ----- update statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(28,22)
    assume true;
    assume true;
    $obj0 := this;
    assume true;
    assume true;
    $obj1 := this;
    assume true;
    assume true;
    $obj2 := this;
    assume true;
    $rhs#0 := Lit(Seq#Empty(): Seq);
    assume true;
    $rhs#1 := Lit(Seq#Empty(): Seq);
    assume true;
    $rhs#2 := N#0;
    this.s1 := $rhs#0;
    this.s2 := $rhs#1;
    this.N := $rhs#2;
    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(29,14)
    assume true;
    assume true;
    assert {:id "id83"} 0 <= N#0;
    havoc $nw;
    assume $nw != null && $Is($nw, Tclass._System.array?(_module.TwoStacks$T));
    assume !$Unbox(read($Heap, $nw, alloc)): bool;
    assume _System.array.Length($nw) == N#0;
    $Heap := update($Heap, $nw, alloc, $Box(true));
    assume $IsGoodHeap($Heap);
    assume $IsHeapAnchor($Heap);
    this.data := $nw;
    // ----- update statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(30,16)
    assume true;
    assume true;
    $obj0 := this;
    assume true;
    assume true;
    $obj1 := this;
    assert {:id "id85"} $Is(LitInt(0), Tclass._System.nat());
    assume true;
    $rhs#3 := LitInt(0);
    assert {:id "id87"} $Is(LitInt(0), Tclass._System.nat());
    assume true;
    $rhs#4 := LitInt(0);
    this.n1 := $rhs#3;
    this.n2 := $rhs#4;
    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(31,14)
    assume true;
    assume true;
    assume true;
    assume true;
    this.Repr := Set#UnionOne(Set#UnionOne(Set#Empty(): Set, $Box(this)), $Box(this.data));
    // ----- new; ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(27,5)
    assume this != null && $Is(this, Tclass._module.TwoStacks?(_module.TwoStacks$T));
    assume !$Unbox(read($Heap, this, alloc)): bool;
    assume $Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq == this.s1;
    assume $Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq == this.s2;
    assume _module.TwoStacks.N(_module.TwoStacks$T, this) == this.N;
    assume $Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set == this.Repr;
    assume $Unbox(read($Heap, this, _module.TwoStacks.data)): ref == this.data;
    assume $Unbox(read($Heap, this, _module.TwoStacks.n1)): int == this.n1;
    assume $Unbox(read($Heap, this, _module.TwoStacks.n2)): int == this.n2;
    $Heap := update($Heap, this, alloc, $Box(true));
    assume $IsGoodHeap($Heap);
    assume $IsHeapAnchor($Heap);
    // ----- divided block after new; ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(27,5)
}



procedure {:verboseName "TwoStacks.push1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.push1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    element#0: Box
       where $IsBox(element#0, _module.TwoStacks$T)
         && $IsAllocBox(element#0, _module.TwoStacks$T, $Heap))
   returns (FullStatus#0: bool);
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.push1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.push1(_module.TwoStacks$T: Ty, this: ref, element#0: Box) returns (FullStatus#0: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;


    // AddMethodImpl: push1, CheckWellFormed$$_module.TwoStacks.push1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id92"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]
           || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
    assume $HeapSucc(old($Heap), $Heap);
    havoc FullStatus#0;
    if (*)
    {
        assert {:id "id93"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id94"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           != _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id95"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id96"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id97"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
             + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           != _module.TwoStacks.N(_module.TwoStacks$T, this);
        assume true;
        assert {:id "id98"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume {:id "id99"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
          Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
            Seq#Build(Seq#Empty(): Seq, element#0)));
    }
    else
    {
        assume true;
        assume {:id "id100"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
               != _module.TwoStacks.N(_module.TwoStacks$T, this)
             && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
               != _module.TwoStacks.N(_module.TwoStacks$T, this)
           ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
            Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
              Seq#Build(Seq#Empty(): Seq, element#0)));
    }

    if (*)
    {
        assert {:id "id101"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id102"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           == _module.TwoStacks.N(_module.TwoStacks$T, this);
        assume {:id "id103"} FullStatus#0 == Lit(false);
    }
    else
    {
        assume true;
        assume {:id "id104"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           ==> FullStatus#0 == Lit(false);
    }

    if (*)
    {
        assert {:id "id105"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id106"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           != _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id107"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id108"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id109"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
             + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           == _module.TwoStacks.N(_module.TwoStacks$T, this);
        assume {:id "id110"} FullStatus#0 == Lit(false);
    }
    else
    {
        assume true;
        assume {:id "id111"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
               != _module.TwoStacks.N(_module.TwoStacks$T, this)
             && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
               == _module.TwoStacks.N(_module.TwoStacks$T, this)
           ==> FullStatus#0 == Lit(false);
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id112"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    assert {:id "id113"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
    assume true;
    assume {:id "id114"} (forall $o: ref :: 
        { $o != null } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> $o != null)
       && (forall $o: ref :: 
        { $Unbox(read(old($Heap), $o, alloc)): bool } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
}



procedure {:verboseName "TwoStacks.push1 (call)"} Call$$_module.TwoStacks.push1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    element#0: Box
       where $IsBox(element#0, _module.TwoStacks$T)
         && $IsAllocBox(element#0, _module.TwoStacks$T, $Heap))
   returns (FullStatus#0: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id115"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id116"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id117"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id118"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id119"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id120"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id121"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id122"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id123"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id124"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#0: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
          LitInt(0) <= i#0
               && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))));
  requires {:id "id125"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#1: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
          LitInt(0) <= i#1
               && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#1))));
  requires {:id "id126"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id127"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id128"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
      Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
        Seq#Build(Seq#Empty(): Seq, element#0)));
  free ensures {:always_assume} true;
  ensures {:id "id129"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} true;
  ensures {:id "id130"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id131"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#2: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
        LitInt(0) <= i#2
             && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#3: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
        LitInt(0) <= i#3
             && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#3))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id132"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.push1 (correctness)"} Impl$$_module.TwoStacks.push1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    element#0: Box
       where $IsBox(element#0, _module.TwoStacks$T)
         && $IsAllocBox(element#0, _module.TwoStacks$T, $Heap))
   returns (FullStatus#0: bool, $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id133"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#4: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4) } 
        LitInt(0) <= i#4
             && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#5: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
        LitInt(0) <= i#5
             && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#5))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id134"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
      Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
        Seq#Build(Seq#Empty(): Seq, element#0)));
  free ensures {:always_assume} true;
  ensures {:id "id135"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} true;
  ensures {:id "id136"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id137"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id138"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id139"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id140"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id141"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id142"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id143"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id144"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id145"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id146"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#6: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6) } 
          LitInt(0) <= i#6
               && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6))));
  ensures {:id "id147"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#7: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7) } 
          LitInt(0) <= i#7
               && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#7))));
  ensures {:id "id148"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id149"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id150"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.push1 (correctness)"} Impl$$_module.TwoStacks.push1(_module.TwoStacks$T: Ty, this: ref, element#0: Box)
   returns (FullStatus#0: bool, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var $rhs#1_0_0: Seq;
  var $rhs#1_0_1: Box;
  var $rhs#1_0_2: int;

    // AddMethodImpl: push1, Impl$$_module.TwoStacks.push1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    $_reverifyPost := false;
    // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(42,9)
    assume true;
    assume true;
    assert {:id "id151"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
    assume true;
    assume true;
    if ($Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref))
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(44,24)
        assume true;
        assume true;
        FullStatus#0 := Lit(false);
    }
    else
    {
        // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(46,13)
        assume true;
        assume true;
        assert {:id "id153"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        if ($Unbox(read($Heap, this, _module.TwoStacks.n1)): int
           != _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref))
        {
            assume true;
            assume true;
            assume true;
            assert {:id "id154"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
        }

        assume true;
        if ($Unbox(read($Heap, this, _module.TwoStacks.n1)): int
             != _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
               + $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             != _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref))
        {
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(47,20)
            assume true;
            assume true;
            assert {:id "id155"} $_ModifiesFrame[this, _module.TwoStacks.s1];
            assert {:id "id156"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
            assume true;
            assume true;
            $rhs#1_0_0 := Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
              Seq#Build(Seq#Empty(): Seq, element#0));
            $Heap := update($Heap, this, _module.TwoStacks.s1, $Box($rhs#1_0_0));
            assume $IsGoodHeap($Heap);
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(48,26)
            assume true;
            assert {:id "id159"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assert {:id "id160"} 0 <= $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
               && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
                 < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
            assume true;
            assert {:id "id161"} $_ModifiesFrame[$Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField($Unbox(read($Heap, this, _module.TwoStacks.n1)): int)];
            assume true;
            $rhs#1_0_1 := element#0;
            $Heap := update($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField($Unbox(read($Heap, this, _module.TwoStacks.n1)): int), 
              $rhs#1_0_1);
            assume $IsGoodHeap($Heap);
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(49,20)
            assume true;
            assume true;
            assert {:id "id164"} $_ModifiesFrame[this, _module.TwoStacks.n1];
            assume true;
            assert {:id "id165"} $Is($Unbox(read($Heap, this, _module.TwoStacks.n1)): int + 1, Tclass._System.nat());
            assume true;
            $rhs#1_0_2 := $Unbox(read($Heap, this, _module.TwoStacks.n1)): int + 1;
            $Heap := update($Heap, this, _module.TwoStacks.n1, $Box($rhs#1_0_2));
            assume $IsGoodHeap($Heap);
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(50,28)
            assume true;
            assume true;
            FullStatus#0 := Lit(true);
        }
        else
        {
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(52,28)
            assume true;
            assume true;
            FullStatus#0 := Lit(false);
        }
    }
}



procedure {:verboseName "TwoStacks.push2 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.push2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    element#0: Box
       where $IsBox(element#0, _module.TwoStacks$T)
         && $IsAllocBox(element#0, _module.TwoStacks$T, $Heap))
   returns (FullStatus#0: bool);
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.push2 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.push2(_module.TwoStacks$T: Ty, this: ref, element#0: Box) returns (FullStatus#0: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;


    // AddMethodImpl: push2, CheckWellFormed$$_module.TwoStacks.push2
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id170"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]
           || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
    assume $HeapSucc(old($Heap), $Heap);
    havoc FullStatus#0;
    if (*)
    {
        assert {:id "id171"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id172"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           != _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id173"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id174"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id175"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
             + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           != _module.TwoStacks.N(_module.TwoStacks$T, this);
        assume true;
        assert {:id "id176"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume {:id "id177"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
          Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
            Seq#Build(Seq#Empty(): Seq, element#0)));
    }
    else
    {
        assume true;
        assume {:id "id178"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
               != _module.TwoStacks.N(_module.TwoStacks$T, this)
             && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
               != _module.TwoStacks.N(_module.TwoStacks$T, this)
           ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
            Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
              Seq#Build(Seq#Empty(): Seq, element#0)));
    }

    if (*)
    {
        assert {:id "id179"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id180"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           == _module.TwoStacks.N(_module.TwoStacks$T, this);
        assume {:id "id181"} FullStatus#0 == Lit(false);
    }
    else
    {
        assume true;
        assume {:id "id182"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           ==> FullStatus#0 == Lit(false);
    }

    if (*)
    {
        assert {:id "id183"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id184"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           != _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id185"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id186"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume true;
        assume {:id "id187"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
             + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           == _module.TwoStacks.N(_module.TwoStacks$T, this);
        assume {:id "id188"} FullStatus#0 == Lit(false);
    }
    else
    {
        assume true;
        assume {:id "id189"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
               != _module.TwoStacks.N(_module.TwoStacks$T, this)
             && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
               == _module.TwoStacks.N(_module.TwoStacks$T, this)
           ==> FullStatus#0 == Lit(false);
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id190"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    assert {:id "id191"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
    assume true;
    assume {:id "id192"} (forall $o: ref :: 
        { $o != null } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> $o != null)
       && (forall $o: ref :: 
        { $Unbox(read(old($Heap), $o, alloc)): bool } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
}



procedure {:verboseName "TwoStacks.push2 (call)"} Call$$_module.TwoStacks.push2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    element#0: Box
       where $IsBox(element#0, _module.TwoStacks$T)
         && $IsAllocBox(element#0, _module.TwoStacks$T, $Heap))
   returns (FullStatus#0: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id193"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id194"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id195"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id196"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id197"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id198"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id199"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id200"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id201"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id202"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#0: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
          LitInt(0) <= i#0
               && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))));
  requires {:id "id203"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#1: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
          LitInt(0) <= i#1
               && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#1))));
  requires {:id "id204"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id205"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id206"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
      Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
        Seq#Build(Seq#Empty(): Seq, element#0)));
  free ensures {:always_assume} true;
  ensures {:id "id207"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} true;
  ensures {:id "id208"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id209"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#2: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
        LitInt(0) <= i#2
             && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#3: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
        LitInt(0) <= i#3
             && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#3))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id210"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.push2 (correctness)"} Impl$$_module.TwoStacks.push2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    element#0: Box
       where $IsBox(element#0, _module.TwoStacks$T)
         && $IsAllocBox(element#0, _module.TwoStacks$T, $Heap))
   returns (FullStatus#0: bool, $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id211"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#4: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4) } 
        LitInt(0) <= i#4
             && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#5: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
        LitInt(0) <= i#5
             && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#5))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id212"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
      Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
        Seq#Build(Seq#Empty(): Seq, element#0)));
  free ensures {:always_assume} true;
  ensures {:id "id213"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} true;
  ensures {:id "id214"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         != _module.TwoStacks.N(_module.TwoStacks$T, this)
       && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
         == _module.TwoStacks.N(_module.TwoStacks$T, this)
     ==> FullStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id215"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id216"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id217"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id218"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id219"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id220"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id221"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id222"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id223"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id224"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#6: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6) } 
          LitInt(0) <= i#6
               && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6))));
  ensures {:id "id225"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#7: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7) } 
          LitInt(0) <= i#7
               && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#7))));
  ensures {:id "id226"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id227"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id228"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.push2 (correctness)"} Impl$$_module.TwoStacks.push2(_module.TwoStacks$T: Ty, this: ref, element#0: Box)
   returns (FullStatus#0: bool, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var $rhs#1_0_0: Seq;
  var $rhs#1_0_1: Box;
  var $rhs#1_0_2: int;

    // AddMethodImpl: push2, Impl$$_module.TwoStacks.push2
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    $_reverifyPost := false;
    // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(65,9)
    assume true;
    assume true;
    assert {:id "id229"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
    assume true;
    assume true;
    if ($Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref))
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(67,24)
        assume true;
        assume true;
        FullStatus#0 := Lit(false);
    }
    else
    {
        // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(69,13)
        assume true;
        assume true;
        assert {:id "id231"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        if ($Unbox(read($Heap, this, _module.TwoStacks.n2)): int
           != _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref))
        {
            assume true;
            assume true;
            assume true;
            assert {:id "id232"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
        }

        assume true;
        if ($Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             != _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
               + $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             != _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref))
        {
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(70,20)
            assume true;
            assume true;
            assert {:id "id233"} $_ModifiesFrame[this, _module.TwoStacks.s2];
            assert {:id "id234"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
            assume true;
            assume true;
            $rhs#1_0_0 := Seq#Append($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
              Seq#Build(Seq#Empty(): Seq, element#0));
            $Heap := update($Heap, this, _module.TwoStacks.s2, $Box($rhs#1_0_0));
            assume $IsGoodHeap($Heap);
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(71,40)
            assume true;
            assert {:id "id237"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assert {:id "id238"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assume true;
            assert {:id "id239"} 0
                 <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                 < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
            assume true;
            assert {:id "id240"} $_ModifiesFrame[$Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                 - 1
                 - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int)];
            assume true;
            $rhs#1_0_1 := element#0;
            $Heap := update($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int), 
              $rhs#1_0_1);
            assume $IsGoodHeap($Heap);
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(72,20)
            assume true;
            assume true;
            assert {:id "id243"} $_ModifiesFrame[this, _module.TwoStacks.n2];
            assume true;
            assert {:id "id244"} $Is($Unbox(read($Heap, this, _module.TwoStacks.n2)): int + 1, Tclass._System.nat());
            assume true;
            $rhs#1_0_2 := $Unbox(read($Heap, this, _module.TwoStacks.n2)): int + 1;
            $Heap := update($Heap, this, _module.TwoStacks.n2, $Box($rhs#1_0_2));
            assume $IsGoodHeap($Heap);
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(73,28)
            assume true;
            assume true;
            FullStatus#0 := Lit(true);
        }
        else
        {
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(75,28)
            assume true;
            assume true;
            FullStatus#0 := Lit(false);
        }
    }
}



procedure {:verboseName "TwoStacks.pop1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.pop1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    PopedItem#0: Box
       where $IsBox(PopedItem#0, _module.TwoStacks$T)
         && $IsAllocBox(PopedItem#0, _module.TwoStacks$T, $Heap));
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.pop1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.pop1(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, PopedItem#0: Box)
{
  var $_ModifiesFrame: [ref,Field]bool;


    // AddMethodImpl: pop1, CheckWellFormed$$_module.TwoStacks.pop1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id249"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]
           || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
    assume $HeapSucc(old($Heap), $Heap);
    havoc EmptyStatus#0, PopedItem#0;
    if (*)
    {
        assert {:id "id250"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume {:id "id251"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0;
        assume true;
        assert {:id "id252"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id253"} 0 <= LitInt(0)
           && LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq);
        assert {:id "id254"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id255"} LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1
           && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq);
        assume {:id "id256"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
          Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
              Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1), 
            LitInt(0)));
        assume {:id "id257"} EmptyStatus#0 == Lit(true);
        assert {:id "id258"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id259"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id260"} 0 <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1
           && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1
             < Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq);
        assume {:id "id261"} PopedItem#0
           == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
            Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1);
    }
    else
    {
        assume true;
        assume {:id "id262"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0
           ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
              Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
                  Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1), 
                LitInt(0)))
             && EmptyStatus#0 == Lit(true)
             && PopedItem#0
               == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
                Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1);
    }

    if (*)
    {
        assert {:id "id263"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume {:id "id264"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
           == LitInt(0);
        assume {:id "id265"} EmptyStatus#0 == Lit(false);
    }
    else
    {
        assume true;
        assume {:id "id266"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
             == LitInt(0)
           ==> EmptyStatus#0 == Lit(false);
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id267"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    assert {:id "id268"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
    assume true;
    assume {:id "id269"} (forall $o: ref :: 
        { $o != null } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> $o != null)
       && (forall $o: ref :: 
        { $Unbox(read(old($Heap), $o, alloc)): bool } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
}



procedure {:verboseName "TwoStacks.pop1 (call)"} Call$$_module.TwoStacks.pop1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    PopedItem#0: Box
       where $IsBox(PopedItem#0, _module.TwoStacks$T)
         && $IsAllocBox(PopedItem#0, _module.TwoStacks$T, $Heap));
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id270"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id271"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id272"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id273"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id274"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id275"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id276"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id277"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id278"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id279"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#0: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
          LitInt(0) <= i#0
               && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))));
  requires {:id "id280"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#1: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
          LitInt(0) <= i#1
               && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#1))));
  requires {:id "id281"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id282"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id283"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
      Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
          Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1), 
        LitInt(0)));
  ensures {:id "id284"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id285"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0
     ==> PopedItem#0
       == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
        Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1);
  free ensures {:always_assume} true;
  ensures {:id "id286"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
       == LitInt(0)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id287"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#2: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
        LitInt(0) <= i#2
             && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#3: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
        LitInt(0) <= i#3
             && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#3))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id288"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.pop1 (correctness)"} Impl$$_module.TwoStacks.pop1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    PopedItem#0: Box
       where $IsBox(PopedItem#0, _module.TwoStacks$T)
         && $IsAllocBox(PopedItem#0, _module.TwoStacks$T, $Heap), 
    $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id289"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#4: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4) } 
        LitInt(0) <= i#4
             && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#5: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
        LitInt(0) <= i#5
             && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#5))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id290"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
      Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
          Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1), 
        LitInt(0)));
  ensures {:id "id291"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id292"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) != 0
     ==> PopedItem#0
       == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
        Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1);
  free ensures {:always_assume} true;
  ensures {:id "id293"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq)
       == LitInt(0)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id294"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id295"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id296"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id297"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id298"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id299"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id300"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id301"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id302"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id303"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#6: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6) } 
          LitInt(0) <= i#6
               && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6))));
  ensures {:id "id304"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#7: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7) } 
          LitInt(0) <= i#7
               && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#7))));
  ensures {:id "id305"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id306"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id307"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.pop1 (correctness)"} Impl$$_module.TwoStacks.pop1(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, PopedItem#0: Box, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var $rhs#1_0: Seq;
  var $rhs#1_1: int;

    // AddMethodImpl: pop1, Impl$$_module.TwoStacks.pop1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    $_reverifyPost := false;
    // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(87,9)
    assume true;
    assume true;
    if ($Unbox(read($Heap, this, _module.TwoStacks.n1)): int == LitInt(0))
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(88,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(false);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(89,23)
        assume true;
        havoc PopedItem#0;
    }
    else
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(91,16)
        assume true;
        assume true;
        assert {:id "id309"} $_ModifiesFrame[this, _module.TwoStacks.s1];
        assert {:id "id310"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id311"} 0 <= LitInt(0)
           && LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq);
        assert {:id "id312"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id313"} LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1
           && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq);
        assume true;
        $rhs#1_0 := Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq, 
            Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s1)): Seq) - 1), 
          LitInt(0));
        $Heap := update($Heap, this, _module.TwoStacks.s1, $Box($rhs#1_0));
        assume $IsGoodHeap($Heap);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(92,23)
        assume true;
        assume true;
        assert {:id "id316"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assert {:id "id317"} 0 <= $Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        assume true;
        PopedItem#0 := read($Heap, 
          $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
          IndexField($Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1));
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(93,16)
        assume true;
        assume true;
        assert {:id "id319"} $_ModifiesFrame[this, _module.TwoStacks.n1];
        assume true;
        assert {:id "id320"} $Is($Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1, Tclass._System.nat());
        assume true;
        $rhs#1_1 := $Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1;
        $Heap := update($Heap, this, _module.TwoStacks.n1, $Box($rhs#1_1));
        assume $IsGoodHeap($Heap);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(94,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(true);
    }
}



procedure {:verboseName "TwoStacks.pop2 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.pop2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    PopedItem#0: Box
       where $IsBox(PopedItem#0, _module.TwoStacks$T)
         && $IsAllocBox(PopedItem#0, _module.TwoStacks$T, $Heap));
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.pop2 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.pop2(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, PopedItem#0: Box)
{
  var $_ModifiesFrame: [ref,Field]bool;


    // AddMethodImpl: pop2, CheckWellFormed$$_module.TwoStacks.pop2
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id324"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]
           || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
    assume $HeapSucc(old($Heap), $Heap);
    havoc EmptyStatus#0, PopedItem#0;
    if (*)
    {
        assert {:id "id325"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume {:id "id326"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0;
        assume true;
        assert {:id "id327"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id328"} 0 <= LitInt(0)
           && LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq);
        assert {:id "id329"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id330"} LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1
           && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq);
        assume {:id "id331"} Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
          Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
              Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1), 
            LitInt(0)));
        assume {:id "id332"} EmptyStatus#0 == Lit(true);
        assert {:id "id333"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id334"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id335"} 0 <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1
           && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1
             < Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq);
        assume {:id "id336"} PopedItem#0
           == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
            Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1);
    }
    else
    {
        assume true;
        assume {:id "id337"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0
           ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
              Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
                  Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1), 
                LitInt(0)))
             && EmptyStatus#0 == Lit(true)
             && PopedItem#0
               == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
                Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1);
    }

    if (*)
    {
        assert {:id "id338"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assume {:id "id339"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
           == LitInt(0);
        assume {:id "id340"} EmptyStatus#0 == Lit(false);
    }
    else
    {
        assume true;
        assume {:id "id341"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
             == LitInt(0)
           ==> EmptyStatus#0 == Lit(false);
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id342"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assume true;
    assert {:id "id343"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
    assume true;
    assume {:id "id344"} (forall $o: ref :: 
        { $o != null } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> $o != null)
       && (forall $o: ref :: 
        { $Unbox(read(old($Heap), $o, alloc)): bool } 
        Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
             && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
           ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
}



procedure {:verboseName "TwoStacks.pop2 (call)"} Call$$_module.TwoStacks.pop2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    PopedItem#0: Box
       where $IsBox(PopedItem#0, _module.TwoStacks$T)
         && $IsAllocBox(PopedItem#0, _module.TwoStacks$T, $Heap));
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id345"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id346"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id347"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id348"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id349"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id350"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id351"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id352"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id353"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id354"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#0: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
          LitInt(0) <= i#0
               && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))));
  requires {:id "id355"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#1: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
          LitInt(0) <= i#1
               && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#1))));
  requires {:id "id356"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id357"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id358"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
      Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
          Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1), 
        LitInt(0)));
  ensures {:id "id359"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id360"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0
     ==> PopedItem#0
       == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
        Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1);
  free ensures {:always_assume} true;
  ensures {:id "id361"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
       == LitInt(0)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id362"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#2: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
        LitInt(0) <= i#2
             && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#3: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
        LitInt(0) <= i#3
             && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#3))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id363"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.pop2 (correctness)"} Impl$$_module.TwoStacks.pop2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    PopedItem#0: Box
       where $IsBox(PopedItem#0, _module.TwoStacks$T)
         && $IsAllocBox(PopedItem#0, _module.TwoStacks$T, $Heap), 
    $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id364"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#4: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4) } 
        LitInt(0) <= i#4
             && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#5: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
        LitInt(0) <= i#5
             && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#5))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // user-defined frame expressions
  free requires {:always_assume} true;
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id365"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0
     ==> Seq#Equal($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
      Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
          Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1), 
        LitInt(0)));
  ensures {:id "id366"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id367"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) != 0
     ==> PopedItem#0
       == Seq#Index($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
        Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1);
  free ensures {:always_assume} true;
  ensures {:id "id368"} Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq)
       == LitInt(0)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id369"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id370"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id371"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id372"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id373"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id374"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id375"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id376"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id377"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id378"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#6: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6) } 
          LitInt(0) <= i#6
               && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6))));
  ensures {:id "id379"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#7: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7) } 
          LitInt(0) <= i#7
               && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#7))));
  ensures {:id "id380"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id381"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  free ensures {:always_assume} true;
  ensures {:id "id382"} (forall $o: ref :: 
      { $o != null } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> $o != null)
     && (forall $o: ref :: 
      { $Unbox(read(old($Heap), $o, alloc)): bool } 
      Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o))
           && !Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o))
         ==> !$Unbox(read(old($Heap), $o, alloc)): bool);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]
         || Set#IsMember($Unbox(read(old($Heap), this, _module.TwoStacks.Repr)): Set, $Box($o)));
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.pop2 (correctness)"} Impl$$_module.TwoStacks.pop2(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, PopedItem#0: Box, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var $rhs#1_0: Seq;
  var $rhs#1_1: int;

    // AddMethodImpl: pop2, Impl$$_module.TwoStacks.pop2
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    $_reverifyPost := false;
    // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(105,9)
    assume true;
    assume true;
    if ($Unbox(read($Heap, this, _module.TwoStacks.n2)): int == LitInt(0))
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(106,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(false);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(107,23)
        assume true;
        havoc PopedItem#0;
    }
    else
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(109,16)
        assume true;
        assume true;
        assert {:id "id384"} $_ModifiesFrame[this, _module.TwoStacks.s2];
        assert {:id "id385"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id386"} 0 <= LitInt(0)
           && LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq);
        assert {:id "id387"} $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), old($Heap));
        assume true;
        assert {:id "id388"} LitInt(0)
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1
           && Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1
             <= Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq);
        assume true;
        $rhs#1_0 := Seq#Drop(Seq#Take($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq, 
            Seq#Length($Unbox(read(old($Heap), this, _module.TwoStacks.s2)): Seq) - 1), 
          LitInt(0));
        $Heap := update($Heap, this, _module.TwoStacks.s2, $Box($rhs#1_0));
        assume $IsGoodHeap($Heap);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(110,23)
        assume true;
        assume true;
        assert {:id "id391"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assert {:id "id392"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assume true;
        assert {:id "id393"} 0
             <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        assume true;
        PopedItem#0 := read($Heap, 
          $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
          IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int));
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(111,16)
        assume true;
        assume true;
        assert {:id "id395"} $_ModifiesFrame[this, _module.TwoStacks.n2];
        assume true;
        assert {:id "id396"} $Is($Unbox(read($Heap, this, _module.TwoStacks.n2)): int - 1, Tclass._System.nat());
        assume true;
        $rhs#1_1 := $Unbox(read($Heap, this, _module.TwoStacks.n2)): int - 1;
        $Heap := update($Heap, this, _module.TwoStacks.n2, $Box($rhs#1_1));
        assume $IsGoodHeap($Heap);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(112,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(true);
    }
}



procedure {:verboseName "TwoStacks.peek1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.peek1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    TopItem#0: Box
       where $IsBox(TopItem#0, _module.TwoStacks$T)
         && $IsAllocBox(TopItem#0, _module.TwoStacks$T, $Heap));
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.peek1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.peek1(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, TopItem#0: Box)
{
  var $_ModifiesFrame: [ref,Field]bool;


    // AddMethodImpl: peek1, CheckWellFormed$$_module.TwoStacks.peek1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id400"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]);
    assume $HeapSucc(old($Heap), $Heap);
    havoc EmptyStatus#0, TopItem#0;
    if (*)
    {
        // assume allocatedness for receiver argument to function
        assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
        assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
        assert {:id "id401"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
        assert {:id "id402"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
              read($Heap, this, _module.TwoStacks.data));
        assert {:id "id403"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               == _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id404"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0)
               <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assert {:id "id405"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id406"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assert {:id "id407"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id408"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assert {:id "id409"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id410"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
               ==> (forall i#0: int :: 
                { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
                  { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
                LitInt(0) <= i#0
                     && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
                     == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))));
        assert {:id "id411"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
               ==> (forall i#1: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
                LitInt(0) <= i#1
                     && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
                     == read($Heap, 
                      $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                      IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - 1
                           - i#1))));
        assert {:id "id412"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assert {:id "id413"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assume _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
        assume _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id414"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this);
        assume {:id "id415"} EmptyStatus#0 == Lit(false);
    }
    else
    {
        assume _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id416"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
           ==> EmptyStatus#0 == Lit(false);
    }

    if (*)
    {
        // assume allocatedness for receiver argument to function
        assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
        assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
        assert {:id "id417"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
        assert {:id "id418"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
              read($Heap, this, _module.TwoStacks.data));
        assert {:id "id419"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               == _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id420"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0)
               <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assert {:id "id421"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id422"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assert {:id "id423"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id424"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assert {:id "id425"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id426"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
               ==> (forall i#2: int :: 
                { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
                  { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
                LitInt(0) <= i#2
                     && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
                     == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))));
        assert {:id "id427"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
               ==> (forall i#3: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
                LitInt(0) <= i#3
                     && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
                     == read($Heap, 
                      $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                      IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - 1
                           - i#3))));
        assert {:id "id428"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assert {:id "id429"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assume _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
        assume _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id430"} !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this);
        assume {:id "id431"} EmptyStatus#0 == Lit(true);
        assume true;
        assume true;
        assert {:id "id432"} 0 <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1
             < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assume {:id "id433"} TopItem#0
           == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
            Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1);
    }
    else
    {
        assume _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id434"} !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
           ==> EmptyStatus#0 == Lit(true)
             && TopItem#0
               == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
                Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1);
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id435"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
}



procedure {:verboseName "TwoStacks.peek1 (call)"} Call$$_module.TwoStacks.peek1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    TopItem#0: Box
       where $IsBox(TopItem#0, _module.TwoStacks$T)
         && $IsAllocBox(TopItem#0, _module.TwoStacks$T, $Heap));
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id436"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id437"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id438"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id439"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id440"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id441"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id442"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id443"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id444"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id445"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#4: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4) } 
          LitInt(0) <= i#4
               && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4))));
  requires {:id "id446"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#5: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
          LitInt(0) <= i#5
               && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#5))));
  requires {:id "id447"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id448"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id449"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id450"} !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id451"} !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
     ==> TopItem#0
       == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
        Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id452"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#6: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6) } 
        LitInt(0) <= i#6
             && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#7: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7) } 
        LitInt(0) <= i#7
             && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#7))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.peek1 (correctness)"} Impl$$_module.TwoStacks.peek1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    TopItem#0: Box
       where $IsBox(TopItem#0, _module.TwoStacks$T)
         && $IsAllocBox(TopItem#0, _module.TwoStacks$T, $Heap), 
    $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id453"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#8: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#8)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#8) } 
        LitInt(0) <= i#8
             && i#8 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#8)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#8))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#9: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#9) } 
        LitInt(0) <= i#9
             && i#9 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#9)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#9))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id454"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id455"} !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id456"} !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
     ==> TopItem#0
       == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, 
        Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id457"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id458"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id459"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id460"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id461"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id462"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id463"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id464"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id465"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id466"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#10: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10) } 
          LitInt(0) <= i#10
               && i#10 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10))));
  ensures {:id "id467"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#11: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11) } 
          LitInt(0) <= i#11
               && i#11 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#11))));
  ensures {:id "id468"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id469"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.peek1 (correctness)"} Impl$$_module.TwoStacks.peek1(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, TopItem#0: Box, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;

    // AddMethodImpl: peek1, Impl$$_module.TwoStacks.peek1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    $_reverifyPost := false;
    // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(122,9)
    assume true;
    assume true;
    if ($Unbox(read($Heap, this, _module.TwoStacks.n1)): int == LitInt(0))
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(123,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(false);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(124,21)
        assume true;
        havoc TopItem#0;
    }
    else
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(126,21)
        assume true;
        assume true;
        assert {:id "id471"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assert {:id "id472"} 0 <= $Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        assume true;
        TopItem#0 := read($Heap, 
          $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
          IndexField($Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1));
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(127,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(true);
    }
}



procedure {:verboseName "TwoStacks.peek2 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.peek2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    TopItem#0: Box
       where $IsBox(TopItem#0, _module.TwoStacks$T)
         && $IsAllocBox(TopItem#0, _module.TwoStacks$T, $Heap));
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.peek2 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.peek2(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, TopItem#0: Box)
{
  var $_ModifiesFrame: [ref,Field]bool;


    // AddMethodImpl: peek2, CheckWellFormed$$_module.TwoStacks.peek2
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id475"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]);
    assume $HeapSucc(old($Heap), $Heap);
    havoc EmptyStatus#0, TopItem#0;
    if (*)
    {
        // assume allocatedness for receiver argument to function
        assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
        assume _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id476"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this);
        assume {:id "id477"} EmptyStatus#0 == Lit(false);
    }
    else
    {
        assume _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id478"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
           ==> EmptyStatus#0 == Lit(false);
    }

    if (*)
    {
        // assume allocatedness for receiver argument to function
        assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
        assume _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id479"} !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this);
        assume {:id "id480"} EmptyStatus#0 == Lit(true);
        assume true;
        assume true;
        assert {:id "id481"} 0 <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1
             < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assume {:id "id482"} TopItem#0
           == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
            Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1);
    }
    else
    {
        assume _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id483"} !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
           ==> EmptyStatus#0 == Lit(true)
             && TopItem#0
               == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
                Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1);
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id484"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
}



procedure {:verboseName "TwoStacks.peek2 (call)"} Call$$_module.TwoStacks.peek2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    TopItem#0: Box
       where $IsBox(TopItem#0, _module.TwoStacks$T)
         && $IsAllocBox(TopItem#0, _module.TwoStacks$T, $Heap));
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id485"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id486"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id487"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id488"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id489"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id490"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id491"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id492"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id493"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id494"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#0: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
          LitInt(0) <= i#0
               && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))));
  requires {:id "id495"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#1: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
          LitInt(0) <= i#1
               && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#1))));
  requires {:id "id496"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id497"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id498"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id499"} !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id500"} !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
     ==> TopItem#0
       == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
        Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id501"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#2: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
        LitInt(0) <= i#2
             && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#3: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
        LitInt(0) <= i#3
             && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#3))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.peek2 (correctness)"} Impl$$_module.TwoStacks.peek2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap))
   returns (EmptyStatus#0: bool, 
    TopItem#0: Box
       where $IsBox(TopItem#0, _module.TwoStacks$T)
         && $IsAllocBox(TopItem#0, _module.TwoStacks$T, $Heap), 
    $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id502"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#4: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4) } 
        LitInt(0) <= i#4
             && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#5: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
        LitInt(0) <= i#5
             && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#5))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id503"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(false);
  free ensures {:always_assume} _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id504"} !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
     ==> EmptyStatus#0 == Lit(true);
  ensures {:id "id505"} !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
     ==> TopItem#0
       == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
        Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id506"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id507"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id508"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id509"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id510"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id511"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id512"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id513"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id514"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id515"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#6: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6) } 
          LitInt(0) <= i#6
               && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6))));
  ensures {:id "id516"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#7: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7) } 
          LitInt(0) <= i#7
               && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#7))));
  ensures {:id "id517"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id518"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.peek2 (correctness)"} Impl$$_module.TwoStacks.peek2(_module.TwoStacks$T: Ty, this: ref)
   returns (EmptyStatus#0: bool, TopItem#0: Box, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;

    // AddMethodImpl: peek2, Impl$$_module.TwoStacks.peek2
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    $_reverifyPost := false;
    // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(137,9)
    assume true;
    assume true;
    if ($Unbox(read($Heap, this, _module.TwoStacks.n2)): int == LitInt(0))
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(138,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(false);
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(139,21)
        assume true;
        havoc TopItem#0;
    }
    else
    {
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(141,21)
        assume true;
        assume true;
        assert {:id "id520"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assert {:id "id521"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assume true;
        assert {:id "id522"} 0
             <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        assume true;
        TopItem#0 := read($Heap, 
          $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
          IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int));
        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(142,25)
        assume true;
        assume true;
        EmptyStatus#0 := Lit(true);
    }
}



// function declaration for _module.TwoStacks.Empty1
function _module.TwoStacks.Empty1(_module.TwoStacks$T: Ty, $heap: Heap, this: ref) : bool;

function _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T: Ty, $heap: Heap, this: ref) : bool;

// frame axiom for _module.TwoStacks.Empty1
axiom (forall _module.TwoStacks$T: Ty, $h0: Heap, $h1: Heap, this: ref :: 
  { $IsHeapAnchor($h0), $HeapSucc($h0, $h1), _module.TwoStacks.Empty1(_module.TwoStacks$T, $h1, this) } 
  $IsGoodHeap($h0)
       && $IsGoodHeap($h1)
       && 
      this != null
       && $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
       && 
      $IsHeapAnchor($h0)
       && $HeapSucc($h0, $h1)
     ==> 
    (forall $o: ref, $f: Field :: 
      $o != null
           && ($o == this
             || Set#IsMember($Unbox(read($h0, this, _module.TwoStacks.Repr)): Set, $Box($o)))
         ==> read($h0, $o, $f) == read($h1, $o, $f))
     ==> _module.TwoStacks.Empty1(_module.TwoStacks$T, $h0, this)
         == _module.TwoStacks.Empty1(_module.TwoStacks$T, $h1, this)
       && _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $h0, this)
         == _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $h1, this));

// consequence axiom for _module.TwoStacks.Empty1
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this) } 
  _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this)
       && (_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
         ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) == LitInt(0))
       && _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
       && _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this));

function _module.TwoStacks.Empty1#requires(Ty, Heap, ref) : bool;

// #requires axiom for _module.TwoStacks.Empty1
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty1#requires(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  $IsGoodHeap($Heap)
       && 
      this != null
       && 
      $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
       && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap)
     ==> _module.TwoStacks.Empty1#requires(_module.TwoStacks$T, $Heap, this)
       == _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this));

// #requires ==> #canCall for _module.TwoStacks.Empty1
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty1#requires(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  _module.TwoStacks.Empty1#requires(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this));

// definition axiom for _module.TwoStacks.Empty1 (revealed)
axiom {:id "id525"} (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
       == (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) == LitInt(0)
         && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int == LitInt(0)));

procedure {:verboseName "TwoStacks.Empty1 (well-formedness)"} CheckWellformed$$_module.TwoStacks.Empty1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap));
  modifies $Heap;
  free ensures {:always_assume} this == this
     || _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id526"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
     ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) == LitInt(0);
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id527"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id528"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id529"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id530"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id531"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id532"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id533"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id534"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id535"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id536"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#0: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0) } 
          LitInt(0) <= i#0
               && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#0))));
  ensures {:id "id537"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#1: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
          LitInt(0) <= i#1
               && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#1))));
  ensures {:id "id538"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id539"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.Empty1 (well-formedness)"} CheckWellformed$$_module.TwoStacks.Empty1(_module.TwoStacks$T: Ty, this: ref)
{
  var $_ReadsFrame: [ref,Field]bool;
  var b$reqreads#0: bool;
  var b$reqreads#1: bool;
  var b$reqreads#2: bool;
  var b$reqreads#3: bool;

    b$reqreads#0 := true;
    b$reqreads#1 := true;
    b$reqreads#2 := true;
    b$reqreads#3 := true;

    $_ReadsFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool
         ==> $o == this
           || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)));
    // Check well-formedness of preconditions, and then assume them
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume true;
    assume true;
    b$reqreads#0 := (forall $o: ref, $f: Field :: 
      $o != null
           && $Unbox(read($Heap, $o, alloc)): bool
           && ($o == this
             || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box($o)))
         ==> $_ReadsFrame[$o, $f]);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id540"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    assert {:id "id541"} b$reqreads#0;
    // Check well-formedness of the reads clause
    b$reqreads#1 := $_ReadsFrame[this, _module.TwoStacks.Repr];
    assume true;
    assert {:id "id542"} b$reqreads#1;
    // Check well-formedness of the decreases clause
    assume true;
    // Check body and ensures clauses
    if (*)
    {
        // Check well-formedness of postcondition and assume false
        if (*)
        {
            // assume allocatedness for receiver argument to function
            assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
            assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
            assert {:id "id543"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
            assert {:id "id544"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                  read($Heap, this, _module.TwoStacks.data));
            assert {:id "id545"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   == _module.TwoStacks.N(_module.TwoStacks$T, this);
            assert {:id "id546"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || LitInt(0)
                   <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                     + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
            assert {:id "id547"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                     + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   <= _module.TwoStacks.N(_module.TwoStacks$T, this);
            assert {:id "id548"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
            assert {:id "id549"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                   <= _module.TwoStacks.N(_module.TwoStacks$T, this);
            assert {:id "id550"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
            assert {:id "id551"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   <= _module.TwoStacks.N(_module.TwoStacks$T, this);
            assert {:id "id552"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
                   ==> (forall i#2: int :: 
                    { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
                      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
                    LitInt(0) <= i#2
                         && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                       ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
                         == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))));
            assert {:id "id553"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
                   ==> (forall i#3: int :: 
                    { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
                    LitInt(0) <= i#3
                         && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                       ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
                         == read($Heap, 
                          $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                          IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                               - 1
                               - i#3))));
            assert {:id "id554"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
                   == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
            assert {:id "id555"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
               ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                 || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                   == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
            assume _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
            assume true;
            assert {:id "id556"} this == this
               || (Set#Subset(Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this))), 
                  Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this))))
                 && !Set#Subset(Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this))), 
                  Set#Union($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                    Set#UnionOne(Set#Empty(): Set, $Box(this)))));
            assume this == this
               || _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id557"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this);
            assume true;
            assume {:id "id558"} Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) == LitInt(0);
        }
        else
        {
            assume _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id559"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
               ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) == LitInt(0);
        }

        // assume allocatedness for receiver argument to function
        assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
        assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id560"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
        assume false;
    }
    else
    {
        // Check well-formedness of body and result subset type constraint
        b$reqreads#2 := $_ReadsFrame[this, _module.TwoStacks.s1];
        assume true;
        if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) == LitInt(0))
        {
            b$reqreads#3 := $_ReadsFrame[this, _module.TwoStacks.n1];
            assume true;
        }

        assume true;
        assume {:id "id561"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this)
           == (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) == LitInt(0)
             && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int == LitInt(0));
        // CheckWellformedWithResult: any expression
        assume $Is(_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this), TBool);
        assert {:id "id562"} b$reqreads#2;
        assert {:id "id563"} b$reqreads#3;
        return;

        assume false;
    }
}



// function declaration for _module.TwoStacks.Empty2
function _module.TwoStacks.Empty2(_module.TwoStacks$T: Ty, $heap: Heap, this: ref) : bool;

function _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T: Ty, $heap: Heap, this: ref) : bool;

// frame axiom for _module.TwoStacks.Empty2
axiom (forall _module.TwoStacks$T: Ty, $h0: Heap, $h1: Heap, this: ref :: 
  { $IsHeapAnchor($h0), $HeapSucc($h0, $h1), _module.TwoStacks.Empty2(_module.TwoStacks$T, $h1, this) } 
  $IsGoodHeap($h0)
       && $IsGoodHeap($h1)
       && 
      this != null
       && $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
       && 
      $IsHeapAnchor($h0)
       && $HeapSucc($h0, $h1)
     ==> 
    (forall $o: ref, $f: Field :: 
      $o != null && $o == this ==> read($h0, $o, $f) == read($h1, $o, $f))
     ==> _module.TwoStacks.Empty2(_module.TwoStacks$T, $h0, this)
         == _module.TwoStacks.Empty2(_module.TwoStacks$T, $h1, this)
       && _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $h0, this)
         == _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $h1, this));

// consequence axiom for _module.TwoStacks.Empty2
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this) } 
  _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this)
       && (_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
         ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) == LitInt(0)));

function _module.TwoStacks.Empty2#requires(Ty, Heap, ref) : bool;

// #requires axiom for _module.TwoStacks.Empty2
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty2#requires(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  $IsGoodHeap($Heap)
       && 
      this != null
       && 
      $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
       && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap)
     ==> _module.TwoStacks.Empty2#requires(_module.TwoStacks$T, $Heap, this) == true);

// #requires ==> #canCall for _module.TwoStacks.Empty2
axiom (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty2#requires(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  _module.TwoStacks.Empty2#requires(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this));

// definition axiom for _module.TwoStacks.Empty2 (revealed)
axiom {:id "id564"} (forall _module.TwoStacks$T: Ty, $Heap: Heap, this: ref :: 
  { _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this), $IsGoodHeap($Heap) } 
  _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
       == (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) == LitInt(0)
         && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int == LitInt(0)));

procedure {:verboseName "TwoStacks.Empty2 (well-formedness)"} CheckWellformed$$_module.TwoStacks.Empty2(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap));
  modifies $Heap;
  free ensures {:always_assume} this == this
     || _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id565"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
     ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) == LitInt(0);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.Empty2 (well-formedness)"} CheckWellformed$$_module.TwoStacks.Empty2(_module.TwoStacks$T: Ty, this: ref)
{
  var $_ReadsFrame: [ref,Field]bool;
  var b$reqreads#0: bool;
  var b$reqreads#1: bool;

    b$reqreads#0 := true;
    b$reqreads#1 := true;

    $_ReadsFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> $o == this);
    // Check well-formedness of preconditions, and then assume them
    // Check well-formedness of the reads clause
    // Check well-formedness of the decreases clause
    // Check body and ensures clauses
    if (*)
    {
        // Check well-formedness of postcondition and assume false
        if (*)
        {
            // assume allocatedness for receiver argument to function
            assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
            assume true;
            assert {:id "id566"} this == this
               || (Set#Subset(Set#UnionOne(Set#Empty(): Set, $Box(this)), 
                  Set#UnionOne(Set#Empty(): Set, $Box(this)))
                 && !Set#Subset(Set#UnionOne(Set#Empty(): Set, $Box(this)), 
                  Set#UnionOne(Set#Empty(): Set, $Box(this))));
            assume this == this
               || _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id567"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this);
            assume true;
            assume {:id "id568"} Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) == LitInt(0);
        }
        else
        {
            assume _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id569"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
               ==> Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) == LitInt(0);
        }

        assume false;
    }
    else
    {
        // Check well-formedness of body and result subset type constraint
        b$reqreads#0 := $_ReadsFrame[this, _module.TwoStacks.s2];
        assume true;
        if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) == LitInt(0))
        {
            b$reqreads#1 := $_ReadsFrame[this, _module.TwoStacks.n2];
            assume true;
        }

        assume true;
        assume {:id "id570"} _module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this)
           == (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) == LitInt(0)
             && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int == LitInt(0));
        // CheckWellformedWithResult: any expression
        assume $Is(_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this), TBool);
        assert {:id "id571"} b$reqreads#0;
        assert {:id "id572"} b$reqreads#1;
        return;

        assume false;
    }
}



procedure {:verboseName "TwoStacks.search1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.search1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    Element#0: Box
       where $IsBox(Element#0, _module.TwoStacks$T)
         && $IsAllocBox(Element#0, _module.TwoStacks$T, $Heap))
   returns (position#0: int);
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.search1 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.search1(_module.TwoStacks$T: Ty, this: ref, Element#0: Box) returns (position#0: int)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var i#0: int;
  var i#4: int;


    // AddMethodImpl: search1, CheckWellFormed$$_module.TwoStacks.search1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id573"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]);
    assume $HeapSucc(old($Heap), $Heap);
    havoc position#0;
    if (*)
    {
        assume {:id "id574"} position#0 == LitInt(-1);
    }
    else
    {
        assume true;
        assume {:id "id575"} position#0 != LitInt(-1);
        assume {:id "id576"} position#0 >= LitInt(1);
    }

    if (*)
    {
        assume {:id "id577"} position#0 >= LitInt(1);
        havoc i#0;
        assume true;
        if (LitInt(0) <= i#0)
        {
            assume true;
        }

        assume {:id "id578"} LitInt(0) <= i#0
           && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assume true;
        assert {:id "id579"} 0 <= i#0
           && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assume {:id "id580"} Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#0)
           == Element#0;
        // assume allocatedness for receiver argument to function
        assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
        assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
        assert {:id "id581"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
        assert {:id "id582"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
              read($Heap, this, _module.TwoStacks.data));
        assert {:id "id583"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               == _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id584"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0)
               <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assert {:id "id585"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id586"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assert {:id "id587"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id588"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assert {:id "id589"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               <= _module.TwoStacks.N(_module.TwoStacks$T, this);
        assert {:id "id590"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
               ==> (forall i#1: int :: 
                { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#1)) } 
                  { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#1) } 
                LitInt(0) <= i#1
                     && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#1)
                     == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#1))));
        assert {:id "id591"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
               ==> (forall i#2: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#2) } 
                LitInt(0) <= i#2
                     && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#2)
                     == read($Heap, 
                      $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                      IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - 1
                           - i#2))));
        assert {:id "id592"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
        assert {:id "id593"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
             || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assume _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
        assume _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id594"} !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this);
    }
    else
    {
        assume position#0 >= LitInt(1)
           ==> (forall i#3: int :: 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
            LitInt(0) <= i#3
                 && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               ==> 
              Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
                 == Element#0
               ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this));
        assume {:id "id595"} position#0 >= LitInt(1)
           ==> (exists i#3: int :: 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
            LitInt(0) <= i#3
               && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
                 == Element#0
               && !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this));
    }

    if (*)
    {
        assume {:id "id596"} position#0 == LitInt(-1);
        havoc i#4;
        assume true;
        if (*)
        {
            if (LitInt(0) <= i#4)
            {
                assume true;
            }

            assume {:id "id597"} LitInt(0) <= i#4
               && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
            if (*)
            {
                assume true;
                assert {:id "id598"} 0 <= i#4
                   && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
                assume {:id "id599"} Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
                   != Element#0;
            }
            else
            {
                assume true;
                assume {:id "id600"} Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
                   == Element#0;
                // assume allocatedness for receiver argument to function
                assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
                assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
                assert {:id "id601"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
                assert {:id "id602"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
                      read($Heap, this, _module.TwoStacks.data));
                assert {:id "id603"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       == _module.TwoStacks.N(_module.TwoStacks$T, this);
                assert {:id "id604"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || LitInt(0)
                       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                assert {:id "id605"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                       <= _module.TwoStacks.N(_module.TwoStacks$T, this);
                assert {:id "id606"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
                assert {:id "id607"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                       <= _module.TwoStacks.N(_module.TwoStacks$T, this);
                assert {:id "id608"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                assert {:id "id609"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                       <= _module.TwoStacks.N(_module.TwoStacks$T, this);
                assert {:id "id610"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
                       ==> (forall i#5: int :: 
                        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#5)) } 
                          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#5) } 
                        LitInt(0) <= i#5
                             && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#5)
                             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#5))));
                assert {:id "id611"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
                       ==> (forall i#6: int :: 
                        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#6) } 
                        LitInt(0) <= i#6
                             && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#6)
                             == read($Heap, 
                              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                                   - 1
                                   - i#6))));
                assert {:id "id612"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
                       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
                assert {:id "id613"} {:subsumption 0} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
                   ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
                     || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                assume _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
                assume _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
                assume {:id "id614"} _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this);
            }
        }
        else
        {
            assume LitInt(0) <= i#4
               ==> 
              i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               ==> 
              Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
                 == Element#0
               ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id615"} LitInt(0) <= i#4
                 && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
                   != Element#0
                 || _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this);
        }

        assume {:id "id616"} (forall i#7: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7) } 
          LitInt(0) <= i#7
               && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7)
                 != Element#0
               || _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this));
    }
    else
    {
        assume position#0 == LitInt(-1)
           ==> (forall i#7: int :: 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7) } 
            LitInt(0) <= i#7
                 && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               ==> 
              Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7)
                 == Element#0
               ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this));
        assume {:id "id617"} position#0 == LitInt(-1)
           ==> (forall i#7: int :: 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7) } 
            LitInt(0) <= i#7
                 && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7)
                   != Element#0
                 || _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this));
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id618"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
}



procedure {:verboseName "TwoStacks.search1 (call)"} Call$$_module.TwoStacks.search1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    Element#0: Box
       where $IsBox(Element#0, _module.TwoStacks$T)
         && $IsAllocBox(Element#0, _module.TwoStacks$T, $Heap))
   returns (position#0: int);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id619"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id620"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id621"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id622"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id623"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id624"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id625"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id626"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id627"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id628"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#8: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#8)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#8) } 
          LitInt(0) <= i#8
               && i#8 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#8)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#8))));
  requires {:id "id629"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#9: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#9) } 
          LitInt(0) <= i#9
               && i#9 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#9)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#9))));
  requires {:id "id630"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id631"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id632"} position#0 == LitInt(-1) || position#0 >= LitInt(1);
  free ensures {:always_assume} position#0 >= LitInt(1)
     ==> (forall i#3: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
      LitInt(0) <= i#3
           && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         ==> 
        Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
           == Element#0
         ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this));
  ensures {:id "id633"} position#0 >= LitInt(1)
     ==> (exists i#3: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
      LitInt(0) <= i#3
         && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
           == Element#0
         && !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this));
  free ensures {:always_assume} position#0 == LitInt(-1)
     ==> (forall i#7: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7) } 
      LitInt(0) <= i#7
           && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         ==> 
        Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7)
           == Element#0
         ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this));
  ensures {:id "id634"} position#0 == LitInt(-1)
     ==> (forall i#7: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7) } 
      LitInt(0) <= i#7
           && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7)
             != Element#0
           || _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this));
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id635"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#10: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10) } 
        LitInt(0) <= i#10
             && i#10 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#11: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11) } 
        LitInt(0) <= i#11
             && i#11 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#11))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.search1 (correctness)"} Impl$$_module.TwoStacks.search1(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    Element#0: Box
       where $IsBox(Element#0, _module.TwoStacks$T)
         && $IsAllocBox(Element#0, _module.TwoStacks$T, $Heap))
   returns (position#0: int, $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id636"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#12: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#12)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#12) } 
        LitInt(0) <= i#12
             && i#12 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#12)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#12))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#13: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#13) } 
        LitInt(0) <= i#13
             && i#13 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#13)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#13))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id637"} position#0 == LitInt(-1) || position#0 >= LitInt(1);
  free ensures {:always_assume} position#0 >= LitInt(1)
     ==> (forall i#3: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
      LitInt(0) <= i#3
           && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         ==> 
        Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
           == Element#0
         ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this));
  ensures {:id "id638"} position#0 >= LitInt(1)
     ==> (exists i#3: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3) } 
      LitInt(0) <= i#3
         && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#3)
           == Element#0
         && !_module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this));
  free ensures {:always_assume} position#0 == LitInt(-1)
     ==> (forall i#7: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7) } 
      LitInt(0) <= i#7
           && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         ==> 
        Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7)
           == Element#0
         ==> _module.TwoStacks.Empty1#canCall(_module.TwoStacks$T, $Heap, this));
  ensures {:id "id639"} position#0 == LitInt(-1)
     ==> (forall i#7: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7) } 
      LitInt(0) <= i#7
           && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#7)
             != Element#0
           || _module.TwoStacks.Empty1(_module.TwoStacks$T, $Heap, this));
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id640"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id641"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id642"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id643"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id644"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id645"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id646"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id647"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id648"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id649"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#14: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#14)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#14) } 
          LitInt(0) <= i#14
               && i#14 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#14)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#14))));
  ensures {:id "id650"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#15: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#15) } 
          LitInt(0) <= i#15
               && i#15 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#15)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#15))));
  ensures {:id "id651"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id652"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.search1 (correctness)"} Impl$$_module.TwoStacks.search1(_module.TwoStacks$T: Ty, this: ref, Element#0: Box)
   returns (position#0: int, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var n#0: int;
  var $PreLoopHeap$loop#0: Heap;
  var $decr_init$loop#00: int;
  var $w$loop#0: bool;
  var i#18: int;
  var i#20: int;
  var $decr$loop#00: int;

    // AddMethodImpl: search1, Impl$$_module.TwoStacks.search1
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    $_reverifyPost := false;
    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(169,15)
    assume true;
    assume true;
    n#0 := LitInt(0);
    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(170,18)
    assume true;
    assume true;
    position#0 := LitInt(0);
    // ----- while statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(172,9)
    // Assume Fuel Constant
    $PreLoopHeap$loop#0 := $Heap;
    $decr_init$loop#00 := Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - n#0;
    havoc $w$loop#0;
    assume $w$loop#0 ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume true;
    assume true;
    assume true;
    assume $w$loop#0 ==> true;
    while (true)
      free invariant $w$loop#0 ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
      invariant {:id "id656"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
      invariant {:id "id657"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data));
      invariant {:id "id658"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id659"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      invariant {:id "id660"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id661"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
      invariant {:id "id662"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id663"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      invariant {:id "id664"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id665"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
             ==> (forall i#16: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#16)) } 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#16) } 
              LitInt(0) <= i#16
                   && i#16 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#16)
                   == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#16))));
      invariant {:id "id666"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
             ==> (forall i#17: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#17) } 
              LitInt(0) <= i#17
                   && i#17 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#17)
                   == read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - 1
                         - i#17))));
      invariant {:id "id667"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
      invariant {:id "id668"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      free invariant {:id "id669"} $w$loop#0
         ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           && 
          _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           && 
          Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
             ==> (forall i#16: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#16)) } 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#16) } 
              LitInt(0) <= i#16
                   && i#16 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#16)
                   == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#16))))
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
             ==> (forall i#17: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#17) } 
              LitInt(0) <= i#17
                   && i#17 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#17)
                   == read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - 1
                         - i#17))))
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      free invariant true;
      invariant {:id "id671"} $w$loop#0 ==> LitInt(0) <= n#0;
      invariant {:id "id672"} $w$loop#0
         ==> n#0 <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
      free invariant true;
      invariant {:id "id675"} $w$loop#0
         ==> 
        position#0 >= LitInt(1)
         ==> (exists i#19: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#19) } 
          LitInt(0) <= i#19
             && i#19 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#19)
               == Element#0);
      free invariant true;
      invariant {:id "id678"} $w$loop#0
         ==> (forall i#21: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#21) } 
          Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1 - n#0
                 < i#21
               && i#21 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#21)
               != Element#0);
      free invariant (forall $o: ref :: 
        { $Heap[$o] } 
        $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
           ==> $Heap[$o] == $PreLoopHeap$loop#0[$o]);
      free invariant $HeapSucc($PreLoopHeap$loop#0, $Heap);
      free invariant (forall $o: ref, $f: Field :: 
        { read($Heap, $o, $f) } 
        $o != null && $Unbox(read($PreLoopHeap$loop#0, $o, alloc)): bool
           ==> read($Heap, $o, $f) == read($PreLoopHeap$loop#0, $o, $f)
             || $_ModifiesFrame[$o, $f]);
      free invariant Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - n#0
         <= $decr_init$loop#00;
    {
        if (!$w$loop#0)
        {
            // assume allocatedness for receiver argument to function
            assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
            assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
            assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id655"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
            if (LitInt(0) <= n#0)
            {
                assume true;
            }

            assume true;
            assume {:id "id670"} LitInt(0) <= n#0
               && n#0 <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
            if (position#0 >= LitInt(1))
            {
                // Begin Comprehension WF check
                havoc i#18;
                if (true)
                {
                    if (LitInt(0) <= i#18)
                    {
                        assume true;
                    }

                    if (LitInt(0) <= i#18
                       && i#18 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq))
                    {
                        assume true;
                        assert {:id "id673"} {:subsumption 0} 0 <= i#18
                           && i#18 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
                    }
                }

                // End Comprehension WF check
                assume true;
            }

            assume true;
            assume {:id "id674"} position#0 >= LitInt(1)
               ==> (exists i#19: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#19) } 
                LitInt(0) <= i#19
                   && i#19 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                   && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#19)
                     == Element#0);
            // Begin Comprehension WF check
            havoc i#20;
            if (true)
            {
                assume true;
                if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1 - n#0
                   < i#20)
                {
                    assume true;
                }

                if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1 - n#0
                     < i#20
                   && i#20 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq))
                {
                    assume true;
                    assert {:id "id676"} {:subsumption 0} 0 <= i#20
                       && i#20 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
                }
            }

            // End Comprehension WF check
            assume true;
            assume true;
            assume {:id "id677"} (forall i#21: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#21) } 
              Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - 1 - n#0
                     < i#21
                   && i#21 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#21)
                   != Element#0);
            assume true;
            assume true;
            assume false;
        }

        assume true;
        assume true;
        if (n#0 == $Unbox(read($Heap, this, _module.TwoStacks.n1)): int)
        {
            break;
        }

        assume true;
        $decr$loop#00 := Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - n#0;
        push;
        // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(179,13)
        assume true;
        assert {:id "id679"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assert {:id "id680"} 0 <= $Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1 - n#0
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1 - n#0
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        assume true;
        if (read($Heap, 
            $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
            IndexField($Unbox(read($Heap, this, _module.TwoStacks.n1)): int - 1 - n#0))
           == Element#0)
        {
            push;
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(181,26)
            assume true;
            assume true;
            position#0 := n#0 + 1;
            // ----- return statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(182,17)
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(182,17)
            assume true;
            assume true;
            position#0 := position#0;
            pop;
            pop;
            return;

            pop;
        }
        else
        {
        }

        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(184,15)
        assume true;
        assume true;
        n#0 := n#0 + 1;
        pop;
        assume true;
        // ----- loop termination check ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(172,9)
        assert {:id "id684"} 0 <= $decr$loop#00
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - n#0
             == $decr$loop#00;
        assert {:id "id685"} Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) - n#0
           < $decr$loop#00;
        assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    }

    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(186,18)
    assume true;
    assume true;
    position#0 := LitInt(-1);
}



procedure {:verboseName "TwoStacks.search3 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.search3(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    Element#0: Box
       where $IsBox(Element#0, _module.TwoStacks$T)
         && $IsAllocBox(Element#0, _module.TwoStacks$T, $Heap))
   returns (position#0: int);
  modifies $Heap;



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.search3 (well-formedness)"} CheckWellFormed$$_module.TwoStacks.search3(_module.TwoStacks$T: Ty, this: ref, Element#0: Box) returns (position#0: int)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var i#0: int;


    // AddMethodImpl: search3, CheckWellFormed$$_module.TwoStacks.search3
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id687"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
    havoc $Heap;
    assume (forall $o: ref :: 
      { $Heap[$o] } 
      $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
         ==> $Heap[$o] == old($Heap)[$o]);
    assume $HeapSucc(old($Heap), $Heap);
    havoc position#0;
    if (*)
    {
        assume {:id "id688"} position#0 == LitInt(-1);
    }
    else
    {
        assume true;
        assume {:id "id689"} position#0 != LitInt(-1);
        assume {:id "id690"} position#0 >= LitInt(1);
    }

    if (*)
    {
        assume {:id "id691"} position#0 >= LitInt(1);
        havoc i#0;
        assume true;
        if (LitInt(0) <= i#0)
        {
            assume true;
        }

        assume {:id "id692"} LitInt(0) <= i#0
           && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assume true;
        assert {:id "id693"} 0 <= i#0
           && i#0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        assume {:id "id694"} Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0)
           == Element#0;
        // assume allocatedness for receiver argument to function
        assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
        assume _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this);
        assume {:id "id695"} !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this);
    }
    else
    {
        assume position#0 >= LitInt(1)
           ==> (forall i#1: int :: 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
            LitInt(0) <= i#1
                 && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               ==> 
              Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
                 == Element#0
               ==> _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this));
        assume {:id "id696"} position#0 >= LitInt(1)
           ==> (exists i#1: int :: 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
            LitInt(0) <= i#1
               && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
               && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
                 == Element#0
               && !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this));
    }

    // assume allocatedness for receiver argument to function
    assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
    assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume {:id "id697"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
}



procedure {:verboseName "TwoStacks.search3 (call)"} Call$$_module.TwoStacks.search3(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    Element#0: Box
       where $IsBox(Element#0, _module.TwoStacks$T)
         && $IsAllocBox(Element#0, _module.TwoStacks$T, $Heap))
   returns (position#0: int);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  requires {:id "id698"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  requires {:id "id699"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  requires {:id "id700"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id701"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id702"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id703"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id704"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id705"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  requires {:id "id706"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  requires {:id "id707"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#2: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2) } 
          LitInt(0) <= i#2
               && i#2 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#2)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#2))));
  requires {:id "id708"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#3: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3) } 
          LitInt(0) <= i#3
               && i#3 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#3)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#3))));
  requires {:id "id709"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  requires {:id "id710"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id711"} position#0 == LitInt(-1) || position#0 >= LitInt(1);
  free ensures {:always_assume} position#0 >= LitInt(1)
     ==> (forall i#1: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
      LitInt(0) <= i#1
           && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         ==> 
        Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
           == Element#0
         ==> _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this));
  ensures {:id "id712"} position#0 >= LitInt(1)
     ==> (exists i#1: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
      LitInt(0) <= i#1
         && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
           == Element#0
         && !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this));
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free ensures {:id "id713"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#4: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4) } 
        LitInt(0) <= i#4
             && i#4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#4)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#4))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#5: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5) } 
        LitInt(0) <= i#5
             && i#5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#5)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#5))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



procedure {:verboseName "TwoStacks.search3 (correctness)"} Impl$$_module.TwoStacks.search3(_module.TwoStacks$T: Ty, 
    this: ref
       where this != null
         && 
        $Is(this, Tclass._module.TwoStacks(_module.TwoStacks$T))
         && $IsAlloc(this, Tclass._module.TwoStacks(_module.TwoStacks$T), $Heap), 
    Element#0: Box
       where $IsBox(Element#0, _module.TwoStacks$T)
         && $IsAllocBox(Element#0, _module.TwoStacks$T, $Heap))
   returns (position#0: int, $_reverifyPost: bool);
  // user-defined preconditions
  free requires {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  free requires {:id "id714"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     && 
    _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
     && 
    Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
     && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
      read($Heap, this, _module.TwoStacks.data))
     && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
       == _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0)
       <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && 
    LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
     && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
       <= _module.TwoStacks.N(_module.TwoStacks$T, this)
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
       ==> (forall i#6: int :: 
        { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6)) } 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6) } 
        LitInt(0) <= i#6
             && i#6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#6)
             == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#6))))
     && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
       ==> (forall i#7: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7) } 
        LitInt(0) <= i#7
             && i#7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#7)
             == read($Heap, 
              $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
              IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - 1
                   - i#7))))
     && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
     && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
       == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  modifies $Heap;
  // user-defined postconditions
  free ensures {:always_assume} true;
  ensures {:id "id715"} position#0 == LitInt(-1) || position#0 >= LitInt(1);
  free ensures {:always_assume} position#0 >= LitInt(1)
     ==> (forall i#1: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
      LitInt(0) <= i#1
           && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         ==> 
        Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
           == Element#0
         ==> _module.TwoStacks.Empty2#canCall(_module.TwoStacks$T, $Heap, this));
  ensures {:id "id716"} position#0 >= LitInt(1)
     ==> (exists i#1: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1) } 
      LitInt(0) <= i#1
         && i#1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#1)
           == Element#0
         && !_module.TwoStacks.Empty2(_module.TwoStacks$T, $Heap, this));
  free ensures {:always_assume} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
  ensures {:id "id717"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
  ensures {:id "id718"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
        read($Heap, this, _module.TwoStacks.data));
  ensures {:id "id719"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
         == _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id720"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0)
         <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id721"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id722"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id723"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id724"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  ensures {:id "id725"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         <= _module.TwoStacks.N(_module.TwoStacks$T, this);
  ensures {:id "id726"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
         ==> (forall i#8: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#8)) } 
            { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#8) } 
          LitInt(0) <= i#8
               && i#8 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#8)
               == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#8))));
  ensures {:id "id727"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
         ==> (forall i#9: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#9) } 
          LitInt(0) <= i#9
               && i#9 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#9)
               == read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - 1
                     - i#9))));
  ensures {:id "id728"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
  ensures {:id "id729"} _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
     ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
       || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
         == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
  // frame condition: object granularity
  free ensures (forall $o: ref :: 
    { $Heap[$o] } 
    $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
       ==> $Heap[$o] == old($Heap)[$o]);
  // boilerplate
  free ensures $HeapSucc(old($Heap), $Heap);



implementation {:smt_option "smt.arith.solver", "2"} {:verboseName "TwoStacks.search3 (correctness)"} Impl$$_module.TwoStacks.search3(_module.TwoStacks$T: Ty, this: ref, Element#0: Box)
   returns (position#0: int, $_reverifyPost: bool)
{
  var $_ModifiesFrame: [ref,Field]bool;
  var n#0: int;
  var $PreLoopHeap$loop#0: Heap;
  var $decr_init$loop#00: int;
  var $w$loop#0: bool;
  var i#12: int;
  var i#14: int;
  var i#16: int;
  var $decr$loop#00: int;
  var i#0_0_0: int;
  var i#0_0_2: int;
  var i#0_0_4: int;
  var i#0_0_6: int;
  var i#0_0_8: int;
  var i#18: int;
  var i#20: int;
  var i#22: int;
  var i#24: int;
  var i#26: int;

    // AddMethodImpl: search3, Impl$$_module.TwoStacks.search3
    $_ModifiesFrame := (lambda $o: ref, $f: Field :: 
      $o != null && $Unbox(read($Heap, $o, alloc)): bool ==> false);
    $_reverifyPost := false;
    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(196,18)
    assume true;
    assume true;
    position#0 := LitInt(0);
    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(197,15)
    assume true;
    assume true;
    n#0 := LitInt(0);
    // ----- while statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(199,9)
    // Assume Fuel Constant
    $PreLoopHeap$loop#0 := $Heap;
    $decr_init$loop#00 := Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - n#0;
    havoc $w$loop#0;
    assume true;
    assume $w$loop#0 ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    assume true;
    assume true;
    assume true;
    assume $w$loop#0 ==> true;
    while (true)
      free invariant true;
      invariant {:id "id733"} $w$loop#0 ==> LitInt(0) <= n#0;
      invariant {:id "id734"} $w$loop#0
         ==> n#0 <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      free invariant $w$loop#0 ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
      invariant {:id "id736"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this));
      invariant {:id "id737"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data));
      invariant {:id "id738"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id739"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      invariant {:id "id740"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id741"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
      invariant {:id "id742"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id743"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      invariant {:id "id744"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this);
      invariant {:id "id745"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
             ==> (forall i#10: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10)) } 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10) } 
              LitInt(0) <= i#10
                   && i#10 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10)
                   == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10))));
      invariant {:id "id746"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
             ==> (forall i#11: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11) } 
              LitInt(0) <= i#11
                   && i#11 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11)
                   == read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - 1
                         - i#11))));
      invariant {:id "id747"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq);
      invariant {:id "id748"} $w$loop#0
         ==> 
        _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
         ==> _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           || $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      free invariant {:id "id749"} $w$loop#0
         ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this)
           && 
          _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this)
           && 
          Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, $Box(this))
           && Set#IsMember($Unbox(read($Heap, this, _module.TwoStacks.Repr)): Set, 
            read($Heap, this, _module.TwoStacks.data))
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             == _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0)
             <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
               + Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && 
          LitInt(0) <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             <= _module.TwoStacks.N(_module.TwoStacks$T, this)
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq) != 0
             ==> (forall i#10: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10)) } 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10) } 
              LitInt(0) <= i#10
                   && i#10 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq, i#10)
                   == read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#10))))
           && (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) != 0
             ==> (forall i#11: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11) } 
              LitInt(0) <= i#11
                   && i#11 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#11)
                   == read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - 1
                         - i#11))))
           && $Unbox(read($Heap, this, _module.TwoStacks.n1)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s1)): Seq)
           && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             == Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
      free invariant true;
      invariant {:id "id752"} $w$loop#0
         ==> 
        position#0 >= LitInt(1)
         ==> (exists i#13: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#13) } 
          LitInt(0) <= i#13
             && i#13 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#13)
               == Element#0);
      free invariant true;
      invariant {:id "id755"} $w$loop#0
         ==> (forall i#15: int :: 
          { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#15) } 
          Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
                 < i#15
               && i#15 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1
             ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#15)
               != Element#0);
      free invariant true;
      invariant {:id "id761"} $w$loop#0
         ==> (forall i#17: int :: 
          { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#17)) } 
          _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                 < i#17
               && i#17
                 < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                   + n#0
             ==> read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#17))
               != Element#0);
      free invariant (forall $o: ref :: 
        { $Heap[$o] } 
        $o != null && $Unbox(read(old($Heap), $o, alloc)): bool
           ==> $Heap[$o] == $PreLoopHeap$loop#0[$o]);
      free invariant $HeapSucc($PreLoopHeap$loop#0, $Heap);
      free invariant (forall $o: ref, $f: Field :: 
        { read($Heap, $o, $f) } 
        $o != null && $Unbox(read($PreLoopHeap$loop#0, $o, alloc)): bool
           ==> read($Heap, $o, $f) == read($PreLoopHeap$loop#0, $o, $f)
             || $_ModifiesFrame[$o, $f]);
      free invariant Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - n#0
         <= $decr_init$loop#00;
    {
        if (!$w$loop#0)
        {
            if (LitInt(0) <= n#0)
            {
                assume true;
            }

            assume true;
            assume {:id "id732"} LitInt(0) <= n#0
               && n#0 <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
            // assume allocatedness for receiver argument to function
            assume $IsAllocBox($Box(this), Tclass._module.TwoStacks?(_module.TwoStacks$T), $Heap);
            assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
            assume _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
            assume {:id "id735"} _module.TwoStacks.Valid(_module.TwoStacks$T, $Heap, this);
            if (position#0 >= LitInt(1))
            {
                // Begin Comprehension WF check
                havoc i#12;
                if (true)
                {
                    if (LitInt(0) <= i#12)
                    {
                        assume true;
                    }

                    if (LitInt(0) <= i#12
                       && i#12 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
                    {
                        assume true;
                        assert {:id "id750"} {:subsumption 0} 0 <= i#12
                           && i#12 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                    }
                }

                // End Comprehension WF check
                assume true;
            }

            assume true;
            assume {:id "id751"} position#0 >= LitInt(1)
               ==> (exists i#13: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#13) } 
                LitInt(0) <= i#13
                   && i#13 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#13)
                     == Element#0);
            // Begin Comprehension WF check
            havoc i#14;
            if (true)
            {
                assume true;
                if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
                   < i#14)
                {
                    assume true;
                }

                if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
                     < i#14
                   && i#14 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1)
                {
                    assume true;
                    assert {:id "id753"} {:subsumption 0} 0 <= i#14
                       && i#14 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                }
            }

            // End Comprehension WF check
            assume true;
            assume true;
            assume {:id "id754"} (forall i#15: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#15) } 
              Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
                     < i#15
                   && i#15 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#15)
                   != Element#0);
            // Begin Comprehension WF check
            havoc i#16;
            if (true)
            {
                assume true;
                assert {:id "id756"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                assume true;
                assume true;
                if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                   < i#16)
                {
                    assume true;
                    assert {:id "id757"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assume true;
                    assume true;
                }

                if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                     < i#16
                   && i#16
                     < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                       + n#0)
                {
                    assume true;
                    assert {:id "id758"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assert {:id "id759"} {:subsumption 0} 0 <= i#16
                       && i#16
                         < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
                }
            }

            // End Comprehension WF check
            assume true;
            assume true;
            assume {:id "id760"} (forall i#17: int :: 
              { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#17)) } 
              _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                     < i#17
                   && i#17
                     < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                       + n#0
                 ==> read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#17))
                   != Element#0);
            assume true;
            assume true;
            assume false;
        }

        assume true;
        assume true;
        if (n#0 == $Unbox(read($Heap, this, _module.TwoStacks.n2)): int)
        {
            break;
        }

        assume true;
        $decr$loop#00 := Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - n#0;
        push;
        // ----- if statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(207,13)
        assume true;
        assert {:id "id762"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assert {:id "id763"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assume true;
        assert {:id "id764"} 0
             <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                 - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               + n#0
           && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                 - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               + n#0
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        assume true;
        if (read($Heap, 
            $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
            IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                 + n#0))
           == Element#0)
        {
            push;
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(209,26)
            assume true;
            assume true;
            position#0 := n#0 + 1;
            // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(211,17)
            assume true;
            assert {:id "id766"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assert {:id "id767"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assume true;
            assert {:id "id768"} {:subsumption 0} 0
                 <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                   + n#0
               && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                   + n#0
                 < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
            assume true;
            assume true;
            assert {:id "id769"} {:subsumption 0} 0 <= $Unbox(read($Heap, this, _module.TwoStacks.n2)): int - 1 - n#0
               && $Unbox(read($Heap, this, _module.TwoStacks.n2)): int - 1 - n#0
                 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
            assume true;
            assert {:id "id770"} read($Heap, 
                $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                     + n#0))
               == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
                $Unbox(read($Heap, this, _module.TwoStacks.n2)): int - 1 - n#0);
            // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(212,17)
            if (position#0 >= LitInt(1))
            {
                // Begin Comprehension WF check
                havoc i#0_0_0;
                if (true)
                {
                    if (LitInt(0) <= i#0_0_0)
                    {
                        assume true;
                    }

                    if (LitInt(0) <= i#0_0_0
                       && i#0_0_0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
                    {
                        assume true;
                        assert {:id "id771"} {:subsumption 0} 0 <= i#0_0_0
                           && i#0_0_0 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                    }
                }

                // End Comprehension WF check
                assume true;
            }

            assume true;
            assert {:id "id772"} {:subsumption 0} position#0 >= LitInt(1)
               ==> (exists i#0_0_1: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_1) } 
                LitInt(0) <= i#0_0_1
                   && i#0_0_1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_1)
                     == Element#0);
            assume {:id "id773"} position#0 >= LitInt(1)
               ==> (exists i#0_0_1: int :: 
                { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_1) } 
                LitInt(0) <= i#0_0_1
                   && i#0_0_1 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_1)
                     == Element#0);
            // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(213,17)
            // Begin Comprehension WF check
            havoc i#0_0_2;
            if (true)
            {
                assume true;
                assert {:id "id774"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                assume true;
                assume true;
                if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                   < i#0_0_2)
                {
                    assume true;
                    assert {:id "id775"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assume true;
                }

                if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                     < i#0_0_2
                   && i#0_0_2
                     < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref) - 1)
                {
                    assume true;
                    assert {:id "id776"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assert {:id "id777"} {:subsumption 0} 0 <= i#0_0_2
                       && i#0_0_2
                         < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
                    assume true;
                    assume true;
                    assert {:id "id778"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assume true;
                    assert {:id "id779"} {:subsumption 0} 0
                         <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - i#0_0_2
                           - 1
                       && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - i#0_0_2
                           - 1
                         < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                }
            }

            // End Comprehension WF check
            assume true;
            assume true;
            assert {:id "id780"} (forall i#0_0_3: int :: 
              { read($Heap, 
                  $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                  IndexField(i#0_0_3)) } 
              _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                     < i#0_0_3
                   && i#0_0_3
                     < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref) - 1
                 ==> read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(i#0_0_3))
                   == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
                    _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - i#0_0_3
                       - 1));
            // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(214,17)
            // Begin Comprehension WF check
            havoc i#0_0_4;
            if (true)
            {
                if (LitInt(0) <= i#0_0_4)
                {
                    assume true;
                }

                if (LitInt(0) <= i#0_0_4
                   && i#0_0_4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
                {
                    assume true;
                    assert {:id "id781"} {:subsumption 0} 0 <= i#0_0_4
                       && i#0_0_4 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                    assume true;
                    assert {:id "id782"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assume true;
                    assert {:id "id783"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assume true;
                    assert {:id "id784"} {:subsumption 0} 0
                         <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - i#0_0_4
                           - 1
                       && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                           - i#0_0_4
                           - 1
                         < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
                }
            }

            // End Comprehension WF check
            assume true;
            assume true;
            assert {:id "id785"} (forall i#0_0_5: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_5) } 
              LitInt(0) <= i#0_0_5
                   && i#0_0_5 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_5)
                   == read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - i#0_0_5
                         - 1)));
            // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(215,17)
            // Begin Comprehension WF check
            havoc i#0_0_6;
            if (true)
            {
                assume true;
                if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
                   < i#0_0_6)
                {
                    assume true;
                }

                if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
                     < i#0_0_6
                   && i#0_0_6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1)
                {
                    assume true;
                    assert {:id "id786"} {:subsumption 0} 0 <= i#0_0_6
                       && i#0_0_6 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
                }
            }

            // End Comprehension WF check
            assume true;
            assume true;
            assert {:id "id787"} (forall i#0_0_7: int :: 
              { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_7) } 
              Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
                     < i#0_0_7
                   && i#0_0_7 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1
                 ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#0_0_7)
                   != Element#0);
            // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(216,17)
            // Begin Comprehension WF check
            havoc i#0_0_8;
            if (true)
            {
                assume true;
                assert {:id "id788"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                assume true;
                assume true;
                if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                     - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                   < i#0_0_8)
                {
                    assume true;
                    assert {:id "id789"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assume true;
                    assume true;
                }

                if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                     < i#0_0_8
                   && i#0_0_8
                     < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                       + n#0)
                {
                    assume true;
                    assert {:id "id790"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
                    assert {:id "id791"} {:subsumption 0} 0 <= i#0_0_8
                       && i#0_0_8
                         < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
                }
            }

            // End Comprehension WF check
            assume true;
            assume true;
            assert {:id "id792"} (forall i#0_0_9: int :: 
              { read($Heap, 
                  $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                  IndexField(i#0_0_9)) } 
              _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                       - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                     < i#0_0_9
                   && i#0_0_9
                     < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                         - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
                       + n#0
                 ==> read($Heap, 
                    $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
                    IndexField(i#0_0_9))
                   != Element#0);
            // ----- return statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(217,17)
            // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(217,17)
            assume true;
            assume true;
            position#0 := position#0;
            pop;
            pop;
            return;

            pop;
        }
        else
        {
        }

        // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(219,15)
        assume true;
        assume true;
        n#0 := n#0 + 1;
        pop;
        assume true;
        // ----- loop termination check ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(199,9)
        assert {:id "id795"} 0 <= $decr$loop#00
           || Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - n#0
             == $decr$loop#00;
        assert {:id "id796"} Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - n#0
           < $decr$loop#00;
        assume LitInt(0) <= n#0
             && n#0 <= Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           ==> _module.TwoStacks.Valid#canCall(_module.TwoStacks$T, $Heap, this);
    }

    // ----- assignment statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(222,18)
    assume true;
    assume true;
    position#0 := LitInt(-1);
    // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(223,9)
    if (position#0 >= LitInt(1))
    {
        // Begin Comprehension WF check
        havoc i#18;
        if (true)
        {
            if (LitInt(0) <= i#18)
            {
                assume true;
            }

            if (LitInt(0) <= i#18
               && i#18 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
            {
                assume true;
                assert {:id "id798"} {:subsumption 0} 0 <= i#18
                   && i#18 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
            }
        }

        // End Comprehension WF check
        assume true;
    }

    assume true;
    assert {:id "id799"} {:subsumption 0} position#0 >= LitInt(1)
       ==> (exists i#19: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#19) } 
        LitInt(0) <= i#19
           && i#19 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#19)
             == Element#0);
    assume {:id "id800"} position#0 >= LitInt(1)
       ==> (exists i#19: int :: 
        { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#19) } 
        LitInt(0) <= i#19
           && i#19 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           && Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#19)
             == Element#0);
    // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(224,9)
    // Begin Comprehension WF check
    havoc i#20;
    if (true)
    {
        assume true;
        assert {:id "id801"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assume true;
        if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             - Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
           < i#20)
        {
            assume true;
            assert {:id "id802"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
        }

        if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             < i#20
           && i#20
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref) - 1)
        {
            assume true;
            assert {:id "id803"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assert {:id "id804"} {:subsumption 0} 0 <= i#20
               && i#20
                 < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
            assume true;
            assume true;
            assert {:id "id805"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assert {:id "id806"} {:subsumption 0} 0
                 <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - i#20
                   - 1
               && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - i#20
                   - 1
                 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        }
    }

    // End Comprehension WF check
    assume true;
    assume true;
    assert {:id "id807"} (forall i#21: int :: 
      { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#21)) } 
      _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
             < i#21
           && i#21
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref) - 1
         ==> read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#21))
           == Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, 
            _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - i#21
               - 1));
    // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(225,9)
    // Begin Comprehension WF check
    havoc i#22;
    if (true)
    {
        if (LitInt(0) <= i#22)
        {
            assume true;
        }

        if (LitInt(0) <= i#22
           && i#22 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq))
        {
            assume true;
            assert {:id "id808"} {:subsumption 0} 0 <= i#22
               && i#22 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
            assume true;
            assert {:id "id809"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assert {:id "id810"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assert {:id "id811"} {:subsumption 0} 0
                 <= _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - i#22
                   - 1
               && _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                   - i#22
                   - 1
                 < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        }
    }

    // End Comprehension WF check
    assume true;
    assume true;
    assert {:id "id812"} (forall i#23: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#23) } 
      LitInt(0) <= i#23
           && i#23 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq)
         ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#23)
           == read($Heap, 
            $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, 
            IndexField(_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                 - i#23
                 - 1)));
    // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(226,9)
    // Begin Comprehension WF check
    havoc i#24;
    if (true)
    {
        assume true;
        if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
           < i#24)
        {
            assume true;
        }

        if (Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
             < i#24
           && i#24 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1)
        {
            assume true;
            assert {:id "id813"} {:subsumption 0} 0 <= i#24
               && i#24 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq);
        }
    }

    // End Comprehension WF check
    assume true;
    assume true;
    assert {:id "id814"} (forall i#25: int :: 
      { Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#25) } 
      Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1 - n#0
             < i#25
           && i#25 < Seq#Length($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq) - 1
         ==> Seq#Index($Unbox(read($Heap, this, _module.TwoStacks.s2)): Seq, i#25)
           != Element#0);
    // ----- assert statement ----- /mnt/shared/gpfs/home/manvij2/UIUC_PROJ_2/Data_verified_compiled/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2/Dafny_Learning_Experience_tmp_tmpuxvcet_u_week8_12_a3 copy 2.dfy(227,9)
    // Begin Comprehension WF check
    havoc i#26;
    if (true)
    {
        assume true;
        assert {:id "id815"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
        assume true;
        assume true;
        if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
             - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
           < i#26)
        {
            assume true;
            assert {:id "id816"} {:subsumption 0} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assume true;
            assume true;
        }

        if (_System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             < i#26
           && i#26
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                 - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               + n#0)
        {
            assume true;
            assert {:id "id817"} $Unbox(read($Heap, this, _module.TwoStacks.data)): ref != null;
            assert {:id "id818"} {:subsumption 0} 0 <= i#26
               && i#26
                 < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref);
        }
    }

    // End Comprehension WF check
    assume true;
    assume true;
    assert {:id "id819"} (forall i#27: int :: 
      { read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#27)) } 
      _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
               - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
             < i#27
           && i#27
             < _System.array.Length($Unbox(read($Heap, this, _module.TwoStacks.data)): ref)
                 - $Unbox(read($Heap, this, _module.TwoStacks.n2)): int
               + n#0
         ==> read($Heap, $Unbox(read($Heap, this, _module.TwoStacks.data)): ref, IndexField(i#27))
           != Element#0);
}



// $Is axiom for non-null type _module.TwoStacks
axiom (forall _module.TwoStacks$T: Ty, c#0: ref :: 
  { $Is(c#0, Tclass._module.TwoStacks(_module.TwoStacks$T)) } 
    { $Is(c#0, Tclass._module.TwoStacks?(_module.TwoStacks$T)) } 
  $Is(c#0, Tclass._module.TwoStacks(_module.TwoStacks$T))
     <==> $Is(c#0, Tclass._module.TwoStacks?(_module.TwoStacks$T)) && c#0 != null);

// $IsAlloc axiom for non-null type _module.TwoStacks
axiom (forall _module.TwoStacks$T: Ty, c#0: ref, $h: Heap :: 
  { $IsAlloc(c#0, Tclass._module.TwoStacks(_module.TwoStacks$T), $h) } 
  $IsAlloc(c#0, Tclass._module.TwoStacks(_module.TwoStacks$T), $h)
     <==> $IsAlloc(c#0, Tclass._module.TwoStacks?(_module.TwoStacks$T), $h));

const unique tytagFamily$nat: TyTagFamily;

const unique tytagFamily$object: TyTagFamily;

const unique tytagFamily$array: TyTagFamily;

const unique tytagFamily$_#Func1: TyTagFamily;

const unique tytagFamily$_#PartialFunc1: TyTagFamily;

const unique tytagFamily$_#TotalFunc1: TyTagFamily;

const unique tytagFamily$_#Func0: TyTagFamily;

const unique tytagFamily$_#PartialFunc0: TyTagFamily;

const unique tytagFamily$_#TotalFunc0: TyTagFamily;

const unique tytagFamily$_tuple#2: TyTagFamily;

const unique tytagFamily$_tuple#0: TyTagFamily;

const unique tytagFamily$TwoStacks: TyTagFamily;

const unique field$s1: NameFamily;

const unique field$s2: NameFamily;

const unique field$Repr: NameFamily;

const unique field$data: NameFamily;

const unique field$n1: NameFamily;

const unique field$n2: NameFamily;
