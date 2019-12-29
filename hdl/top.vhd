library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY top IS

PORT(
    ---------FPGA Connections-------------
    CLOCK_50            : in    std_logic;
    SW                  : in    std_logic_vector(9 downto 0);
    KEY                 : in    std_logic_vector(3 downto 0);
    LEDR                : out   std_logic_vector(9 downto 0);


    -- //////////// SEG7 //////////
    HEX0                : out   std_logic_vector(6 downto 0);
    HEX1                : out   std_logic_vector(6 downto 0);
    HEX2                : out   std_logic_vector(6 downto 0);
    HEX3                : out   std_logic_vector(6 downto 0);
    HEX4                : out   std_logic_vector(6 downto 0);
    HEX5                : out   std_logic_vector(6 downto 0);


    ---------HPS Connections---------------
    HPS_CONV_USB_N      : inout std_logic;
    HPS_DDR3_ADDR       : out   std_logic_vector(14 downto 0);
    HPS_DDR3_BA         : out   std_logic_vector(2 downto 0);
    HPS_DDR3_CAS_N      : out   std_logic;
    HPS_DDR3_CKE        : out   std_logic;
    HPS_DDR3_CK_N       : out   std_logic;
    HPS_DDR3_CK_P       : out   std_logic;
    HPS_DDR3_CS_N       : out   std_logic;
    HPS_DDR3_DM         : out   std_logic_vector(3 downto 0);
    HPS_DDR3_DQ         : inout std_logic_vector(31 downto 0);
    HPS_DDR3_DQS_N      : inout std_logic_vector(3 downto 0);
    HPS_DDR3_DQS_P      : inout std_logic_vector(3 downto 0);
    HPS_DDR3_ODT        : out   std_logic;
    HPS_DDR3_RAS_N      : out   std_logic;
    HPS_DDR3_RESET_N    : out   std_logic;
    HPS_DDR3_RZQ        : in    std_logic;
    HPS_DDR3_WE_N       : out   std_logic;

    HPS_ENET_GTX_CLK    : out   std_logic;
    HPS_ENET_INT_N      : inout std_logic;
    HPS_ENET_MDC        : out   std_logic;
    HPS_ENET_MDIO       : inout std_logic;
    HPS_ENET_RX_CLK     : in    std_logic;
    HPS_ENET_RX_DATA    : in    std_logic_vector(3 downto 0);
    HPS_ENET_RX_DV      : in    std_logic;
    HPS_ENET_TX_DATA    : out   std_logic_vector(3 downto 0);
    HPS_ENET_TX_EN      : out   std_logic;

    HPS_KEY             : inout std_logic;
    HPS_LED             : inout std_logic;

    HPS_SD_CLK          : out   std_logic;
    HPS_SD_CMD          : inout std_logic;
    HPS_SD_DATA         : inout std_logic_vector(3 downto 0);

    HPS_UART_RX         : in    std_logic;
    HPS_UART_TX         : out   std_logic;

    HPS_USB_CLKOUT      : in    std_logic;
    HPS_USB_DATA        : inout std_logic_vector(7 downto 0);
    HPS_USB_DIR         : in    std_logic;
    HPS_USB_NXT         : in    std_logic;
    HPS_USB_STP         : out   std_logic;

    HPS_I2C1_SCLK       : inout std_logic;
    HPS_I2C1_SDAT       : inout std_logic;
    HPS_I2C2_SCLK       : inout std_logic;
    HPS_I2C2_SDAT       : inout std_logic;
    HPS_I2C_CONTROL     : inout std_logic;

    HPS_LTC_GPIO        : inout std_logic;
    HPS_GSENSOR_INT     : inout std_logic;

    HPS_SPIM_CLK        : out   std_logic;
    HPS_SPIM_MISO       : in    std_logic;
    HPS_SPIM_MOSI       : out   std_logic;
    HPS_SPIM_SS         : inout std_logic;

    --////////// GPIO, GPIO connect to RFS - RF and Sensor //////////
    --BT_KEY            : inout std_logic;
    --BT_UART_RX        : in    std_logic;
    --BT_UART_TX        : out   std_logic;
    LSENSOR_INT         : in    std_logic;
    LSENSOR_SCL         : inout std_logic;
    LSENSOR_SDA         : inout std_logic;
    MPU_AD0_SDO         : in    std_logic;
    MPU_CS_n            : inout std_logic;
    MPU_FSYNC           : out   std_logic;
    MPU_INT             : in    std_logic;
    MPU_SCL_SCLK        : inout std_logic;
    MPU_SDA_SDI         : inout std_logic;
    RH_TEMP_DRDY_n      : in    std_ulogic;
    RH_TEMP_I2C_SCL     : inout std_logic;
    RH_TEMP_I2C_SDA     : inout std_logic;
    TMD_D               : out   std_logic_vector(7 downto 0);
    --UART2USB_CTS      : in    std_logic;
    --UART2USB_RTS      : out   std_logic;
    --UART2USB_RX       : in    std_logic;
    --UART2USB_TX       : out   std_logic;
    --WIFI_EN           : out   std_logic;
    --WIFI_RST_n        : out   std_logic;
    --WIFI_UART0_CTS    : in    std_logic;
    --WIFI_UART0_RTS    : out   std_logic;
    --WIFI_UART0_RX     : in    std_logic;
    --WIFI_UART0_TX     : out   std_logic;
    --WIFI_UART1_RX     : in    std_logic
    GPIO_0              : out   std_logic_vector(35 downto 0)
);

END ENTITY;

ARCHITECTURE MAIN OF top IS
    component HPSPlatform is
        port (
            clk_clk                              : in    std_logic                     := 'X';             -- clk
            hps_0_h2f_reset_reset_n                    : out   std_logic;                                        -- reset_n
            hps_0_f2h_cold_reset_req_reset_n     : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_debug_reset_req_reset_n    : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_stm_hw_events_stm_hwevents : in    std_logic_vector(27 downto 0) := (others => 'X'); -- stm_hwevents
            hps_0_f2h_warm_reset_req_reset_n     : in    std_logic                     := 'X';             -- reset_n
            hps_io_hps_io_emac1_inst_TX_CLK      : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
            hps_io_hps_io_emac1_inst_TXD0        : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
            hps_io_hps_io_emac1_inst_TXD1        : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
            hps_io_hps_io_emac1_inst_TXD2        : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
            hps_io_hps_io_emac1_inst_TXD3        : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
            hps_io_hps_io_emac1_inst_RXD0        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
            hps_io_hps_io_emac1_inst_MDIO        : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
            hps_io_hps_io_emac1_inst_MDC         : out   std_logic;                                        -- hps_io_emac1_inst_MDC
            hps_io_hps_io_emac1_inst_RX_CTL      : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
            hps_io_hps_io_emac1_inst_TX_CTL      : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
            hps_io_hps_io_emac1_inst_RX_CLK      : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
            hps_io_hps_io_emac1_inst_RXD1        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
            hps_io_hps_io_emac1_inst_RXD2        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
            hps_io_hps_io_emac1_inst_RXD3        : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
            hps_io_hps_io_sdio_inst_CMD          : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
            hps_io_hps_io_sdio_inst_D0           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
            hps_io_hps_io_sdio_inst_D1           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
            hps_io_hps_io_sdio_inst_CLK          : out   std_logic;                                        -- hps_io_sdio_inst_CLK
            hps_io_hps_io_sdio_inst_D2           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
            hps_io_hps_io_sdio_inst_D3           : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
            hps_io_hps_io_usb1_inst_D0           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
            hps_io_hps_io_usb1_inst_D1           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
            hps_io_hps_io_usb1_inst_D2           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
            hps_io_hps_io_usb1_inst_D3           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
            hps_io_hps_io_usb1_inst_D4           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
            hps_io_hps_io_usb1_inst_D5           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
            hps_io_hps_io_usb1_inst_D6           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
            hps_io_hps_io_usb1_inst_D7           : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
            hps_io_hps_io_usb1_inst_CLK          : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
            hps_io_hps_io_usb1_inst_STP          : out   std_logic;                                        -- hps_io_usb1_inst_STP
            hps_io_hps_io_usb1_inst_DIR          : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
            hps_io_hps_io_usb1_inst_NXT          : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
            hps_io_hps_io_spim1_inst_CLK         : out   std_logic;                                        -- hps_io_spim1_inst_CLK
            hps_io_hps_io_spim1_inst_MOSI        : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
            hps_io_hps_io_spim1_inst_MISO        : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
            hps_io_hps_io_spim1_inst_SS0         : out   std_logic;                                        -- hps_io_spim1_inst_SS0
            hps_io_hps_io_uart0_inst_RX          : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
            hps_io_hps_io_uart0_inst_TX          : out   std_logic;                                        -- hps_io_uart0_inst_TX
            hps_io_hps_io_i2c0_inst_SDA          : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
            hps_io_hps_io_i2c0_inst_SCL          : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
            hps_io_hps_io_i2c1_inst_SDA          : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
            hps_io_hps_io_i2c1_inst_SCL          : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
            hps_io_hps_io_gpio_inst_GPIO09       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
            hps_io_hps_io_gpio_inst_GPIO35       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
            hps_io_hps_io_gpio_inst_GPIO40       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
            hps_io_hps_io_gpio_inst_GPIO48       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO48
            hps_io_hps_io_gpio_inst_GPIO53       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
            hps_io_hps_io_gpio_inst_GPIO54       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
            hps_io_hps_io_gpio_inst_GPIO61       : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
            memory_mem_a                         : out   std_logic_vector(14 downto 0);                    -- mem_a
            memory_mem_ba                        : out   std_logic_vector(2 downto 0);                     -- mem_ba
            memory_mem_ck                        : out   std_logic;                                        -- mem_ck
            memory_mem_ck_n                      : out   std_logic;                                        -- mem_ck_n
            memory_mem_cke                       : out   std_logic;                                        -- mem_cke
            memory_mem_cs_n                      : out   std_logic;                                        -- mem_cs_n
            memory_mem_ras_n                     : out   std_logic;                                        -- mem_ras_n
            memory_mem_cas_n                     : out   std_logic;                                        -- mem_cas_n
            memory_mem_we_n                      : out   std_logic;                                        -- mem_we_n
            memory_mem_reset_n                   : out   std_logic;                                        -- mem_reset_n
            memory_mem_dq                        : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
            memory_mem_dqs                       : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                     : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                       : out   std_logic;                                        -- mem_odt
            memory_mem_dm                        : out   std_logic_vector(3 downto 0);                     -- mem_dm
            memory_oct_rzqin                     : in    std_logic                     := 'X';             -- oct_rzqin
            reset_reset_n                        : in    std_logic                     := 'X';             -- reset_n
            leds_external_connection_export      : out   std_logic_vector(9 downto 0);                     -- export
            seven_segment_conduit_end_export     : out   std_logic_vector(41 downto 0);                    -- export
            switches_external_connection_export  : in    std_logic_vector(9 downto 0)  := (others => 'X'); -- export
            hmi_subsystemapds9301_apdsinterrupt_irq_n      : in    std_logic                     := 'X';             -- irq_n
            hmi_subsystemapds9301_i2c_scl_in  : in    std_logic                     := 'X';             -- scl_in
            hmi_subsystemapds9301_i2c_scl_oe  : out   std_logic;                                        -- scl_oe
            hmi_subsystemapds9301_i2c_sda_in  : in    std_logic                     := 'X';             -- sda_in
            hmi_subsystemapds9301_i2c_sda_oe  : out   std_logic;                                        -- sda_oe
            hmi_subsystemhdc1000_hdcrdy_interrupt        : in    std_logic                     := 'X';             -- interrupt
            hmi_subsystemhdc1000_i2c_0_i2c_serial_sda_in : in    std_logic                     := 'X';             -- sda_in
            hmi_subsystemhdc1000_i2c_0_i2c_serial_scl_in : in    std_logic                     := 'X';             -- scl_in
            hmi_subsystemhdc1000_i2c_0_i2c_serial_sda_oe : out   std_logic;                                        -- sda_oe
            hmi_subsystemhdc1000_i2c_0_i2c_serial_scl_oe : out   std_logic;                                        -- scl_oe
            hmi_subsystemmpu9250_spi_MISO       : in    std_logic                     := 'X';             -- MISO
            hmi_subsystemmpu9250_spi_MOSI       : out   std_logic;                                        -- MOSI
            hmi_subsystemmpu9250_spi_SCLK       : out   std_logic;                                        -- SCLK
            hmi_subsystemmpu9250_spi_SS_n       : out   std_logic;                                        -- SS_n
            hmi_subsystemmpu9250_mpuint_irq_n   : in    std_logic                     := 'X'              -- irq_n
        );
    end component HPSPlatform;

    component i2c_io_buf
    PORT
    (
        datain  : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        oe      : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        dataio  : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        dataout	: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
    end component;


   signal HPS_H2F_RST : std_logic;

   constant        hps_cold_reset  : std_logic := '0';
   constant        hps_warm_reset  : std_logic := '0';
   constant        hps_debug_reset : std_logic := '0';
   constant        sync_levels     : natural   := 100;

   signal stm_hw_events : std_logic_vector(27 downto 0);
   signal test : std_logic;
   signal key_reset_sync : std_logic_vector(sync_levels downto 0);

   signal hdc1000_i2c_serial_sda_in : std_logic;
   signal hdc1000_i2c_serial_scl_in : std_logic;
   signal hdc1000_i2c_serial_sda_oe : std_logic;
   signal hdc1000_i2c_serial_scl_oe : std_logic;

   signal apds9301_i2c_serial_sda_in : std_logic;
   signal apds9301_i2c_serial_scl_in : std_logic;
   signal apds9301_i2c_serial_sda_oe : std_logic;
   signal apds9301_i2c_serial_scl_oe : std_logic;

BEGIN


u0 : component HPSPlatform
        port map (
            clk_clk                         => CLOCK_50,                         --                     clk.clk
            reset_reset_n                   => key_reset_sync(0),                   --                   reset.reset_n
            memory_mem_a                    => HPS_DDR3_ADDR,                    --                  memory.mem_a
            memory_mem_ba                   => HPS_DDR3_BA,                   --                        .mem_ba
            memory_mem_ck                   => HPS_DDR3_CK_P,                   --                        .mem_ck
            memory_mem_ck_n                 => HPS_DDR3_CK_N,                 --                        .mem_ck_n
            memory_mem_cke                  => HPS_DDR3_CKE,                  --                        .mem_cke
            memory_mem_cs_n                 => HPS_DDR3_CS_N,                 --                        .mem_cs_n
            memory_mem_ras_n                => HPS_DDR3_RAS_N,                --                        .mem_ras_n
            memory_mem_cas_n                => HPS_DDR3_CAS_N,                --                        .mem_cas_n
            memory_mem_we_n                 => HPS_DDR3_WE_N,                 --                        .mem_we_n
            memory_mem_reset_n              => HPS_DDR3_RESET_N,              --                        .mem_reset_n
            memory_mem_dq                   => HPS_DDR3_DQ,                   --                        .mem_dq
            memory_mem_dqs                  => HPS_DDR3_DQS_P,                  --                        .mem_dqs
            memory_mem_dqs_n                => HPS_DDR3_DQS_N,                --                        .mem_dqs_n
            memory_mem_odt                  => HPS_DDR3_ODT,                  --                        .mem_odt
            memory_mem_dm                   => HPS_DDR3_DM,                   --                        .mem_dm
            memory_oct_rzqin                => HPS_DDR3_RZQ,                --                        .oct_rzqin
            hps_0_h2f_reset_reset_n               => HPS_H2F_RST,             --         hps_0_h2f_reset.reset_n
            hps_0_f2h_cold_reset_req_reset_n     => not(hps_cold_reset),     --     hps_0_f2h_cold_reset_req.reset_n
            hps_0_f2h_debug_reset_req_reset_n    => not(hps_debug_reset),    --    hps_0_f2h_debug_reset_req.reset_n
            hps_0_f2h_stm_hw_events_stm_hwevents => stm_hw_events, --      hps_0_f2h_stm_hw_events.stm_hwevents
            hps_0_f2h_warm_reset_req_reset_n     => not(hps_warm_reset),     --     hps_0_f2h_warm_reset_req.reset_n
            hps_io_hps_io_emac1_inst_TX_CLK => HPS_ENET_GTX_CLK, --                  hps_io.hps_io_emac1_inst_TX_CLK
            hps_io_hps_io_emac1_inst_TXD0   => HPS_ENET_TX_DATA(0),   --                        .hps_io_emac1_inst_TXD0
            hps_io_hps_io_emac1_inst_TXD1   => HPS_ENET_TX_DATA(1),   --                        .hps_io_emac1_inst_TXD1
            hps_io_hps_io_emac1_inst_TXD2   => HPS_ENET_TX_DATA(2),   --                        .hps_io_emac1_inst_TXD2
            hps_io_hps_io_emac1_inst_TXD3   => HPS_ENET_TX_DATA(3),   --                        .hps_io_emac1_inst_TXD3
            hps_io_hps_io_emac1_inst_RXD0   => HPS_ENET_RX_DATA(0),   --                        .hps_io_emac1_inst_RXD0
            hps_io_hps_io_emac1_inst_MDIO   => HPS_ENET_MDIO,   --                        .hps_io_emac1_inst_MDIO
            hps_io_hps_io_emac1_inst_MDC    => HPS_ENET_MDC,    --                        .hps_io_emac1_inst_MDC
            hps_io_hps_io_emac1_inst_RX_CTL => HPS_ENET_RX_DV, --                        .hps_io_emac1_inst_RX_CTL
            hps_io_hps_io_emac1_inst_TX_CTL => HPS_ENET_TX_EN, --                        .hps_io_emac1_inst_TX_CTL
            hps_io_hps_io_emac1_inst_RX_CLK => HPS_ENET_RX_CLK, --                        .hps_io_emac1_inst_RX_CLK
            hps_io_hps_io_emac1_inst_RXD1   => HPS_ENET_RX_DATA(1),   --                        .hps_io_emac1_inst_RXD1
            hps_io_hps_io_emac1_inst_RXD2   => HPS_ENET_RX_DATA(2),   --                        .hps_io_emac1_inst_RXD2
            hps_io_hps_io_emac1_inst_RXD3   => HPS_ENET_RX_DATA(3),   --                        .hps_io_emac1_inst_RXD3
            hps_io_hps_io_sdio_inst_CMD     => HPS_SD_CMD,     --                        .hps_io_sdio_inst_CMD
            hps_io_hps_io_sdio_inst_D0      => HPS_SD_DATA(0),      --                        .hps_io_sdio_inst_D0
            hps_io_hps_io_sdio_inst_D1      => HPS_SD_DATA(1),      --                        .hps_io_sdio_inst_D1
            hps_io_hps_io_sdio_inst_CLK     => HPS_SD_CLK,     --                        .hps_io_sdio_inst_CLK
            hps_io_hps_io_sdio_inst_D2      => HPS_SD_DATA(2),      --                        .hps_io_sdio_inst_D2
            hps_io_hps_io_sdio_inst_D3      => HPS_SD_DATA(3),      --                        .hps_io_sdio_inst_D3
            hps_io_hps_io_usb1_inst_D0      => HPS_USB_DATA(0),      --                        .hps_io_usb1_inst_D0
            hps_io_hps_io_usb1_inst_D1      => HPS_USB_DATA(1),      --                        .hps_io_usb1_inst_D1
            hps_io_hps_io_usb1_inst_D2      => HPS_USB_DATA(2),      --                        .hps_io_usb1_inst_D2
            hps_io_hps_io_usb1_inst_D3      => HPS_USB_DATA(3),      --                        .hps_io_usb1_inst_D3
            hps_io_hps_io_usb1_inst_D4      => HPS_USB_DATA(4),      --                        .hps_io_usb1_inst_D4
            hps_io_hps_io_usb1_inst_D5      => HPS_USB_DATA(5),      --                        .hps_io_usb1_inst_D5
            hps_io_hps_io_usb1_inst_D6      => HPS_USB_DATA(6),      --                        .hps_io_usb1_inst_D6
            hps_io_hps_io_usb1_inst_D7      => HPS_USB_DATA(7),      --                        .hps_io_usb1_inst_D7
            hps_io_hps_io_usb1_inst_CLK     => HPS_USB_CLKOUT,     --                        .hps_io_usb1_inst_CLK
            hps_io_hps_io_usb1_inst_STP     => HPS_USB_STP,     --                        .hps_io_usb1_inst_STP
            hps_io_hps_io_usb1_inst_DIR     => HPS_USB_DIR,     --                        .hps_io_usb1_inst_DIR
            hps_io_hps_io_usb1_inst_NXT     => HPS_USB_NXT,     --                        .hps_io_usb1_inst_NXT
            hps_io_hps_io_spim1_inst_CLK    => HPS_SPIM_CLK,         --                             .hps_io_spim1_inst_CLK
            hps_io_hps_io_spim1_inst_MOSI   => HPS_SPIM_MOSI,        --                             .hps_io_spim1_inst_MOSI
            hps_io_hps_io_spim1_inst_MISO   => HPS_SPIM_MISO,        --                             .hps_io_spim1_inst_MISO
            hps_io_hps_io_spim1_inst_SS0    => HPS_SPIM_SS,         --                             .hps_io_spim1_inst_SS0
            hps_io_hps_io_uart0_inst_RX     => HPS_UART_RX,     --                        .hps_io_uart0_inst_RX
            hps_io_hps_io_uart0_inst_TX     => HPS_UART_TX,      --                        .hps_io_uart0_inst_TX
            hps_io_hps_io_i2c0_inst_SDA          => HPS_I2C1_SDAT,          --                             .hps_io_i2c0_inst_SDA
            hps_io_hps_io_i2c0_inst_SCL          => HPS_I2C1_SCLK,          --                             .hps_io_i2c0_inst_SCL
            hps_io_hps_io_i2c1_inst_SDA          => HPS_I2C2_SDAT,          --                             .hps_io_i2c1_inst_SDA
            hps_io_hps_io_i2c1_inst_SCL          => HPS_I2C2_SCLK,          --                             .hps_io_i2c1_inst_SCL
            hps_io_hps_io_gpio_inst_GPIO09  => HPS_CONV_USB_N,            -- hps_io_gpio_inst_GPIO09
            hps_io_hps_io_gpio_inst_GPIO35       => HPS_ENET_INT_N,       --                             .hps_io_gpio_inst_GPIO35
            hps_io_hps_io_gpio_inst_GPIO40       => HPS_LTC_GPIO,       --                             .hps_io_gpio_inst_GPIO40
            hps_io_hps_io_gpio_inst_GPIO48       => HPS_I2C_CONTROL,       --                             .hps_io_gpio_inst_GPIO48
            hps_io_hps_io_gpio_inst_GPIO53  => HPS_LED,         -- hps_io_gpio_inst_GPIO53
            hps_io_hps_io_gpio_inst_GPIO54  => HPS_KEY,            -- hps_io_gpio_inst_GPIO54
            hps_io_hps_io_gpio_inst_GPIO61       => HPS_GSENSOR_INT,       --                             .hps_io_gpio_inst_GPIO61


            -- periph
--            leds_external_connection_export  => LEDR,  -- led_external_connection.export
            switches_external_connection_export   => SW,   --  sw_external_connection.export

            seven_segment_conduit_end_export(6+7*0 downto  7*0)    => HEX0,
            seven_segment_conduit_end_export(6+7*1 downto  7*1)    => HEX1,
            seven_segment_conduit_end_export(6+7*2 downto  7*2)    => HEX2,
            seven_segment_conduit_end_export(6+7*3 downto  7*3)    => HEX3,
            seven_segment_conduit_end_export(6+7*4 downto  7*4)    => HEX4,
            seven_segment_conduit_end_export(6+7*5 downto  7*5)    => HEX5,

            hmi_subsystemhdc1000_hdcrdy_interrupt        => RH_TEMP_DRDY_n,           --             hdc1000_0_hdcrdy.interrupt
            hmi_subsystemhdc1000_i2c_0_i2c_serial_sda_in => hdc1000_i2c_serial_sda_in,      --     hdc1000_i2c_0_i2c_serial.sda_in
            hmi_subsystemhdc1000_i2c_0_i2c_serial_scl_in => hdc1000_i2c_serial_scl_in,      --                             .scl_in
            hmi_subsystemhdc1000_i2c_0_i2c_serial_sda_oe => hdc1000_i2c_serial_sda_oe,      --                             .sda_oe
            hmi_subsystemhdc1000_i2c_0_i2c_serial_scl_oe => hdc1000_i2c_serial_scl_oe,      --                             .scl_oe

            hmi_subsystemapds9301_apdsinterrupt_irq_n    => LSENSOR_INT,      --     hmi_subsystemapds9301_apdsinterrupt.irq_n
            hmi_subsystemapds9301_i2c_sda_in  => apds9301_i2c_serial_sda_in,  --  hmi_subsystemapds9301_i2c_0_i2c_serial.scl_in
            hmi_subsystemapds9301_i2c_scl_in  => apds9301_i2c_serial_scl_in,  --                                        .scl_oe
            hmi_subsystemapds9301_i2c_sda_oe  => apds9301_i2c_serial_sda_oe,  --                                        .sda_in
            hmi_subsystemapds9301_i2c_scl_oe  => apds9301_i2c_serial_scl_oe,

            hmi_subsystemmpu9250_spi_MISO       => MPU_AD0_SDO,       --     hmi_subsystemmpu9250_spi_0_external.MISO
            hmi_subsystemmpu9250_spi_MOSI       => MPU_SDA_SDI,       --                                        .MOSI
            hmi_subsystemmpu9250_spi_SCLK       => MPU_SCL_SCLK,       --                                        .SCLK
            hmi_subsystemmpu9250_spi_SS_n       => MPU_CS_n,       --                                        .SS_n
            hmi_subsystemmpu9250_mpuint_irq_n   => MPU_INT             --           hmi_subsystemmpu9250_mpuint.irq_n
        );

    key_sync : process( CLOCK_50, HPS_H2F_RST, SW(0) )
    begin
        if (HPS_H2F_RST AND SW(0)) = '0' then
            key_reset_sync <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            key_reset_sync(sync_levels) <= '1';
            key_reset_sync(sync_levels-1 downto 0) <= key_reset_sync(sync_levels downto 1);
        end if;
    end process; -- key_sync

    hdc1000_i2c_io : component i2c_io_buf
        port map (
            datain     => (others => '0'),
            oe(1)      => hdc1000_i2c_serial_scl_oe,
            oe(0)      => hdc1000_i2c_serial_sda_oe,
            dataout(1) => hdc1000_i2c_serial_scl_in,
            dataout(0) => hdc1000_i2c_serial_sda_in,
            dataio(1)  => RH_TEMP_I2C_SCL,
            dataio(0)  => RH_TEMP_I2C_SDA);

    apds9301_i2c_io : component i2c_io_buf
        port map (
            datain     => (others => '0'),
            oe(1)      => apds9301_i2c_serial_scl_oe,
            oe(0)      => apds9301_i2c_serial_sda_oe,
            dataout(1) => apds9301_i2c_serial_scl_in,
            dataout(0) => apds9301_i2c_serial_sda_in,
            dataio(1)  => LSENSOR_SCL,
            dataio(0)  => LSENSOR_SDA);

    LEDR(0) <= HPS_H2F_RST AND key_reset_sync(0);
    LEDR(LEDR'high downto 1) <= (others => '0');

    GPIO_0( 0) <= RH_TEMP_DRDY_n;
    GPIO_0( 1) <= RH_TEMP_I2C_SCL;
    GPIO_0( 2) <= RH_TEMP_I2C_SDA;

    GPIO_0( 4) <= LSENSOR_INT;
    GPIO_0( 5) <= LSENSOR_SCL;
    GPIO_0( 6) <= LSENSOR_SDA;

    GPIO_0(10) <= MPU_SCL_SCLK;
    GPIO_0(11) <= MPU_CS_n;
    GPIO_0(12) <= MPU_INT;
    GPIO_0(14) <= MPU_AD0_SDO;
    GPIO_0(15) <= MPU_SDA_SDI;

END ARCHITECTURE;
