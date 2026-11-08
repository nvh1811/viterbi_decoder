# Bộ Giải Mã Viterbi (K=3, R=1/2) — Nhóm 9 VLSI

Dự án thiết kế, kiểm chứng (Verification) và tổng hợp (Synthesis) bộ giải mã Viterbi quyết định cứng (Hard-decision).

---

## 1. Thông số kỹ thuật chính (Specifications)
- **Thuật toán:** Hard-decision Viterbi Decoder, khoảng cách Hamming.
- **Tham số mã:** Constraint Length `K = 3` (4 trạng thái: `00`, `01`, `10`, `11`), Coding Rate `R = 1/2`.
- **Đa thức sinh:** $g_1 = 111$ ($x^2 + x + 1$), $g_2 = 101$ ($x^2 + 1$).
- **Giao diện dữ liệu:**
  - `data_in[15:0]`: Khung dữ liệu 16-bit nhận từ kênh truyền (8 cặp bit).
  - `data_out[7:0]`: 8-bit bản tin gốc được giải mã khôi phục.
- **Độ trễ xử lý (Latency):** Đúng **18 chu kỳ clock** từ khi nhận xung `start` đến khi phát cờ `done`.

---

## 2. Công cụ hỗ trợ thiết kế (Tools)
- **Tool vẽ Diagram:** [https://app.diagrams.net/](https://app.diagrams.net/) 
- **Tool vẽ Waveform:** [https://wavedrom.com/editor.html](https://wavedrom.com/editor.html)

---

## 3. Cấu trúc thư mục & Phân chia công việc

```text
Viterbi_decoder/
├── data_file/
│   ├── input.txt              # 1024 khung 16-bit mã hóa (đưa vào data_in)
│   └── output.txt             # 1024 bản tin 8-bit chuẩn (đối chiếu data_out)
├── docs/                      # Bản vẽ kiến trúc, FSM, Datapath, Waveform 
│   ├── figures/               # Các sơ đồ khối chi tiết (.png)
│   ├── Viterbi_decoder.drawio # File thiết kế drawio gốc
│   └── waveform.svg           # Giản đồ định thời hệ thống
├── ref/                       # Tài liệu tham khảo
├── rtl/                       
│   ├── input_buffer.v         # (VT-013) Chốt khung 16-bit & 8 cặp rx_pair
│   ├── metric_update.v        # (VT-014, VT-015) Gồm: bmc, acs, metric_update
│   ├── survivor_mem.v         # (VT-016) Bộ nhớ 8x4 bit lưu decision_vec
│   ├── traceback.v            # (VT-017) Chọn state có PM min & truy vết 8 bước
│   ├── controller.v           # (VT-018) FSM 5 trạng thái, bộ đếm & 7 enable
│   └── viterbi_decoder.v      # (VT-019) Top module kết nối 5 khối chức năng
├── testbench/                 # 
│   ├── tb_input_buffer.v      # [VT-020a] Unit test cho input_buffer
│   ├── tb_controller.v        # [VT-020a] Unit test cho controller & FSM
│   ├── tb_survivor_mem.v      # [VT-020c] Unit test cho survivor_mem
│   ├── tb_traceback.v         # [VT-020c] Unit test cho traceback
│   ├── tb_bmc.v               # [VT-020b] Unit test cho BMC
│   ├── tb_acs.v               # [VT-020b] Unit test cho ACS
│   ├── tb_metric_update.v     # [VT-020b] Unit test cho metric_update
│   └── tb_viterbi_decoder.v   # [VT-020d] Testbench Top (chạy 1024 vector)
└── sim/                       # Môi trường chạy mô phỏng
    ├── filelist.f             # Danh sách file mã nguồn RTL và Testbench
    ├── Makefile               # Script tự động hóa dòng lệnh (Make)
    └── run.do                 # Script cấu hình mô phỏng  cho QuestaSim
```

---

## 4. Hướng dẫn chạy mô phỏng (Simulation)

> **Lưu ý:** Trước khi chạy, luôn mở terminal và chuyển vào thư mục `sim`:
> ```bash
> cd sim
> ```

### Cách 1: Sử dụng Makefile (Khuyên dùng trong VS Code)

Dành cho các bạn thích thao tác nhanh qua dòng lệnh hoặc chạy kiểm thử tự động:

| Mục đích | Lệnh chạy | Mô tả |
| :--- | :--- | :--- |
| **Chạy Testbench Top** | `make` | Chạy 1024 test vector, in kết quả PASS/FAIL ra terminal và lưu log tại `run/tb_viterbi_decoder.log`. |
| **Mở Waveform GUI** | `make gui` | Tự động biên dịch và mở giao diện QuestaSim hiển thị đầy đủ dạng sóng đã tô màu. |
| **Chạy 1 Unit Test riêng** | `make unit TB=<tên_tb>` | Ví dụ: `make unit TB=tb_bmc` hoặc `make unit TB=tb_input_buffer`. |
| **Chạy tất cả 7 Unit Test** | `make all_unit` | Tự động chạy lần lượt toàn bộ 7 testbench con để kiểm tra hồi quy. |
| **Dọn dẹp file rác** | `make clean` | Xóa thư mục tạm `run/`, thư viện `work/` và các file log mô phỏng. |

---

### Cách 2: Sử dụng `run.do` trong QuestaSim / ModelSim

Dành cho các bạn mở phần mềm QuestaSim GUI:

1. Tại cửa sổ **Transcript** của QuestaSim, gõ lệnh chuyển vào thư mục `sim`:
   ```tcl
   cd D:/HUST/2026.1/VLSI/Viterbi_decoder/sim
   ```
2. Chạy Testbench Top (`tb_viterbi_decoder`):
   ```tcl
   do run.do
   ```
3. Chạy một Unit Testbench bất kỳ:
   ```tcl
   do run.do tb_input_buffer
   do run.do tb_bmc
   do run.do tb_controller
   ```

---

## 5. Hướng dẫn sử dụng Git & Phối hợp nhóm

### 5.1. Quy định vùng code (Tránh xung đột Merge Conflict)
Mỗi thành viên chỉ chỉnh sửa trong phạm vi file được phân công để hạn chế tối đa xung đột code:
- **Hiếu:** Chỉ sửa các file thiết kế trong thư mục `rtl/`.
- **Tuyển:** Chỉ sửa các file testbench được giao (`tb_input_buffer.v`, `tb_controller.v`, `tb_survivor_mem.v`, `tb_traceback.v`).
- **Nhật:** Chỉ sửa các file testbench được giao (`tb_bmc.v`, `tb_acs.v`, `tb_metric_update.v`, `tb_viterbi_decoder.v`).

---

### 5.2. Lần đầu tải dự án về máy (Clone)
Nếu máy bạn chưa có dự án, mở Terminal trong VS Code và chạy:
```bash
git clone <URL_repo_GitHub>
cd Viterbi_decoder
```

---

### 5.3. Quy trình làm việc (Pull → Sửa file → Commit → Push)

Cả nhóm thống nhất làm việc trực tiếp trên nhánh `main` theo đúng 4 bước sau:

1. **Bước 1 — Luôn kéo code mới nhất về trước khi sửa file:**
   ```bash
   git pull origin main
   ```
2. **Bước 2 — Chỉnh sửa file & chạy mô phỏng kiểm tra:**
   - Sửa các file được phân công trong `rtl/` hoặc `testbench/`.
   - Chạy mô phỏng tại thư mục `sim/` để đảm bảo code không bị lỗi cú pháp.
3. **Bước 3 — Kiểm tra các file vừa thay đổi:**
   ```bash
   git status
   ```
4. **Bước 4 — Lưu thay đổi (Commit) và đẩy lên GitHub (Push):**
   ```bash
   git add .                                              # Hoặc git add <tên_file>
   git commit -m "[RTL/TB] Mo ta ngan gon noi dung sua"
   git push origin main
   ```

---

### 5.4. Bảng tra cứu nhanh các lệnh Git thường dùng

| Mục đích | Câu lệnh Git |
| :--- | :--- |
| Kéo code mới nhất từ GitHub về máy | `git pull origin main` |
| Xem trạng thái các file đang sửa | `git status` |
| Xem chi tiết các dòng code vừa sửa | `git diff` |
| Xem lịch sử commit gọn gàng | `git log --oneline` |
| Hủy bỏ thay đổi của 1 file (khi sửa nhầm, chưa `git add`) | `git checkout -- <đường_dẫn_file>` |
| Bỏ file ra khỏi vùng chuẩn bị commit (đã lỡ `git add`) | `git reset HEAD <đường_dẫn_file>` |
| Tạm cất code đang sửa dở để `git pull` | `git stash` *(lấy lại bằng `git stash pop`)* |

---

### 5.5. Cách xử lý khi bị từ chối Push hoặc gặp xung đột (Conflict)

- **Trường hợp 1: Báo lỗi `rejected - non-fast-forward` khi `git push`** (do bạn cùng nhóm vừa đẩy code mới lên mà máy bạn chưa cập nhật):
  ```bash
  git pull --rebase origin main
  git push origin main
  ```
- **Trường hợp 2: Báo lỗi `CONFLICT` khi `git pull`** (do 2 người vô tình sửa cùng 1 file):
  1. Mở file bị báo lỗi trong VS Code, tìm các đoạn đánh dấu `<<<<<<<`, `=======`, `>>>>>>>`.
  2. Nhấn chọn trực tiếp trên VS Code: **Accept Current Change** (giữ code của bạn), **Accept Incoming Change** (lấy code trên mạng), hoặc **Accept Both Changes** (giữ cả hai), rồi lưu file lại (`Ctrl + S`).
  3. Hoàn tất và đẩy lên lại:
     ```bash
     git add <file_bị_xung_đột>
     git commit -m "Fix merge conflict"
     git push origin main
     ```
