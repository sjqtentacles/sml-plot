(* test_clamp.sml -- value clamping into a closed interval. *)

structure ClampTests =
struct
  open Support
  structure H = Harness

  fun run () =
    let
      val () = H.section "clamp"
      val () = checkReal "interior value is unchanged" (0.5, P.clamp 0.0 1.0 0.5)
      val () = checkReal "below low clamps to low"     (0.0, P.clamp 0.0 1.0 ~3.0)
      val () = checkReal "above high clamps to high"   (1.0, P.clamp 0.0 1.0 2.0)
      val () = checkReal "low boundary"                (0.0, P.clamp 0.0 1.0 0.0)
      val () = checkReal "high boundary"               (1.0, P.clamp 0.0 1.0 1.0)
      val () = checkReal "negative range interior"     (~2.5, P.clamp ~5.0 0.0 ~2.5)
      val () = checkReal "swapped bounds are tolerated" (0.5, P.clamp 1.0 0.0 0.5)
    in () end
end
