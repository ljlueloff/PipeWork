-----------------------------------------------------------------------------------
--!     @file    pipe_responder_interface.vhd
--!     @brief   PIPE RESPONDER INTERFACE
--!     @version 0.0.1
--!     @date    2013/3/30
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--! @brief   PIPE RESPONDER INTERFACE
-----------------------------------------------------------------------------------
entity  PIPE_RESPONDER_INTERFACE is
    generic (
        PUSH_VALID          : --! @brief PUSH VALID :
                              --! レスポンダ側からリクエスタ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PUSH_VALID>1でデータ転送を行う.
                              --! * PUSH_VALID=0でデータ転送を行わない.
                              integer :=  1;
        PULL_VALID          : --! @brief PUSH VALID :
                              --! リクエスタ側からレスポンダ側へのデータ転送を行うか
                              --! どうかを指定する.
                              --! * PULL_VALID>1でデータ転送を行う.
                              --! * PULL_VALID=0でデータ転送を行わない.
                              integer :=  1;
        ADDR_BITS           : --! @brief Request Address Bits :
                             --! REQ_ADDR信号のビット数を指定する.
                          integer := 32;
        ADDR_VALID          : --! @brief Request Address Valid :
                              --! REQ_ADDR信号を有効にするかどうかを指定する.
                              --! * ADDR_VALID=0で無効.
                              --! * ADDR_VALID>0で有効.
                              integer :=  1;
        SIZE_BITS           : --! @brief Transfer Size Bits :
                              --! REQ_SIZE/ACK_SIZE信号のビット数を指定する.
                              integer := 32;
        SIZE_VALID          : --! @brief Request Size Valid :
                              --! REQ_SIZE信号を有効にするかどうかを指定する.
                              --! * SIZE_VALID=0で無効.
                              --! * SIZE_VALID>0で有効.
                              integer :=  1;
        MODE_BITS           : --! @brief Request Mode Bits :
                              --! REQ_MODE信号のビット数を指定する.
                              integer := 32;
        COUNT_BITS          : --! @brief Flow Counter Bits :
                              --! フロー制御用カウンタのビット数を指定する.
                              integer := 32;
        BUF_DEPTH           : --! @brief Buffer Depth :
                              --! バッファの容量(バイト数)を２のべき乗値で指定する.
                              integer := 12;
        O_VALVE_FIXED       : --! @brief Outlet Valve Fixed Mode :
                              --! 出力用バルブのモードを指定する.
                              --! * O_VALVE_FIXED=0 : フローカウンタによるフロー制
                              --!   御を行う.
                              --! * O_VALVE_FIXED=1 : 常にバルブが閉じた状態にする.
                              --! * O_VALVE_FIXED=2 : 常にバルブが開いた状態にする.
                              integer :=  0;
        O_VALVE_PRECEDE     : --! @brief Outlet Valve Precede Mode :
                              --! 出力用バルブを先行(Precede)モードでフローを制御
                              --! するかどうかを指定する.
                              --! * O_VALVE_PRECEDE=0 : 非先行モード. フローカウン
                              --!   タの加算にT_PUSH_FIN_SIZE(入力が確定(FINAL)し
                              --!   たバイト数)を使う.
                              --! * O_VALVE_PRECEDE=1 : 先行モード. フローカウンタ
                              --!   の加算に T_PUSH_RSV_SIZE(入力する予定(RESERVE)
                              --!   のバイト数)を使う.
                              integer :=  0;
        I_VALVE_FIXED       : --! @brief Intake Valve Fixed Mode :
                              --! 入力用バルブのモードを指定する.
                              --! * I_VALVE_FIXED=0 : フローカウンタによるフロー制
                              --!   御を行う.
                              --! * I_VALVE_FIXED=1 : 常にバルブが閉じた状態にする.
                              --! * I_VALVE_FIXED=2 : 常にバルブが開いた状態にする.
                              integer :=  0;
        I_VALVE_PRECEDE     : --! @brief Intake Valve Precede Mode :
                              --! 入力用バルブを先行(Precede)モードでフローを制御
                              --! するかどうかを指定する.
                              --! * I_VALVE_PRECEDE=0 : 非先行モード. 
                              --!   フローカウンタの減算にT_PULL_FIN_SIZE(出力が確
                              --!   定(FINAL)したバイト数)を使う.
                              --! * I_VALVE_PRECEDE=1 : 先行モード. 
                              --!   フローカウンタの減算に T_PULL_RSV_SIZE(出力する
                              --!   予定(RESERVE)のバイト数)を使う.
                              integer :=  0
    );
    port (
    ------------------------------------------------------------------------------
    -- Clock and Reset Signals.
    ------------------------------------------------------------------------------
        CLK                 : --! @brief CLOCK :
                              --! クロック信号
                              in  std_logic;
        RST                 : --! @brief ASYNCRONOUSE RESET :
                              --! 非同期リセット信号.アクティブハイ.
                              in  std_logic;
        CLR                 : --! @brief SYNCRONOUSE RESET :
                              --! 同期リセット信号.アクティブハイ.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Request from Responder Signals.
    -------------------------------------------------------------------------------
        T_REQ_ADDR          : --! @brief Request Address from responder :
                              --! 転送開始アドレスを入力する.  
                              in  std_logic_vector(ADDR_BITS-1 downto 0);
        T_REQ_SIZE          : --! @brief Request transfer Size from responder :
                              --! 転送したいバイト数を入力する. 
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        T_REQ_BUF_PTR       : --! @brief Request Buffer Pointer from responder :
                              --! 転送時のバッファポインタを入力する.
                              in  std_logic_vector(BUF_DEPTH-1 downto 0);
        T_REQ_MODE          : --! @brief Request Mode signals from responder :
                              --! 転送開始時に指定された各種情報を入力する.
                              in  std_logic_vector(MODE_BITS-1 downto 0);
        T_REQ_DIR           : --! @brief Request Direction from responder :
                              --! 転送方向(PUSH/PULL)を指定する.
                              --! * T_REQ_DIR='1' : PUSH(Responder側からRequester側へデータ転送)
                              --! * T_REQ_DIR='0' : PULL(Requester側からResponder側へデータ転送)
                              in  std_logic;
        T_REQ_FIRST         : --! @brief Request First transaction from responder :
                              --! 最初のトランザクションであることを示す.
                              --! * T_REQ_FIRST=1の場合、内部状態を初期化してから
                              --!   トランザクションを開始する.
                              in  std_logic;
        T_REQ_LAST          : --! @brief Request Last transaction from responder :
                              --! 最後のトランザクションであることを示す.
                              --! * T_REQ_LAST=1の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_LAST 信号をアサートする.
                              --! * T_REQ_LAST=0の場合、Acknowledge を返す際に、
                              --!   すべてのトランザクションが終了していると、
                              --!   ACK_NEXT 信号をアサートする.
                              in  std_logic;
        T_REQ_VALID         : --! @brief Request Valid signal from responder  :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              --! * この信号のアサートでもってトランザクションを開始する.
                              --! * 一度この信号をアサートすると Acknowledge を返す
                              --!   まで、この信号はアサートされなくてはならない.
                              in  std_logic;
        T_REQ_READY         : --! @brief Request Ready signal from requester :
                              --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                              out std_logic;
    -------------------------------------------------------------------------------
    -- Acknowledge to Responder Signals.
    -------------------------------------------------------------------------------
        T_ACK_VALID         : --! @brief Acknowledge Valid signal to responder :
                              --! 上記の Command Request の応答信号.
                              --! 下記の 各種 Acknowledge 信号が有効である事を示す.
                              out std_logic;
        T_ACK_NEXT          : --! @brief Acknowledge with need Next transaction to responder :
                              --! すべてのトランザクションが終了かつ REQ_LAST=0 の
                              --! 場合、この信号がアサートされる.
                              out std_logic;
        T_ACK_LAST          : --! @brief Acknowledge with Last transaction to responder :
                              --! すべてのトランザクションが終了かつ REQ_LAST=1 の
                              --! 場合、この信号がアサートされる.
                              out std_logic;
        T_ACK_ERROR         : --! @brief Acknowledge with Error to responder :
                              --! トランザクション中になんらかのエラーが発生した場
                              --! 合、この信号がアサートされる.
                              out std_logic;
        T_ACK_STOP          : --! @brief Acknowledge with Stop operation to responder :
                              --! トランザクションが中止された場合、この信号がアサ
                              --! ートされる.
                              out std_logic;
        T_ACK_SIZE          : --! @brief Acknowledge transfer Size to responder :
                              --! 転送したバイト数を示す.
                              out std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from Responder.
    -------------------------------------------------------------------------------
        T_PUSH_FIN_VALID    : --! @brief Push Final Valid from responder :
                              --! T_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from Requester.
    -------------------------------------------------------------------------------
        T_PULL_FIN_VALID    : --! @brief Pull Final Valid from responder :
                              --! T_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        T_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals to Responder.
    -------------------------------------------------------------------------------
        O_VALVE_OPEN        : --! @brief Outlet Vavle Open :
                              in  std_logic;
        O_FLOW_PAUSE        : --! @brief Outlet Valve Flow Pause :
                              --! 出力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに O_FLOW_READY_LEVEL 未満のデータしか無い
                              --! ことを示す.
                              out std_logic;
        O_FLOW_STOP         : --! @brief Outlet Valve Flow Stop :
                              --! 出力の中止を指示する信号.
                              out std_logic;
        O_FLOW_LAST         : --! @brief Outlet Valve Flow Last :
                              --! 入力側から最後の入力を示すフラグがあったことを示す.
                              out std_logic;
        O_FLOW_SIZE         : --! @brief Outlet Valve Flow Enable Size :
                              --! 出力可能なバイト数を出力.
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        O_FLOW_READY        : --! @brief Outlet Valve Flow Ready :
                              --! プールバッファに O_FLOW_READY_LEVEL 以上のデータがある
                              --! ことを示す.
                              out std_logic;
        O_POOL_READY        : --! @brief Outlet Valve Pool Ready :
                              --! 先行モード(O_VALVE_PRECEDE=1)の時、プールバッファに 
                              --! O_POOL_READY_LEVEL 以上のデータがあることを示す.
                              out std_logic;
        O_FLOW_READY_LEVEL  : --! @brief Outlet Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以上の時に転送を開始する.
                              --! フローカウンタの値がこの値未満の時に転送を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        O_POOL_READY_LEVEL  : --! @brief Outlet Valve Pool Ready Lelvel :
                              --! 先行モード(O_VALVE_PRECEDE=1)の時、T_PULL_FIN_SIZEに
                              --! よるフローカウンタの加算結果が、この値以上の時に
                              --! O_POOL_READY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Valve Signals to Responder.
    -------------------------------------------------------------------------------
        I_VALVE_OPEN        : --! @brief Intake Vavle Open :
                              in  std_logic;
        I_FLOW_PAUSE        : --! @brief Intake Valve Flow Pause :
                              --! 入力を一時的に止めたり、再開することを指示する信号.
                              --! プールバッファに I_FLOW_READY_LEVEL を越えるデータが溜っ
                              --! ていて、これ以上データが入らないことを示す.
                              out std_logic;
        I_FLOW_STOP         : --! @brief Intake Valve Flow Stop :
                              --! 入力の中止を指示する信号.
                              out std_logic;
        I_FLOW_LAST         : --! @brief Intake Valve Flow Last :
                              --! 入力側から最後の入力を示すフラグがあったことを示す.
                              out std_logic;
        I_FLOW_SIZE         : --! @brief Intake Valve Flow Enable Size :
                              --! 入力可能なバイト数
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        I_FLOW_READY        : --! @brief Intake Valve Flow Ready :
                              --! プールバッファに I_FLOW_READY_LEVEL 以下のデータしか無く、
                              --! データの入力が可能な事を示す.
                              out std_logic;
        I_POOL_READY        : --! @brief Intake Valve Pool Ready :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、プールバッファに 
                              --! I_POOL_READY_LEVEL以下のデータしか無いことを示す.
                              out std_logic;
        I_FLOW_READY_LEVEL  : --! @brief Intake Valve Flow Ready Level :
                              --! 一時停止する/しないを指示するための閾値.
                              --! フローカウンタの値がこの値以下の時に入力を開始する.
                              --! フローカウンタの値がこの値を越えた時に入力を一時停止.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_POOL_READY_LEVEL  : --! @brief Intake Valve Pool Ready Level :
                              --! 先行モード(I_VALVE_PRECEDE=1)の時、M_PULL_FIN_SIZE に
                              --! よるフローカウンタの減算結果が、この値以下の時に
                              --! I_POOL_READY 信号をアサートする.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        I_POOL_SIZE         : --! @brief Intake Pool Size :
                              --! 入力用プールの総容量を指定する.
                              --! I_FLOW_SIZE を求めるのに使用する.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Request to Requester Signals.
    -------------------------------------------------------------------------------
        M_REQ_START         : --! @brief Request Start signal to requester :
                              --! 転送開始を指示する.
                              out std_logic;
        M_REQ_ADDR          : --! @brief Request Address to requester :
                              --! 転送開始アドレスを出力する.  
                              out std_logic_vector(ADDR_BITS-1 downto 0);
        M_REQ_SIZE          : --! @brief Request transfer Size to requester :
                              --! 転送したいバイト数を出力する. 
                              out std_logic_vector(SIZE_BITS-1 downto 0);
        M_REQ_BUF_PTR       : --! @brief Request Buffer Pointer to requester :
                              --! 転送時のバッファポインタを出力する.
                              out std_logic_vector(BUF_DEPTH-1 downto 0);
        M_REQ_MODE          : --! @brief Request Mode signals to requester :
                              --! 転送開始時に指定された各種情報を出力する.
                              out std_logic_vector(MODE_BITS-1 downto 0);
        M_REQ_DIR           : --! @brief Request Direction to requester :
                              --! 転送方向(PUSH/PULL)を指定する.
                              --! * M_REQ_DIR='1' : PUSH(Responder側からRequester側へデータ転送)
                              --! * M_REQ_DIR='0' : PULL(Requester側からResponder側へデータ転送)
                              out std_logic;
        M_REQ_FIRST         : --! @brief Request First transaction to requester :
                              --! 最初のトランザクションであることを示す.
                              --! * REQ_FIRST=1の場合、内部状態を初期化してから
                              --!   トランザクションを開始する.
                              out std_logic;
        M_REQ_LAST          : --! @brief Request Last transaction to requester :
                              --! 最後のトランザクションであることを示す.
                              out std_logic;
        M_REQ_VALID         : --! @brief Request Valid signal to requester :
                              --! 上記の各種リクエスト信号が有効であることを示す.
                              out std_logic;
        M_REQ_READY         : --! @brief Request Ready signal from requester :
                              --! 上記の各種リクエスト信号を受け付け可能かどうかを示す.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Response from Requester Signals.
    -------------------------------------------------------------------------------
        M_RES_START         : --! @brief Request Start signal from requester :
                              --! 転送を開始したことを示す入力信号.
                              in  std_logic;
        M_RES_DONE          : --! @brief Transaction Done signal from requester :
                              --! 転送を終了したことを示す入力信号.
                              in  std_logic;
        M_RES_ERROR         : --! @brief Transaction Error signal from requester :
                              --! 転送を異常終了したことを示す入力信号.
                              in  std_logic;
    -------------------------------------------------------------------------------
    -- Outlet Valve Signals from Requester.
    -------------------------------------------------------------------------------
        M_PUSH_FIN_VALID    : --! @brief Push Final Valid from requester :
                              --! M_PUSH_FIN_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        M_PUSH_FIN_LAST     : --! @brief Push Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ入力であ
                              --! ることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        M_PUSH_FIN_SIZE     : --! @brief Push Final Size :
                              --! レスポンダ側からの"確定した"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PUSH_RSV_VALID    : --! @brief Push Reserve Valid from requester :
                              --! M_PUSH_RSV_LAST/SIZE が有効であることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        M_PUSH_RSV_LAST     : --! @brief Push Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ入力で
                              --! あることを示す.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        M_PUSH_RSV_SIZE     : --! @brief Push Reserve Size :
                              --! レスポンダ側からの"予定された"入力バイト数.
                              --! * 出力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 出力用バルブが非先行モード(O_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Valve Signals from requester.
    -------------------------------------------------------------------------------
        M_PULL_FIN_VALID    : --! @brief Pull Final Valid from requester :
                              --! M_PULL_FIN_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        M_PULL_FIN_LAST     : --! @brief Pull Final Last flags :
                              --! レスポンダ側からの最後の"確定した"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic;
        M_PULL_FIN_SIZE     : --! @brief Pull Final Size :
                              --! レスポンダ側からの"確定した"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0);
        M_PULL_RSV_VALID    : --! @brief Pull Reserve Valid from requester :
                              --! M_PULL_RSV_LAST/SIZE が有効であることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが先行(Precede)モードで無い場合は
                              --!   未使用.
                              in  std_logic;
        M_PULL_RSV_LAST     : --! @brief Pull Reserve Last flags :
                              --! レスポンダ側からの最後の"予定された"データ出力で
                              --! あることを示す.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic;
        M_PULL_RSV_SIZE     : --! @brief Pull Reserve Size :
                              --! レスポンダ側からの"予定された"出力バイト数.
                              --! * 入力用バルブが固定(Fixed)モードの場合は未使用.
                              --! * 入力用バルブが非先行モード(I_VALVE_PRECEDE=0)
                              --!   の場合は未使用.
                              in  std_logic_vector(SIZE_BITS-1 downto 0)
    );
end PIPE_RESPONDER_INTERFACE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.COMPONENTS.FLOAT_OUTLET_MANIFOLD_VALVE;
use     PIPEWORK.COMPONENTS.FLOAT_INTAKE_MANIFOLD_VALVE;
use     PIPEWORK.COMPONENTS.COUNT_UP_REGISTER;
architecture RTL of PIPE_RESPONDER_INTERFACE is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  reset             : std_logic := '0';
    constant  pause             : std_logic := '0';
    constant  stop              : std_logic := '0';
    signal    start             : std_logic;
    type      STATE_TYPE    is  ( IDLE_STATE, REQ_STATE, ACK_STATE );
    signal    curr_state        : STATE_TYPE;
    signal    xfer_dir          : std_logic;
    signal    xfer_last         : std_logic;
    signal    ack_error         : std_logic;
    signal    ack_last          : std_logic;
    signal    push_mode         : boolean;
    signal    pull_mode         : boolean;
    constant  size_all_clr      : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '0');
    constant  size_all_set      : std_logic_vector(SIZE_BITS-1 downto 0) := (others => '1');
    signal    size_load         : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    size_up_size      : std_logic_vector(SIZE_BITS-1 downto 0);
    signal    size_up_valid     : std_logic;
    signal    size_up_select    : boolean;
    signal    m_valve_open      : std_logic;
    signal    m_res_open        : std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    start <= '1' when (curr_state = IDLE_STATE and T_REQ_VALID = '1' and M_REQ_READY = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (CLK, RST)
        variable next_state : STATE_TYPE;
    begin
        if (RST = '1') then
                curr_state <= IDLE_STATE;
                xfer_dir   <= '0';
                xfer_last  <= '1';
                ack_error  <= '0';
                ack_last   <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_state <= IDLE_STATE;
                xfer_dir   <= '0';
                xfer_last  <= '1';
                ack_error  <= '0';
                ack_last   <= '0';
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (start = '1') then
                            next_state := REQ_STATE;
                        else
                            next_state := IDLE_STATE;
                        end if;
                    when REQ_STATE =>
                        if    (M_RES_DONE = '1') then
                            next_state := ACK_STATE;
                        else
                            next_state := REQ_STATE;
                        end if;
                    when ACK_STATE =>
                            next_state := IDLE_STATE;
                    when others =>
                            next_state := IDLE_STATE;
                end case;
                curr_state <= next_state;
                if (start = '1') then
                    xfer_dir  <= T_REQ_DIR;
                    xfer_last <= T_REQ_LAST;
                end if;
                if (curr_state = REQ_STATE and M_RES_DONE = '1') then
                    if    (M_RES_ERROR = '1') then
                        ack_error <= '1';
                        ack_last  <= '0';
                    elsif (xfer_last = '1') then
                        ack_error <= '0';
                        ack_last  <= '1';
                    else
                        ack_error <= '0';
                        ack_last  <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    push_mode   <= (PUSH_VALID /= 0 and PULL_VALID  = 0) or
                   (PUSH_VALID /= 0 and PULL_VALID /= 0 and xfer_dir  = '1');
    pull_mode   <= (PULL_VALID /= 0 and PUSH_VALID  = 0) or
                   (PULL_VALID /= 0 and PUSH_VALID /= 0 and xfer_dir  = '0');
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    T_REQ_READY <= '1' when (curr_state = IDLE_STATE and M_REQ_READY = '1') else '0';
    T_ACK_VALID <= '1' when (curr_state = ACK_STATE) else '0';
    T_ACK_ERROR <= '1' when (curr_state = ACK_STATE  and ack_error   = '1') else '0';
    T_ACK_NEXT  <= '1' when (curr_state = ACK_STATE  and ack_last    = '0') else '0';
    T_ACK_LAST  <= '1' when (curr_state = ACK_STATE  and ack_last    = '1') else '0';
    T_ACK_STOP  <= '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    SIZE_REGS: COUNT_UP_REGISTER                     -- 
        generic map (                                -- 
            VALID           => 1                   , -- 
            BITS            => SIZE_BITS           , --
            REGS_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
            REGS_WEN        => size_load           , -- In  :
            REGS_WDATA      => size_all_clr        , -- In  :
            REGS_RDATA      => open                , -- Out :
            UP_ENA          => m_valve_open        , -- In  :
            UP_VAL          => size_up_valid       , -- In  :
            UP_BEN          => size_all_set        , -- In  :
            UP_SIZE         => size_up_size        , -- In  :
            COUNTER         => T_ACK_SIZE            -- Out :
       );
    size_load     <= size_all_set     when (start = '1') else size_all_clr;
    size_up_valid <= M_PULL_FIN_VALID when (push_mode  ) else M_PUSH_FIN_VALID;
    size_up_size  <= M_PULL_FIN_SIZE  when (push_mode  ) else M_PUSH_FIN_SIZE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    M_REQ_START   <= start;
    M_REQ_VALID   <= '1' when (curr_state = REQ_STATE) else '0';
    M_REQ_ADDR    <= T_REQ_ADDR;
    M_REQ_SIZE    <= T_REQ_SIZE;
    M_REQ_BUF_PTR <= T_REQ_BUF_PTR;
    M_REQ_MODE    <= T_REQ_MODE;
    M_REQ_FIRST   <= T_REQ_FIRST;
    M_REQ_LAST    <= T_REQ_LAST;
    M_REQ_DIR     <= '1' when (PUSH_VALID /= 0 and PULL_VALID  = 0) else
                     '0' when (PUSH_VALID  = 0 and PULL_VALID /= 0) else T_REQ_DIR;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                m_res_open <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                m_res_open <= '0';
            elsif (M_RES_START = '1' and M_RES_DONE = '0') then
                m_res_open <= '1';
            elsif (m_res_open  = '1' and M_RES_DONE = '1') then
                m_res_open <= '0';
            end if;
        end if;
    end process;
    m_valve_open <= '1' when (M_RES_START = '1' or m_res_open = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    O_VALVE: FLOAT_OUTLET_MANIFOLD_VALVE             -- 
        generic map (                                -- 
            PRECEDE         => O_VALVE_PRECEDE     , -- 
            FIXED           => O_VALVE_FIXED       , -- 
            COUNT_BITS      => COUNT_BITS          , -- 
            SIZE_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            RESET           => reset               , -- In  :
            PAUSE           => pause               , -- In  :
            STOP            => stop                , -- In  :
            INTAKE_OPEN     => m_valve_open        , -- In  :
            OUTLET_OPEN     => O_VALVE_OPEN        , -- In  :
            FLOW_READY_LEVEL=> O_FLOW_READY_LEVEL  , -- In  :
            POOL_READY_LEVEL=> O_POOL_READY_LEVEL  , -- In  :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PUSH_FIN_VALID  => M_PUSH_FIN_VALID    , -- In  :
            PUSH_FIN_LAST   => M_PUSH_FIN_LAST     , -- In  :
            PUSH_FIN_SIZE   => M_PUSH_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PUSH_RSV_VALID  => M_PUSH_RSV_VALID    , -- In  :
            PUSH_RSV_LAST   => M_PUSH_RSV_LAST     , -- In  :
            PUSH_RSV_SIZE   => M_PUSH_RSV_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_VALID      => T_PULL_FIN_VALID    , -- In  :
            PULL_LAST       => T_PULL_FIN_LAST     , -- In  :
            PULL_SIZE       => T_PULL_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY      => O_FLOW_READY        , -- Out :
            FLOW_PAUSE      => O_FLOW_PAUSE        , -- Out :
            FLOW_STOP       => O_FLOW_STOP         , -- Out :
            FLOW_LAST       => O_FLOW_LAST         , -- Out :
            FLOW_SIZE       => O_FLOW_SIZE         , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Counter.
        ---------------------------------------------------------------------------
            FLOW_COUNT      => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            PAUSED          => open                , -- Out :
            POOL_COUNT      => open                , -- Out :
            POOL_READY      => O_POOL_READY          -- Out :
        );                                           -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_VALVE: FLOAT_INTAKE_MANIFOLD_VALVE             --
        generic map (                                -- 
            PRECEDE         => I_VALVE_PRECEDE     , -- 
            FIXED           => I_VALVE_FIXED       , -- 
            COUNT_BITS      => COUNT_BITS          , -- 
            SIZE_BITS       => SIZE_BITS             -- 
        )                                            -- 
        port map (                                   -- 
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => CLK                 , -- In  :
            RST             => RST                 , -- In  :
            CLR             => CLR                 , -- In  :
        ---------------------------------------------------------------------------
        -- Control Signals.
        ---------------------------------------------------------------------------
            RESET           => reset               , -- In  :
            PAUSE           => pause               , -- In  :
            STOP            => stop                , -- In  :
            INTAKE_OPEN     => I_VALVE_OPEN        , -- In  :
            OUTLET_OPEN     => m_valve_open        , -- In  :
            POOL_SIZE       => I_POOL_SIZE         , -- In  :
            FLOW_READY_LEVEL=> I_FLOW_READY_LEVEL  , -- In  :
            POOL_READY_LEVEL=> I_POOL_READY_LEVEL  , -- In  :
        ---------------------------------------------------------------------------
        -- Push Final Size Signals.
        ---------------------------------------------------------------------------
            PULL_FIN_VALID  => M_PULL_FIN_VALID    , -- In  :
            PULL_FIN_LAST   => M_PULL_FIN_LAST     , -- In  :
            PULL_FIN_SIZE   => M_PULL_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Push Reserve Size Signals.
        ---------------------------------------------------------------------------
            PULL_RSV_VALID  => M_PULL_RSV_VALID    , -- In  :
            PULL_RSV_LAST   => M_PULL_RSV_LAST     , -- In  :
            PULL_RSV_SIZE   => M_PULL_RSV_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PUSH_VALID      => T_PUSH_FIN_VALID    , -- In  :
            PUSH_LAST       => T_PUSH_FIN_LAST     , -- In  :
            PUSH_SIZE       => T_PUSH_FIN_SIZE     , -- In  :
        ---------------------------------------------------------------------------
        -- Outlet Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_READY      => I_FLOW_READY        , -- Out :
            FLOW_PAUSE      => I_FLOW_PAUSE        , -- Out :
            FLOW_STOP       => I_FLOW_STOP         , -- Out :
            FLOW_LAST       => I_FLOW_LAST         , -- Out :
            FLOW_SIZE       => I_FLOW_SIZE         , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Counter.
        ---------------------------------------------------------------------------
            FLOW_COUNT      => open                , -- Out :
            FLOW_NEG        => open                , -- Out :
            PAUSED          => open                , -- Out :
            POOL_COUNT      => open                , -- Out :
            POOL_READY      => I_POOL_READY          -- Out :
        );                                           -- 
end RTL;