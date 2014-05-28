#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   0.0.2
#       Created     :   2014/5/28
#       File name   :   vhdl-reader.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   VHDLのソースコードを解析する ruby モジュール.
#                       VHDL 言語としてアナライズしているわけでなく、たんなる文字
#                       列として処理していることに注意。
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2012-2014 Ichiro Kawazome
#       All rights reserved.
# 
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions
#       are met:
# 
#         1. Redistributions of source code must retain the above copyright
#            notice, this list of conditions and the following disclaimer.
# 
#         2. Redistributions in binary form must reproduce the above copyright
#            notice, this list of conditions and the following disclaimer in
#            the documentation and/or other materials provided with the
#            distribution.
# 
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#       A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
#       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#---------------------------------------------------------------------------------
require 'forwardable'
module PipeWork
  module VHDL_Reader
    #-----------------------------------------------------------------------------
    # 
    #-----------------------------------------------------------------------------
    class Token
      attr_reader :sym, :text, :line_number
      def initialize(sym, text, line_number)
        @sym  = sym
        @text = text
        @line_number = line_number
      end
    end
    #-----------------------------------------------------------------------------
    # VHDLの字句解析モジュール
    #-----------------------------------------------------------------------------
    module Lexer
      #---------------------------------------------------------------------------
      # VHDL の予約語
      #---------------------------------------------------------------------------
      RESERVED_WORDS = [
        :ABS          , :ACCESS       , :AFTER        , :ALIAS        , :ALL          , 
        :AND          , :ARCHITECTURE , :ARRAY        , :ASSERT       , :ATTRIBUTE    ,
        :BEGIN        , :BLOCK        , :BODY         , :BUFFER       , :BUS          ,
        :CASE         , :COMPONENT    , :CONFIGULATION, :CONSTANT     , :DISCONNECT   , 
        :DOWNTO       , :ELSE         , :ELSIF        , :END          , :ENTITY       , 
        :EXIT         , :FILE         , :FOR          , :FUNCTION     , :GENERATE     , 
        :GENERIC      , :GUARDED      , :IF           , :IMPURE       , :IN           , 
        :INERTIAL     , :INOUT        , :IS           , :LABEL        , :LIBRARY      , 
        :LINKAGE      , :LITERAL      , :LOOP         , :MAP          , :MOD          ,
        :NAND         , :NEW          , :NEXT         , :NOR          , :NOT          , 
        :NULL         , :OF           , :ON           , :OPEN         , :OR           , 
        :OTHERS       , :OUT          , :PACKAGE      , :PORT         , :POSTPONED    , 
        :PROCEDURE    , :PROCESS      , :PURE         , :RANGE        , :RECORD       , 
        :REGISTER     , :REJECT       , :REM          , :REPORT       , :RETURN       , 
        :ROL          , :ROR          , :SELECT       , :SEVERITY     , :SHARED       , 
        :SIGNAL       , :SLA          , :SLL          , :SRA          , :SRL          , 
        :SUBTYPE      , :THEN         , :TO           , :TRANSPORT    , :TYPE         ,
        :UNAFFECTED   , :UNITS        , :UNTIL        , :USE          , :VARIABLE     ,
        :WAIT         , :WHEN         , :WHILE        , :WITH         , :XNOR         , 
        :XOR
      ]
      #---------------------------------------------------------------------------
      # VHDL の２文字以上からなるオペレータのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_SPECIAL_OPS = [
        /^(=>)/   , /^(<=)/   , /^(:=)/   , /^(<<)/   , /^(>>)/   , /^(<>)/   ,
        /^(\/=)/  , /^(\*\*)/ , /^(\?\?)/ , /^(\?=)/  , /^(\?<)/  , /^(\?>)/  ,
        /^(\?<=)/ , /^(\?>=)/ , /^(\?\/=)/
      ]
      #---------------------------------------------------------------------------
      # VHDL の一文字からなるオペレータのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_SPECIAL_SINGLE    = /^([\(\)\[\]\{\}\.\+\-\*\/\|\?,:;'#<>=&"@`])/
      #---------------------------------------------------------------------------
      # VHDL の一文字からなるオペレータのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_SPECIAL_CHARACTER = /^([[:graph:]&&[:^alnum:]])/
      #---------------------------------------------------------------------------
      # VHDL のリテラルのパターンマッチを定義
      #---------------------------------------------------------------------------
      REGEXP_LITERAL = /^([a-zA-Z][a-zA-Z0-9_]+)/
      #---------------------------------------------------------------------------
      # 文字列から VHDL の字句を抽出してその配列を返すメソッド.
      #---------------------------------------------------------------------------
      def scan_text(text_line, line_number)
        tokens = Array.new
        line   = String.new(text_line)
        line.sub!(/--.*$/  ,'')
        line.sub!(/[\n\r]$/,'')
        while line.length > 0
          ## p line
          line.sub!(/^[[:^graph:]]+/ ,'')
          break if line.length == 0
          #-----------------------------------------------------------------------
          # 先頭に英文字がある場合
          #-----------------------------------------------------------------------
          if line[0] =~ /^[[:alpha:]]/
            text = ""
            line.sub!(/^([[:alpha:]][[:alnum:]_]*)/){text=$1;""}
            if RESERVED_WORDS.index(text.upcase.to_sym)
              tokens << Token.new(text.upcase.to_sym, text, line_number)
            else
              tokens << Token.new(:IDENTFIER,         text, line_number)
            end
            next
          end
          #-----------------------------------------------------------------------
          # 先頭に数字がある場合
          #-----------------------------------------------------------------------
          if line[0] =~ /^[[:digit:]]/
            text = ""
            line.sub!(/^([[:digit:]][[:digit:]_\.]*)/){text=$1;""}
            if line[0] =~ /^#/
              line.sub!(/^(#[[:xdigit:]_\.]+#)/){text=text+$1;""}
            end
            if line[0] =~ /^[Ee]/
              line.sub!(/^([Ee][\+\-]?[[:digit:]_\.]+#)/){text=text+$1;""}
            end
            tokens << Token.new(:NUMBER, text, line_number)
            next
          end
          #-----------------------------------------------------------------------
          # ２文字以上からなるオペレータがあるかどうかを解析する
          #-----------------------------------------------------------------------
          found_special_ops = FALSE
          REGEXP_SPECIAL_OPS.each {|r|
            if (line =~ r)
              text = ""
              line.sub!(r){text=$1;""}
              tokens << Token.new(text.to_sym, text, line_number)
              found_special_ops = TRUE
              break
            end
          }
          next if found_special_ops == TRUE
          #-----------------------------------------------------------------------
          # １文字からなるオペレータがあるかどうかを解析する
          #-----------------------------------------------------------------------
          if line[0] =~ REGEXP_SPECIAL_SINGLE
            text = ""
            line.sub!(REGEXP_SPECIAL_SINGLE){text=$1;""}
            tokens << Token.new(text.to_sym, text, line_number)
            next
          end
          #-----------------------------------------------------------------------
          # 上記以外はエラー
          #-----------------------------------------------------------------------
          line.sub!(/^./,'')
        end
        return tokens
      end
      module_function :scan_text
    end
    #-----------------------------------------------------------------------------
    # LibraryUnit   : ソースコードを読んだ時のユニット毎の依存関係を保持するクラス.
    #                 ここで言うユニットとは entity, architecture, package, 
    #                 package body のこと.
    #-----------------------------------------------------------------------------
    class LibraryUnit
      attr_reader :type, :name, :library_name, :file_name, :use_unit_name_list
      attr_reader :text_lines , :tokens
      def initialize(unit_type, unit_name, libary_name, file_name, use_clause_list)
        @type               = unit_type
        @name               = unit_name.upcase
        @file_name          = file_name
        @library_name       = libary_name.upcase
        @tokens             = Array.new
        @text_lines         = Hash.new
        @use_unit_name_list = Hash.new
        use_clause_list.each do |use_clause|
          library_name = use_clause[:LibraryName].upcase
          if @use_unit_name_list[library_name] == nil
            @use_unit_name_list[library_name] = Set.new
          end
          if use_clause.key?(:PackageName) 
            @use_unit_name_list[library_name] << use_clause[:PackageName].upcase
          end
          if use_clause.key?(:EntityName) 
            @use_unit_name_list[library_name] << use_clause[:EntityName].upcase
          end
        end
      end
      def scan_text(text_line, line_number)
        @text_lines[line_number] = text_line
        tokens = Lexer.scan_text(text_line, line_number)
        @tokens.concat(tokens)
        return tokens
      end
      def debug_print
        warn @name
        warn "  name      : " + @name.to_s      
        warn "  type      : " + @type.to_s 
        warn "  library   : " + @library_name.to_s 
        warn "  file_name : " + @file_name.to_s 
        warn "  use       : "
        @use_unit_name_list.each do |library_name, package_set|
          package_set.each do |package_name|
            warn "    - library : " + library_name.to_s
            warn "      package : " + package_name.to_s
          end
        end
      end
    end
    #-----------------------------------------------------------------------------
    # Entity        : ソースコードを読んだ時の Entity 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class Entity < LibraryUnit
      def initialize(  entity_name, library_name, file_name, use_clause_list)
        super(:Entity, entity_name, library_name, file_name, use_clause_list)
      end
      def parse(text_line, line_number)
        tokens = scan_text(text_line, line_number)
        if ((@tokens[-3].sym == :END      ) and
            (@tokens[-2].sym == :ENTITY   ) and 
            (@tokens[-1].sym == :";"      )) or
           ((@tokens[-3].sym == :END      ) and
            (@tokens[-2].sym == :IDENTFIER) and 
            (@tokens[-2].text.upcase == @name) and 
            (@tokens[-1].sym == :";"      ))
          return :END
        else
          return :BEGIN
        end
      end
    end
    #-----------------------------------------------------------------------------
    # Architecture  : ソースコードを読んだ時の Architecture 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class Architecture < LibraryUnit
      attr_reader :arch_name, :external_entity_list
      def initialize(entity_name, arch_name, library_name, file_name, use_clause_list)
        super(:Architecture, entity_name, library_name, file_name, use_clause_list)
        @arch_name     = arch_name.upcase
        @external_list = Array.new
      end
      def parse(text_line, line_number)
        tokens = scan_text(text_line, line_number)
        if ((@tokens[-3].sym == :END) and
            (@tokens[-2].sym == :ARCHITECTURE) and
            (@tokens[-1].sym == :";")) or
           ((@tokens[-3].sym == :END) and
            (@tokens[-2].sym == :IDENTFIER) and
            (@tokens[-2].text.upcase == @arch_name) and 
            (@tokens[-1].sym == :";")) 
          make_external_list
          return :END
        else
          return :BEGIN
        end
      end
      def make_external_list
        @tokens.each_index{ |i|
          if @tokens[i].sym == :MAP
            if (@tokens[i-2].sym == :IDENTFIER) and
               (@tokens[i-1].sym == :PORT or @tokens[i-1].sym == :GENERIC) and
               (@tokens[i+1].sym == :"(")
              name = @tokens[i-2].text.upcase
              if (@tokens[i-3].sym == :".") and 
                 (@tokens[i-4].sym == :IDENTFIER) 
                lib = @tokens[i-4].text.upcase
                n   = i-5
              else
                lib = nil
                n   = i-3
              end
              if (@tokens[n  ].sym == :ENTITY)
                n   = n-1
              end
              if (@tokens[n  ].sym == :":") and
                 (@tokens[n-1].sym == :IDENTFIER) 
                label = @tokens[n-1].text.upcase
              else
                label = nil
              end
              @external_list << {:Name => name, :Library => lib, :Label => label}
            end
          end
        }
      end
      def debug_print
        super
        @external_list.each do |item|
            warn "    - external: " + name
            warn "      name    : " + item[:Name].to_s
            warn "      library : " + item[:Library].to_s
            warn "      label   : " + item[:Label].to_s
        end
      end
    end
    #-----------------------------------------------------------------------------
    # Package       : ソースコードを読んだ時の Package 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class Package < LibraryUnit
      def initialize(   package_name, library_name, file_name, use_clause_list)
        super(:Package, package_name, library_name, file_name, use_clause_list)
      end
      def parse(text_line, line_number)
        tokens = scan_text(text_line, line_number)
        if ((@tokens[-3].sym == :END) and
            (@tokens[-2].sym == :PACKAGE) and
            (@tokens[-1].sym == :";")) or
           ((@tokens[-3].sym == :END) and
            (@tokens[-2].sym == :IDENTFIER) and
            (@tokens[-2].text.upcase == @name) and 
            (@tokens[-1].sym == :";")) 
          return :END
        else
          return :BEGIN
        end
      end
    end
    #-----------------------------------------------------------------------------
    # PackageBody   : ソースコードを読んだ時の Package body 記述を保持するクラス
    #-----------------------------------------------------------------------------
    class PackageBody < LibraryUnit
      def initialize(       package_name, library_name, file_name, use_clause_list)
        super(:PackageBody, package_name, library_name, file_name, use_clause_list)
      end
      def parse(text_line, line_number)
        tokens = scan_text(text_line, line_number)
        if ((@tokens[-4].sym == :END) and
            (@tokens[-3].sym == :PACKAGE) and
            (@tokens[-2].sym == :BODY) and
            (@tokens[-1].sym == :";")) or
           ((@tokens[-3].sym == :END) and
            (@tokens[-2].sym == :IDENTFIER) and
            (@tokens[-2].text.upcase == @name) and 
            (@tokens[-1].sym == :";")) 
          return :END
        else
          return :BEGIN
        end
      end
    end
    #-----------------------------------------------------------------------------
    # LibraryUnitList  : LibraryUnitの配列クラス
    #-----------------------------------------------------------------------------
    class LibraryUnitList < Array
      #---------------------------------------------------------------------------
      # analyze_path : 与えられたパス名を解析し、ディレクトリならば再帰的に探索し、
      #                ファイルならば read_file を呼び出して、自分自身に LibraryUnit 
      #                を追加する.
      #                "."で始まるディレクトリは探索しない.
      #                "~"で終わるファイルは読まない.
      #---------------------------------------------------------------------------
      def analyze_path(path_name, library_name)
        if File::ftype(path_name) == "directory"
          Dir::foreach(path_name) do |name|
            next if name =~ /^\./
            if path_name =~ /\/$/
              analyze_path(path_name + name      , library_name)
            else
              analyze_path(path_name + "/" + name, library_name)
            end
          end
        elsif path_name =~ /~$/
        else 
          read_file(path_name, library_name)
        end
        return self
      end
      #---------------------------------------------------------------------------
      # read_file  : VHDLソースファイルを読んで自分自身に LibraryUnit を追加する.
      #---------------------------------------------------------------------------
      def read_file(file_name, library_name)
        if @verbose 
          warn "analyze file : " + file_name
        end
        File.open(file_name) do |file|
          analyze_file(file, file_name, library_name)
        end
        return self
      end
      #---------------------------------------------------------------------------
      # analyze_file : VHDLソースコードを解析して LibraryUnit を生成し、自分自身に
      #                生成した LibraryUnit を追加する.
      #---------------------------------------------------------------------------
      def analyze_file(file, file_name, library_name)
        unit_name    = nil
        unit_info    = nil
        library_list = Array.new
        use_list     = Array.new
        line_number  = 0
        #-------------------------------------------------------------------------
        # ファイルから一行ずつ読み込む。
        #-------------------------------------------------------------------------
        file.each_line do |line|
          text_line = line.encode("UTF-8", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?')
          #-----------------------------------------------------------------------
          # 行番号の更新
          #-----------------------------------------------------------------------
          line_number += 1
          #-----------------------------------------------------------------------
          # 
          #-----------------------------------------------------------------------
          if (unit_info == nil) 
            #---------------------------------------------------------------------
            # 
            #---------------------------------------------------------------------
            tokens = Lexer.scan_text(text_line, line_number)
            s = tokens.map{|token| token.sym}
            #---------------------------------------------------------------------
            # library ライブラリ名; の解釈
            #---------------------------------------------------------------------
            if s[0] == :LIBRARY
              tokens.drop(1).each {|token|
                break if token.sym == :";"
                next  if token.sym == :","
                library_list << token.text
              }
              ## p library_list
              next
            end
            #---------------------------------------------------------------------
            # use ライブラリ名.パッケージ名.アイテム名; の解釈
            #---------------------------------------------------------------------
            if (s[0] == :USE      ) and 
               (s[1] == :IDENTFIER) and
               (s[2] == :"."      ) and 
               (s[3] == :IDENTFIER) and
               (s[4] == :"."      ) and 
               (s[5] == :IDENTFIER) and
               (s[6] == :";"      )
              use_list << {:LibraryName => tokens[1].text, 
                           :PackageName => tokens[3].text, 
                           :ItemName    => tokens[5].text
                          }
              ## p use_list
              next
            end
            #---------------------------------------------------------------------
            # use ライブラリ名.パッケージ名.all; の解釈
            #---------------------------------------------------------------------
            if (s[0] == :USE      ) and 
               (s[1] == :IDENTFIER) and
               (s[2] == :"."      ) and 
               (s[3] == :IDENTFIER) and
               (s[4] == :"."      ) and 
               (s[5] == :ALL      ) and
               (s[6] == :";"      )
              use_list << {:LibraryName => tokens[1].text, 
                           :PackageName => tokens[3].text, 
                           :ItemName    => tokens[5].text
                          }
              ## p use_list
              next
            end
            #---------------------------------------------------------------------
            # use ライブラリ名.パッケージ名; の解釈
            #---------------------------------------------------------------------
            if (s[0] == :USE      ) and 
               (s[1] == :IDENTFIER) and
               (s[2] == :"."      ) and 
               (s[3] == :IDENTFIER) and
               (s[4] == :";"      )
              use_list << {:LibraryName => tokens[1].text, 
                           :PackageName => tokens[3].text, 
                          }
              ## p use_list
              next
            end
            #---------------------------------------------------------------------
            # entity 宣言の開始
            #---------------------------------------------------------------------
            if (s[0] == :ENTITY      ) and
               (s[1] == :IDENTFIER   ) and
               (s[2] == :IS          )
              unit_name = tokens[1].text
              unit_info = Entity.new(unit_name, library_name, file_name, use_list)
            end
            #---------------------------------------------------------------------
            # architecture 宣言の開始
            #---------------------------------------------------------------------
            if (s[0] == :ARCHITECTURE) and 
               (s[1] == :IDENTFIER   ) and
               (s[2] == :OF          ) and
               (s[3] == :IDENTFIER   ) and
               (s[4] == :IS          )
              unit_name   = tokens[1].text
              entity_name = tokens[3].text
              use_list << {:LibraryName => library_name, :EntityName => entity_name}
              unit_info = Architecture.new(entity_name, unit_name, library_name, file_name, use_list)
            end
            #---------------------------------------------------------------------
            # package 宣言の開始
            #---------------------------------------------------------------------
            if (s[0] == :PACKAGE     ) and 
               (s[1] == :IDENTFIER   ) and
               (s[2] == :IS          )
              unit_name = tokens[1].text
              unit_info = Package.new(unit_name, library_name, file_name, use_list)
            end
            #---------------------------------------------------------------------
            # package body 宣言の開始
            #---------------------------------------------------------------------
            if (s[0] == :PACKAGE     ) and 
               (s[1] == :BODY        ) and
               (s[2] == :IDENTFIER   ) and
               (s[3] == :IS          )
              unit_name = tokens[2].text
              use_list << {:LibraryName => library_name, :PackageName => unit_name}
              unit_info = PackageBody.new(unit_name, library_name, file_name, use_list)
            end
          end
          #-----------------------------------------------------------------------
          # entity, architecture, package, package body のパース
          #-----------------------------------------------------------------------
          if unit_info != nil
            case unit_info.parse(text_line, line_number)
              when :END
                # unit_info.debug_print
                self << unit_info
                unit_name    = ""
                unit_info    = nil
                library_list = Array.new
                use_list     = Array.new
            end
          end
        end
        #-------------------------------------------------------------------------
        # 自分自身を返す.
        #-------------------------------------------------------------------------
        return self
      end
      #---------------------------------------------------------------------------
      # デバッグ用
      #---------------------------------------------------------------------------
      def debug_print
        self.each { |unit| unit.debug_print }
      end
    end
    #-----------------------------------------------------------------------------
    # UnitFile      : ソースコードを読んだ時のファイル毎の依存関係を保持するクラス
    #-----------------------------------------------------------------------------
    class UnitFile
      attr_reader   :file_name, :library_name
      attr_accessor :level, :unit_name_list, :use_name_list, :use_list, :be_used_list
      def initialize(file_name, library_name)
        @file_name      = file_name
        @library_name   = library_name
        @unit_name_list = Set.new
        @use_name_list  = Set.new
        @use_list       = Set.new
        @be_used_list   = Set.new
        @level          = 0
      end
      def add_use_name_list(use_name_list)
        use_name_list.each do |library_name, package_list|
          if (library_name.upcase == @library_name.upcase)
             @use_name_list = @use_name_list + package_list
          end
        end
      end
      def debug_print
        warn "- file_name : " + @file_name
        warn "  level     : " + @level.to_s
        @unit_name_list.each do |unit_name|
          warn "  - unit  : " + unit_name
        end
        @use_name_list.each   do |use_name|
          warn "  - use   : " + use_name
        end
        @use_list.each   do |use|
          warn "  - use!  : " + use.file_name
        end
        @be_used_list.each   do |use|
          warn "  - used! : " + use.file_name
        end
      end
      def set_level(level,checked_list)
        if level > @level
          @level = level
          @use_list.each do |use|
            next if checked_list.member?(use)
            use.set_level(level+1, checked_list << self)
          end
        end
      end
      def compare_level (target)
        if    @level > target.level then return -1
        elsif @level < target.level then return  1
        else return @file_name <=> target.file_name
        end
      end
      def to_formatted_string(format)
        file_name    = @file_name
        library_name = @library_name
        return eval('"' + format + '"')
      end
    end
    #-----------------------------------------------------------------------------
    # UnitFileList  : UnitFileの配列クラス
    #-----------------------------------------------------------------------------
    class UnitFileList
      extend Forwardable
      def initialize
        @list    = Array.new
        @defined = Hash.new
      end
      def_delegators(:@list, :[], :each, :assoc, :size, :length)
      #---------------------------------------------------------------------------
      # add_unit : LibraryUnitオブジェクトをUnitFileに変換して@list に追加する.
      #---------------------------------------------------------------------------
      def add_unit(unit)
        #-------------------------------------------------------------------------
        # UnitFile を生成して、@list に登録する.
        # ただし、一度生成した UnitFile は新たに生成せずに、すでにあるものを使う.
        #-------------------------------------------------------------------------
        if @defined.key?(unit.file_name)
          unit_file = @defined[unit.file_name]
        else
          unit_file = UnitFile.new(unit.file_name, unit.library_name)
          @defined[unit.file_name] = unit_file
          @list << unit_file
        end
        #-------------------------------------------------------------------------
        # UnitFile に、そのファイルで定義しているエンティティの名前または
        # パッケージの名前を登録する
        #-------------------------------------------------------------------------
        case unit.type
          when :Entity 
            unit_file.unit_name_list << unit.name
          when :Package 
            unit_file.unit_name_list << unit.name
        end
        unit_file.add_use_name_list(unit.use_unit_name_list)
      end
      #---------------------------------------------------------------------------
      # add_unit_list : LibraryUnitの配列をUnitFileに変換して@listに追加する.
      #---------------------------------------------------------------------------
      def add_unit_list(unit_list)
        unit_list.each do |unit|
          add_unit(unit)
        end
      end
      #---------------------------------------------------------------------------
      # set_order     : @listを走査してファイル間の依存関係の順にlevelをセットする.
      #---------------------------------------------------------------------------
      def set_order_level
        defined_unit_file = Hash.new
        #-------------------------------------------------------------------------
        # @list を走査してファイルに定義されている unit_name を取り出して、
        # defined_unit_file を生成する.
        #-------------------------------------------------------------------------
        @list.each do |unit_file|
          unit_file.unit_name_list.each do |unit_name|
            defined_unit_file[unit_name] = unit_file
          end
        end
        #-------------------------------------------------------------------------
        # @list を走査して依存関係を構築し、各 unit_file の use_list および
        # be_used_list を作成する.
        #-------------------------------------------------------------------------
        @list.each do |unit_file|
          unit_file.use_name_list.each do |use_name|
            if defined_unit_file.key?(use_name)
              if (unit_file.equal?(defined_unit_file[use_name]) == false)
                unit_file.use_list << defined_unit_file[use_name]
                defined_unit_file[use_name].be_used_list << unit_file
              end
            else
              $stderr.printf "%s : %s を定義しているファイルがみつかりません.\n", unit_file.file_name, use_name
            end
          end
        end
        #-------------------------------------------------------------------------
        # @list を走査して、参照されている順に高い値をlevelにセットする.
        #-------------------------------------------------------------------------
        @list.each do |unit_file|
          if unit_file.use_list.empty? == false
            unit_file.set_level(1, Set.new)
          end
        end
      end
      #---------------------------------------------------------------------------
      # @list を level の高い順番にソートする.
      #---------------------------------------------------------------------------
      def sort_by_level
        @list.sort! { |a,b| a.compare_level(b) }
      end
      #---------------------------------------------------------------------------
      # デバッグ用
      #---------------------------------------------------------------------------
      def debug_print
        @list.each { |unit_file| unit_file.debug_print }
      end
    end
  end
end
