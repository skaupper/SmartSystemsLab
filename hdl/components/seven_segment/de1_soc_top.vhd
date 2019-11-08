library ieee;
library soc_system;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all;
use soc_system.all;

entity de1_soc_top is
    port 
    (
        -- //////////// ADC //////////
        ADC_CS_N               : inout std_logic;
        ADC_DIN                : out   std_logic;
        ADC_DOUT               : in    std_logic;
        ADC_SCLK               : out   std_logic;
    
        -- //////////// Audio //////////
        AUD_ADCDAT             : in    std_logic;
        AUD_ADCLRCK            : inout std_logic;
        AUD_BCLK               : inout std_logic;
        AUD_DACDAT             : out   std_logic;
        AUD_DACLRCK            : inout std_logic;
        AUD_XCK                : out   std_logic;
    
        -- //////////// CLOCK //////////
        CLOCK_50               : in    std_logic;
        CLOCK2_50              : in    std_logic;
        CLOCK3_50              : in    std_logic;
        CLOCK4_50              : in    std_logic;
    
        -- //////////// SDRAM //////////
        DRAM_ADDR              : out   std_logic_vector(12 downto 0);
        DRAM_BA                : out   std_logic_vector(1 downto 0);
        DRAM_CAS_N             : out   std_logic;
        DRAM_CKE               : out   std_logic;
        DRAM_CLK               : out   std_logic;
        DRAM_CS_N              : out   std_logic;
        DRAM_DQ                : inout std_logic_vector(15 downto 0);
        DRAM_LDQM              : out   std_logic;
        DRAM_RAS_N             : out   std_logic;
        DRAM_UDQM              : out   std_logic;
        DRAM_WE_N              : out   std_logic;
    
        -- //////////// I2C for Audio and Video-In //////////
        FPGA_I2C_SCLK          : out   std_logic;
        FPGA_I2C_SDAT          : inout std_logic;
    
        -- //////////// SEG7 //////////
        HEX0                   : out   std_logic_vector(6 downto 0);
        HEX1                   : out   std_logic_vector(6 downto 0);
        HEX2                   : out   std_logic_vector(6 downto 0);
        HEX3                   : out   std_logic_vector(6 downto 0);
        HEX4                   : out   std_logic_vector(6 downto 0);
        HEX5                   : out   std_logic_vector(6 downto 0);
    
        -- //////////// IR //////////
        IRDA_RXD               : in    std_logic;
        IRDA_TXD               : out   std_logic;
    
        -- //////////// KEY //////////
        KEY                    : in    std_logic_vector(3 downto 0);
    
        -- //////////// LED //////////
        LEDR                   : out   std_logic_vector(9 downto 0);
    
        -- //////////// PS2 //////////
        PS2_CLK                : inout std_logic;
        PS2_CLK2               : inout std_logic;
        PS2_DAT                : inout std_logic;
        PS2_DAT2               : inout std_logic;
    
        -- //////////// SW //////////
        SW                     : in    std_logic_vector(9 downto 0);
    
        -- //////////// Video-In //////////
        TD_CLK27               : in    std_logic;
        TD_DATA                : in    std_logic_vector(7 downto 0);
        TD_HS                  : in    std_logic;
        TD_RESET_N             : out   std_logic;
        TD_VS                  : in    std_logic;
    
        -- //////////// VGA //////////
        VGA_B                  : out   std_logic_vector(7 downto 0);
        VGA_BLANK_N            : out   std_logic;
        VGA_CLK                : out   std_logic;
        VGA_G                  : out   std_logic_vector(7 downto 0);
        VGA_HS                 : out   std_logic;
        VGA_R                  : out   std_logic_vector(7 downto 0);
        VGA_SYNC_N             : out   std_logic;
        VGA_VS                 : out   std_logic;

        -- //////////// HPS //////////
        HPS_CONV_USB_N         : inout std_logic;
        HPS_DDR3_ADDR          : out   std_logic_vector(14 downto 0);
        HPS_DDR3_BA            : out   std_logic_vector(2 downto 0);
        HPS_DDR3_CAS_N         : out   std_logic;
        HPS_DDR3_CK_N          : out   std_logic;
        HPS_DDR3_CK_P          : out   std_logic;
        HPS_DDR3_CKE           : out   std_logic;
        HPS_DDR3_CS_N          : out   std_logic;
        HPS_DDR3_DM            : out   std_logic_vector(3 downto 0);
        HPS_DDR3_DQ            : inout std_logic_vector(31 downto 0);
        HPS_DDR3_DQS_N         : inout std_logic_vector(3 downto 0);
        HPS_DDR3_DQS_P         : inout std_logic_vector(3 downto 0);
        HPS_DDR3_ODT           : out   std_logic;
        HPS_DDR3_RAS_N         : out   std_logic;
        HPS_DDR3_RESET_N       : out   std_logic;
        HPS_DDR3_RZQ           : in    std_logic;
        HPS_DDR3_WE_N          : out   std_logic;
        HPS_ENET_GTX_CLK       : out   std_logic;
        HPS_ENET_INT_N         : inout std_logic;
        HPS_ENET_MDC           : out   std_logic;
        HPS_ENET_MDIO          : inout std_logic;
        HPS_ENET_RX_CLK        : in    std_logic;
        HPS_ENET_RX_DATA       : in    std_logic_vector(3 downto 0);
        HPS_ENET_RX_DV         : in    std_logic;
        HPS_ENET_TX_DATA       : out   std_logic_vector(3 downto 0);
        HPS_ENET_TX_EN         : out   std_logic;
        HPS_FLASH_DATA         : inout std_logic_vector(3 downto 0);
        HPS_FLASH_DCLK         : out   std_logic;
        HPS_FLASH_NCSO         : out   std_logic;
        HPS_GSENSOR_INT        : inout std_logic;
        HPS_I2C_CONTROL        : inout std_logic;
        HPS_I2C1_SCLK          : inout std_logic;
        HPS_I2C1_SDAT          : inout std_logic;
        HPS_I2C2_SCLK          : inout std_logic;
        HPS_I2C2_SDAT          : inout std_logic;
        HPS_KEY                : inout std_logic;
        HPS_LED                : inout std_logic;
        HPS_LTC_GPIO           : inout std_logic;
        HPS_SD_CLK             : out   std_logic;
        HPS_SD_CMD             : inout std_logic;
        HPS_SD_DATA            : inout std_logic_vector(3 downto 0);
        HPS_SPIM_CLK           : out   std_logic;
        HPS_SPIM_MISO          : in    std_logic;
        HPS_SPIM_MOSI          : out   std_logic;
        HPS_SPIM_SS            : inout std_logic;
        HPS_UART_RX            : in    std_logic;
        HPS_UART_TX            : out   std_logic;
        HPS_USB_CLKOUT         : in    std_logic;
        HPS_USB_DATA           : inout std_logic_vector(7 downto 0);
        HPS_USB_DIR            : in    std_logic;
        HPS_USB_NXT            : in    std_logic;
        HPS_USB_STP            : out   std_logic;
    
        -- //////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
        GPIO_0                 : inout std_logic_vector(35 downto 0);
    
        -- //////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
        GPIO_1                 : inout std_logic_vector(35 downto 0)
    );
end entity de1_soc_top;

architecture rtl of de1_soc_top is

    signal fpga_debounced_buttons : std_logic_vector(3 downto 0);
    signal fpga_led_internal      : std_logic_vector(9 downto 0);
    signal hps_fpga_reset_n       : std_logic;
    signal hps_reset_req          : std_logic_vector(2 downto 0);
    signal hps_cold_reset         : std_logic;        
    signal hps_warm_reset         : std_logic;       
    signal hps_debug_reset        : std_logic;        
    signal stm_hw_events          : std_logic_vector(27 downto 0);

    component hps_reset
    port (
        probe           : in  std_logic;
        source_clk      : in  std_logic;
        source          : out std_logic_vector(2 downto 0)
    );
    end component;

    component altera_edge_detector
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        signal_in       : in  std_logic;
        pulse_out       : out std_logic
    );
    end component;

begin
    stm_hw_events     <= "0000" & SW &  fpga_led_internal &  fpga_debounced_buttons;

    -- Create the SoC instance
    soc_system_inst : entity soc_system.soc_system
    port map (
            memory_mem_a                                      => HPS_DDR3_ADDR,   
            memory_mem_ba                                     => HPS_DDR3_BA,     
            memory_mem_ck                                     => HPS_DDR3_CK_P,   
            memory_mem_ck_n                                   => HPS_DDR3_CK_N,   
            memory_mem_cke                                    => HPS_DDR3_CKE,    
            memory_mem_cs_n                                   => HPS_DDR3_CS_N,   
            memory_mem_ras_n                                  => HPS_DDR3_RAS_N,  
            memory_mem_cas_n                                  => HPS_DDR3_CAS_N,  
            memory_mem_we_n                                   => HPS_DDR3_WE_N,   
            memory_mem_reset_n                                => HPS_DDR3_RESET_N,
            memory_mem_dq                                     => HPS_DDR3_DQ,     
            memory_mem_dqs                                    => HPS_DDR3_DQS_P,  
            memory_mem_dqs_n                                  => HPS_DDR3_DQS_N,  
            memory_mem_odt                                    => HPS_DDR3_ODT,    
            memory_mem_dm                                     => HPS_DDR3_DM,     
            memory_oct_rzqin                                  => HPS_DDR3_RZQ,    

            hps_0_hps_io_hps_io_emac1_inst_TX_CLK             => HPS_ENET_GTX_CLK,
            hps_0_hps_io_hps_io_emac1_inst_TXD0               => HPS_ENET_TX_DATA(0),
            hps_0_hps_io_hps_io_emac1_inst_TXD1               => HPS_ENET_TX_DATA(1),
            hps_0_hps_io_hps_io_emac1_inst_TXD2               => HPS_ENET_TX_DATA(2),
            hps_0_hps_io_hps_io_emac1_inst_TXD3               => HPS_ENET_TX_DATA(3),
            hps_0_hps_io_hps_io_emac1_inst_RXD0               => HPS_ENET_RX_DATA(0),
            hps_0_hps_io_hps_io_emac1_inst_MDIO               => HPS_ENET_MDIO,      
            hps_0_hps_io_hps_io_emac1_inst_MDC                => HPS_ENET_MDC,  
            hps_0_hps_io_hps_io_emac1_inst_RX_CTL             => HPS_ENET_RX_DV,
            hps_0_hps_io_hps_io_emac1_inst_TX_CTL             => HPS_ENET_TX_EN, 
            hps_0_hps_io_hps_io_emac1_inst_RX_CLK             => HPS_ENET_RX_CLK,
            hps_0_hps_io_hps_io_emac1_inst_RXD1               => HPS_ENET_RX_DATA(1),
            hps_0_hps_io_hps_io_emac1_inst_RXD2               => HPS_ENET_RX_DATA(2),
            hps_0_hps_io_hps_io_emac1_inst_RXD3               => HPS_ENET_RX_DATA(3),
        
            hps_0_hps_io_hps_io_qspi_inst_IO0                 => HPS_FLASH_DATA(0),
            hps_0_hps_io_hps_io_qspi_inst_IO1                 => HPS_FLASH_DATA(1),
            hps_0_hps_io_hps_io_qspi_inst_IO2                 => HPS_FLASH_DATA(2),
            hps_0_hps_io_hps_io_qspi_inst_IO3                 => HPS_FLASH_DATA(3),
            hps_0_hps_io_hps_io_qspi_inst_SS0                 => HPS_FLASH_NCSO,   
            hps_0_hps_io_hps_io_qspi_inst_CLK                 => HPS_FLASH_DCLK,    

            hps_0_hps_io_hps_io_sdio_inst_CMD                 => HPS_SD_CMD,     
            hps_0_hps_io_hps_io_sdio_inst_D0                  => HPS_SD_DATA(0), 
            hps_0_hps_io_hps_io_sdio_inst_D1                  => HPS_SD_DATA(1), 
            hps_0_hps_io_hps_io_sdio_inst_CLK                 => HPS_SD_CLK,     
            hps_0_hps_io_hps_io_sdio_inst_D2                  => HPS_SD_DATA(2), 
            hps_0_hps_io_hps_io_sdio_inst_D3                  => HPS_SD_DATA(3),  
   
            hps_0_hps_io_hps_io_usb1_inst_D0                  => HPS_USB_DATA(0),
            hps_0_hps_io_hps_io_usb1_inst_D1                  => HPS_USB_DATA(1),
            hps_0_hps_io_hps_io_usb1_inst_D2                  => HPS_USB_DATA(2),
            hps_0_hps_io_hps_io_usb1_inst_D3                  => HPS_USB_DATA(3),
            hps_0_hps_io_hps_io_usb1_inst_D4                  => HPS_USB_DATA(4),
            hps_0_hps_io_hps_io_usb1_inst_D5                  => HPS_USB_DATA(5),
            hps_0_hps_io_hps_io_usb1_inst_D6                  => HPS_USB_DATA(6),
            hps_0_hps_io_hps_io_usb1_inst_D7                  => HPS_USB_DATA(7),
            hps_0_hps_io_hps_io_usb1_inst_CLK                 => HPS_USB_CLKOUT, 
            hps_0_hps_io_hps_io_usb1_inst_STP                 => HPS_USB_STP,    
            hps_0_hps_io_hps_io_usb1_inst_DIR                 => HPS_USB_DIR,    
            hps_0_hps_io_hps_io_usb1_inst_NXT                 => HPS_USB_NXT,

            hps_0_hps_io_hps_io_spim1_inst_CLK                => HPS_SPIM_CLK,
            hps_0_hps_io_hps_io_spim1_inst_MOSI               => HPS_SPIM_MOSI,
            hps_0_hps_io_hps_io_spim1_inst_MISO               => HPS_SPIM_MISO,
            hps_0_hps_io_hps_io_spim1_inst_SS0                => HPS_SPIM_SS,     

            hps_0_hps_io_hps_io_uart0_inst_RX                 => HPS_UART_RX,    
            hps_0_hps_io_hps_io_uart0_inst_TX                 => HPS_UART_TX,   

            hps_0_hps_io_hps_io_i2c0_inst_SDA                 => HPS_I2C1_SDAT,  
            hps_0_hps_io_hps_io_i2c0_inst_SCL                 => HPS_I2C1_SCLK,    

            hps_0_hps_io_hps_io_i2c1_inst_SDA                 => HPS_I2C2_SDAT,  
            hps_0_hps_io_hps_io_i2c1_inst_SCL                 => HPS_I2C2_SCLK, 

            hps_0_hps_io_hps_io_gpio_inst_GPIO09              => HPS_CONV_USB_N, 
            hps_0_hps_io_hps_io_gpio_inst_GPIO35              => HPS_ENET_INT_N, 
            hps_0_hps_io_hps_io_gpio_inst_GPIO40              => HPS_LTC_GPIO,
            hps_0_hps_io_hps_io_gpio_inst_GPIO48              => HPS_I2C_CONTROL,
            hps_0_hps_io_hps_io_gpio_inst_GPIO53              => HPS_LED,   
            hps_0_hps_io_hps_io_gpio_inst_GPIO54              => HPS_KEY,   
            hps_0_hps_io_hps_io_gpio_inst_GPIO61              => HPS_GSENSOR_INT,

            hps_0_f2h_stm_hw_events_stm_hwevents              => stm_hw_events,   

            clk_clk                                           => CLOCK_50,        
            reset_reset_n                                     => hps_fpga_reset_n,
            hps_0_h2f_reset_reset_n                           => hps_fpga_reset_n,
            hps_0_f2h_warm_reset_req_reset_n                  => not hps_warm_reset, 
            hps_0_f2h_debug_reset_req_reset_n                 => not hps_debug_reset,
            hps_0_f2h_cold_reset_req_reset_n                  => not hps_cold_reset,

            output_led_export                                 => LEDR,
            output_seven_segment_export(6+7*0 downto  7*0)    => HEX0,
            output_seven_segment_export(6+7*1 downto  7*1)    => HEX1,
            output_seven_segment_export(6+7*2 downto  7*2)    => HEX2,
            output_seven_segment_export(6+7*3 downto  7*3)    => HEX3,
            output_seven_segment_export(6+7*4 downto  7*4)    => HEX4,
            output_seven_segment_export(6+7*5 downto  7*5)    => HEX5,
            input_switch_export                               => SW,
            dac_ch0_export(9 downto 2)                        => VGA_R,
            dac_ch1_export(9 downto 2)                        => VGA_G,
            dac_ch2_export(9 downto 2)                        => VGA_B,
            dac_clk_export                                    => VGA_CLK
    );

    -- unblank all DAC channels
    VGA_BLANK_N <= '1';

    -- Source/Probe megawizard instance
    hps_reset_inst : hps_reset
    port map (
        probe           => '0',                 -- hack because no default value assigned in IP
        source_clk      => CLOCK_50,
        source          => hps_reset_req
    );

    pulse_cold_reset : altera_edge_detector 
    port map (
        clk             => CLOCK_50,
        rst_n           => hps_fpga_reset_n,
        signal_in       => hps_reset_req(0),
        pulse_out       => hps_cold_reset
    );

    pulse_warm_reset : altera_edge_detector 
    port map (
        clk             => CLOCK_50,
        rst_n           => hps_fpga_reset_n,
        signal_in       => hps_reset_req(1),
        pulse_out       => hps_warm_reset
    );

    pulse_debug_reset : altera_edge_detector 
    port map (
        clk             => CLOCK_50,
        rst_n           => hps_fpga_reset_n,
        signal_in       => hps_reset_req(2),
        pulse_out       => hps_debug_reset
    );

end architecture rtl;
