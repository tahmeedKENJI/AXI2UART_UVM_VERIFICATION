package tb_pkg;

    parameter int ID_WIDTH   = 8;
    parameter int ADDR_WIDTH = 8;
    parameter int DATA_WIDTH = 32;
    parameter int STRB_WIDTH = $clog2(DATA_WIDTH);
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

    typedef struct packed {
        logic parityEnable;
        logic parityType;
        logic [1:0] numStopBits;
        int baudRate;
    } uart_config_t;

    uart_config_t uart_default_config = '{
        parityEnable : 1'b0,
        parityType   : 1'b0,
        numStopBits  : 2'd1,
        baudRate     : 9600
    };
    
endpackage