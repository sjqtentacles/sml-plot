(* sml-plot demo: a single multi-series chart combining a Line, a Scatter, and a
   Hist, with a title, axis labels, gridlines, and a legend, encoded to
   assets/chart.png via Image.encodePng.

   All data is built from exact arithmetic only -- a tiny integer LCG plus
   polynomials and divisions -- with NO transcendental functions, so the
   rendered PNG is byte-identical across MLton and Poly/ML (the determinism the
   suite and the README screenshot rely on). *)

(* --- deterministic integer LCG (Numerical Recipes constants) --- *)
val seed = ref (0w20260621 : Word32.word)
fun nextWord () =
  ( seed := !seed * 0w1664525 + 0w1013904223
  ; !seed )
(* uniform real in [0,1) with 16 bits of resolution *)
fun uniform () =
  let val w = Word32.toInt (Word32.>> (nextWord (), 0w16)) (* 0..65535 *)
  in real w / 65536.0 end

(* --- line: a smooth parabola sampled on [0,10] --- *)
val linePts =
  List.tabulate (41, fn i =>
    let val x = real i * 0.25
    in (x, 8.0 - (x - 5.0) * (x - 5.0) * 0.22) end)

(* --- scatter: points scattered around the parabola --- *)
val scatterPts =
  List.tabulate (22, fn _ =>
    let
      val x = uniform () * 10.0
      val base = 8.0 - (x - 5.0) * (x - 5.0) * 0.22
      val jitter = (uniform () - 0.5) * 2.4
    in (x, base + jitter) end)

(* --- histogram: 240 bell-ish samples (mean of three uniforms) over [0,10] --- *)
val histSamples =
  List.tabulate (240, fn _ =>
    ((uniform () + uniform () + uniform ()) / 3.0) * 10.0)

val chart : Plot.chart =
  { width  = 760
  , height = 440
  , series = [ Plot.Hist histSamples
             , Plot.Line linePts
             , Plot.Scatter scatterPts ]
  , title  = "sml-plot: line + scatter + histogram"
  , axes   = { xlabel = "x", ylabel = "value", grid = true }
  , legend = true }

val img = Plot.render chart

val () =
  let val os = BinIO.openOut "assets/chart.png"
  in
    BinIO.output (os, Image.encodePng img);
    BinIO.closeOut os;
    print "wrote assets/chart.png\n"
  end
