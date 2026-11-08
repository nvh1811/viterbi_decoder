# =============================================================================
# Makefile cho BTL Viterbi Decoder — Nhóm 9 VLSI
# Cách dùng:
#   make              : Chạy mô phỏng Top testbench (tb_viterbi_decoder)
#   make gui          : Mở giao diện Waveform QuestaSim cho Top testbench
#   make unit TB=tb_bmc : Chạy riêng 1 unit testbench bất kỳ
#   make all_unit     : Chạy kiểm thử toàn bộ 7 unit testbench
#   make clean        : Xóa sạch thư mục kết quả và file tạm
# =============================================================================

SHELL    := /bin/bash
RUN_DIR  := run
FILELIST := filelist.f
TB       ?= tb_viterbi_decoder

# Danh sách tất cả các Unit Testbench (Tuyển & Nhật)
UNIT_TESTS := tb_input_buffer tb_controller tb_bmc tb_acs tb_metric_update tb_survivor_mem tb_traceback

.PHONY: all sim gui $(UNIT_TESTS) all_unit clean

# 1. Chạy mặc định Top Testbench (Console mode)
all: sim

sim:
	@mkdir -p $(RUN_DIR)
	@if [ -d "$(RUN_DIR)/work" ]; then vdel -lib $(RUN_DIR)/work -all; fi
	vlib $(RUN_DIR)/work
	vlog -timescale "1ns/1ps" -work $(RUN_DIR)/work -f $(FILELIST) > $(RUN_DIR)/build.log 2>&1
	vsim -c -work $(RUN_DIR)/work $(TB) -do "run -all; quit -f" | tee $(RUN_DIR)/$(TB).log

# 2. Mở giao diện Waveform GUI
gui:
	@mkdir -p $(RUN_DIR)
	@if [ -d "$(RUN_DIR)/work" ]; then vdel -lib $(RUN_DIR)/work -all; fi
	vlib $(RUN_DIR)/work
	vlog -timescale "1ns/1ps" -work $(RUN_DIR)/work -f $(FILELIST)
	vsim -gui -work $(RUN_DIR)/work $(TB) -do "add wave sim:/$(TB)/*; run -all; wave zoom full"

# 3. Chạy từng Unit Test cụ thể (VD: make unit TB=tb_bmc)
unit:
	@mkdir -p $(RUN_DIR)
	@if [ -d "$(RUN_DIR)/work_$(TB)" ]; then vdel -lib $(RUN_DIR)/work_$(TB) -all; fi
	vlib $(RUN_DIR)/work_$(TB)
	vlog -timescale "1ns/1ps" -work $(RUN_DIR)/work_$(TB) -f $(FILELIST) > $(RUN_DIR)/build_$(TB).log 2>&1
	vsim -c -work $(RUN_DIR)/work_$(TB) $(TB) -do "run -all; quit -f" | tee $(RUN_DIR)/$(TB).log

# 4. Tự động chạy toàn bộ các Unit test lần lượt
all_unit:
	@for t in $(UNIT_TESTS); do \
		echo "=== Chay kiem thu: $$t ==="; \
		$(MAKE) unit TB=$$t; \
	done

# 5. Dọn dẹp file tạm
clean:
	rm -rf $(RUN_DIR) transcript *.wlf vsim.wlf modelsim.ini