(* test_render.sml -- end-to-end rendering: dimensions, determinism, and
   robustness on degenerate inputs.  The pixel maths is covered numerically by
   the other suites; here we only assert the image envelope and that rendering
   is a pure, repeatable function. *)

structure RenderTests =
struct
  open Support
  structure H = Harness

  val axes = { xlabel = "x", ylabel = "y", grid = true }

  val sampleChart : P.chart =
    { width = 320, height = 240
    , series = [ P.Line [(0.0, 0.0), (1.0, 2.0), (2.0, 1.0), (3.0, 3.0)]
               , P.Scatter [(0.5, 1.0), (2.5, 2.5)] ]
    , title = "demo"
    , axes = axes
    , legend = true }

  fun dim (img : I.image) = (#width img, #height img)

  (* exact-colour pixel accounting for the additive area/pie series *)
  fun b i = Word8.fromInt i
  fun rgb (r, g, bl) : I.rgba8 = { r = b r, g = b g, b = b bl, a = 0w255 }
  (* first two entries of the series palette in plot.sml *)
  val cyan  = rgb (120, 210, 235)
  val amber = rgb (240, 190, 96)

  fun eqPx (p : I.rgba8, q : I.rgba8) =
    #r p = #r q andalso #g p = #g q andalso #b p = #b q andalso #a p = #a q

  fun countColor (img : I.image) c =
    let
      val w = #width img and h = #height img
      fun loop (x, y, acc) =
        if y >= h then acc
        else if x >= w then loop (0, y + 1, acc)
        else loop (x + 1, y, if eqPx (I.getPixel img (x, y), c) then acc + 1 else acc)
    in loop (0, 0, 0) end

  val noAxes = { xlabel = "", ylabel = "", grid = false }

  fun run () =
    let
      val () = H.section "render dimensions"
      val img = P.render sampleChart
      val () = H.checkInt "width matches spec"  (320, #width img)
      val () = H.checkInt "height matches spec" (240, #height img)
      val () = H.checkInt "data length is 4*w*h"
                 (4 * 320 * 240, Word8Vector.length (#data img))

      val () = H.section "render determinism"
      val img2 = P.render sampleChart
      val () = H.check "two renders are byte-identical" (#data img = #data img2)

      val () = H.section "render robustness"
      val empty = P.render
        { width = 200, height = 120, series = [], title = ""
        , axes = { xlabel = "", ylabel = "", grid = false }, legend = false }
      val () = H.checkInt "empty series still sized" (200 * 120, pixels empty)

      val bars = P.render
        { width = 260, height = 180
        , series = [ P.Bar [("a", 3.0), ("b", 7.0), ("c", 1.0)]
                   , P.Hist [1.0, 1.5, 2.0, 2.2, 2.9, 3.1, 3.3, 9.0] ]
        , title = "bars+hist", axes = axes, legend = true }
      val () = H.checkInt "bar+hist chart sized" (260 * 180, pixels bars)

      val tiny = P.render
        { width = 0, height = ~5, series = [], title = "x"
        , axes = axes, legend = false }
      val () = H.check "non-positive size clamps to >=1x1"
                 (#width tiny >= 1 andalso #height tiny >= 1)

      val () = H.section "render area series"
      val areaPts = [(0.0, 1.0), (1.0, 3.0), (2.0, 2.0), (3.0, 4.0)]
      val areaSpec : P.chart =
        { width = 200, height = 150, series = [P.Area areaPts]
        , title = "", axes = noAxes, legend = false }
      val areaImg = P.render areaSpec
      val lineImg = P.render
        { width = 200, height = 150, series = [P.Line areaPts]
        , title = "", axes = noAxes, legend = false }
      val aCount = countColor areaImg cyan
      val lCount = countColor lineImg cyan
      val () = H.check "area fills coloured pixels" (aCount > 0)
      val () = H.check "area covers more than the bare line (filled to baseline)"
                 (aCount > lCount)
      val () = H.check "area render is byte-identical on repeat"
                 (#data areaImg = #data (P.render areaSpec))

      val () = H.section "render pie series"
      val pieSpec : P.chart =
        { width = 200, height = 200, series = [P.Pie [("a", 1.0), ("b", 1.0)]]
        , title = "", axes = noAxes, legend = false }
      val pieImg = P.render pieSpec
      val s0 = countColor pieImg cyan
      val s1 = countColor pieImg amber
      val () = H.check "pie first slice present" (s0 > 0)
      val () = H.check "pie second slice present" (s1 > 0)
      val () = H.check "two equal slices have ~equal area"
                 (Int.abs (s0 - s1) <= Int.max (s0, s1) div 8)
      val () = H.check "pie render is byte-identical on repeat"
                 (#data pieImg = #data (P.render pieSpec))
      val oneImg = P.render
        { width = 200, height = 200, series = [P.Pie [("only", 1.0)]]
        , title = "", axes = noAxes, legend = false }
      val () = H.check "single full-turn slice fills its colour"
                 (countColor oneImg cyan > 0)
      val () = H.check "single slice draws no second colour"
                 (countColor oneImg amber = 0)
    in () end
end
