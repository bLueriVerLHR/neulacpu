`default_nettype wire

module axi_ctrl_v5
#(
    parameter TAG_WD       = 21,
    parameter INDEX_WD     = 64,
    parameter CACHELINE_WD = 512,
    parameter STAGE_WD     = 12
)
(
    input clk,
    input reset,

    // icache interface
    input                          icache_re,           // miss
    input      [31             :0] icache_raddr,         // miss_addr
    output reg [CACHELINE_WD -1:0] icache_cacheline_new,

    input                          icache_we,           // we_back
    input      [31             :0] icache_waddr,         // waddr
    input      [CACHELINE_WD -1:0] icache_cacheline_old, // wback

    output reg                     icache_refresh, 

    // dcache interface
    input                          dcache_re,           // miss
    input      [31             :0] dcache_raddr,         // miss_addr
    output reg [CACHELINE_WD -1:0] dcache_cacheline_new,

    input                          dcache_we,           // we_back
    input      [31             :0] dcache_waddr,         // waddr
    input      [CACHELINE_WD -1:0] dcache_cacheline_old, // wback
    
    output reg                     dcache_refresh,       // fin

    // uncache  interface
    input                          uncache_en,
    input      [3              :0] uncache_we,
    input      [31             :0] uncache_addr,
    input      [31             :0] uncache_wdata,
    output reg [31             :0] uncache_rdata,
    output reg                     uncache_refresh,

    //æ»çº¿ä¾§æ¥å?
    //è¯»å°å?ééä¿¡å·
    output reg [3 :0] arid,     //è¯»å°å?IDï¼ç¨æ¥æ å¿ä¸ç»åä¿¡å·
    output reg [31:0] araddr,   //è¯»å°å?ï¼ç»åºä¸æ¬¡åçªåä¼ è¾çè¯»å°å
    output reg [3 :0] arlen,    //çªåé¿åº¦ï¼ç»åºçªåä¼ è¾çæ¬¡æ°
    output reg [2 :0] arsize,   //çªåå¤§å°ï¼ç»åºæ¯æ¬¡çªåä¼ è¾çå­èæ?
    output reg [1 :0] arburst,  //çªåç±»å
    output reg [1 :0] arlock,   //æ»çº¿éä¿¡å·ï¼å¯æä¾æä½çåå­æ?
    output reg [3 :0] arcache,  //åå­ç±»åï¼è¡¨æä¸æ¬¡ä¼ è¾æ¯ææ ·éè¿ç³»ç»ç?
    output reg [2 :0] arprot,   //ä¿æ¤ç±»åï¼è¡¨æä¸æ¬¡ä¼ è¾çç¹æçº§åå®å¨ç­çº§
    output reg 		  arvalid,  //ææä¿¡å·ï¼è¡¨ææ­¤ééçå°å?æ§å¶ä¿¡å·ææ
    input  		      arready,  //è¡¨æ"ä»?"å¯ä»¥æ¥æ¶å°ååå¯¹åºçæ§å¶ä¿¡å·
    //è¯»æ°æ®é?éä¿¡å· 
    input      [3 :0] rid,      //è¯»ID tag
    input      [31:0] rdata,    //è¯»æ°æ?
    input      [1 :0] rresp,    //è¯»ååºï¼è¡¨æè¯»ä¼ è¾çç¶æ??
    input  		      rlast,    //è¡¨æè¯»çªåçæ?åä¸æ¬¡ä¼ è¾?
    input  		      rvalid,   //è¡¨ææ­¤é?éä¿¡å·ææ
    output reg		  rready,   //è¡¨æä¸»æºè½å¤æ¥æ¶è¯»æ°æ®åååºä¿¡æ¯
 
    //åå°å?ééä¿¡å· 
    output reg [3 :0] awid,     //åå°å?IDï¼ç¨æ¥æ å¿ä¸ç»åä¿¡å·
    output reg [31:0] awaddr,   //åå°å?ï¼ç»åºä¸æ¬¡åçªåä¼ è¾çåå°å
    output reg [3 :0] awlen,    //çªåé¿åº¦ï¼ç»åºçªåä¼ è¾çæ¬¡æ°
    output reg [2 :0] awsize,   //çªåå¤§å°ï¼ç»åºæ¯æ¬¡çªåä¼ è¾çå­èæ?
    output reg [1 :0] awburst,  //çªåç±»å
    output reg [1 :0] awlock,   //æ»çº¿éä¿¡å·ï¼å¯æä¾æä½çåå­æ?
    output reg [3 :0] awcache,  //åå­ç±»åï¼è¡¨æä¸æ¬¡ä¼ è¾æ¯ææ ·éè¿ç³»ç»ç?
    output reg [2 :0] awprot,   //ä¿æ¤ç±»åï¼è¡¨æä¸æ¬¡ä¼ è¾çç¹æçº§åå®å¨ç­çº§
    output reg 		  awvalid,  //ææä¿¡å·ï¼è¡¨ææ­¤ééçå°å?æ§å¶ä¿¡å·ææ
    input  		      awready,  //è¡¨æ"ä»?"å¯ä»¥æ¥æ¶å°ååå¯¹åºçæ§å¶ä¿¡å·
    //åæ°æ®é?éä¿¡å· 
    output reg [3 :0] wid,      //ä¸?æ¬¡åä¼ è¾çID tag
    output reg [31:0] wdata,    //åæ°æ?
    output reg [3 :0] wstrb,    //åæ°æ®ææçå­èçº¿ï¼ç¨æ¥è¡¨æå?8bitsæ°æ®æ¯ææç
    output reg 		  wlast,    //è¡¨ææ­¤æ¬¡ä¼ è¾æ¯æåä¸ä¸ªçªåä¼ è¾?
    output reg		  wvalid,   //åææï¼è¡¨ææ­¤æ¬¡åææ?
    input  		      wready,   //è¡¨æä»æºå¯ä»¥æ¥æ¶åæ°æ?
    //åååºé?éä¿¡å·
    input      [3 :0] bid,      //åååºID tag
    input      [1 :0] bresp,    //åååºï¼è¡¨æåä¼ è¾çç¶æ?? 00ä¸ºæ­£å¸¸ï¼å½ç¶å¯ä»¥ä¸çä¼?
    input  		      bvalid,   //åååºææ?
    output reg        bready    //è¡¨æä¸»æºè½å¤æ¥æ¶åååº?

);
    reg [CACHELINE_WD -1:0] icache_rdata_buffer;
    reg [CACHELINE_WD -1:0] icache_wdata_buffer;
    reg [CACHELINE_WD -1:0] dcache_rdata_buffer;
    reg [CACHELINE_WD -1:0] dcache_wdata_buffer;
    reg [31             :0] icache_raddr_buffer;
    reg [31             :0] icache_waddr_buffer;
    reg [31             :0] dcache_raddr_buffer;
    reg [31             :0] dcache_waddr_buffer;
    reg [3              :0] icache_offset;
    reg [3              :0] dcache_offset;
    reg [3              :0] dcache_offset_w;
    reg                     icache_re_buffer;
    reg                     dcache_re_buffer;
    reg                     icache_we_buffer;
    reg                     dcache_we_buffer;

    reg                     uncache_en_buffer;
    reg [3              :0] uncache_we_buffer;
    reg [31             :0] uncache_addr_buffer;
    reg [31             :0] uncache_wdata_buffer; 
    reg [31             :0] uncache_rdata_buffer;

    reg [STAGE_WD     -1:0] stage;
    reg [STAGE_WD     -1:0] stage_w;

    always @(posedge clk) begin
        if(reset) begin
            arid <= 4'b0000;
            araddr <= 32'b0;
            arlen <= 4'b0000;
            arsize <= 3'b010;
            arburst <= 2'b01;
            arlock <= 2'b00;
            arcache <= 4'b0000;
            arprot <= 3'b000;
            arvalid <= 1'b0;

            rready <= 1'b0;
            
            stage                <= {{(STAGE_WD-1){1'b0}}, 1'b1};

            icache_refresh       <= 0;
            dcache_refresh       <= 0;
            icache_cacheline_new <= 0;
            dcache_cacheline_new <= 0;

            uncache_refresh <= 1'b0;
            uncache_rdata   <= 32'b0;
        end
        else begin
            case (1'b1)
                stage[0]: begin
                    icache_refresh  <= 1'b0;
                    dcache_refresh  <= 1'b0;
                    uncache_refresh <= 1'b0;

                    icache_re_buffer   <= icache_re;
                    icache_raddr_buffer <= icache_raddr;
                    icache_we_buffer    <= icache_we;
                    icache_waddr_buffer <= icache_waddr;
                    
                    dcache_re_buffer   <= dcache_re;
                    dcache_raddr_buffer <= dcache_raddr;
                    dcache_we_buffer    <= dcache_we;
                    dcache_waddr_buffer <= dcache_waddr;

                    uncache_en_buffer    <= uncache_en;
                    uncache_we_buffer    <= uncache_we;
                    uncache_addr_buffer  <= uncache_addr;
                    uncache_wdata_buffer <= uncache_wdata;

                    if (dcache_we|(uncache_en&((|uncache_we)))) begin
                        stage <= stage << 1;    
                    end
                    else if (icache_re|dcache_re|(uncache_en&~(|uncache_we))) begin
                        stage <= stage << 2;
                    end
                end
                stage[1]: begin
                    icache_wdata_buffer <= icache_cacheline_old;
                    dcache_wdata_buffer <= dcache_cacheline_old;
                    if (icache_re_buffer|dcache_re_buffer|(uncache_en_buffer&~(|uncache_we_buffer))) begin
                        stage <= stage << 1;
                    end
                    else begin
                        stage <= {1'b0,1'b1,10'b0};
                    end
                end
                stage[2]:begin
                    if (icache_re_buffer) begin
                        arid    <= 4'b0;
                        araddr  <= icache_raddr_buffer;
                        arlen   <= 4'hf;
                        arsize  <= 3'b010;
                        arvalid <= 1'b1;

                        stage   <= stage << 1;
                    end
                    else begin
                        stage   <= stage << 3;
                    end
                end
                stage[3]:begin
                    if (arready) begin
                        arvalid       <= 1'b0;
                        araddr        <= 32'b0;
                        rready        <= 1'b1;
                        icache_offset <= 4'd0;
                        stage         <= stage << 1;
                    end
                end
                stage[4]:begin
                    if (!rlast&rvalid) begin
                        icache_rdata_buffer[icache_offset*32+:32] <= rdata;
                        icache_offset <= icache_offset + 1'b1;
                    end
                    else if(rlast&rvalid) begin
                        icache_rdata_buffer[icache_offset*32+:32] <= rdata;
                        rready <= 1'b0;
                        stage  <= stage << 1;
                    end
                end
                stage[5]:begin
                    if (dcache_re_buffer) begin
                        arid    <= 4'b1;
                        araddr  <= dcache_raddr_buffer;
                        arlen   <= 4'hf;
                        arsize  <= 3'b010;
                        arvalid <= 1'b1;

                        stage <= stage << 1;
                    end
                    else if (uncache_en_buffer&~(|uncache_we_buffer)) begin
                        arid <= 4'b1;
                        araddr <= uncache_addr_buffer;
                        arlen <= 4'b0;
                        arsize <= 3'b010;
                        arvalid <= 1'b1;
                        stage <= stage << 3;
                    end
                    else begin
                        stage <= {1'b0,1'b1,10'b0};
                    end
                end
                stage[6]:begin
                    if (arready) begin
                        arvalid       <= 1'b0;
                        araddr        <= 32'b0;
                        rready        <= 1'b1;
                        dcache_offset <= 4'd0;
                        stage         <= stage << 1;
                    end
                end
                stage[7]:begin
                    if (!rlast&rvalid) begin
                        dcache_rdata_buffer[dcache_offset*32+:32] <= rdata;
                        dcache_offset <= dcache_offset + 1'b1;
                    end
                    else if (rlast&rvalid) begin
                        dcache_rdata_buffer[dcache_offset*32+:32] <= rdata;
                        rready <= 1'b0;
                        stage  <= {1'b0,1'b1,10'b0};
                    end
                end
                stage[8]:begin
                    if (arready) begin
                        arvalid <= 1'b0;
                        araddr  <= 32'b0;
                        rready  <= 1'b1;
                        stage   <= stage << 1;
                    end
                end
                stage[9]:begin
                    if (rvalid) begin
                        uncache_rdata_buffer <= rdata;
                        rready <= 1'b0;
                        stage  <= {1'b0,1'b1,10'b0};
                    end
                end
                stage[10]:begin
                    if (stage_w[10]|stage_w[0]) begin
                        stage <= stage << 1;
                    end
                end
                stage[11]:begin
                    if (icache_re_buffer) begin
                        icache_refresh <= 1'b1;
                        icache_cacheline_new <= icache_rdata_buffer;
                    end
                    if (dcache_re_buffer) begin
                        dcache_refresh <= 1'b1;
                        dcache_cacheline_new <= dcache_rdata_buffer;
                    end
                    if (uncache_en_buffer) begin
                        uncache_refresh <= 1'b1;   
                        uncache_rdata <= uncache_rdata_buffer;
                    end
                    stage <= 0;
                end
                default:begin
                    stage          <= {{(STAGE_WD-1){1'b0}}, 1'b1};
                    icache_refresh <= 1'b0;
                    dcache_refresh <= 1'b0;
                    uncache_refresh <= 1'b0;
                end
            endcase
        end
    end

    always @ (posedge clk) begin
        if (reset) begin
            awid    <= 4'b0001;
            awaddr  <= 32'b0;
            awlen   <= 4'b0000;
            awsize  <= 3'b010;
            awburst <= 2'b01;
            awlock  <= 2'b00;
            awcache <= 4'b0000;
            awprot  <= 3'b000;
            awvalid <= 1'b0;

            wid    <= 4'b0001;
            wdata  <= 32'b0;
            wstrb  <= 4'b0000;
            wlast  <= 1'b0;
            wvalid <= 1'b0;

            bready <= 1'b0;
            
            stage_w <= {{(STAGE_WD-1){1'b0}}, 1'b1};
        end
        else begin
            case (1'b1)
                stage_w[0]:begin
                    if (stage[1]) begin
                        if (dcache_we_buffer) begin
                            awid <= 4'b1;
                            awaddr <= dcache_waddr_buffer;
                            awlen <= 4'hf;
                            awsize <= 3'b010;
                            awvalid <= 1'b1;
                            wstrb <= 4'b1111;
                            wlast <= 1'b0;
                            bready <= 1'b1;
                            dcache_offset_w <= 4'b0;
                            stage_w <= stage_w << 1;
                        end
                        else if (|uncache_we_buffer) begin // write
                            awid <= 4'b1;
                            awaddr <= uncache_addr_buffer;
                            awlen <= 4'b0;
                            case (uncache_we_buffer)
                                4'b0001,4'b0010,4'b0100,4'b1000:begin
                                    awsize <= 3'b000; 
                                    wstrb <= uncache_we_buffer;       
                                end
                                4'b0011,4'b1100:begin
                                    awsize <= 3'b001;
                                    wstrb <= uncache_we_buffer;
                                end
                                4'b1111:begin
                                    awsize <= 3'b010;
                                    wstrb <= uncache_we_buffer;
                                end
                                default:begin
                                    awsize <= 3'b010;
                                    wstrb <= uncache_we_buffer;
                                end
                            endcase
                            awvalid <= 1'b1;
                            wlast <= 1'b0;
                            bready <= 1'b1;
                            stage_w <= stage_w << 4;
                        end
                    end
                end
                stage_w[1]:begin
                    if (awready) begin
                        awvalid <= 1'b0;
                        awaddr <= 32'b0;
                        wdata <= dcache_wdata_buffer[dcache_offset_w*32+:32];
                        wvalid <= 1'b1;
                        wlast <= dcache_offset_w == 4'b1111 ? 1'b1 : 1'b0;
                        dcache_offset_w <= dcache_offset_w + 1'b1;
                        if (dcache_offset_w == 4'b1111) begin
                            stage_w <= stage_w << 1;
                        end
                    end
                    else if (wready) begin
                        wdata <= dcache_wdata_buffer[dcache_offset_w*32+:32];
                        wvalid <= 1'b1;
                        wlast <= dcache_offset_w == 4'b1111 ? 1'b1 : 1'b0;
                        dcache_offset_w <= dcache_offset_w + 1'b1;
                        if (dcache_offset_w == 4'b1111) begin
                            stage_w <= stage_w << 1;
                        end
                    end
                end
                stage_w[2]:begin
                    if (wready) begin
                        wdata <= 32'b0;
                        wvalid <= 1'b0;    
                        wlast <= 1'b0;
                        stage_w <= stage_w << 1;
                    end
                end
                stage_w[3]:begin
                    if (bvalid) begin
                        bready <= 1'b0;
                        stage_w <= {1'b0,1'b1,{10{1'b0}}};
                    end
                end
                stage_w[4]:begin
                    if (awready) begin
                        awvalid <= 1'b0;
                        awaddr <= 32'b0;
                        wdata <= uncache_wdata_buffer;
                        wvalid <= 1'b1;
                        wlast <= 1'b1;
                        stage_w <= stage_w << 1;
                    end
                end
                stage_w[5]:begin
                    if (wready) begin
                        wdata <= 32'b0;
                        wvalid <= 1'b0;
                        wlast <= 1'b0;
                        stage_w <= stage_w << 1;
                    end
                end
                stage_w[6]:begin
                    if (bvalid) begin
                        bready <= 1'b0;
                        stage_w <= {1'b0,1'b1,{10{1'b0}}};
                    end
                end
                stage_w[10]:begin
                    if (stage[11]) begin
                        stage_w <= {{(STAGE_WD-1){1'b0}}, 1'b1};    
                    end
                end
                default:begin
                    stage_w <= {{(STAGE_WD-1){1'b0}}, 1'b1};
                end
            endcase
        end
    end

endmodule