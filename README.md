<h1 align="center"> USB Protocol (Verilog RTL Design)</h1>


<p align="center">
<img src="https://img.shields.io/badge/Protocol-USB-blue?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Design-RTL-orange?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Language-Verilog-green?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Flow-OpenROAD-purple?style=for-the-badge"/>
</p>

<p align="center">
<img src="https://img.shields.io/badge/Status-Complete-success?style=flat-square"/>
<img src="https://img.shields.io/badge/Stage-RTL→GDS-blue?style=flat-square"/>
<img src="https://img.shields.io/badge/Tech-Sky130HD-informational?style=flat-square"/>
</p>

---
<p align="center">
 This is a simplified USB RTL implementation focusing on packet transfer, encoding/decoding, and endpoint handling. Full USB features like enumeration and PHY behavior are beyond scope.
</p>

---

## How USB Differs from SPI and I²C

While SPI and I²C are commonly used for short-distance, low-to-moderate speed communication, **USB introduces a significantly more advanced communication model**.

###  Key Differences

| Aspect | USB | SPI | I²C |
|--------|-----|-----|-----|
| Communication Style | Packet-based | Continuous streaming | Byte-oriented |
| Architecture | Host–Device | Master–Slave | Multi-Master |
| Signaling | Differential (D+, D−) | Single-ended | Open-drain |
| Clocking | Embedded (NRZI + Bit Stuffing) | Dedicated clock (SCLK) | Shared clock (SCL) |
| Data Framing | Structured packets | No strict framing | Start/Stop conditions |
| Error Handling | CRC + Handshake (ACK/NAK) | Minimal | ACK/NACK |
| Complexity | High | Low | Medium |

### Summary

> USB extends beyond traditional serial protocols like SPI and I²C by incorporating packetization, embedded clocking, and differential signaling, making it more suitable for high-speed and real-world communication systems.

---

## USB Protocol Overview

<img width="912" height="602" alt="image" src="https://github.com/user-attachments/assets/c4d752ed-51ab-4341-aec4-ef29050b0e88" />

### Description

This project presents a **Verilog RTL implementation of the USB (Universal Serial Bus)** protocol with focus on:

- Packet-based communication (**Token, Data, Handshake**)  
- Differential signaling (**D+ / D− lines**)  
- **NRZI encoding** and **bit stuffing**  
- Endpoint-based data transfer  
- ASIC flow validation using **OpenROAD**  

> This is a simplified USB RTL implementation focusing on packet transfer, encoding/decoding, and endpoint handling. Full USB features like enumeration and PHY-level behavior are beyond the scope of this design.

### Interface Signals

| Signal | Direction | Description |
|--------|----------|-------------|
| D+     | Bidirectional | Differential data line |
| D−     | Bidirectional | Complementary data line |
| CLK    | Internal | System clock |
| RESET  | Input | System reset |
| TX_EN  | Input | Transmit enable |
| RX_EN  | Input | Receive enable |


---
## Working Principle

<img width="1097" height="725" alt="image" src="https://github.com/user-attachments/assets/2ea23ca8-00f5-4984-b0cc-f33cb735804a" />

The USB (Universal Serial Bus) protocol enables communication between a **host and one or more devices** using a structured, packet-based approach over differential signaling lines.

### 🔹 1. Host-Driven Communication
- USB follows a **host-controlled architecture**
- All communication is **initiated by the host**
- Devices respond only when requested

### 🔹 2. Differential Signaling (D+ / D−)
- Data is transmitted using **two complementary lines (D+ and D−)**
- Improves **noise immunity** and signal integrity
- Logical states are represented using voltage differences

### 🔹 3. Packet-Based Communication
USB transfers data using three main packet types:
- **Token Packet** → Specifies address and transfer type  
- **Data Packet** → Carries actual payload  
- **Handshake Packet** → Provides status (ACK / NAK / STALL)

### 🔹 4. Data Transfer Flow
1. Host sends a **Token Packet**  
2. Device responds with a **Data Packet**  
3. Host completes with a **Handshake Packet**
   
### 🔹 5. NRZI Encoding
- USB uses **Non-Return-to-Zero Inverted (NRZI)** encoding:
  - `1` → No transition  
  - `0` → Transition  
- Ensures efficient data transmission without frequent toggling

### 🔹 Bit Stuffing
- To maintain synchronization:
  - After **six consecutive ‘1’s**, a `0` is inserted
- Prevents loss of clock information during transmission


> USB combines differential signaling, NRZI encoding, and structured packet communication to enable reliable, high-speed data transfer in a host-controlled system.
---
## USB Packet Structure

- **Token Packet** → Address & control  
- **Data Packet** → Payload  
- **Handshake Packet** → Status (ACK / NAK / STALL) 

---

##  Data Transfer Mechanism

- Serial communication using shift logic  
- NRZI encoding/decoding  
- Bit stuffing removal/insertion  

```verilog
// Example: NRZI Encoding Logic
always @(posedge clk) begin
    if (data_in == 1'b0)
        d_plus <= ~d_plus;
    else
        d_plus <= d_plus;
end
```
---
## Architecture

### Top Module
- Integrates TX, RX, endpoints  
- Controls overall USB communication flow  

### Transmitter (`usb_tx.v`)
- Handles packet generation  
- NRZI encoding  
- Bit stuffing  

### Receiver (`usb_recv.v`)
- NRZI decoding  
- Bit unstuffing  
- Packet extraction  

### Endpoint (`usb_ep.v`, `usb_ep_banked.v`)
- Manages data buffers  
- Handles endpoint addressing  
- Supports multiple transfers  

### Utility Modules (`usb_utils.v`, `utils.v`)
- Common logic blocks  
- Encoding/decoding helpers  


---

##  Module Breakdown

### `usb_top.v`
- Top-level integration  
- Connects TX, RX, endpoints  
- Routes USB signals  


### `usb_tx.v`
- Packet formation  
- Encoding logic  
- Transmission FSM  

**FSM:**

> IDLE → SYNC → DATA → EOP

### `usb_recv.v`
- Packet detection  
- Decoding logic  
- Reception FSM  

**FSM:**

> IDLE → SYNC → RECEIVE → DECODE → DONE

### `usb_ep.v`
- Endpoint control logic  
- Data buffering  


### `usb_ep_banked.v`
- Multi-buffer endpoint support  
- Improves throughput  


---

##  Operation Flow

### Transmit Flow


> LOAD DATA → ENCODE → TRANSMIT → EOP



### Receive Flow


> DETECT SYNC → DECODE → STORE DATA → ACK

---

##  OpenROAD Results

### 🔹 Timing

```
 "finish__timing__setup__ws": 16.5348 (MET)
 "finish__timing__hold__ws" : 0.349513 (MET)
```


### 🔹 Area

``` 
"finish__design__instance__count__stdcell"       : 683
"finish__design__instance__area__stdcell"        : 6954.17 um^2
"finish__design__instance__utilization__stdcell" : 0.583824 (58%)

```


### 🔹 Physical Verification


```
 "finish__timing__drv__setup_violation_count" : 0
 "finish__timing__drv__hold_violation_count"  : 0
```

---

##  Final Output

- `6_final.odb`
  
  <img width="1919" height="1020" alt="image" src="https://github.com/user-attachments/assets/65a370ec-3e97-4814-b7ce-0926c0779b8f" />

  > → Post-layout optimized database  

- `6_final.gds`

  <img width="1919" height="1016" alt="image" src="https://github.com/user-attachments/assets/2f796fec-e275-4510-af75-127b43309062" />

  > → Tape-out ready layout

---

<p align="center"><b>
This project demonstrates progression from basic protocols (SPI, I²C) to a more complex, real-world communication system (USB).
</p>

---
