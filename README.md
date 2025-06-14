# mt5_regime_detect

## 📈 **Project Vision**

สร้าง “AI/Automation System” สำหรับตรวจจับตลาด Regime (Trend/Sideway/Trap ฯลฯ) แบบ hedge fund  
**โดยใช้ MQL5 (MetaTrader 5), Expert Advisor (EA) ตัวเดียว รวบรวม feature/indicator ทุกตัว แล้ว export dataset สำหรับ GPT/ML/Backtest/Trade Automation**

---

## ⚡️ **Core Workflow Overview**

1. **MT5 EA (RegimeMasterEA.mq5)**

   - รวม logic indicator ทุกชนิดไว้ใน EA เดียว
   - คำนวณ feature หลัก เช่น BOS, Sweep, Volume Spike, OB Retest, Candle Strength, Session, Multi-TF
   - Fill struct (RegimeFeature) ต่อแท่งเทียน/บาร์
   - Validate แต่ละ feature ด้วย `ValidateFeature` หากไม่ผ่านจะ log และไม่ export
   - Export ข้อมูลเป็น .csv/.json ตาม format ที่ lock ไว้

2. **Data Export**

    - Export dataset ทุกฟีเจอร์ (field ครบ) ไว้ใน `data/exported_features.csv`
      โดยไฟล์จะถูกเปิดแบบ append เพื่อไม่ลบทับข้อมูลเดิม
    - JSON export จะบันทึกลง `data/exported_features.json` แบบต่อท้ายไฟล์เดิมเช่นกัน
    - รองรับ feed ไป GPT/ML/Automation ภายนอก
    - มี `control_panel.mqh` ให้ดูค่าฟีเจอร์ล่าสุดและกด toggle export ON/OFF

3. **Integration**
   - ต่อยอด integration (Python/API) สำหรับ process/monitor/automation เพิ่มเติม

---

## 🛠 **Setup in MetaTrader 5**

Place the entire `EA/` directory and the `indicators/` folder inside your terminal's `MQL5/Experts` directory.
Both folders must sit side by side inside `MQL5/Experts` so that any `..\\EA\\` and
`..\\indicators\\` includes resolve correctly when compiling.

**Important:** All source files in this repository are written for **MQL5** and must be compiled with **MetaEditor&nbsp;5** that ships with MetaTrader&nbsp;5. Attempting to use the MetaTrader&nbsp;4 environment will lead to compiler errors because the API is incompatible.

Common symptoms of compiling in the wrong environment include messages such as `CTrade` not found or "function must have body" for event handlers. Ensure you open the project with MetaEditor&nbsp;5 before building.

```plaintext
MQL5/Experts/
├── EA/
│   └── RegimeMasterEA.mq5
└── indicators/
    ├── atr_tools.mqh
    └── ...
```

All `.mqh` files in `indicators/` are included by `RegimeMasterEA.mq5` using relative paths such as `..\indicators\atr_tools.mqh`. Keep this layout exactly as shipped.

Missing files will produce "undeclared identifier" errors when functions like `CalcATR` or `DetectBOS` are referenced.
## 🧩 **Project Structure**

```plaintext
mt5_regime_detect/
├── EA/
│   ├── RegimeMasterEA.mq5           # EA หลัก รวม logic indicator/export
│   ├── features_struct.mqh          # struct RegimeFeature, type ต่างๆ
│   ├── control_panel.mqh           # on-chart panel + export toggle
│   └── ExportUtils.mqh              # function ช่วย export csv/json, log
├── indicators/
│   ├── bos_detector.mqh             # logic หา BOS + overlay เส้น/ลูกศร
│   │                                   # ใช้ DetectBOS() หรือ DetectBOSLookback() กำหนด lookback ได้
│   ├── sweep_detector.mqh           # logic sweep + overlay vertical line (define SWEEP_DETECTOR_OVERLAY_INDICATOR)
│   ├── volume_tools.mqh             # logic volume spike/divergent
│   ├── volume_display.mqh           # subwindow volume chart with spike/divergence highlight
│   ├── ob_retest.mqh                # logic OB retest/trap + overlay rectangle highlight (width/color adjustable)
│   ├── candle_momentum.mqh          # logic candle strength/direction + overlay icons (define CANDLE_MOMENTUM_OVERLAY_INDICATOR)
│   ├── session_tools.mqh            # logic session/context
│   ├── session_display.mqh          # overlay session zones + news icon (define SESSION_DISPLAY_INDICATOR)
│   ├── atr_tools.mqh                # ATR & StdDev calculations + overlay indicator
│   ├── stddev_display.mqh           # subwindow StdDev line with threshold alert (define STDDEV_DISPLAY_INDICATOR)
│   ├── ma_slope.mqh                 # moving average slope + overlay display (define MA_SLOPE_DISPLAY_INDICATOR)
│   ├── rsi_tools.mqh                # RSI indicator
│   ├── rsi_display.mqh           # subwindow RSI indicator with levels (define RSI_DISPLAY_INDICATOR)
│   ├── mtf_signal_display.mqh        # overlay bitmask from MTF signal (define MTF_SIGNAL_DISPLAY_INDICATOR)
│   ├── regime_display.mqh            # show RegimeType label on chart (define REGIME_DISPLAY_INDICATOR)
│   └── regime_classifier.mqh        # classify market regime
│   # indicator modules now include "..\\EA\\features_struct.mqh" for shared enums
├── data/
│   ├── exported_features.csv        # ไฟล์ export dataset
├── test/
│   ├── test_features_indicator.mq5  # script/unit test function/indicator
│   ├── test_indicator_math.mq5      # validate ATR/StdDev/RSI/MA slope
│   ├── test_detect_regime_sets.mq5  # verify DetectRegime against preset cases
│   ├── test_processbar_history.mq5  # history edge-case tests
│   └── test_processbar_populate.mq5 # mock ProcessBar data population
├── docs/
│   ├── data_dictionary.md           # อธิบาย field/format
│   └── logic_note.md
├── .gitignore
├── requirements.txt                 # Python deps (pandas, numpy, pytest) สำหรับ automation/testing
└── LICENSE
🏗 Key Feature Fields (RegimeFeature struct)
ทุก field ใน struct จะ auto-calc/logic-only, ไม่ manual (strict standard, no “feeling”)

Layer	Field Name	Type	Description
Meta    time,symbol,open,high,low,close,tick_volume,atr,stddev,ma_slope,rsi datetime/string/num  Bar metadata + volatility metrics
Structure/Trend	bos, trend_dir	bool/enum	Break of Structure, Trend direction
Range/Volatility	range_compression	bool	Detect sideway compression/expansion
Volume	volume_spike, divergent	bool	Volume confirm, trap/flip
Liquidity/Sweep	sweep	bool	Liquidity grab, fake breakout
OB Retest/Trap	ob_retest	bool	เจาะจงโซน trap/fake move
Candle/Momentum	candle_strength, dir	enum	Momentum strength/direction
Session/Context	session, news_flag	enum/bool	Market session/context/news flag
Multi-TF	mtf_signal	dict/obj	Cross-check หลาย TF
Classification  regime          enum    Result from DetectRegime

DetectRegime evaluates features and sets `regime` (UPTREND,DOWNTREND,etc.)
Data Dictionary, format, and logic—reference in /docs/data_dictionary.md

🔁 Workflow Summary
EA รวบรวมทุก indicator/feature (import mqh ทุกตัวใน /indicators)

Loop ทุก bar → Fill struct RegimeFeature

Export dataset ตาม format (.csv/.json)

ใช้ปุ่มใน `control_panel.mqh` บนกราฟเพื่อเปิด/ปิดการ export dataset

(Optional) Feed dataset ไป GPT API/ML/Automation layer

Test logic/indicator ทุกตัวใน /test

🛡 Strict Standards / Hedge Fund Rules
ทุก field/feature ห้าม manual, ต้องได้จาก logic/script เท่านั้น

Data validation script/logic ใน ExportUtils.mqh

type, range, completeness check ทุก row

Data Dictionary/Field Type/Enum/Threshold — lock ที่ /docs/data_dictionary.md

Version control + log ทุก commit/feature change

🧠 Extend/Automation Ideas
Integration Python script สำหรับ process/export เพิ่มเติม

Dashboard / Monitor / API feed / Notification (future)

A/B test logic, backtest auto, Meta-learning (future)

👊 Dev Guideline (for AI/Codex/Teammate)
Reference all structure/logic/rules/flow จากไฟล์นี้

เวลาสร้าง/แก้ไฟล์ ให้ maintain logic ตาม field ใน RegimeFeature

ถ้าจะเปลี่ยน field/type/logic ต้องอัปเดต data_dictionary.md ทุกครั้ง

ทุกการ export, validate, integration — ให้ยึด logic+format ตามที่นิยามไว้ตรงนี้

ใช้ parameter รูปแบบ `const MqlRates &rates[]` ในฟังก์ชัน indicator ให้เหมือนกันทุกไฟล์

ถาม/Generate code อะไร — ให้ refer “README.md” repo นี้เป็น base context เสมอ

🏆 Goal
“สร้างระบบวิเคราะห์ Regime ที่ strict, ตรวจสอบย้อนกลับได้, ไม่มี bias/manual, export dataset ได้มาตรฐาน hedge fund, พร้อมต่อยอด ML/GPT/Automation ระดับโลก”
```
