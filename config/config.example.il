;==============================================================================
; DFF Characterization Automation
; Example Configuration File
;
; Copy this file to:
;   config/config.il
;
; Then update the Cadence project, DUT, and PDK-specific settings
; for your local environment.
;
; Simulation algorithms and post-processing logic are defined separately.
;==============================================================================


;==============================================================================
; Project Root
;==============================================================================

; DFF_CHAR_ROOT is provided by the shell environment.
;
; Example (csh/tcsh):
;   setenv DFF_CHAR_ROOT /path/to/dff-characterization-automation

DFF_CHAR_ROOT = getShellEnvVar(
    "DFF_CHAR_ROOT"
)

unless(
    DFF_CHAR_ROOT

    error(
        "ERROR: DFF_CHAR_ROOT environment variable is not set.\n"
    )
)


;==============================================================================
; Cadence Project
;==============================================================================

; Cadence simulation/project directory
DFF_PROJECT_DIR =
    "/path/to/your/cadence/simulation"


; DUT library
DFF_LIBRARY =
    "YOUR_LIBRARY"


; DUT / testbench cell
DFF_CELL =
    "YOUR_DFF_TESTBENCH"


; Maestro and config view names
DFF_MAESTRO_VIEW =
    "maestro"

DFF_CONFIG_VIEW =
    "config"


;==============================================================================
; PDK Model Files
;==============================================================================

; Default model file used by each test
DFF_TOP_MODEL_FILE =
    "/path/to/your/pdk/models/spectre/toplevel.scs"


; Default model section
DFF_TOP_MODEL_SECTION =
    "YOUR_TOP_MODEL_SECTION"


; Model file used for PVT and Monte Carlo corners
DFF_MODEL_FILE =
    "/path/to/your/pdk/models/spectre/model_usage.scs"


;==============================================================================
; Common Simulation Conditions
;==============================================================================

DFF_FREQUENCY =
    500K

DFF_LOAD_CAP =
    5f

DFF_SUB =
    0

DFF_NOMINAL_VDD =
    5


;==============================================================================
; Characterization Interface
;==============================================================================

; Test names
DFF_SETUP_TEST_NAME =
    "SETUP_TIME"

DFF_HOLD_TEST_NAME =
    "HOLD_TIME"

DFF_ETC_TEST_NAME =
    "ETC"


; Timing variable names
DFF_SETUP_VARIABLE =
    "TSETUP"

DFF_HOLD_VARIABLE =
    "THOLD"


; Required CLK-to-Q output name
;
; The CLK-to-Q expression itself may be defined freely by the user in ADE.
; The framework only requires the output name specified below.
DFF_CLK_TO_Q_OUTPUT =
    "DELAY_CLK_TO_Q"


;==============================================================================
; Setup Time Characterization
;==============================================================================

; Sweep applied to DFF_SETUP_VARIABLE
DFF_SETUP_SWEEP =
    "{From/To}Linear:200p:50p:1n{From/To}"


; Fixed hold-time value used during setup-time characterization
DFF_SETUP_TEST_HOLD =
    100n


;==============================================================================
; Hold Time Characterization
;==============================================================================

; Sweep applied to DFF_HOLD_VARIABLE
DFF_HOLD_SWEEP =
    "{From/To}Linear:-50p:50p:1n{From/To}"


; Fixed setup-time value used during hold-time characterization
DFF_HOLD_TEST_SETUP =
    100n


;==============================================================================
; ETC Characterization
;==============================================================================

; Fixed setup/hold values used for additional scalar measurements
DFF_ETC_SETUP =
    250n

DFF_ETC_HOLD =
    250n


;==============================================================================
; Timing Extraction
;==============================================================================

; Sweep point used to obtain the nominal CLK-to-Q delay
DFF_TIMING_REFERENCE =
    1e-9


; Setup/Hold boundary criterion
;
; Threshold CLK-to-Q
;     = Nominal CLK-to-Q x DFF_TIMING_DEGRADATION
DFF_TIMING_DEGRADATION =
    1.005


;==============================================================================
; PVT Configuration
;==============================================================================

; Temperatures used for PVT characterization
DFF_PVT_TEMPERATURES =
    "-40 27 150"


; Supply voltages used for PVT characterization
DFF_PVT_VDD =
    "4.5 5 5.5"


; Replace these section names with the process corners
; provided by your PDK.
DFF_PVT_MODEL_SECTIONS =
    "\"YOUR_TT_SECTION\" \"YOUR_FF_SECTION\" \"YOUR_SS_SECTION\" \"YOUR_SF_SECTION\" \"YOUR_FS_SECTION\""


; Optional additional model section required by the PDK
DFF_PRE_SIMU_SECTION =
    "\"YOUR_PRE_SIMU_SECTION\""


;==============================================================================
; Monte Carlo Configuration
;==============================================================================

DFF_MONTE_TEMPERATURES =
    "-40 150"

DFF_MONTE_VDD =
    "4.5 5.5"


; Replace with the Monte Carlo model section provided by your PDK.
DFF_MONTE_MODEL_SECTION =
    "\"YOUR_MONTE_CARLO_SECTION\""


; Number of Monte Carlo samples
DFF_MONTE_POINTS =
    "100"


; Monte Carlo random seed
DFF_MONTE_SEED =
    "12345"


;==============================================================================
; Repository Directories
;==============================================================================

DFF_DATA_DIR =
    strcat(
        DFF_CHAR_ROOT
        "/data"
    )


DFF_RAW_DIR =
    strcat(
        DFF_DATA_DIR
        "/raw"
    )


DFF_RESULT_DIR =
    strcat(
        DFF_CHAR_ROOT
        "/results"
    )


DFF_LOG_DIR =
    strcat(
        DFF_CHAR_ROOT
        "/logs"
    )


DFF_PYTHON_DIR =
    strcat(
        DFF_CHAR_ROOT
        "/python"
    )


;==============================================================================
; PVT Output Files
;==============================================================================

DFF_PVT_SETUP_CSV =
    strcat(
        DFF_RAW_DIR
        "/SETUP_TIME_PVT.csv"
    )


DFF_PVT_HOLD_CSV =
    strcat(
        DFF_RAW_DIR
        "/HOLD_TIME_PVT.csv"
    )


DFF_PVT_ETC_CSV =
    strcat(
        DFF_RAW_DIR
        "/ETC_PVT.csv"
    )


DFF_PVT_RESULT =
    strcat(
        DFF_RESULT_DIR
        "/PVT_RESULT.xlsx"
    )


DFF_PVT_PYTHON =
    strcat(
        DFF_PYTHON_DIR
        "/pvt_summary.py"
    )


DFF_PVT_OCEAN_LOG =
    strcat(
        DFF_LOG_DIR
        "/pvt_ocean.log"
    )


DFF_PVT_PYTHON_LOG =
    strcat(
        DFF_LOG_DIR
        "/pvt_python.log"
    )


;==============================================================================
; Monte Carlo Output Files
;==============================================================================

DFF_MONTE_SETUP_CSV =
    strcat(
        DFF_RAW_DIR
        "/SETUP_TIME_MONTE.csv"
    )


DFF_MONTE_HOLD_CSV =
    strcat(
        DFF_RAW_DIR
        "/HOLD_TIME_MONTE.csv"
    )


DFF_MONTE_ETC_CSV =
    strcat(
        DFF_RAW_DIR
        "/ETC_MONTE.csv"
    )


DFF_MONTE_RESULT =
    strcat(
        DFF_RESULT_DIR
        "/MONTE_RESULT.xlsx"
    )


DFF_MONTE_PYTHON =
    strcat(
        DFF_PYTHON_DIR
        "/monte_summary.py"
    )


DFF_MONTE_OCEAN_LOG =
    strcat(
        DFF_LOG_DIR
        "/monte_ocean.log"
    )


DFF_MONTE_PYTHON_LOG =
    strcat(
        DFF_LOG_DIR
        "/monte_python.log"
    )


;==============================================================================
; Configuration Summary
;==============================================================================

printf("\n")
printf("============================================\n")
printf(" DFF Characterization Configuration Loaded\n")
printf("============================================\n")


printf(
    "Root Directory : %s\n"
    DFF_CHAR_ROOT
)


printf(
    "Cadence Project: %s\n"
    DFF_PROJECT_DIR
)


printf(
    "Library        : %s\n"
    DFF_LIBRARY
)


printf(
    "Cell           : %s\n"
    DFF_CELL
)


printf(
    "Setup Test     : %s\n"
    DFF_SETUP_TEST_NAME
)


printf(
    "Hold Test      : %s\n"
    DFF_HOLD_TEST_NAME
)


printf(
    "ETC Test       : %s\n"
    DFF_ETC_TEST_NAME
)


printf(
    "CLK-to-Q Output: %s\n"
    DFF_CLK_TO_Q_OUTPUT
)


printf(
    "PVT Temp       : %s\n"
    DFF_PVT_TEMPERATURES
)


printf(
    "PVT VDD        : %s\n"
    DFF_PVT_VDD
)


printf(
    "Monte Temp     : %s\n"
    DFF_MONTE_TEMPERATURES
)


printf(
    "Monte VDD      : %s\n"
    DFF_MONTE_VDD
)


printf(
    "Monte Runs     : %s\n"
    DFF_MONTE_POINTS
)


printf("============================================\n\n")
