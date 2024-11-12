-- TIMER_FREQ.vhd (First part of two-part peripheral)
-- Last updated on 7/20/2024
--
-- This part of the timer takes in 12MHz as a clock (CLOCK_12MHz) then converts it to a user-defined frequency (TIMER_CLOCK) for the TIMER second-part peripheral.
-- This also sends a NEG_FREQ signal to the TIMER portion, to signal whether to count in the forward or in the reverse direction.
-- When RESETN is active, default freqency is 10 Hz

-- TIMER_FREQ control the clock speed going to the clock
-- On OUT instruction, ACC = Freq (Neg, Zero, Pos)
--        If ACC = 0, then stop timer
--        Else if ACC = POS, then count up
--        Else if ACC = NEG, then count down

-- OUT TIMER_FREQ : Sets Timer frequency (Hz)
-- IN TIMER_FREQ : Gets Timer frequency (Hz)

LIBRARY IEEE;
LIBRARY LPM;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE LPM.LPM_COMPONENTS.ALL;

ENTITY TIMER_FREQ IS
    PORT (
    CLOCK_12MHz     : IN STD_LOGIC;
    RESETN          : IN STD_LOGIC;
    CS              : IN STD_LOGIC;
    IO_WRITE        : IN STD_LOGIC;
    IO_DATA         : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    NEG_FREQ        : OUT STD_LOGIC;
    TIMER_CLOCK     : OUT STD_LOGIC
);
END TIMER_FREQ;

ARCHITECTURE a OF TIMER_FREQ IS
    CONSTANT clk_freq    : INTEGER := 12000000;
    CONSTANT half_freq   : INTEGER := clk_freq/2;

    SIGNAL clock_int    : STD_LOGIC;
    SIGNAL clock_count  : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL input_freq   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL neg          : STD_LOGIC;

    SIGNAL divisor      : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL quotient     : STD_LOGIC_VECTOR(23 DOWNTO 0);
    SIGNAL remain       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL div_ready    : STD_LOGIC;

    SIGNAL OUT_EN       : STD_LOGIC;

    COMPONENT lpm_divide
        GENERIC (
            lpm_widthd  : INTEGER := 24;
            lpm_widthn  : INTEGER := 24
        );
        PORT (
            denom       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            numer       : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            quotient    : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
            remain      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    -- -- Use Intel LPM IP to create tristate drivers
    IO_BUS: lpm_bustri
    GENERIC MAP (
        lpm_width => 16
    )
    PORT MAP (
        data        => input_freq,
        enabledt    => OUT_EN,
        tridata     => IO_DATA
    );

    -- Instantiate the lpm_divide component
    div_inst: lpm_divide
    GENERIC MAP (
        lpm_widthd  => 16,
        lpm_widthn  => 24
    )
    PORT MAP (
        denom       => input_freq,
        numer       => std_logic_vector(to_unsigned(half_freq, 24)),
        quotient    => quotient,
        remain      => remain
    );

    OUT_EN <= (CS AND NOT(IO_WRITE));

    PROCESS (CLOCK_12MHz, RESETN)
    BEGIN
        IF (RESETN = '0') THEN
            clock_count <= (OTHERS => '0');
            clock_int <= '0';
        ELSIF (rising_edge(CLOCK_12MHz)) THEN
            IF (input_freq = x"0000") THEN
                clock_count <= clock_count;
            ELSIF clock_count < (quotient - 1) THEN
                clock_count <= clock_count + 1;
            ELSE
                clock_count <= (OTHERS => '0');
                clock_int <= NOT clock_int;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clock_int, RESETN, CS, IO_WRITE)
    BEGIN
        IF (RESETN = '0') THEN
            -- default clock freq = 10Hz
            input_freq <= x"000A";
            neg <= '0';
        ELSIF ((CS AND IO_WRITE) = '1') THEN
            IF (IO_DATA(15) = '1') THEN
                input_freq <= NOT(IO_DATA) + 1;
                neg <= '1';
            ELSE
                input_freq <= IO_DATA;
                neg <= '0';
            END IF;
        END IF;
    END PROCESS;

    TIMER_CLOCK <= clock_int;
    NEG_FREQ <= neg;

END a;
