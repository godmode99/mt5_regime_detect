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
   - รองรับ feed ไป GPT/ML/Automation ภายนอก

3. **Integration**
   - ต่อยอด integration (Python/API) สำหรับ process/monitor/automation เพิ่มเติม

---

## 🧩 **Project Structure**

```plaintext
mt5_regime_detect/
├── EA/
│   ├── RegimeMasterEA.mq5           # EA หลัก รวม logic indicator/export
│   ├── features_struct.mqh          # struct RegimeFeature, type ต่างๆ
│   └── ExportUtils.mqh              # function ช่วย export csv/json, log
├── indicators/
│   ├── bos_detector.mqh             # logic หา BOS + overlay เส้น/ลูกศร
│   ├── sweep_detector.mqh           # logic sweep
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
│   └── regime_classifier.mqh        # classify market regime
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

ถาม/Generate code อะไร — ให้ refer “README.md” repo นี้เป็น base context เสมอ

🏆 Goal
“สร้างระบบวิเคราะห์ Regime ที่ strict, ตรวจสอบย้อนกลับได้, ไม่มี bias/manual, export dataset ได้มาตรฐาน hedge fund, พร้อมต่อยอด ML/GPT/Automation ระดับโลก”
```
