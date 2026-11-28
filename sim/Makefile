# =============================================================================
# Makefile cho BTL Viterbi Decoder — Nhóm 9 VLSI
# Cách dùng:
#   make                   : Chạy mô phỏng Top testbench (tb_viterbi_top)
#   make gui               : Mở giao diện Waveform QuestaSim (mặc định TB=tb_viterbi_top)
#   make unit TB=tb_in_buf : Chạy 1 unit testbench (hoặc: make tb_in_buf)
#   make all_unit          : Chạy toàn bộ 7 unit testbench và tổng hợp PASS/FAIL
#   make cov TB=tb_ctrl    : Đo code coverage cho 1 testbench (+acc, giữ FSM)
#   make cov_all           : Chạy coverage cho tất cả TB và gộp (vcover merge)
#   make cov_merge         : Gộp các file run/cov_*.ucdb hiện có và xuất báo cáo DU
#   make clean             : Xóa sạch thư mục run/, work/, log và file tạm
#   make help              : Hiển thị hướng dẫn chi tiết
# =============================================================================

SHELL       := /bin/bash
.SHELLFLAGS := -o pipefail -c

RUN_DIR     := run
FILELIST    := filelist.f
TB          ?= tb_viterbi_top
DUT_INST    ?= dut

# Cờ coverage:
# - COV_TYPE: thu thập đủ Statement, Branch, Condition, Expression, FSM, Toggle
# - COV_RPT : mặc định lọc 5 hạng mục theo V-Plan (bcesf); dùng COV_RPT=bcesft nếu muốn cả Toggle
COV_TYPE    ?= sbceft
COV_RPT     ?= bcesf

VLOG_FLAGS  := -timescale "1ns/1ps"
VOPT_FLAGS  := -voptargs="+acc"

RTL_MODULES := in_buf bmc acs met_upd sur_mem trb ctrl viterbi_top
UNIT_TESTS  := tb_in_buf tb_ctrl tb_bmc tb_acs tb_met_upd tb_sur_mem tb_trb
ALL_TESTS   := $(UNIT_TESTS) tb_viterbi_top
COV_TESTS   ?= $(ALL_TESTS)

.PHONY: all help sim gui unit $(UNIT_TESTS) all_unit cov cov_unit cov_all cov_merge clean

# Hàm shell nội bộ: biên dịch RTL (tùy chọn cờ coverage) + đúng file TB nếu có
# Tham số $(1): thư mục work, $(2): file build log, $(3): cờ coverage cho RTL (có thể rỗng)
define compile_tb
	@mkdir -p $(RUN_DIR)
	@if [ -d "$(1)" ]; then vdel -lib $(1) -all; fi
	@vlib $(1)
	@rtl_srcs=$$(grep -E '^[[:space:]]*\.\./rtl/' $(FILELIST) | tr -d '\r'); \
	if [ -f "../testbench/$(TB).v" ] && [ -n "$$rtl_srcs" ]; then \
		echo "vlog $(3) $(VLOG_FLAGS) -work $(1) <RTL> + ../testbench/$(TB).v"; \
		vlog $(3) $(VLOG_FLAGS) -work $(1) $$rtl_srcs > $(2) 2>&1 && \
		vlog $(VLOG_FLAGS) -work $(1) ../testbench/$(TB).v >> $(2) 2>&1; \
	else \
		echo "vlog $(3) $(VLOG_FLAGS) -work $(1) -f $(FILELIST)"; \
		vlog $(3) $(VLOG_FLAGS) -work $(1) -f $(FILELIST) > $(2) 2>&1; \
	fi || { cat $(2); exit 1; }
endef

# Hàm shell nội bộ: kiểm tra log mô phỏng có lỗi runtime/FAIL hay không
# Tham số $(1): file log mô phỏng
define check_sim_log
	@if grep -Eq '\[FAIL\]|TONG SO LOI|Errors: [1-9]|\*\* Error|\*\* Fatal' "$(1)"; then \
		echo ">>> [RESULT] $(TB): FAIL (xem $(1))"; \
		exit 1; \
	else \
		echo ">>> [RESULT] $(TB): PASS"; \
	fi
endef

# 0. Hướng dẫn sử dụng
help:
	@echo "=== Makefile — Viterbi Decoder (Nhom 9 VLSI) ==="
	@echo "  make                      : Chay Top testbench (TB=tb_viterbi_top)"
	@echo "  make sim TB=<tb>          : Chay console 1 testbench bat ky"
	@echo "  make gui TB=<tb>          : Mo QuestaSim GUI + waveform day du"
	@echo "  make unit TB=<tb>         : Chay 1 unit testbench (hoac: make <ten_tb>)"
	@echo "  make all_unit             : Chay ca 7 unit test & in bang PASS/FAIL"
	@echo "  make cov TB=<tb>          : Chay coverage 1 TB -> run/cov_<tb>.txt & HTML"
	@echo "  make cov_all              : Chay coverage cac TB (COV_TESTS=...) & merge"
	@echo "  make cov_merge            : Gop run/cov_*.ucdb hien co -> report theo DU"
	@echo "  make clean                : Xoa toan bo file tam"
	@echo "Bien tuy chon: TB=$(TB) | COV_TYPE=$(COV_TYPE) | COV_RPT=$(COV_RPT)"

# 1. Chạy mặc định Top Testbench (Console mode)
all: sim

sim:
	$(call compile_tb,$(RUN_DIR)/work_$(TB),$(RUN_DIR)/build_$(TB).log,)
	vsim -c $(VOPT_FLAGS) -work $(RUN_DIR)/work_$(TB) $(TB) -do "run -all; quit -f" | tee $(RUN_DIR)/$(TB).log
	$(call check_sim_log,$(RUN_DIR)/$(TB).log)

# 2. Mở giao diện Waveform GUI (kèm tín hiệu nội bộ DUT và chống popup $finish)
gui:
	$(call compile_tb,$(RUN_DIR)/work_$(TB),$(RUN_DIR)/build_$(TB).log,)
	vsim -gui -onfinish stop $(VOPT_FLAGS) -work $(RUN_DIR)/work_$(TB) $(TB) -do \
		'configure wave -signalnamewidth 1; configure wave -timelineunits ns; add wave -noupdate -group "TB_$(TB)" sim:/$(TB)/*; if {[find instances sim:/$(TB)/dut] ne ""} { add wave -noupdate -group "DUT" sim:/$(TB)/dut/*; foreach inst [find instances -recursive sim:/$(TB)/dut/*] { set p [lindex $$inst 0]; if {$$p ne "" && $$p ne "/$(TB)/dut"} { catch {add wave -noupdate -group [string map [list "/$(TB)/dut/" ""] $$p] sim:$${p}/*} } } }; run -all; wave zoom full'

# 3. Chạy từng Unit Test cụ thể (VD: make unit TB=tb_in_buf hoặc make tb_in_buf)
unit: sim

$(UNIT_TESTS):
	@$(MAKE) unit TB=$@

# 4. Tự động chạy toàn bộ 7 Unit test lần lượt và tổng hợp PASS/FAIL
all_unit:
	@mkdir -p $(RUN_DIR)
	@fail_list=""; pass_cnt=0; fail_cnt=0; \
	for t in $(UNIT_TESTS); do \
		echo ""; \
		echo "=== Chay kiem thu: $$t ==="; \
		if $(MAKE) unit TB=$$t; then \
			pass_cnt=$$((pass_cnt + 1)); \
		else \
			fail_cnt=$$((fail_cnt + 1)); \
			fail_list="$$fail_list $$t"; \
		fi; \
	done; \
	echo ""; \
	echo "============================================="; \
	echo "TONG KET UNIT TESTS: PASS=$$pass_cnt | FAIL=$$fail_cnt"; \
	if [ -n "$$fail_list" ]; then \
		echo "CAC TEST FAIL:$$fail_list"; \
		echo "============================================="; \
		exit 1; \
	fi; \
	echo "============================================="

# 5. Đo Code Coverage cho 1 Testbench (giữ +acc để trích xuất FSM & đủ tín hiệu)
cov:
	$(call compile_tb,$(RUN_DIR)/work_cov_$(TB),$(RUN_DIR)/build_cov_$(TB).log,+cover=$(COV_TYPE))
	vsim -c -coverage $(VOPT_FLAGS) -work $(RUN_DIR)/work_cov_$(TB) $(TB) \
		-do "coverage save -onexit $(RUN_DIR)/cov_$(TB).ucdb; run -all; quit -f" | tee $(RUN_DIR)/sim_cov_$(TB).log
	@cp -f $(RUN_DIR)/cov_$(TB).ucdb $(RUN_DIR)/cov.ucdb
	MSYS_NO_PATHCONV=1 vcover report -details -code $(COV_RPT) -instance=/$(TB)/$(DUT_INST) $(RUN_DIR)/cov_$(TB).ucdb > $(RUN_DIR)/cov_$(TB).txt
	MSYS_NO_PATHCONV=1 vcover report -details -codeAll -instance=/$(TB)/$(DUT_INST) $(RUN_DIR)/cov_$(TB).ucdb > $(RUN_DIR)/cov_$(TB)_all.txt
	@cp -f $(RUN_DIR)/cov_$(TB)_all.txt $(RUN_DIR)/cov_report.txt
	MSYS_NO_PATHCONV=1 vcover report -html -output $(RUN_DIR)/cov_html_$(TB) -details -codeAll -instance=/$(TB)/$(DUT_INST) $(RUN_DIR)/cov_$(TB).ucdb
	@echo "--- Coverage Summary ($(TB)/$(DUT_INST), code=$(COV_RPT)) ---"
	MSYS_NO_PATHCONV=1 vcover report -summary -code $(COV_RPT) -instance=/$(TB)/$(DUT_INST) $(RUN_DIR)/cov_$(TB).ucdb
	$(call check_sim_log,$(RUN_DIR)/sim_cov_$(TB).log)

cov_unit: cov

# 6. Chạy coverage cho danh sách COV_TESTS rồi gộp kết quả (vcover merge)
cov_all:
	@mkdir -p $(RUN_DIR)
	@rm -f $(RUN_DIR)/cov_*.ucdb
	@fail_tests=""; \
	for t in $(COV_TESTS); do \
		echo ""; \
		echo "=== Chay Coverage: $$t ==="; \
		if ! $(MAKE) cov TB=$$t; then \
			fail_tests="$$fail_tests $$t"; \
		fi; \
	done; \
	$(MAKE) cov_merge; \
	if [ -n "$$fail_tests" ]; then \
		echo ">>> CANH BAO: Co TB fail trong luc chay cov_all:$$fail_tests"; \
		exit 1; \
	fi

# 7. Gộp tất cả file UCDB đã có và xuất báo cáo theo từng Design Unit RTL
cov_merge:
	@ucdbs=$$(ls $(RUN_DIR)/cov_*.ucdb 2>/dev/null | grep -v 'cov_merged\.ucdb' || true); \
	if [ -z "$$ucdbs" ]; then \
		echo "Khong tim thay file $(RUN_DIR)/cov_*.ucdb de gop. Hay chay 'make cov TB=...' hoac 'make cov_all' truoc."; \
		exit 1; \
	fi; \
	echo "=== Gop coverage tu: $$ucdbs ==="; \
	vcover merge $(RUN_DIR)/cov_merged.ucdb $$ucdbs; \
	vcover report -code $(COV_RPT) $(RUN_DIR)/cov_merged.ucdb > $(RUN_DIR)/cov_merged_summary.txt; \
	: > $(RUN_DIR)/cov_merged_du.txt; \
	for du in $(RTL_MODULES); do \
		vcover report -details -code $(COV_RPT) -du=work.$$du $(RUN_DIR)/cov_merged.ucdb >> $(RUN_DIR)/cov_merged_du.txt 2>/dev/null || true; \
	done; \
	vcover report -html -output $(RUN_DIR)/cov_merged_html -details -codeAll $(RUN_DIR)/cov_merged.ucdb; \
	echo "=== TONG HOP COVERAGE DA GOP (code=$(COV_RPT)) ==="; \
	cat $(RUN_DIR)/cov_merged_summary.txt

# 8. Dọn dẹp toàn bộ file tạm của Makefile và run.do
clean:
	rm -rf $(RUN_DIR) work transcript *.wlf vsim.wlf modelsim.ini *.ucdb cov_html
