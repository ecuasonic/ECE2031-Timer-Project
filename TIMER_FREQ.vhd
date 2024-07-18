-- TIMER2.VHD (a peripheral for SCOMP)
-- 2024.07.08
--
-- This timer provides a 16 bit counter value with a resolution of the CLOCK period.
-- Writing any value to timer resets to 0x0000, but the timer continues to run.
-- The counter value rolls over to 0x0000 after a clock tick at 0xFFFF.

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY TIMER_FREQ IS
    PORT(
        CLOCK_100kHz,
        CLOCK_10kHz,
        CLOCK_100Hz,
        CLOCK_32Hz,
        CLOCK_10Hz,
        CLOCK_4Hz,
        RESETN,
        CS,
        IO_WRITE : IN    STD_LOGIC;
        IO_DATA  : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END TIMER_FREQ;

ARCHITECTURE a OF TIMER_FREQ IS
    SIGNAL COUNT     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL IO_COUNT  : STD_LOGIC_VECTOR(15 DOWNTO 0); -- a stable copy of the count for the IO
    SIGNAL OUT_EN    : STD_LOGIC;
    SIGNAL CLOCK     : STD_LOGIC;

    BEGIN

    -- Use Intel LPM IP to create tristate drivers
    IO_BUS: lpm_bustri
    GENERIC MAP (
        lpm_width => 16
    )
    PORT MAP (
        data     => IO_COUNT,
        enabledt => OUT_EN,
        tridata  => IO_DATA
    );

    -- IO data should be driven when SCOMP is requesting data
    OUT_EN <= (CS AND NOT(IO_WRITE));

    PROCESS (CLOCK, RESETN, CS, IO_WRITE)
    BEGIN
        -- If RESETN == 0 and OUT, then COUNT = 0
        -- IF (RESETN = '0' OR (CS AND IO_WRITE) = '1') THEN

        IF (RESETN = '0') THEN
            COUNT <= x"0000";
            CLOCK <= CLOCK_10Hz;
        ELSIF ((CS AND IO_WRITE) = '1') THEN
            CASE IO_DATA IS
                WHEN x"0000" =>
                   CLOCK <= CLOCK_4Hz;
                WHEN x"0001" =>
                   CLOCK <= CLOCK_10Hz;
                WHEN x"0002" =>
                   CLOCK <= CLOCK_32Hz;
                WHEN x"0003" =>
                   CLOCK <= CLOCK_100Hz;
                WHEN x"0004" =>
                   CLOCK <= CLOCK_10kHz;
                WHEN x"0005" =>
                   CLOCK <= CLOCK_100kHz;
                WHEN OTHERS =>
                    CLOCK <= CLOCK_10Hz;
            END CASE;
        ELSIF (rising_edge(CLOCK)) THEN
            COUNT <= COUNT + 1;
        END IF;
    END PROCESS;

    -- Use a latch to prevent IO_COUNT from changing while an IO operation is occuring.
    -- Note that this is only safe because the clock used for this peripheral
    -- is derived from the same clock used for SCOMP; they're not separate
    -- clock domains.
    PROCESS (CS, COUNT, IO_COUNT)
    BEGIN
        IF CS = '1' THEN
            IO_COUNT <= IO_COUNT;
        ELSE
            IO_COUNT <= COUNT;
        END IF;
    END PROCESS;

END a;