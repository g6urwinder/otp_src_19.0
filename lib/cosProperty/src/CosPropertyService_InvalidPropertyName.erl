%%  coding: latin-1
%%------------------------------------------------------------
%%
%% Implementation stub file
%% 
%% Target: CosPropertyService_InvalidPropertyName
%% Source: /net/isildur/ldisk/daily_build/19_prebuild_master-opu_o.2016-06-21_20/otp_src_19/lib/cosProperty/src/CosProperty.idl
%% IC vsn: 4.4.1
%% 
%% This file is automatically generated. DO NOT EDIT IT.
%%
%%------------------------------------------------------------

-module('CosPropertyService_InvalidPropertyName').
-ic_compiled("4_4_1").


-include("CosPropertyService.hrl").

-export([tc/0,id/0,name/0]).



%% returns type code
tc() -> {tk_except,"IDL:omg.org/CosPropertyService/InvalidPropertyName:1.0",
                   "InvalidPropertyName",[]}.

%% returns id
id() -> "IDL:omg.org/CosPropertyService/InvalidPropertyName:1.0".

%% returns name
name() -> "CosPropertyService_InvalidPropertyName".



