#!/bin/bash

wbgen2 -V tim_rcv_core_regs.vhd -H record -p tim_rcv_core_regs_pkg.vhd -K ../../../sim/regs/wb_tim_rcv_core_regs.vh -s defines -C wb_tim_rcv_core_regs.h -f html -D doc/wb_tim_rcv_core.html tim_rcv_core.wb
