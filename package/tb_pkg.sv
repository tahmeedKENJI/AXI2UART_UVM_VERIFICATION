package tb_pkg;

    parameter int ID_WIDTH   = 8;
    parameter int ADDR_WIDTH = 8;
    parameter int DATA_WIDTH = 32;
    parameter int STRB_WIDTH = $clog2(DATA_WIDTH) - 1;
    parameter int USER_WIDTH = 8;

    parameter int BAUD_RATE = 9600;

    typedef enum logic [3:0] {
        IDLE,
        START,
        DATA, 
        PARITY,
        STOP
    } uart_state_t;

    typedef logic [7:0] serial_to_parallel_t;

    typedef logic [ID_WIDTH-1:0]    axi_id_t;
    typedef logic [ADDR_WIDTH-1:0]  axi_addr_t;
    typedef logic [DATA_WIDTH-1:0]  axi_data_t;
    typedef logic [STRB_WIDTH-1:0]  axi_strb_t;
    typedef logic [USER_WIDTH-1:0]  axi_user_t;
    typedef logic [1:0]             axi_resp_t;

    typedef struct packed {
        logic parityEnable;
        logic parityType;
        logic [3:0] numDataBits;
        logic [1:0] numStopBits;
        logic rx_int_en;
        int baudRate;
    } uart_config_t;

    uart_config_t uart_default_config = '{
        parityEnable : 1'b0,
        parityType   : 1'b0, // 0: Even, 1: Odd
        numDataBits  : 4'd8,
        numStopBits  : 2'd1,
        rx_int_en    : 1'b1,
        baudRate     : 9600
    };
    
endpackage