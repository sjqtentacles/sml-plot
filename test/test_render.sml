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
    in () end
end
