(* test_extent.sml -- data range computation with degenerate handling. *)

structure ExtentTests =
struct
  open Support
  structure H = Harness

  fun pairEq name ((elo, ehi), (alo, ahi)) =
    ( checkReal (name ^ " lo") (elo, alo)
    ; checkReal (name ^ " hi") (ehi, ahi) )

  fun run () =
    let
      val () = H.section "extent"
      val () = pairEq "empty list -> (0,1)" ((0.0, 1.0), P.extent [])
      val () = pairEq "ascending span" ((1.0, 5.0), P.extent [1.0, 5.0, 3.0])
      val () = pairEq "negatives included" ((~2.0, 7.0), P.extent [3.0, ~2.0, 7.0, 0.0])
      val () = pairEq "singleton is padded by 1" ((2.0, 4.0), P.extent [3.0])
      val () = pairEq "flat data is padded by 1" ((3.0, 5.0), P.extent [4.0, 4.0, 4.0])
    in () end
end
