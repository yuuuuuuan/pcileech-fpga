# PCILeech CaptainDMA 75T — Intel I219-LM 变体

本目录是 [`../75t484_x1`](../75t484_x1) 的派生变体，面向 **CaptainDMA 75T (xc7a75tfgg484-2)** 硬件板。  
固件伪装身份为 **Intel I219-LM Gigabit Ethernet Controller**，该设备广泛预装于 Lenovo ThinkPad 系列笔记本，驱动在 Windows/Linux 下开箱即用，不会触发"发现新设备"弹窗。

> **⚠️ 重要**：本变体未修改 `../75t484_x1/` 中的任何文件。  
> 所有未修改的源文件（`.sv`、FIFO/BRAM `.xci`、`.xdc`）由 Vivado TCL 脚本直接从 `../75t484_x1/` 引用。

---

## 设备身份参数

| 参数 | 值 | 说明 |
|------|----|------|
| Vendor ID | `0x8086` | Intel |
| Device ID | `0x156F` | I219-LM |
| Revision ID | `0x03` | 常见笔记本版本 |
| Class Code | `0x020000` | Ethernet Controller |
| SubVendor ID | `0x17AA` | Lenovo |
| SubDevice ID | `0x2233` | ThinkPad T460/T560 |
| DSN | `0x000000010100E64B` | PCIe 扩展配置空间设备序列号 |

---

## 与 75t484_x1 的差异（仅 3 个文件）

| 文件 | 修改内容 |
|------|---------|
| `ip/pcie_7x_0.xci` | DID / RevID / SubVen / SubDev / ClassCode（component_parameters + model_parameters 均已同步更新） |
| `ip/pcileech_cfgspace.coe` | 配置空间 BRAM：DW0（VID/DID）、DW2（ClassCode/RevID）、DW11（SubVen/SubDev） |
| `src/pcileech_pcie_cfg_a7.sv` | `rw[127:64]` DSN 寄存器初始值 |

所有其他文件来自 `../75t484_x1/`（通过 TCL 脚本引用）：
- `src/` 下的所有其他 `.sv` / `.svh` 文件
- `ip/` 下的所有 FIFO / BRAM / writemask `.xci` 和 `.coe`
- `src/pcileech_75t484_x1_captaindma_75t.xdc`（引脚约束）

---

## 编译步骤

### 1. 生成 Vivado 工程（约 5~10 分钟）

在 **Vivado Tcl Shell** 中执行：

```tcl
cd <repo>/CaptainDMA/75t484_x1_i219lm
source vivado_generate_project_captaindma_75t_i219lm.tcl -notrace
```

### 2. 编译（综合 + 实现，约 30~60 分钟）

```tcl
source vivado_build.tcl -notrace
```

编译完成后输出 `pcileech_75t484_x1_i219lm.bin`。

### 3. 烧录

**方式一：JTAG 临时（断电丢失）**
1. Vivado → Open Hardware Manager → Open Target → Program Device
2. 选择 `pcileech_75t484_x1_i219lm.bit`

**方式二：SPI Flash 永久**
```tcl
write_cfgmem -format mcs -size 16 -interface SPIx4 \
  -loadbit "up 0x0 pcileech_75t484_x1_i219lm.bit" \
  -file pcileech_75t484_x1_i219lm.mcs
```
然后在 Hardware Manager 中写入 Flash。

**方式三：通过 pcileech USB 更新**
```bash
pcileech.exe flash -v -in pcileech_75t484_x1_i219lm.bin
```

---

## 验证

目标机插入 FPGA 后：

```bash
# Linux
lspci -nn | grep "8086:156f"
# 期望：xx:xx.x Ethernet controller [0200]: Intel Corporation Ethernet Connection I219-LM [8086:156f] (rev 03)

# 详细能力链验证
lspci -vvvs $(lspci -n | grep "8086:156f" | cut -d' ' -f1)
```

攻击者 PC 上（USB 连接后）：

```bash
pcileech identify
# 期望：TARGET: Intel Corporation Ethernet Connection I219-LM (8086:156F)

pcileech dump -min 0x1000 -max 0x1100 -out test.bin
```

---

## 如何为其他设备创建新变体

参照本目录结构：

1. 新建目录 `../75t484_x1_<设备名>/`，创建 `ip/` 和 `src/` 子目录
2. 复制并修改这 3 个文件：
   - `ip/pcie_7x_0.xci`（同时修改 `component_parameters` 和 `model_parameters`）
   - `ip/pcileech_cfgspace.coe`（修改 VID/DID/Class/SubVen/SubDev 对应的 DWORD）
   - `src/pcileech_pcie_cfg_a7.sv`（修改 `rw[127:64]` DSN 值）
3. 复制并修改 `vivado_generate_project_captaindma_75t_<设备名>.tcl`（修改 `_xil_proj_name_`，确保 `shared_dir` 指向 `../75t484_x1`）
4. 复制 `vivado_build.tcl`，修改输出文件名
