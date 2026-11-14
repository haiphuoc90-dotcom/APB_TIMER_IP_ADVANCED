################################################################################
# Makefile hỗ trợ đa môi trường:
# - Server trung tâm / trường: Dùng QuestaSim (vlib, vlog, vsim, vcover)
# - Máy cá nhân / WSL / Linux: Dùng Icarus Verilog (iverilog, vvp, gtkwave)
################################################################################

TESTNAME        ?= apb_error_handling
TB_NAME         ?= test_bench
RADIX           ?= decimal
REGRESS_LIST    ?= pat.list

# Kiểm tra xem QuestaSim (vlib) có trên máy không
HAS_QUESTA := $(shell command -v vlib 2>/dev/null)

#=============================
all: build run

all_wave: build run wave

all_cov: build_cov run_cov

build:
	@mkdir -p log
	@if [ -f "../testcases/$(TESTNAME).v" ]; then \
		cp -f "../testcases/$(TESTNAME).v" run_test.v; \
	elif [ -f "../test_case/$(TESTNAME).v" ]; then \
		cp -f "../test_case/$(TESTNAME).v" run_test.v; \
	fi
ifdef HAS_QUESTA
	vlib work
	vmap work work
	vlog -f compile.f | tee compile.log
else
	@echo "--- COMPILING WITH ICARUS VERILOG: $(TESTNAME) ---"
	iverilog -g2012 -I ../rtl -I ../tb -I . -o sim.vvp -f compile.f | tee compile.log
endif

build_cov:
ifdef HAS_QUESTA
	mkdir -p log
	@if [ -f "../testcases/$(TESTNAME).v" ]; then \
		cp -f "../testcases/$(TESTNAME).v" run_test.v; \
	elif [ -f "../test_case/$(TESTNAME).v" ]; then \
		cp -f "../test_case/$(TESTNAME).v" run_test.v; \
	fi
	vlib work
	vmap work work
	vlog +cover=bcesft -f compile.f
else
	@$(MAKE) build TESTNAME=$(TESTNAME)
endif

run:
ifdef HAS_QUESTA
	vsim -debugDB -l $(TESTNAME).log -voptargs=+acc -assertdebug -c $(TB_NAME) -do "log -r /*;run -all;"
	cp $(TESTNAME).log ./log
	mv $(TESTNAME).log sim.log
else
	@echo "--- RUNNING SIMULATION (iverilog): $(TESTNAME) ---"
	vvp sim.vvp | tee log/$(TESTNAME).log
endif

run_cov:
ifdef HAS_QUESTA
	vsim -debugDB -coverage -l $(TESTNAME).log -c $(TB_NAME) -voptargs="+cover=bcesft" -assertdebug -do "coverage save -onexit $(TESTNAME).ucdb; log -r /*;run -all"
	cp $(TESTNAME).log ./log
	mv $(TESTNAME).log sim.log
else
	@$(MAKE) run TESTNAME=$(TESTNAME)
endif

wave:
	@if command -v vsim >/dev/null 2>&1; then \
		vsim -i -view vsim.wlf -do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)" & \
	elif command -v gtkwave >/dev/null 2>&1; then \
		gtkwave waveform.vcd & \
	else \
		echo "Neither vsim nor gtkwave found. Please install gtkwave: sudo apt install gtkwave"; \
	fi

gen_cov:
ifdef HAS_QUESTA
	mkdir -p coverage
	vcover merge IP.ucdb *.ucdb
	vcover report IP.ucdb -output coverage/summary_report.txt
	vcover report -zeros -details -code bcesft -annotate -All -codeAll IP.ucdb -output coverage/detail_report.txt
else
	@echo "gen_cov requires QuestaSim (vcover). Not supported on Icarus Verilog."
endif

gen_html:
ifdef HAS_QUESTA
	mkdir -p coverage
	vcover merge IP.ucdb *.ucdb
	vcover report -zeros -details -code bcesft -annotate -testhitdataAll -html IP.ucdb
else
	@echo "gen_html requires QuestaSim (vcover). Not supported on Icarus Verilog."
endif

clean:
	rm -rf work vsim.dbg *.ini *.log *.wlf transcript *.ucdb run_test.v ../tb/run_test.v waveform.vcd sim.vvp log rep.log coverage

# Chạy toàn bộ regression test (Tương thích cả QuestaSim và Icarus Verilog)
regress:
ifdef HAS_QUESTA
	@echo "--- RUNNING QUESTA REGRESSION ---"
	@cat $(REGRESS_LIST) | grep -v '^//' | while read -r pat || [ -n "$$pat" ]; do \
		if [ -n "$$pat" ]; then \
			$(MAKE) all TESTNAME=$$pat || true; \
		fi \
	done
else
	@chmod +x run.sh report.sh 2>/dev/null || true
	@./run.sh
	@./report.sh
endif

all_cov_group:
ifdef HAS_QUESTA
	$(MAKE) all_cov TESTNAME=reg_init_chk
	$(MAKE) all_cov TESTNAME=reg_reserved_chk
	$(MAKE) all_cov TESTNAME=reg_1hot_chk
	$(MAKE) all_cov TESTNAME=reg_byte_access
	$(MAKE) all_cov TESTNAME=reg_rw_chk
	$(MAKE) all_cov TESTNAME=cnt_halt_chk
	$(MAKE) all_cov TESTNAME=cnt_ctrl_chk
	$(MAKE) all_cov TESTNAME=interrupt_chk
	$(MAKE) all_cov TESTNAME=counter_chk
	$(MAKE) all_cov TESTNAME=apb_protocol_chk
	$(MAKE) all_cov TESTNAME=apb_wait_state
	$(MAKE) all_cov TESTNAME=apb_error_handling
else
	@echo "=========================================================================="
	@echo "[THÔNG BÁO]: vlib (QuestaSim) không có trên máy này."
	@echo "Tự động chuyển sang chạy toàn bộ regression test bằng Icarus Verilog..."
	@echo "=========================================================================="
	@chmod +x run.sh report.sh 2>/dev/null || true
	@./run.sh
	@./report.sh
endif

help:
	@echo ""
	@echo "************************************************************************"
	@echo "** make all TESTNAME=<name> : Chạy 1 testcase cụ thể"
	@echo "** make regress             : Chạy toàn bộ 12 testcases"
	@echo "** make all_cov_group       : Chạy đo coverage (QuestaSim) hoặc tự chuyển iverilog"
	@echo "** make wave                : Mở xem dạng sóng (QuestaSim hoặc GTKWave)"
	@echo "** make clean               : Dọn dẹp các file rác sau khi chạy"
	@echo "************************************************************************"
	@echo ""
