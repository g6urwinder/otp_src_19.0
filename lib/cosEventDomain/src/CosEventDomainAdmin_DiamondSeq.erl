%%  coding: latin-1
%%------------------------------------------------------------
%%
%% Implementation stub file
%% 
%% Target: CosEventDomainAdmin_DiamondSeq
%% Source: /net/isildur/ldisk/daily_build/19_prebuild_master-opu_o.2016-06-21_20/otp_src_19/lib/cosEventDomain/src/CosEventDomainAdmin.idl
%% IC vsn: 4.4.1
%% 
%% This file is automatically generated. DO NOT EDIT IT.
%%
%%------------------------------------------------------------

-module('CosEventDomainAdmin_DiamondSeq').
-ic_compiled("4_4_1").


-include("CosEventDomainAdmin.hrl").

-export([tc/0,id/0,name/0]).



%% returns type code
tc() -> {tk_sequence,{tk_sequence,{tk_sequence,tk_long,0},0},0}.

%% returns id
id() -> "IDL:omg.org/CosEventDomainAdmin/DiamondSeq:1.0".

%% returns name
name() -> "CosEventDomainAdmin_DiamondSeq".


