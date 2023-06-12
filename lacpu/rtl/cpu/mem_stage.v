`include "mycpu.vh"

module mem_stage(
    input                          clk            ,
    input                          reset          ,
    //allowin
    input                          ws_allowin     ,
    output                         ms_allowin     ,
    //from es
    input                          es_to_ms_valid ,
    input  [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus   ,
    //to ws
    output                         ms_to_ws_valid ,
    output [`MS_TO_WS_BUS_WD -1:0] ms_to_ws_bus   ,
    //from data-sram
    input  [31                 :0] data_sram_rdata,
    //to fw
    output [`MS_TO_FW_BUS_WD -1:0] ms_to_fw_bus   ,
    //to es
    output [`MS_TO_ES_BUS_WD -1:0] ms_to_es_bus   ,
    //div mul
    input  [31:0]     div_result    ,
    input  [31:0]     mod_result
);

    reg         ms_valid;
    wire        ms_ready_go;

    reg [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus_r;
    wire [ 4:0] ms_load_op;
    wire [ 2:0] ms_store_op;
    wire        ms_mem_to_reg;
    wire        ms_reg_we;
    wire [ 4:0] ms_dest;
    wire [31:0] ms_alu_result;
    wire [31:0] ms_pc;
    wire [ 1:0] ms_div_op;

    assign {ms_div_op        ,   //77:76
            ms_load_op       ,   //75:71
            ms_mem_to_reg    ,   //70:70
            ms_reg_we        ,   //69:69
            ms_dest          ,   //68:64
            ms_alu_result    ,   //63:32
            ms_pc                //31:0 
        } = es_to_ms_bus_r;
    
    wire [31:0] mem_result;
    wire [31:0] ms_final_result;


    assign ms_to_ws_bus = {ms_reg_we      ,  //69:69
                           ms_dest        ,  //68:64
                           ms_final_result,  //63:32
                           ms_pc             //31:0
                          };

    assign ms_to_fw_bus = {ms_dest, ms_reg_we};

    assign ms_to_es_bus = {ms_alu_result};

    assign ms_ready_go    = 1'b1;
    assign ms_allowin     = !ms_valid || ms_ready_go && ws_allowin;
    assign ms_to_ws_valid = ms_valid && ms_ready_go;
    always @(posedge clk) begin
        if (reset) begin
            ms_valid <= 1'b0;
        end
        else if (ms_allowin) begin
            ms_valid <= es_to_ms_valid;
        end

        if (reset) begin
            es_to_ms_bus_r <= 0;
        end
        if (es_to_ms_valid && ms_allowin) begin
            es_to_ms_bus_r  <= es_to_ms_bus;
        end
    end

    assign mem_result = (ms_load_op[0] || ms_load_op[3]) ? ((ms_alu_result[1:0] == 2'b00) ? {{24{ms_load_op[3] ? data_sram_rdata[ 7] : 1'b0 }}, data_sram_rdata[ 7:0]       } :
                                                            (ms_alu_result[1:0] == 2'b01) ? {{16{ms_load_op[3] ? data_sram_rdata[ 7] : 1'b0 }}, data_sram_rdata[ 7:0],  8'b0} :
                                                            (ms_alu_result[1:0] == 2'b10) ? {{ 8{ms_load_op[3] ? data_sram_rdata[ 7] : 1'b0 }}, data_sram_rdata[ 7:0], 16'b0} :
                                                                                            {                                                   data_sram_rdata[ 7:0], 24'b0}) :
                        (ms_load_op[1] || ms_load_op[4]) ? ((ms_alu_result[1:0] == 2'b00) ? {{16{ms_load_op[4] ? data_sram_rdata[15] : 1'b0 }}, data_sram_rdata[15:0]       } :
                                                                                            {                                                   data_sram_rdata[15:0], 16'b0}) :
                         ms_load_op[2]                   ? (                                                                                    data_sram_rdata              ) :
                                                             32'b0;

    assign ms_final_result = ms_mem_to_reg ? mem_result :
                             ms_div_op[0]  ? div_result :
                             ms_div_op[1]  ? mod_result :
                                             ms_alu_result;

endmodule
