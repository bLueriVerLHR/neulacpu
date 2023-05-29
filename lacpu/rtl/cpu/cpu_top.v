`include "mycpu.v"

module mycpu_top(
    input         clk,
    input         resetn,
    // inst sram interface
    output        inst_sram_en,
    output [ 3:0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    // data sram interface
    output        data_sram_en,
    output [ 3:0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    //div
    output [31:0] div_divisor_data,
    output        div_divisor_valid,
    input         div_divisor_ready,
    output [31:0] div_dividend_data,
    output        div_dividend_valid,
    input         div_dividend_ready,
    input         div_dout_valid,
    input  [63:0] div_dout_data,
    //divu
    output [31:0] divu_divisor_data,
    output        divu_divisor_valid,
    input         divu_divisor_ready,
    output [31:0] divu_dividend_data,
    output        divu_dividend_valid,
    input         divu_dividend_ready,
    input         divu_dout_valid,
    input  [63:0] divu_dout_data,
    // trace debug interface
    output [31:0] debug_wb_pc,
    output [ 3:0] debug_wb_rf_wen,
    output [ 4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);
    reg         reset;
    always @(posedge clk) reset <= ~resetn;

    wire         ds_allowin;
    wire         es_allowin;
    wire         ms_allowin;
    wire         ws_allowin;
    wire         fs_to_ds_valid;
    wire         ds_to_es_valid;
    wire         es_to_ms_valid;
    wire         ms_to_ws_valid;
    wire [`FS_TO_DS_BUS_WD -1:0] fs_to_ds_bus;
    wire [`DS_TO_ES_BUS_WD -1:0] ds_to_es_bus;
    wire [`ES_TO_MS_BUS_WD -1:0] es_to_ms_bus;
    wire [`MS_TO_WS_BUS_WD -1:0] ms_to_ws_bus;
    wire [`WS_TO_RF_BUS_WD -1:0] ws_to_rf_bus;
    wire [`BR_BUS_WD       -1:0] br_bus;
    wire [`DS_TO_FW_BUS_WD -1:0] ds_to_fw_bus;
    wire [`ES_TO_FW_BUS_WD -1:0] es_to_fw_bus;
    wire [`MS_TO_FW_BUS_WD -1:0] ms_to_fw_bus;
    wire [`FW_TO_ES_BUS_WD -1:0] fw_to_es_bus;
    wire [`MS_TO_ES_BUS_WD -1:0] ms_to_es_bus;
    wire [`WS_TO_ES_BUS_WD -1:0] ws_to_es_bus;
    wire [`DS_TO_LU_BUS_WD -1:0] ds_to_lu_bus;
    wire [`ES_TO_LU_BUS_WD -1:0] es_to_lu_bus;
    wire                         lu_to_es_bus;


    // IF stage
    if_stage if_stage(
        .clk            (clk            ),
        .reset          (reset          ),
        //allowin
        .ds_allowin     (ds_allowin     ),
        //brbus
        .br_bus         (br_bus         ),
        //outputs
        .fs_to_ds_valid (fs_to_ds_valid ),
        .fs_to_ds_bus   (fs_to_ds_bus   ),
        // inst sram interface
        .inst_sram_en   (inst_sram_en   ),
        .inst_sram_wen  (inst_sram_wen  ),
        .inst_sram_addr (inst_sram_addr ),
        .inst_sram_wdata(inst_sram_wdata),
        .inst_sram_rdata(inst_sram_rdata)
    );
    // ID stage
    id_stage id_stage(
        .clk            (clk            ),
        .reset          (reset          ),
        //allowin
        .es_allowin     (es_allowin     ),
        .ds_allowin     (ds_allowin     ),
        //from fs
        .fs_to_ds_valid (fs_to_ds_valid ),
        .fs_to_ds_bus   (fs_to_ds_bus   ),
        //to es
        .ds_to_es_valid (ds_to_es_valid ),
        .ds_to_es_bus   (ds_to_es_bus   ),
        //to rf: for write back
        .ws_to_rf_bus   (ws_to_rf_bus   ),
        //to fw
        .ds_to_fw_bus   (ds_to_fw_bus   ),
        //to lu
        .ds_to_lu_bus   (ds_to_lu_bus   )
    );
    // EXE stage
    exe_stage exe_stage(
        .clk            (clk            ),
        .reset          (reset          ),
        //allowin
        .ms_allowin     (ms_allowin     ),
        .es_allowin     (es_allowin     ),
        //from ds
        .ds_to_es_valid (ds_to_es_valid ),
        .ds_to_es_bus   (ds_to_es_bus   ),
        //to ms
        .es_to_ms_valid (es_to_ms_valid ),
        .es_to_ms_bus   (es_to_ms_bus   ),
        //from fw
        .fw_to_es_bus   (fw_to_es_bus   ),
        //to fw
        .es_to_fw_bus   (es_to_fw_bus   ),
        //from ms
        .ms_to_ds_bus   (ms_to_es_bus   ),
        //from ws
        .ws_to_ds_bus   (ws_to_es_bus   ),
        //to lu
        .es_to_lu_bus   (es_to_lu_bus   ),
        //from lu
        .lu_to_es_bus   (lu_to_es_bus   ),
        // data sram interface
        .data_sram_en   (data_sram_en   ),
        .data_sram_wen  (data_sram_wen  ),
        .data_sram_addr (data_sram_addr ),
        .data_sram_wdata(data_sram_wdata),
        //div
        .div_divisor_data   (div_divisor_data   ),
        .div_divisor_valid  (div_divisor_valid  ),
        .div_divisor_ready  (div_divisor_ready  ),
        .div_dividend_data  (div_dividend_data  ),
        .div_dividend_valid (div_dividend_valid ),
        .div_dividend_ready (div_dividend_ready ),
        .div_dout_valid     (div_dout_valid     ),
        .div_dout_data      (div_dout_data      ),
        //divu
        .divu_divisor_data  (divu_divisor_data  ),
        .divu_divisor_valid (divu_divisor_valid ),
        .divu_divisor_ready (divu_divisor_ready ),
        .divu_dividend_data (divu_dividend_data ),
        .divu_dividend_valid(divu_dividend_valid),
        .divu_dividend_ready(divu_dividend_ready),
        .divu_dout_valid    (divu_dout_valid    ),
        .divu_dout_data     (divu_dout_data     )
    );
    // MEM stage
    mem_stage mem_stage(
        .clk            (clk            ),
        .reset          (reset          ),
        //allowin
        .ws_allowin     (ws_allowin     ),
        .ms_allowin     (ms_allowin     ),
        //from es
        .es_to_ms_valid (es_to_ms_valid ),
        .es_to_ms_bus   (es_to_ms_bus   ),
        //to ws
        .ms_to_ws_valid (ms_to_ws_valid ),
        .ms_to_ws_bus   (ms_to_ws_bus   ),
        //to fs
        .br_bus         (br_bus         ),
        //from data-sram
        .data_sram_rdata(data_sram_rdata),
        //to fw
        .ms_to_fw_bus   (ms_to_fw_bus   ),
        //to es
        .ms_to_es_bus   (ms_to_es_bus   )
    );
    // WB stage
    wb_stage wb_stage(
        .clk            (clk            ),
        .reset          (reset          ),
        //allowin
        .ws_allowin     (ws_allowin     ),
        //from ms
        .ms_to_ws_valid (ms_to_ws_valid ),
        .ms_to_ws_bus   (ms_to_ws_bus   ),
        //to rf: for write back
        .ws_to_rf_bus   (ws_to_rf_bus   ),
        //to es
        .ws_to_es_bus   (ws_to_es_bus   ),
        //trace debug interface
        .debug_wb_pc      (debug_wb_pc      ),
        .debug_wb_rf_wen  (debug_wb_rf_wen  ),
        .debug_wb_rf_wnum (debug_wb_rf_wnum ),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

    // Forwarding
    forward forward(
        .clk            (clk         ),
        .reset          (reset       ),
        .ds_to_fw_bus   (ds_to_fw_bus),
        .es_to_fw_bus   (es_to_fw_bus),
        .ms_to_fw_bus   (ms_to_fw_bus),
        .fw_to_es_bus   (fw_to_es_bus)
    );
    //Loaduse
    loaduse loaduse(
        .ds_to_lu_bus   (ds_to_lu_bus),
        .es_to_lu_bus   (es_to_lu_bus),
        .lu_to_es_bus   (lu_to_es_bus)
    );

endmodule
