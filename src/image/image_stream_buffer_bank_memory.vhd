-----------------------------------------------------------------------------------
--!     @file    image_stream_buffer_bank_memory.vhd
--!     @brief   Image Stream Buffer Bank Memory Module :
--!              異なる形のイメージストリームを継ぐためのバッファのバンク分割型メモ
--!              リモジュール
--!     @version 1.8.0
--!     @date    2019/2/1
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2018-2019 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief   Image Stream Buffer Bank Memory Module :
--!          異なる形のイメージストリームを継ぐためのバッファのバンク分割型メモ
--!          リモジュール
-----------------------------------------------------------------------------------
entity  IMAGE_STREAM_BUFFER_BANK_MEMORY is
    generic (
        I_PARAM         : --! @brief INPUT  STREAM PARAMETER :
                          --! 入力側のストリームのパラメータを指定する.
                          --! * I_PARAM.ELEM_BITS = O_PARAM.ELEM_BITS でなければならない.
                          --! * I_PARAM.INFO_BITS = 0 でなければならない.
                          --! * I_PARAM.SHAPE.D.SIZE = 1 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          --! * O_PARAM.ELEM_BITS = I_PARAM.ELEM_BITS でなければならない.
                          --! * O_PARAM.INFO_BITS = 0 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        CHANNEL_SIZE    : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! * チャネル数が可変の場合は 0 を指定する.
                          integer := 0;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        MAX_D_SIZE      : --! @brief MAX OUTPUT CHANNEL SIZE :
                          integer := 1;
        QUEUE_SIZE      : --! @brief OUTPUT QUEUE SIZE :
                          --! 出力キューの大きさをワード数で指定する.
                          --! * O_QUEUE_SIZE=0 の場合は出力にキューが挿入されずダイ
                          --!   レクトに出力される.
                          integer := 0;
        ID              : --! @brief SDPRAM IDENTIFIER :
                          --! どのモジュールで使われているかを示す識別番号.
                          integer := 0 
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK             : --! @brief CLOCK :
                          --! クロック信号
                          in  std_logic; 
        RST             : --! @brief ASYNCRONOUSE RESET :
                          --! 非同期リセット信号.アクティブハイ.
                          in  std_logic;
        CLR             : --! @brief SYNCRONOUSE RESET :
                          --! 同期リセット信号.アクティブハイ.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側 制御 I/F
    -------------------------------------------------------------------------------
        I_ENABLE        : --! @brief INPUT STREAM ENABLE :
                          in  std_logic;
        I_LINE_START    : --! @brief INPUT STREAM LINE START :
                          --  ラインの入力を開始することを示す.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_DONE     : --! @brief INPUT STREAM LINE DONE :
                          --  ラインの入力が終了したことを示す.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
    -------------------------------------------------------------------------------
    -- 入力側 ストリーム I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 制御 I/F
    -------------------------------------------------------------------------------
        O_LINE_START    : --! @brief OUTPUT LINE START :
                          --! ライン開始信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        O_LINE_ATRB     : --! @brief OUTPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to MAX_D_SIZE := 1;
    -------------------------------------------------------------------------------
    -- 出力側 ストリーム I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          in  std_logic
    );
end IMAGE_STREAM_BUFFER_BANK_MEMORY;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_BUFFER_BANK_MEMORY_WRITER;
use     PIPEWORK.IMAGE_COMPONENTS.IMAGE_STREAM_BUFFER_BANK_MEMORY_READER;
use     PIPEWORK.COMPONENTS.SDPRAM;
architecture RTL of IMAGE_STREAM_BUFFER_BANK_MEMORY is
    -------------------------------------------------------------------------------
    -- BUF_WIDTH : メモリのビット幅を２のべき乗値で示す
    -------------------------------------------------------------------------------
    function  CALC_BUF_WIDTH    return integer is
        variable width              :  integer;
    begin
        width := 0;
        while (2**width < (O_PARAM.SHAPE.C.SIZE * O_PARAM.ELEM_BITS)) loop
            width := width + 1;
        end loop;
        return width;
    end function;
    constant  BUF_WIDTH             :  integer := CALC_BUF_WIDTH;
    -------------------------------------------------------------------------------
    -- BUF_DEPTH: メモリバンク１つあたりの深さ(ビット単位)を２のべき乗値で示す
    -------------------------------------------------------------------------------
    function  CALC_BUF_DEPTH    return integer is
        variable size               :  integer;
        variable depth              :  integer;
    begin
        size  := ELEMENT_SIZE*O_PARAM.ELEM_BITS;
        size  := (size + BANK_SIZE - 1)/BANK_SIZE;
        depth := 0;
        while (2**depth < size) loop
            depth := depth + 1;
        end loop;
        return depth;
    end function;
    constant  BUF_DEPTH             :  integer := CALC_BUF_DEPTH;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  BUF_DATA_BITS         :  integer := 2**BUF_WIDTH;
    constant  BUF_ADDR_BITS         :  integer := BUF_DEPTH - BUF_WIDTH;
    constant  BUF_WENA_BITS         :  integer := 1;
    signal    buf_wdata             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
    signal    buf_waddr             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
    signal    buf_we                :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_WENA_BITS-1 downto 0);
    signal    buf_rdata             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
    signal    buf_raddr             :  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    x_size                :  integer range 0 to ELEMENT_SIZE;
    signal    c_size                :  integer range 0 to ELEMENT_SIZE;
    signal    c_offset              :  integer range 0 to 2**BUF_ADDR_BITS;
begin
    -------------------------------------------------------------------------------
    -- WRITER :
    -------------------------------------------------------------------------------
    WRITER: IMAGE_STREAM_BUFFER_BANK_MEMORY_WRITER   -- 
        generic map (                                -- 
            I_PARAM         => I_PARAM             , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE        , -- 
            CHANNEL_SIZE    => CHANNEL_SIZE        , --   
            BANK_SIZE       => BANK_SIZE           , --   
            LINE_SIZE       => LINE_SIZE           , --   
            BUF_ADDR_BITS   => BUF_ADDR_BITS       , --   
            BUF_DATA_BITS   => BUF_DATA_BITS         --   
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_ENABLE        => I_ENABLE            , -- In  :
            I_LINE_START    => I_LINE_START        , -- In  :
            I_LINE_DONE     => I_LINE_DONE         , -- Out :
            I_DATA          => I_DATA              , -- In  :
            I_VALID         => I_VALID             , -- In  :
            I_READY         => I_READY             , -- Out :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            X_SIZE          => x_size              , -- Out :
            C_SIZE          => c_size              , -- Out :
            C_OFFSET        => c_offset            , -- Out :
        ---------------------------------------------------------------------------
        -- バッファ I/F
        ---------------------------------------------------------------------------
            BUF_DATA        => buf_wdata           , -- Out :
            BUF_ADDR        => buf_waddr           , -- Out :
            BUF_WE          => buf_we                -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BUF_L:  for line in 0 to LINE_SIZE-1 generate
        B:  for bank in 0 to BANK_SIZE-1 generate
                constant  RAM_ID :  integer := ID + (line*BANK_SIZE)+bank;
                signal    wdata  :  std_logic_vector(BUF_DATA_BITS-1 downto 0);
                signal    waddr  :  std_logic_vector(BUF_ADDR_BITS-1 downto 0);
                signal    we     :  std_logic_vector(BUF_WENA_BITS-1 downto 0);
                signal    rdata  :  std_logic_vector(BUF_DATA_BITS-1 downto 0);
                signal    raddr  :  std_logic_vector(BUF_ADDR_BITS-1 downto 0);
            begin
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            wdata <= buf_wdata((line*BANK_SIZE+bank+1)*BUF_DATA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_DATA_BITS);
            waddr <= buf_waddr((line*BANK_SIZE+bank+1)*BUF_ADDR_BITS-1 downto (line*BANK_SIZE+bank)*BUF_ADDR_BITS);
            we    <= buf_we   ((line*BANK_SIZE+bank+1)*BUF_WENA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_WENA_BITS);
            raddr <= buf_raddr((line*BANK_SIZE+bank+1)*BUF_ADDR_BITS-1 downto (line*BANK_SIZE+bank)*BUF_ADDR_BITS);
            buf_rdata((line*BANK_SIZE+bank+1)*BUF_DATA_BITS-1 downto (line*BANK_SIZE+bank)*BUF_DATA_BITS) <= rdata;
            -----------------------------------------------------------------------
            --
            -----------------------------------------------------------------------
            RAM: SDPRAM                   -- 
                generic map (             -- 
                    DEPTH   => BUF_DEPTH, -- メモリの深さ(ビット単位)を2のべき乗値で指定する.
                    RWIDTH  => BUF_WIDTH, -- リードデータ(RDATA)の幅(ビット数)を2のべき乗値で指定する.
                    WWIDTH  => BUF_WIDTH, -- ライトデータ(WDATA)の幅(ビット数)を2のべき乗値で指定する.
                    WEBIT   => 0        , -- ライトイネーブル信号(WE)の幅(ビット数)を2のべき乗値で指定する.
                    ID      => RAM_ID     -- どのモジュールで使われているかを示す識別番号.
                )                         -- 
                port map (                -- 
                    WCLK    => CLK      , -- In  :
                    WE      => we       , -- In  : 
                    WADDR   => waddr    , -- In  : 
                    WDATA   => wdata    , -- In  : 
                    RCLK    => CLK      , -- In  :
                    RADDR   => raddr    , -- In  :
                    RDATA   => rdata      -- Out :
                );                        -- 
        end generate;
    end generate;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    READER: IMAGE_STREAM_BUFFER_BANK_MEMORY_READER   -- 
        generic map (                                -- 
            O_PARAM         => O_PARAM             , -- 
            ELEMENT_SIZE    => ELEMENT_SIZE        , --   
            CHANNEL_SIZE    => CHANNEL_SIZE        , --   
            BANK_SIZE       => BANK_SIZE           , --   
            LINE_SIZE       => LINE_SIZE           , --   
            MAX_D_SIZE      => MAX_D_SIZE          , --
            BUF_ADDR_BITS   => BUF_ADDR_BITS       , --   
            BUF_DATA_BITS   => BUF_DATA_BITS       , --
            QUEUE_SIZE      => QUEUE_SIZE            -- 
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- クロック&リセット信号
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- 入力側 I/F
        ---------------------------------------------------------------------------
            I_LINE_START    => O_LINE_START        , -- In  :
            I_LINE_ATRB     => O_LINE_ATRB         , -- In  :
            X_SIZE          => x_size              , -- In  :
            D_SIZE          => D_SIZE              , -- In  :
            C_SIZE          => c_size              , -- In  :
            C_OFFSET        => c_offset            , -- In  :
        ---------------------------------------------------------------------------
        -- 出力側 I/F
        ---------------------------------------------------------------------------
            O_DATA          => O_DATA              , -- Out :
            O_VALID         => O_VALID             , -- Out :
            O_READY         => O_READY             , -- Out :
        ---------------------------------------------------------------------------
        -- バッファメモリ I/F
        ---------------------------------------------------------------------------
            BUF_DATA        => buf_rdata           , -- In  :
            BUF_ADDR        => buf_raddr             -- Out :
        );
end RTL;
