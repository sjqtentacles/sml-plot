(* entry.sml -- runs every suite and exits with a status code. *)

fun runAllSuites () =
  ( Harness.reset ()
  ; ClampTests.run ()
  ; ExtentTests.run ()
  ; NiceTests.run ()
  ; ProjectTests.run ()
  ; RenderTests.run ()
  ; Harness.run () )

fun main () =
  OS.Process.exit
    (if runAllSuites () then OS.Process.success else OS.Process.failure)
