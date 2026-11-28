# =============================================================================
# File        : sim/run.do
# Mô tả       : Script chạy mô phỏng tự động trên ModelSim / QuestaSim
# Cách dùng   :
#   1. Trên GUI (tại cửa sổ Transcript của QuestaSim):
#        cd D:/HUST/2026.1/VLSI/Viterbi_decoder/sim
#        do run.do                   ;# Chạy tb_viterbi_top (chế độ thường)
#        do run.do tb_ctrl           ;# Chạy unit test tb_ctrl
#        do run.do tb_ctrl cov       ;# Chạy tb_ctrl + thu thập & báo cáo coverage
#        do run.do cov               ;# Chạy tb_viterbi_top + coverage
#   2. Trong Terminal (batch mode):
#        vsim -c -do "do run.do tb_in_buf; quit -f"
#        vsim -c -do "do run.do tb_ctrl cov; quit -f"
# =============================================================================

# 1. Đọc tham số dòng lệnh: $1 = tên testbench (hoặc "cov"), $2 = "cov"
set TB_TOP   "tb_viterbi_top"
set COV_MODE 0

if {$argc >= 1} {
    if {[string equal -nocase $1 "cov"]} {
        set COV_MODE 1
    } else {
        set TB_TOP $1
    }
}
if {$argc >= 2 && [string equal -nocase $2 "cov"]} {
    set COV_MODE 1
}

set RUN_DIR "run"
file mkdir $RUN_DIR

# 2. Đóng phiên mô phỏng đang mở (tránh khóa thư viện work khi chạy lại trên GUI)
catch {quit -sim}

# 3. Xóa và tạo lại thư viện work
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# 4. Đọc danh sách file RTL từ filelist.f và biên dịch chọn lọc
set rtl_files {}
if {[file exists filelist.f]} {
    set fp [open "filelist.f" r]
    while {[gets $fp line] >= 0} {
        set trimmed [string trim $line]
        if {[string match "../rtl/*" $trimmed]} {
            lappend rtl_files $trimmed
        }
    }
    close $fp
}

set tb_file "../testbench/${TB_TOP}.v"
set vlog_cov_opt ""
if {$COV_MODE == 1} {
    set vlog_cov_opt "+cover=sbceft"
}

if {[catch {
    if {[llength $rtl_files] > 0 && [file exists $tb_file]} {
        if {$COV_MODE == 1} {
            eval vlog $vlog_cov_opt -timescale "1ns/1ps" -work work $rtl_files
        } else {
            eval vlog -timescale "1ns/1ps" -work work $rtl_files
        }
        vlog -timescale "1ns/1ps" -work work $tb_file
    } else {
        if {$COV_MODE == 1} {
            vlog $vlog_cov_opt -timescale "1ns/1ps" -work work -f filelist.f
        } else {
            vlog -timescale "1ns/1ps" -work work -f filelist.f
        }
    }
} compile_err]} {
    echo ">>> \[ERROR\] Bien dich that bai cho $TB_TOP:"
    echo $compile_err
    return -code error $compile_err
}

# 5. Khởi chạy mô phỏng (+acc giữ nguyên FSM & tín hiệu nội bộ; -onfinish stop để không thoát trước khi xuất báo cáo)
set vsim_cmd [list vsim -voptargs="+acc" -onfinish stop -work work]
if {$COV_MODE == 1} {
    lappend vsim_cmd -coverage
}
lappend vsim_cmd work.$TB_TOP

eval $vsim_cmd

# 6. Nếu ở chế độ đồ họa (GUI), thêm Waveform theo nhóm phân cấp rõ ràng
if {[batch_mode] == 0} {
    configure wave -signalnamewidth 1
    configure wave -timelineunits ns

    add wave -noupdate -divider "TESTBENCH ($TB_TOP)"
    add wave -noupdate -group "TB_$TB_TOP" sim:/$TB_TOP/*

    if {[find instances sim:/$TB_TOP/dut] ne ""} {
        add wave -noupdate -divider "DUT (/dut)"
        add wave -noupdate -group "DUT" sim:/$TB_TOP/dut/*

        # Tự động add thêm các khối con bên trong DUT (nếu có, vd: tb_viterbi_top, tb_met_upd)
        set sub_insts [find instances -recursive sim:/$TB_TOP/dut/*]
        foreach inst $sub_insts {
            set inst_path [lindex $inst 0]
            if {$inst_path ne "" && $inst_path ne "/$TB_TOP/dut"} {
                set grp_name [string map [list "/$TB_TOP/dut/" ""] $inst_path]
                catch {add wave -noupdate -group $grp_name sim:${inst_path}/*}
            }
        }
    }
}

# 7. Chạy mô phỏng
if {$COV_MODE == 1} {
    set ucdb_file "${RUN_DIR}/cov_${TB_TOP}.ucdb"
    coverage save -onexit $ucdb_file
}

run -all

if {[batch_mode] == 0} {
    wave zoom full
}

# 8. Lưu & xuất báo cáo coverage nếu bật chế độ cov
if {$COV_MODE == 1} {
    set ucdb_file "${RUN_DIR}/cov_${TB_TOP}.ucdb"
    coverage save $ucdb_file
    echo "=== COVERAGE SUMMARY ($TB_TOP/dut) ==="
    if {[find instances sim:/$TB_TOP/dut] ne ""} {
        catch {exec vcover report -summary -code bcesf -instance=/$TB_TOP/dut $ucdb_file} rpt_summary
        echo $rpt_summary
        catch {exec vcover report -details -code bcesf -instance=/$TB_TOP/dut -output ${RUN_DIR}/cov_${TB_TOP}.txt $ucdb_file}
        catch {exec vcover report -details -codeAll -instance=/$TB_TOP/dut -output ${RUN_DIR}/cov_${TB_TOP}_all.txt $ucdb_file}
        catch {exec vcover report -html -output ${RUN_DIR}/cov_html_${TB_TOP} -details -codeAll -instance=/$TB_TOP/dut $ucdb_file}
    } else {
        catch {exec vcover report -summary -code bcesf $ucdb_file} rpt_summary
        echo $rpt_summary
        catch {exec vcover report -details -code bcesf -output ${RUN_DIR}/cov_${TB_TOP}.txt $ucdb_file}
    }
    echo ">>> Da luu UCDB: $ucdb_file"
}

if {[batch_mode] == 1} {
    quit -f
}
