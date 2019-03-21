-----------------------------------------------------------------------------------
--!     @file    image_components.vhd                                            --
--!     @brief   PIPEWORK IMAGE COMPONENTS LIBRARY DESCRIPTION                   --
--!     @version 1.8.0                                                           --
--!     @date    2019/03/21                                                      --
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>                     --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--                                                                               --
--      Copyright (C) 2019 Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>           --
--      All rights reserved.                                                     --
--                                                                               --
--      Redistribution and use in source and binary forms, with or without       --
--      modification, are permitted provided that the following conditions       --
--      are met:                                                                 --
--                                                                               --
--        1. Redistributions of source code must retain the above copyright      --
--           notice, this list of conditions and the following disclaimer.       --
--                                                                               --
--        2. Redistributions in binary form must reproduce the above copyright   --
--           notice, this list of conditions and the following disclaimer in     --
--           the documentation and/or other materials provided with the          --
--           distribution.                                                       --
--                                                                               --
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      --
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        --
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR    --
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT    --
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,    --
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT         --
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,    --
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY    --
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      --
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE    --
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.     --
--                                                                               --
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library PIPEWORK;
use     PIPEWORK.IMAGE_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief PIPEWORK IMAGE COMPONENTS LIBRARY DESCRIPTION                         --
-----------------------------------------------------------------------------------
package IMAGE_COMPONENTS is
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_ATRB_GENERATOR                                           --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_ATRB_GENERATOR
    generic (
        ATRB_SIZE       : --! @brief ATTRIBUTE VECTOR SIZE :
                          integer := 1;
        STRIDE          : --! @brief STRIDE SIZE SIZE :
                          integer := 1;
        MAX_SIZE        : --! @brief MAX SIZE :
                          integer := 8;
        MAX_START_BORDER: --! @brief MAX START BORDER SIZE :
                          integer := 0;
        MAX_LAST_BORDER : --! @brief MAX LAST  BORDER SIZE :
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
    -- 入力 I/F
    -------------------------------------------------------------------------------
        LOAD            : --! @brief LOAD :
                          in  std_logic;
        CHOP            : --! @brief COUNT ENABLE :
                          in  std_logic;
        SIZE            : --! @brief SIZE :
                          in  integer range 0 to MAX_SIZE;
        START_BORDER    : --! @brief START BORDER SIZE :
                          in  integer range 0 to MAX_START_BORDER := 0;
        LAST_BORDER     : --! @brief LAST  BORDER SIZE :
                          in  integer range 0 to MAX_LAST_BORDER  := 0;
    -------------------------------------------------------------------------------
    -- 出力 I/F
    -------------------------------------------------------------------------------
        ATRB            : --! @brief OUTPUT ATTRIBUTE VECTOR:
                          --! 属性出力.
                          out IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        START           : --! @brief OUTPUT START :
                          --! 現在の出力が最初の出力であることを示す.
                          out std_logic;
        LAST            : --! @brief OUTPUT LAST :
                          --! 現在の出力が最後の出力であることを示す.
                          out std_logic;
        TERM            : --! @brief OUTPUT TERMINATE :
                          --! 現在の最終位置が負になっていることを示す.
                          out std_logic;
        NEXT_ATRB       : --! @brief OUTPUT ATTRIBUTE VECTOR(NEXT CYCLE) :
                          --! 次のクロックでの属性出力.
                          out IMAGE_STREAM_ATRB_VECTOR(0 to ATRB_SIZE-1);
        NEXT_START      : --! @brief OUTPUT START(NEXT CYCLE) :
                          --! 次のクロックでの出力が最初の出力であることを示す.
                          out std_logic;
        NEXT_LAST       : --! @brief OUTPUT LAST(NEXT_CYCLE) :
                          --! 次のクロックでの出力が最後の出力であることを示す.
                          out std_logic;
        NEXT_TERM       : --! @brief OUTPUT TERMINATE(NEXT_CYCLE) :
                          --! 次のクロックでの最終位置が負になっていることを示す.
                          out std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_GENERATOR                                                --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_GENERATOR
    generic (
        O_PARAM         : --! @brief OUTPUT IMAGE STREAM PARAMETER :
                          --! 出力側イメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(32,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE PARAMETER :
                          IMAGE_SHAPE_TYPE        := NEW_IMAGE_SHAPE_CONSTANT(32,1,1,1);
                          --! 出力側イメージストリームのパラメータを指定する.
        I_DATA_BITS     : --! @brief INPUT  STREAM DATA BIT SIZE :
                          --! 入力側のデータのビット幅を指定する.
                          --! * I_DATA_BITS = O_PARAM.DATA.ELEM_FIELD.SIZE でなけれ
                          --!   ばならない.
                          integer := 32
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
    -- SHAPE SIZE I/F
    -------------------------------------------------------------------------------
        START           : --! @brief STREAM START :
                          in  std_logic;
        BUSY            : --! @brief STREAM BUSY :
                          out std_logic;
        DONE            : --! @brief STREAM DONE :
                          out std_logic;
        C_SIZE          : --! @brief INPUT SHAPE.C SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        D_SIZE          : --! @brief INPUT SHAPE.D SIZE :
                          in  integer range 0 to O_SHAPE.D.MAX_SIZE := O_SHAPE.D.SIZE;
        X_SIZE          : --! @brief INPUT SHAPE.X SIZE :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        Y_SIZE          : --! @brief INPUT SHAPE.Y SIZE :
                          in  integer range 0 to O_SHAPE.Y.MAX_SIZE := O_SHAPE.Y.SIZE;
    -------------------------------------------------------------------------------
    -- STREAM 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_DATA_BITS    -1 downto 0);
        I_VALID         : --! @brief INPUT STREAM VALID :
                          --! 入力ストリムーデータ有効信号.
                          --! I_DATA/I_STRB/I_LAST が有効であることを示す.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM READY :
                          --! 入力ストリムーデータレディ信号.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- IMAGE STREAM 出力側 I/F
    -------------------------------------------------------------------------------
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! イメージストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力イメージストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力イメージストリームデータレディ信号.
                          in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_CHANNEL_REDUCER                                          --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_CHANNEL_REDUCER
    generic (
        I_PARAM         : --! @brief INPUT  STREAM PARAMETER :
                          --! 入力側のイメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のイメージストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        C_SIZE          : --! @brief CHANNEL SIZE :
                          --! チャネル数を指定する.
                          --! * C_SIZE に 0 を指定すると I_PARAM.SHAPE.C.SIZE と
                          --!   O_PARAM.SHAPE.C.SIZE の最大公約数がチャネル数に設定
                          --!   される.
                          --! * C_SIZE に 1 以上を指定した場合、チャネル数は C_SIZE
                          --!   の値に設定される. ただし、C_SIZE は I_PARAM.SHAPE.C.SIZE
                          --!   と O_PARAM.SHAPE.C.SIZE の最大公約数でなければならない.
                          --!   C_SIZE が I_PARAM.SHAPE.C.SIZE と O_PARAM.SHAPE.C.SIZE
                          --!   の最大公約数でない場合はチャネル数は 1 に設定される.
                          integer := 0;
        C_DONE          : --! @brief CHANNEL DONE MODE :
                          --! キューに入れるデータをチャネル毎に区切るか否かを指定する.
                          --! * C_DONE = 0 を指定すると、データは区切りなく入力する
                          --!   事ができる.但し、出力側でチャネルの区切って出力する
                          --!   ので回路が少し増える.
                          --! * C_DONE = 1 を指定すると、チャネルの最後のデータが入
                          --!   力されると、キューに残っているデータを掃き出すまで、
                          --!   一旦、データの入力を停止する.
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
    -- 各種制御信号
    -------------------------------------------------------------------------------
        START           : --! @brief START :
                          --! 開始信号.
                          --! * 最初にデータ入力と同時にアサートしても構わない.
                          in  std_logic := '0';
        DONE            : --! @brief DONE :
                          --! 終了信号.
                          --! * この信号をアサートすることで、キューに残っているデータ
                          --!   を掃き出す.
                          in  std_logic := '0';
        BUSY            : --! @brief BUSY :
                          --! ビジー信号.
                          --! * 最初にデータが入力されたときにアサートされる.
                          --! * 最後のデータが出力し終えたらネゲートされる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_ENABLE        : --! @brief INPUT ENABLE :
                          --! 入力許可信号.
                          --! * この信号がアサートされている場合、キューの入力を許可する.
                          --! * この信号がネゲートされている場合、I_READY はアサートされない.
                          in  std_logic := '1';
        I_DATA          : --! @brief INPUT IMAGE STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_DONE          : --! @brief INPUT IMAGE STREAM DONE :
                          --! 最終ストリーム信号入力.
                          --! * 最後のストリームデータ入力であることを示すフラグ.
                          --! * 基本的にはDONE信号と同じ働きをするが、I_DONE信号は
                          --!   最後のストリームデータを入力する際に同時にアサートする.
                          --! * 最後のストリームデータ入力は必ず最後のチャネルを含んで
                          --!   いなければならない.
                          in  std_logic := '0';
        I_VALID         : --! @brief INPUT IMAGE STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT IMAGE STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_ENABLE        : --! @brief OUTPUT ENABLE :
                          --! 出力許可信号.
                          --! * この信号がアサートされている場合、キューの出力を許可する.
                          --! * この信号がネゲートされている場合、O_VALID はアサートされない.
                          in  std_logic := '1';
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_DONE          : --! @brief OUTPUT IMAGE STREAM DONE :
                          --! 最終ストリーム信号出力.
                          --! * 最後のストリーム出力であることを示すフラグ.
                          out std_logic;
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でストリームデータがキュー
                          --!   から取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          --! * キューから次のストリームデータを取り除く準備が出来て
                          --!   いることを示す.
                          --! * O_VALID='1'and O_READY='1'でストリームデータがキュー
                          --!   から取り除かれる.
                          in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER                                                   --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER
    generic (
        I_PARAM         : --! @brief INPUT  IMAGE STREAM PARAMETER :
                          --! 入力側のイメージストリームのパラメータを指定する.
                          --! * I_PARAM.ELEM_BITS = O_PARAM.ELEM_BITS でなければならない.
                          --! * I_PARAM.INFO_BITS = 0 でなければならない.
                          --! * I_PARAM.SHAPE.D.SIZE = 1 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT IMAGE STREAM PARAMETER :
                          --! 出力側のイメージストリームのパラメータを指定する.
                          --! * O_PARAM.ELEM_BITS = I_PARAM.ELEM_BITS でなければならない.
                          --! * O_PARAM.INFO_BITS = 0 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 出力側のイメージの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向の要素数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 0;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
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
    -- 
    -------------------------------------------------------------------------------
        C_SIZE          : --! @brief OUTPUT C CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        D_SIZE          : --! @brief OUTPUT D CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.D.MAX_SIZE := O_SHAPE.D.SIZE;
        X_SIZE          : --! @brief OUTPUT X SIZE :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        Y_SIZE          : --! @brief OUTPUT Y SIZE :
                          in  integer range 0 to O_SHAPE.Y.MAX_SIZE := O_SHAPE.Y.SIZE;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT IMAGE STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT IMAGE STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT IMAGE STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_RETURN        : --! @brief OUTPUT RETURN :
                          --! 再出力要求信号.
                          --! * O_RETURN='0'の時、ラインの最後のストリームデータが
                          --!   出力された後、O_PARAM.STRIDE.Y で指定された値の分だ
                          --!   けラインを FEED する.
                          --! * O_RETURN='1'の時、ラインの最後のストリームデータが
                          --!   出力された後、ラインバッファの内容を再度出力する.
                          in  std_logic := '0';
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATA が有効であることを示す.
                          --! * O_VALID='1'and O_READY='1'でストリームデータがキュー
                          --!   から取り除かれる.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          --! * キューから次のストリームデータを取り除く準備が出来て
                          --!   いることを示す.
                          --! * O_VALID='1'and O_READY='1'でストリームデータがキュー
                          --!   から取り除かれる.
                          in  std_logic
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER_BANK_MEMORY                                       --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER_BANK_MEMORY
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
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 出力側のイメージの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
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
        C_SIZE          : --! @brief OUTPUT C CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        D_SIZE          : --! @brief OUTPUT D CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.D.MAX_SIZE := O_SHAPE.D.SIZE;
        X_SIZE          : --! @brief OUTPUT X SIZE :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
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
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER_BANK_MEMORY_WRITER                                --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER_BANK_MEMORY_WRITER
    generic (
        I_PARAM         : --! @brief INPUT  STREAM PARAMETER :
                          --! 入力側のストリームのパラメータを指定する.
                          --! * I_PARAM.SHAPE.D.SIZE = 1 でなければならない.
                          --! * I_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        I_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 入力側のイメージの形(SHAPE)を指定する.
                          --! * このモジュールでは I_SHAPE.C のみを使用する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        BUF_ADDR_BITS   : --! メモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! メモリのデータのビット幅を指定する.
                          integer := 8
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_ENABLE        : --! @brief INPUT STREAM ENABLE :
                          in  std_logic;
        I_LINE_START    : --! @brief INPUT STREAM LINE START :
                          --  ラインの入力を開始することを示す.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_DONE     : --! @brief INPUT STREAM LINE DONE :
                          --  ラインの入力が終了したことを示す.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
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
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_OFFSET      : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- バッファ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE              -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER_BANK_MEMORY_READER                                --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER_BANK_MEMORY_READER
    generic (
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          --! * O_PARAM.ELEM_BITS = I_PARAM.ELEM_BITS でなければならない.
                          --! * O_PARAM.INFO_BITS = 0 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 出力側のイメージの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8;
        QUEUE_SIZE      : --! @brief OUTPUT QUEUE SIZE :
                          --! 出力キューの大きさをワード数で指定する.
                          --! * QUEUE_SIZE=0 の場合は出力にキューが挿入されずダイレ
                          --!   クトに出力される.
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_START    : --! @brief INPUT LINE START :
                          --! ライン開始信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.D.MAX_SIZE := O_SHAPE.D.SIZE;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
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
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER_INTAKE                                            --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER_INTAKE
    generic (
        I_PARAM         : --! @brief INPUT  IMAGE STREAM PARAMETER :
                          --! 入力側のイメージストリームのパラメータを指定する.
                          --! * I_PARAM.INFO_BITS = 0 でなければならない.
                          --! * I_PARAM.SHAPE.D.SIZE = 1 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        I_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 入力側のイメージの形(SHAPE)を指定する.
                          --! * このモジュールでは I_SHAPE.C のみを使用する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT IMAGE STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT IMAGE STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT IMAGE STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
    -------------------------------------------------------------------------------
        O_LINE_VALID    : --! @brief OUTPUT LINE VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_X_SIZE        : --! @brief OUTPUT X SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_SIZE        : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to ELEMENT_SIZE;
        O_C_OFFSET      : --! @brief OUTPUT CHANNEL SIZE :
                          out integer range 0 to 2**BUF_ADDR_BITS;
        O_LINE_ATRB     : --! @brief OUTPUT LINE ATTRIBUTE :
                          --! ライン属性出力.
                          out IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        O_LINE_FEED     : --! @brief OUTPUT LINE FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        O_LINE_RETURN   : --! @brief OUTPUT LINE RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER WRITE DATA :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0);
        BUF_WE          : --! @brief BUFFER WRITE ENABLE :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE              -1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER_INTAKE_LINE_SELECTOR                              --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER_INTAKE_LINE_SELECTOR
    generic (
        I_PARAM         : --! @brief INPUT  STREAM PARAMETER :
                          --! 入力側のストリームのパラメータを指定する.
                          --! * I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          --! * I_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * I_PARAM.SHAPE.C.SIZE = O_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.D.SIZE = O_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.X.SIZE = O_PARAM.SHAPE.X.SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          --! * O_PARAM.ELEM_SIZE    = I_PARAM.ELEM_SIZE    でなければならない.
                          --! * O_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * O_PARAM.SHAPE.C.SIZE = I_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.D.SIZE = I_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.X.SIZE = I_PARAM.SHAPE.X.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        QUEUE_SIZE      : --! @brief OUTPUT QUEUE SIZE :
                          --! 出力キューの大きさをワード数で指定する.
                          --! * QUEUE_SIZE=0 の場合は出力にキューが挿入されずダイレ
                          --!   クトに出力される.
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 Stream I/F
    -------------------------------------------------------------------------------
        O_ENABLE        : --! @brief OUTPUT ENABLE :
                          --! 出力許可信号.
                          out std_logic;
        O_LINE_START    : --! @brief OUTPUT LINE VALID :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        O_LINE_DONE     : --! @brief OUTPUT LINE DONE :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        O_DATA          : --! @brief OUTPUT IMAGE STREAM DATA :
                          --! ストリームデータ出力.
                          out std_logic_vector(O_PARAM.DATA.SIZE-1 downto 0);
        O_VALID         : --! @brief OUTPUT IMAGE STREAM DATA VALID :
                          --! 出力ストリームデータ有効信号.
                          --! * O_DATAが有効であることを示す.
                          out std_logic;
        O_READY         : --! @brief OUTPUT IMAGE STREAM DATA READY :
                          --! 出力ストリームデータレディ信号.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- ライン制御 I/F
    -------------------------------------------------------------------------------
        LINE_VALID      : --! @brief OUTPUT LINE VALID :
                          --! ライン出力有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        LINE_ATRB       : --! @brief OUTPUT LINE ATTRIBUTE :
                          --! ライン属性出力.
                          out IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        LINE_FEED       : --! @brief OUTPUT LINE FEED :
                          --! 出力終了信号.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        LINE_RETURN     : --! @brief OUTPUT LINE RETURN :
                          --! 再出力要求信号.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          in  std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0')
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER_OUTLET                                            --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER_OUTLET
    generic (
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 出力側のストリームのパラメータを指定する.
                          --! * O_PARAM.INFO_BITS = 0 でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_SHAPE         : --! @brief OUTPUT IMAGE SHAPE :
                          --! 出力側のイメージの形(SHAPE)を指定する.
                          IMAGE_SHAPE_TYPE := NEW_IMAGE_SHAPE_CONSTANT(8,1,1,1,1);
        ELEMENT_SIZE    : --! @brief ELEMENT SIZE :
                          --! 列方向のエレメント数を指定する.
                          integer := 256;
        BANK_SIZE       : --! @brief MEMORY BANK SIZE :
                          --! メモリのバンク数を指定する.
                          integer := 1;
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        BUF_ADDR_BITS   : --! バッファメモリのアドレスのビット幅を指定する.
                          integer := 8;
        BUF_DATA_BITS   : --! バッファメモリのデータのビット幅を指定する.
                          integer := 8
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
    -- 各種サイズ
    -------------------------------------------------------------------------------
        X_SIZE          : --! @brief INPUT X SIZE :
                          in  integer range 0 to O_SHAPE.X.MAX_SIZE := O_SHAPE.X.SIZE;
        D_SIZE          : --! @brief OUTPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.D.MAX_SIZE := O_SHAPE.D.SIZE;
        C_SIZE          : --! @brief INPUT CHANNEL SIZE :
                          in  integer range 0 to O_SHAPE.C.MAX_SIZE := O_SHAPE.C.SIZE;
        C_OFFSET        : --! @brief OUTPUT CHANNEL BUFFER ADDRESS OFFSET :
                          in  integer range 0 to 2**BUF_ADDR_BITS;
    -------------------------------------------------------------------------------
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_VALID    : --! @brief INPUT LINE VALID :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        I_LINE_ATRB     : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        I_LINE_FEED     : --! @brief INPUT LINE FEED :
                          --! ラインフィード信号出力.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '1');
        I_LINE_RETURN   : --! @brief INPUT LINE RETURN :
                          --! ラインリターン信号出力.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          out std_logic_vector(LINE_SIZE-1 downto 0) := (others => '0');
    -------------------------------------------------------------------------------
    -- 出力側 I/F
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
                          in  std_logic;
        O_LAST          : --! @brief OUTPUT LINE FEED :
                          --! 最終ストリーム入力.
                          in  std_logic;
        O_FEED          : --! @brief OUTPUT LINE FEED :
                          --! ラインフィード入力.
                          in  std_logic;
        O_RETURN        : --! @brief OUTPUT LINE RETURN :
                          --! ラインリターン入力.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- バッファメモリ I/F
    -------------------------------------------------------------------------------
        BUF_DATA        : --! @brief BUFFER READ DATA :
                          in  std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_DATA_BITS-1 downto 0);
        BUF_ADDR        : --! @brief BUFFER WRITE ADDRESS :
                          out std_logic_vector(LINE_SIZE*BANK_SIZE*BUF_ADDR_BITS-1 downto 0)
    );
end component;
-----------------------------------------------------------------------------------
--! @brief IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR                              --
-----------------------------------------------------------------------------------
component IMAGE_STREAM_BUFFER_OUTLET_LINE_SELECTOR
    generic (
        I_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! 入力側のストリームのパラメータを指定する.
                          --! * I_PARAM.ELEM_SIZE    = O_PARAM.ELEM_SIZE    でなければならない.
                          --! * I_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * I_PARAM.SHAPE.C.SIZE = O_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.D.SIZE = O_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.X.SIZE = O_PARAM.SHAPE.X.SIZE でなければならない.
                          --! * I_PARAM.SHAPE.Y.SIZE = LINE_SIZE でなければならない.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        O_PARAM         : --! @brief OUTPUT STREAM PARAMETER :
                          --! * O_PARAM.ELEM_SIZE    = I_PARAM.ELEM_SIZE    でなければならない.
                          --! * O_PARAM.INFO_BITS    = 0                    でなければならない.
                          --! * O_PARAM.SHAPE.C.SIZE = I_PARAM.SHAPE.C.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.D.SIZE = I_PARAM.SHAPE.D.SIZE でなければならない.
                          --! * O_PARAM.SHAPE.X.SIZE = I_PARAM.SHAPE.X.SIZE でなければならない.
                          --! 出力側のストリームのパラメータを指定する.
                          IMAGE_STREAM_PARAM_TYPE := NEW_IMAGE_STREAM_PARAM(8,1,1,1);
        LINE_SIZE       : --! @brief MEMORY LINE SIZE :
                          --! メモリのライン数を指定する.
                          integer := 1;
        QUEUE_SIZE      : --! @brief OUTPUT QUEUE SIZE :
                          --! 出力キューの大きさをワード数で指定する.
                          --! * QUEUE_SIZE=0 の場合は出力にキューが挿入されずダイレ
                          --!   クトに出力される.
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
    -- 入力側 I/F
    -------------------------------------------------------------------------------
        I_LINE_START    : --! @brief INPUT LINE START :
                          --! ライン有効信号.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        I_DATA          : --! @brief INPUT STREAM DATA :
                          --! ストリームデータ入力.
                          in  std_logic_vector(I_PARAM.DATA.SIZE-1 downto 0);
        I_VALID         : --! @brief INPUT STREAM DATA VALID :
                          --! 入力ストリームデータ有効信号.
                          --! * I_DATAが有効であることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          in  std_logic;
        I_READY         : --! @brief INPUT STREAM DATA READY :
                          --! 入力ストリームデータレディ信号.
                          --! * キューが次のストリームデータを入力出来ることを示す.
                          --! * I_VALID='1'and I_READY='1'でストリームデータがキュー
                          --!   に取り込まれる.
                          out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側 I/F
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
                          in  std_logic;
        O_LAST          : --! @brief OUTPUT LINE FEED :
                          --! 最終ストリーム入力.
                          in  std_logic;
        O_FEED          : --! @brief OUTPUT LINE FEED :
                          --! ラインフィード入力.
                          in  std_logic;
        O_RETURN        : --! @brief OUTPUT LINE RETURN :
                          --! ラインリターン入力.
                          in  std_logic;
    -------------------------------------------------------------------------------
    -- ライン制御 I/F
    -------------------------------------------------------------------------------
        LINE_VALID      : --! @brief INPUT LINE VALID :
                          --! ライン有効信号.
                          in  std_logic_vector(LINE_SIZE-1 downto 0);
        LINE_ATRB       : --! @brief INPUT LINE ATTRIBUTE :
                          --! ライン属性入力.
                          in  IMAGE_STREAM_ATRB_VECTOR(LINE_SIZE-1 downto 0);
        LINE_FEED       : --! @brief INPUT LINE FEED :
                          --! ラインフィード信号出力.
                          --! * この信号をアサートすることでバッファをクリアして
                          --!   入力可能な状態に戻る.
                          out std_logic_vector(LINE_SIZE-1 downto 0);
        LINE_RETURN     : --! @brief INPUT LINE RETURN :
                          --! ラインリターン信号出力.
                          --! * この信号をアサートすることでバッファの内容を再度
                          --!   出力する.
                          out std_logic_vector(LINE_SIZE-1 downto 0)
    );
end component;
end IMAGE_COMPONENTS;
