(* support.sml -- shared helpers for the sml-plot test suite.

   The layout maths is real-valued, so we compare with an absolute+relative
   epsilon rather than the harness's structural equality. *)

structure Support =
struct
  structure P = Plot
  structure I = Image
  structure H = Harness

  val eps = 1E~9

  fun approx (a, b) =
    let val d = Real.abs (a - b)
    in d <= eps orelse d <= eps * Real.max (Real.abs a, Real.abs b) end

  fun rstr x = Real.fmt (StringCvt.GEN (SOME 12)) x

  fun checkReal name (expected, actual) =
    H.check
      (name ^ " (expected " ^ rstr expected ^ ", got " ^ rstr actual ^ ")")
      (approx (expected, actual))

  fun checkRealList name (expected, actual) =
    H.check
      (name ^ " (expected " ^ Int.toString (length expected)
        ^ " values, got " ^ Int.toString (length actual) ^ ")")
      (length expected = length actual
       andalso ListPair.all approx (expected, actual))

  (* Decode an image's pixel count for sanity checks. *)
  fun pixels ({ width, height, ... } : I.image) = width * height
end
