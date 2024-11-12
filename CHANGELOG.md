# Change Log

## (2024-7-27)

- `SCOMP2.sof` is the .sof file that was tested on the DE10, and was shown to work, but there is a bug in the assembly code
    - Line 95
    - `OUT COUNT` instead of `STORE COUNT` was used on the rocketship countdown.
    - `COUNT: DW 0`, so COUNT represented an addresss whose value didn't correspond to any IO Address, therefore no IO device effect was seen.
    - The program appeared to be correct, since the `COUNT_DOWN` subroutine was programmed such that when `timer_counter` = 0, then break out. `timer_counter` = 3 to begin with, and so `COUNT` acted as though `COUNT` = 3 even though `COUNT` = 4 at the time.
    - `timer_project2.zip` corresponds with SCOMP2.sof

- `SCOMP.sof` is fixed .sof file, but untested since lab is closed.
    - `timer_project.zip` corresponds with SCOMP.sof
