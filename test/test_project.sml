(* test_project.sml -- the data->pixel linear transform. *)

structure ProjectTests =
struct
  open Support
  structure H = Harness

  fun run () =
    let
      val () = H.section "project (x-axis, increasing pixels)"
      val px = fn v => P.project { dlo = 0.0, dhi = 10.0, plo = 0.0, phi = 100.0 } v
      val () = checkReal "low maps to plo"  (0.0,   px 0.0)
      val () = checkReal "high maps to phi" (100.0, px 10.0)
      val () = checkReal "midpoint"         (50.0,  px 5.0)
      val () = checkReal "below range extrapolates" (~20.0, px ~2.0)

      val () = H.section "project (y-axis, inverted pixels)"
      (* bottom pixel = 100 maps to data low; top pixel = 0 maps to data high *)
      val py = fn v => P.project { dlo = 0.0, dhi = 10.0, plo = 100.0, phi = 0.0 } v
      val () = checkReal "data low at bottom"  (100.0, py 0.0)
      val () = checkReal "data high at top"    (0.0,   py 10.0)
      val () = checkReal "data mid in middle"  (50.0,  py 5.0)

      val () = H.section "project (degenerate range)"
      val pz = fn v => P.project { dlo = 5.0, dhi = 5.0, plo = 0.0, phi = 100.0 } v
      val () = checkReal "zero-width maps to midpoint" (50.0, pz 5.0)
      val () = checkReal "zero-width is constant"      (50.0, pz 999.0)
    in () end
end
