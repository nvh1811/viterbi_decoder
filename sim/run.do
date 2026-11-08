# =============================================================================
# File        : sim/run.do
# Mô tả       : Script chạy mô phỏng tự động trên ModelSim / QuestaSim
# Cách dùng   :
#   1. Trên GUI:
#        cd D:/HUST/2026.1/VLSI/Viterbi_decoder/sim
#        do run.do
#        do run.do tb_bmc
#   2. Trong VS Code Terminal:
#        vsim -c -do "do run.do; quit -f"
# =============================================================================

# 1. Nhận tên module testbench từ tham số (mặc định tb_viterbi_decoder)
if {$argc >= 1} {
    set TB_TOP $1
} else {
    set TB_TOP "tb_viterbi_decoder"
}

# 2. Xóa và tạo lại thư viện work
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# 3. Biên dịch toàn bộ RTL và Testbench (ép timescale đồng bộ)
vlog -timescale "1ns/1ps" -work work -f filelist.f

# 4. Khởi chạy mô phỏng (tối ưu hóa giữ lại visibility tín hiệu)
vsim -voptargs="+acc" work.$TB_TOP

# 5. Nếu chạy ở chế độ đồ họa (GUI) thì mở Waveform
if {[batch_mode] == 0} {
    add wave -position insertpoint sim:/$TB_TOP/*
    if {[find instances -bydu -nodu sim:/$TB_TOP/dut] ne ""} {
        add wave -position insertpoint sim:/$TB_TOP/dut/*
    }
}

# 6. Chạy mô phỏng
run -all

if {[batch_mode] == 0} {
    wave zoom full
}