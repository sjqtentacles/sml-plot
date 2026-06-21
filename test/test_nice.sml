(* test_nice.sml -- "nice number" tick selection (Heckbert). *)

structure NiceTests =
struct
  open Support
  structure H = Harness

  fun run () =
    let
      val () = H.section "niceNum"
      val () = checkReal "non-positive -> 0"        (0.0,  P.niceNum (0.0, true))
      val () = checkReal "1 ceil -> 1"              (1.0,  P.niceNum (1.0, false))
      val () = checkReal "7 ceil -> 10"             (10.0, P.niceNum (7.0, false))
      val () = checkReal "6 round -> 5"             (5.0,  P.niceNum (6.0, true))
      val () = checkReal "2.5 round -> 2"           (2.0,  P.niceNum (2.5, true))
      val () = checkReal "50 ceil -> 50"            (50.0, P.niceNum (50.0, false))
      val () = checkReal "0.0123 ceil -> 0.02"      (0.02, P.niceNum (0.0123, false))
      val () = checkReal "3000 round -> 5000"       (5000.0, P.niceNum (3000.0, true))

      val () = H.section "niceAxis"
      val a = P.niceAxis (0.0, 100.0, 5)
      val () = checkReal "axis lo"   (0.0,   #lo a)
      val () = checkReal "axis hi"   (100.0, #hi a)
      val () = checkReal "axis step" (20.0,  #step a)

      val b = P.niceAxis (2.0, 11.0, 5)
      val () = checkReal "padded axis lo"   (2.0,  #lo b)
      val () = checkReal "padded axis hi"   (12.0, #hi b)
      val () = checkReal "padded axis step" (2.0,  #step b)

      val () = H.section "ticks"
      val () = checkRealList "0..100 by 20"
                 ([0.0, 20.0, 40.0, 60.0, 80.0, 100.0], P.ticks (0.0, 100.0, 5))
      val () = checkRealList "2..12 by 2"
                 ([2.0, 4.0, 6.0, 8.0, 10.0, 12.0], P.ticks (2.0, 11.0, 5))
    in () end
end
