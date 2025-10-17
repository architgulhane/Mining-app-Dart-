class MockResponsesService {
  // Pattern matching for questions - ORDER MATTERS! Most specific patterns first
  static String? getHardcodedResponse(String query) {
    final lowerQuery = query.toLowerCase().trim();
    
    // EQUIPMENT STATUS QUESTIONS (Most Specific First)
    
    // 1. Distinct status values with counts
    if (_containsAny(lowerQuery, [
      ['distinct status', 'last 7 days'],
      ['list', 'distinct status'],
      ['all distinct status'],
      ['unique status', 'counts'],
      ['status values', 'last 7']
    ])) {
      return _distinctStatuses();
    }
    
    // 2. Missing or invalid critical fields
    if (_containsAny(lowerQuery, [
      ['20 records', 'missing'],
      ['20 records', 'invalid'],
      ['show 20 records'],
      ['missing', 'invalid', 'critical'],
      ['records', 'missing or invalid']
    ])) {
      return _missingInvalidFields();
    }
    
    // 3. Invalid duration records
    if (_containsAny(lowerQuery, [
      ['duration ≤ 0'],
      ['duration <= 0'],
      ['duration', '≤'],
      ['end_time < start_time'],
      ['end_time', '<', 'start_time'],
      ['records where duration']
    ])) {
      return _invalidDurationRecords();
    }
    
    // 4. Status timeline with gaps/overlaps
    if (_containsAny(lowerQuery, [
      ['status timeline', 'yesterday'],
      ['each equipment_id', 'status timeline'],
      ['ordered status timeline'],
      ['flag overlaps', 'gaps'],
      ['overlaps', 'gaps', '>5'],
      ['status', 'start', 'end', 'gaps']
    ])) {
      return _statusTimeline();
    }
    
    // 5. Transition matrix
    if (_containsAny(lowerQuery, [
      ['transition matrix'],
      ['compute transition'],
      ['from→to'],
      ['illegal transitions'],
      ['status', 'from', 'to', 'pairs']
    ])) {
      return _transitionMatrix();
    }
    
    // 6. Sessions crossing shifts
    if (_containsAny(lowerQuery, [
      ['sessions crossing', 'shifts'],
      ['crossing two shifts'],
      ['sessions', 'without closing'],
      ['identify sessions crossing']
    ])) {
      return _sessionsCrossingShifts();
    }
    
    // 7. Availability KPIs (Specific calculation)
    if (_containsAny(lowerQuery, [
      ['calculate availability', 'utilization'],
      ['availability %', 'utilization %'],
      ['availability', 'standby', '%'],
      ['availability', 'yesterday', 'equipment_id'],
      ['utilization', 'standby', 'equipment_id']
    ])) {
      return _availabilityKPIs();
    }
    
    // 8. Availability Explanation
    if (_containsAny(lowerQuery, [
      ['availability', 'filters', 'mapping'],
      ['availability', 'aggregation steps'],
      ['availability', 'total minutes', 'final'],
      ['availability', 'explain'],
      ['yesterday availability', 'equipment_id', 'show']
    ])) {
      return _availabilityExplain();
    }
    
    // 9. MTBF and MTTR
    if (_containsAny(lowerQuery, [
      ['mtbf', 'mttr'],
      ['mtbf'],
      ['mttr'],
      ['mean time between failures'],
      ['mean time to repair'],
      ['provide mtbf']
    ])) {
      return _mtbfMttr();
    }
    
    // 10. Fleet uptime/downtime by hour (Active vs Inactive Hours)
    if (_containsAny(lowerQuery, [
      ['fleet-level', 'uptime'],
      ['fleet', 'uptime', 'downtime'],
      ['give fleet-level'],
      ['uptime', 'downtime', 'by hour'],
      ['fleet', 'last 48 hours'],
      ['hours', '20%', 'below'],
      ['active', 'inactive', 'hours'],
      ['active vs inactive']
    ])) {
      return _fleetUptime();
    }
    
    // 11. Top 10 downtime reasons
    if (_containsAny(lowerQuery, [
      ['top 10 downtime'],
      ['top 10', 'downtime reasons'],
      ['downtime reasons', 'total minutes'],
      ['downtime reasons', 'last 24']
    ])) {
      return _downtimeReasons();
    }
    
    // 12. Max downtime analysis
    if (_containsAny(lowerQuery, [
      ['max downtime', 'yesterday'],
      ['equipment_id', 'max downtime'],
      ['max downtime', 'preceding'],
      ['max downtime', 'show preceding']
    ])) {
      return _maxDowntimeAnalysis();
    }
    
    // 13. Shift comparison (A vs B)
    if (_containsAny(lowerQuery, [
      ['compare shift a', 'shift b'],
      ['shift a vs shift b'],
      ['shift a', 'shift b', 'availability'],
      ['shift a', 'shift b', 'recovery'],
      ['compare', 'shift', 'availability', 'recovery']
    ])) {
      return _shiftRecoveryComparison();
    }
    
    // 14. Weekday status distribution
    if (_containsAny(lowerQuery, [
      ['status distributions', 'weekday'],
      ['return status', 'weekday'],
      ['status', 'by weekday'],
      ['recurring bad days']
    ])) {
      return _weekdayStatusDistribution();
    }
    
    // 15. GPS work zones
    if (_containsAny(lowerQuery, [
      ['join status to gps'],
      ['gps', 'run minutes'],
      ['run', 'outside', 'zones'],
      ['% run minutes', 'outside']
    ])) {
      return _gpsWorkZones();
    }
    
    // 16. RUN status with speed = 0
    if (_containsAny(lowerQuery, [
      ['status = run', 'speed = 0'],
      ['status', 'run', 'speed', '0'],
      ['run but speed'],
      ['run', 'speed = 0', 'consecutive'],
      ['when status', 'run', 'speed']
    ])) {
      return _runSpeedAnomaly();
    }
    
    // 17. Ingestion latency
    if (_containsAny(lowerQuery, [
      ['ingestion latency'],
      ['report ingestion'],
      ['ingestion', 'last 24 hours'],
      ['latency', 'flag items', '>15']
    ])) {
      return _ingestionLatency();
    }
    
    // 18. Stale telemetry
    if (_containsAny(lowerQuery, [
      ['stale telemetry'],
      ['detect stale'],
      ['no status change', '>2'],
      ['no heartbeat']
    ])) {
      return _staleTelemetry();
    }
    
    // 19. SLA breaches
    if (_containsAny(lowerQuery, [
      ['sla', 'breaches'],
      ['list all breaches'],
      ['down exceeded', 'sla'],
      ['breaches', 'down', '>30']
    ])) {
      return _slaBreaches();
    }
    
    // 20. Alert summary by shift
    if (_containsAny(lowerQuery, [
      ['alert summary'],
      ['produce alert summary'],
      ['auto-alerts', 'triggered'],
      ['alerts', 'acknowledged', 'resolved']
    ])) {
      return _alertSummary();
    }
    
    // PRODUCTION QUESTIONS (Original questions)
    
    if (_contains(lowerQuery, ['ore moved', 'waste moved'])) {
      return _oreAndWasteByShift();
    }
    
    if (_contains(lowerQuery, ['unique trucks', 'loaders', 'shovels'])) {
      return _uniqueEquipmentCount();
    }
    
    if (_contains(lowerQuery, ['payload', 'statistics'])) {
      return _payloadStatistics();
    }
    
    if (_contains(lowerQuery, ['duplicate records'])) {
      return _duplicateRecords();
    }
    
    if (_contains(lowerQuery, ['oee']) && _contains(lowerQuery, ['fleet'])) {
      return _fleetOEE();
    }
    
    if (_contains(lowerQuery, ['cycle time', 'breakdown'])) {
      return _cycleTimeBreakdown();
    }
    
    if (_contains(lowerQuery, ['crusher', 'reconciliation'])) {
      return _crusherReconciliation();
    }
    
    if (_contains(lowerQuery, ['ore grade', 'analysis'])) {
      return _oreGradeAnalysis();
    }
    
    if (_contains(lowerQuery, ['fuel consumption'])) {
      return _fuelConsumption();
    }
    
    if (_contains(lowerQuery, ['hourly throughput'])) {
      return _hourlyThroughput();
    }
    
    if (_contains(lowerQuery, ['shift a', 'shift b', 'compare']) && !lowerQuery.contains('availability')) {
      return _shiftComparison();
    }
    
    if (_contains(lowerQuery, ['week-over-week'])) {
      return _weeklyTrend();
    }
    
    if (_contains(lowerQuery, ['delay reasons'])) {
      return _topDelayReasons();
    }
    
    if (_contains(lowerQuery, ['loader', 'bottleneck'])) {
      return _loaderBottleneck();
    }
    
    if (_contains(lowerQuery, ['haul distance'])) {
      return _haulDistanceAnalysis();
    }
    
    if (_contains(lowerQuery, ['negative', 'impossible values'])) {
      return _dataIntegrityCheck();
    }
    
    if (_contains(lowerQuery, ['timestamp outliers'])) {
      return _timestampOutliers();
    }
    
    if (_contains(lowerQuery, ['gps', 'dump polygons'])) {
      return _gpsValidation();
    }
    
    // Default fallback
    return null;
  }
  
  static bool _contains(String text, List<String> keywords) {
    return keywords.every((keyword) => text.contains(keyword.toLowerCase()));
  }
  
  // Check if ANY of the keyword combinations match
  static bool _containsAny(String text, List<List<String>> keywordGroups) {
    for (var keywords in keywordGroups) {
      if (_contains(text, keywords)) {
        return true;
      }
    }
    return false;
  }
  
  // Response Methods
  
  static String _oreAndWasteByShift() {
    return '''**Total Ore & Waste Moved Yesterday**

**Shift A (06:00 - 14:00):**
• Ore Moved: 12,450 t
• Waste Moved: 8,320 t
• Start: 2025-01-08 06:00:00
• End: 2025-01-08 14:00:00

**Shift B (14:00 - 22:00):**
• Ore Moved: 11,890 t
• Waste Moved: 7,650 t
• Start: 2025-01-08 14:00:00
• End: 2025-01-08 22:00:00

**Shift C (22:00 - 06:00):**
• Ore Moved: 10,230 t
• Waste Moved: 6,890 t
• Start: 2025-01-08 22:00:00
• End: 2025-01-09 06:00:00

**Daily Total:**
• Ore: 34,570 t
• Waste: 22,860 t''';
  }
  
  static String _missingInvalidFields() {
    return '''**Query: Show 20 records with missing/invalid critical fields**

**SQL Query:**
```sql
SELECT *, 
       CASE 
         WHEN equipment_id IS NULL THEN 'Missing equipment_id'
         WHEN status IS NULL THEN 'Missing status'
         WHEN start_time IS NULL THEN 'Missing start_time'
         WHEN end_time IS NULL THEN 'Missing end_time'
         WHEN duration <= 0 THEN 'Invalid duration'
         WHEN end_time < start_time THEN 'End before start'
         ELSE 'Valid'
       END AS issue
FROM equipment_status_data
WHERE equipment_id IS NULL OR status IS NULL 
   OR start_time IS NULL OR end_time IS NULL 
   OR duration <= 0 OR end_time < start_time
LIMIT 20;
```

**Sample Results:**
1. ID: 45892 - Missing equipment_id
2. ID: 45901 - Missing status
3. ID: 45923 - Invalid duration (-5 min)
4. ID: 45967 - Missing start_time
5. ID: 46012 - End before start
6. ID: 46089 - Missing equipment_id
7. ID: 46123 - Invalid duration (0)
8. ID: 46187 - Missing end_time

**Total Issues Found:** 127 records (2.3% of dataset)''';
  }
  
  static String _uniqueEquipmentCount() {
    return '''**Unique Equipment Observed (Last 7 Days)**

**Trucks:** 45 units
IDs: TRK-001 through TRK-045

**Loaders:** 12 units
IDs: LDR-001 through LDR-012

**Shovels:** 8 units
IDs: SHV-001 through SHV-008

**Date Range:** 2025-01-01 to 2025-01-08
**Total Equipment:** 65 units''';
  }
  
  static String _payloadStatistics() {
    return '''**Truck Payload Statistics (Yesterday)**

**Min Payload:** 89.2 t (TRK-023, Load ID: L-89234)
**Median Payload:** 145.7 t
**Mean Payload:** 147.3 t
**Max Payload:** 198.4 t (TRK-015, Load ID: L-89567)

**Sample Records:**
Min: TRK-023, 89.2t, 06:23:45, Pit A → ROM
Max: TRK-015, 198.4t, 14:56:12, Pit B → Crusher

**Total Loads Analyzed:** 1,247''';
  }
  
  static String _duplicateRecords() {
    return '''**Duplicate Records (Last 7 Days)**

**Total Duplicates Found:** 34 records

**Examples:**
1. TRK-012, 2025-01-07 08:15:23 (3 copies)
2. LDR-005, 2025-01-06 14:42:11 (2 copies)
3. TRK-034, 2025-01-05 19:33:04 (2 copies)
4. SHV-002, 2025-01-04 11:08:52 (4 copies)
5. TRK-019, 2025-01-03 16:21:37 (2 copies)

**Root Cause:** Possible double-entry from telemetry system restart''';
  }
  
  static String _invalidDurationRecords() {
    return '''**Query: Return records where duration ≤ 0 or end_time < start_time**

**SQL Query:**
```sql
SELECT equipment_id, start_time, end_time, duration
FROM equipment_status_data
WHERE duration <= 0 OR end_time < start_time;
```

**Results Found:** 23 invalid records

**Examples:**
1. TRK-012: duration = -5 min (end before start)
2. LDR-005: duration = 0 min (invalid)
3. TRK-023: end_time < start_time by 15 min
4. SHV-002: duration = -12 min
5. TRK-034: duration = 0 min

**Impact:** 0.4% of dataset
**Action:** Flagged for data correction''';
  }
  
  static String _fleetOEE() {
    return '''**Truck Fleet OEE (Yesterday)**

**Formula Applied:**
OEE = Availability × Performance × Quality

**Availability:** 87.3%
= (Operating Time / Planned Time) × 100
= (20.95h / 24h) × 100

**Performance:** 91.5%
= (Actual Output / Theoretical Max) × 100
= (34,570t / 37,800t) × 100

**Quality:** 98.2%
= (Good Loads / Total Loads) × 100
= (1,224 / 1,247) × 100

**Overall OEE:** 78.5%
= 87.3% × 91.5% × 98.2%

**Assessment:** Good performance, above 75% industry standard''';
  }
  
  static String _cycleTimeBreakdown() {
    return '''**Average Cycle Time Per Truck (Today)**

**Total Average Cycle:** 24.3 minutes

**Component Breakdown:**
• Queue Time: 3.2 min (13.2%)
• Load Time: 4.5 min (18.5%)
• Haul Time (Loaded): 8.7 min (35.8%)
• Dump Time: 2.1 min (8.6%)
• Return Time (Empty): 5.8 min (23.9%)

**Best Performer:** TRK-008 (19.2 min avg)
**Worst Performer:** TRK-034 (31.7 min avg)

**Cycles Analyzed:** 1,089 complete cycles''';
  }
  
  static String _crusherReconciliation() {
    return '''**Production Reconciliation: Crusher vs Truck Dumps**

**Time Period:** 2025-01-08 06:00 to 2025-01-09 06:00

**Crusher Throughput:** 33,890 t
**Truck Dumps Total:** 34,570 t

**Delta:** -680 t (-2.0%)

**Analysis:**
• Variance within acceptable range (±3%)
• Possible causes:
  - Material stockpile buffer
  - Moisture content differences
  - Measurement calibration variance

**Status:** ✅ Reconciled within tolerance''';
  }
  
  static String _oreGradeAnalysis() {
    return '''**ROM Ore Grade Analysis (Yesterday)**

**Average Grade:** 1.87% Cu
**Tonnage-Weighted Grade:** 1.92% Cu

**Grade Variance:** ±0.15%
**Record Count Used:** 1,247 loads

**Grade Distribution:**
• High Grade (>2.0%): 423 loads (33.9%)
• Medium Grade (1.5-2.0%): 612 loads (49.1%)
• Low Grade (<1.5%): 212 loads (17.0%)

**Highest Grade:** 2.34% Cu (Pit B, Bench 4)
**Lowest Grade:** 1.21% Cu (Pit A, Bench 2)''';
  }
  
  static String _fuelConsumption() {
    return '''**Fuel Consumption by Truck Model (Last 3 Days)**

**CAT 797F (30 units):**
• Fuel: 2.8 L/t hauled
• Rating: ⭐⭐⭐ Average

**Komatsu 930E (15 units):**
• Fuel: 2.4 L/t hauled
• Rating: ⭐⭐⭐⭐⭐ Best

**Liebherr T282C (12 units):**
• Fuel: 3.2 L/t hauled
• Rating: ⭐⭐ Worst

**Fleet Average:** 2.7 L/t
**Potential Savings:** 18% if all trucks matched best performer''';
  }
  
  static String _hourlyThroughput() {
    return '''**Hourly Throughput (Last 48 Hours)**

**Moving Average:** 1,441 t/h

**Hours >20% Below Average (flagged):**
• Hour 14 (2025-01-08 14:00): 1,089 t/h (-24%)
• Hour 23 (2025-01-08 23:00): 1,123 t/h (-22%)
• Hour 31 (2025-01-09 07:00): 1,098 t/h (-24%)
• Hour 42 (2025-01-09 18:00): 1,134 t/h (-21%)

**Peak Hour:** Hour 19 (2025-01-08 19:00) - 1,876 t/h
**Lowest Hour:** Hour 31 (2025-01-09 07:00) - 1,098 t/h

**Trend:** ↗️ Improving over last 12 hours''';
  }
  
  static String _shiftComparison() {
    return '''**Shift A vs Shift B Comparison (Last 7 Days)**

**Shift A (Day Shift):**
• Tons: 86,450 t
• Avg Cycle Time: 23.8 min
• Utilization: 89.2%

**Shift B (Evening Shift):**
• Tons: 81,230 t
• Avg Cycle Time: 24.9 min
• Utilization: 86.7%

**Difference:**
• Tons: +6.4% (Shift A)
• Cycle Time: -1.1 min (Shift A faster)
• Utilization: +2.5% (Shift A higher)

**Statistical Test:** p-value = 0.032
**Conclusion:** ✅ Difference IS statistically significant (p < 0.05)''';
  }
  
  static String _weeklyTrend() {
    return '''**Week-Over-Week Ore Production Trend (6 Weeks)**

**Week 1 (Dec 4-10):** 234,500 t
**Week 2 (Dec 11-17):** 241,200 t (+2.9%)
**Week 3 (Dec 18-24):** 238,900 t (-1.0%)
**Week 4 (Dec 25-31):** 228,300 t (-4.4%) *Holiday effect*
**Week 5 (Jan 1-7):** 243,800 t (+6.8%)
**Week 6 (Jan 8-14):** 247,600 t (+1.6%)

**Trend:** ↗️ Upward (excluding holiday week)

**Next Week Forecast (Baseline):** 250,400 t (+1.1%)
**Confidence:** Medium (±3.5%)''';
  }
  
  static String _topDelayReasons() {
    return '''**Top 5 Delay Reasons (Last 24 Hours)**

**1. Loader Queue**
• Total Time: 487 minutes
• Mean Duration: 8.2 min/event
• Equipment: TRK-001 to TRK-045 (all trucks)

**2. Mechanical Breakdown**
• Total Time: 234 minutes
• Mean Duration: 58.5 min/event
• Equipment: TRK-023, LDR-005, SHV-003

**3. Shift Change**
• Total Time: 180 minutes
• Mean Duration: 60 min/event
• Equipment: Fleet-wide

**4. Wet Conditions**
• Total Time: 156 minutes
• Mean Duration: 26 min/event
• Equipment: Pit A operations

**5. Refueling**
• Total Time: 143 minutes
• Mean Duration: 11.9 min/event
• Equipment: TRK-003, TRK-012, TRK-029''';
  }
  
  static String _loaderBottleneck() {
    return '''**Loader LDR-005 Bottleneck Analysis (Yesterday)**

**Idle Time:** 4.7 hours (highest in fleet)

**Truck Pairings:**
• TRK-012: 12 loads, Avg Queue: 9.3 min
• TRK-015: 11 loads, Avg Queue: 10.1 min
• TRK-023: 14 loads, Avg Queue: 8.7 min
• TRK-034: 9 loads, Avg Queue: 11.4 min
• TRK-041: 13 loads, Avg Queue: 9.8 min

**Average Queue Time:** 9.9 minutes (fleet avg: 3.2 min)

**Likely Bottleneck:**
• LDR-005 mechanical issues (slow bucket cycle)
• Recommend: Immediate maintenance check
• Impact: +309% queue time vs fleet average''';
  }
  
  static String _haulDistanceAnalysis() {
    return '''**Haul Distance Analysis by Location (Yesterday)**

**Longest Average Haul Distance:**

**1. Pit C, Bench 7**
• Distance: 4.8 km
• Avg Cycle Time: 31.2 min (+28% vs fleet avg)
• Fuel Impact: 3.4 L/t (+26% vs fleet avg)
• Loads: 89

**2. Pit A, Bench 5**
• Distance: 4.3 km
• Avg Cycle Time: 28.7 min (+18% vs fleet avg)
• Fuel Impact: 3.1 L/t (+15% vs fleet avg)
• Loads: 134

**3. Pit B, Bench 8**
• Distance: 3.9 km
• Avg Cycle Time: 26.4 min (+9% vs fleet avg)
• Fuel Impact: 2.9 L/t (+7% vs fleet avg)
• Loads: 156

**Recommendation:** Consider crusher relocation or haul road optimization''';
  }
  
  static String _dataIntegrityCheck() {
    return '''**Data Integrity Check - Invalid Values**

**Negative Values Found:**
• 3 records with negative tons
• Record IDs: 46012, 46089, 46234

**Impossible Speeds (>120 km/h):**
• 7 records detected
• TRK-012: 134 km/h (2025-01-08 14:23)
• TRK-029: 127 km/h (2025-01-08 16:45)
• TRK-041: 142 km/h (2025-01-08 19:12)

**Payload Exceeds Capacity (>120% rated):**
• 12 records found
• TRK-015: 198.4t (rated: 180t, +10.2%)
• TRK-023: 203.7t (rated: 180t, +13.2%)

**Total Invalid Records:** 22 (0.4% of dataset)
**Action:** Flagged for manual review''';
  }
  
  static String _timestampOutliers() {
    return '''**Timestamp Outliers Detection**

**Out-of-Order Records:** 8 found
• Records with timestamp earlier than previous entry

**Overlapping Shifts:** 5 instances
• Shift end time > next shift start time
• Example: Shift A ended 14:12, Shift B started 14:00

**Future-Dated Entries:** 3 records
• Dates beyond current system time
• Record IDs: 46567, 46589, 46601
• Dates: 2025-01-15 (6 days in future)

**Total Outliers:** 16 records
**Percentage:** 0.3% of dataset
**Likely Cause:** Clock sync issues on field devices''';
  }
  
  static String _gpsValidation() {
    return '''**GPS Dump Location Validation**

**Analysis Period:** Last 24 hours
**Total Dump Events:** 1,247

**Within Known Dump Polygons:** 1,189 (95.3%)

**Outside Boundary:** 58 dumps (4.7%)

**Breakdown by Location:**
• ROM Pad: 3 outside (±15m tolerance)
• Crusher: 1 outside (±10m tolerance)
• Waste Dump A: 42 outside (±25m tolerance)
• Waste Dump B: 12 outside (±20m tolerance)

**Possible Causes:**
• GPS drift/inaccuracy
• Temporary dump areas not in polygon database
• Equipment operators dumping at unapproved locations

**Recommendation:** Update polygon boundaries or investigate irregular dumps''';
  }
  
  static String _distinctStatuses() {
    return '''**Query: List distinct status values seen in last 7 days and their counts**

**SQL Query:**
```sql
SELECT status, COUNT(*)
FROM equipment_status_data
WHERE date BETWEEN CURDATE() - INTERVAL 7 DAY AND CURDATE()
GROUP BY status;
```

**Results:**
• RUN: 45,892 records (68.2%)
• IDLE: 12,456 records (18.5%)
• DOWN: 5,234 records (7.8%)
• MAINT: 2,890 records (4.3%)
• READY: 890 records (1.3%)

**Unexpected Statuses Flagged:**
• UNKNOWN: 23 records (0.03%) ⚠️
• OFFLINE: 8 records (0.01%) ⚠️
• ERROR: 4 records (0.006%) ⚠️

**Total Records:** 67,397
**Data Quality:** 99.94% valid statuses''';
  }
  
  static String _statusTimeline() {
    return '''**Query: For each equipment_id yesterday, list ordered status timeline**

**SQL Query:**
```sql
SELECT equipment_id, status, start_time, end_time,
       TIMEDIFF(start_time, LAG(end_time) OVER (PARTITION BY equipment_id ORDER BY start_time)) AS gap_from_previous,
       CASE WHEN TIMEDIFF(start_time, LAG(end_time) OVER (PARTITION BY equipment_id ORDER BY start_time)) > '00:05:00' 
            THEN 'Gap >5min' ELSE '' END AS gap_flag,
       CASE WHEN start_time < LAG(end_time) OVER (PARTITION BY equipment_id ORDER BY start_time) 
            THEN 'Overlap' ELSE '' END AS overlap_flag
FROM equipment_status_data
WHERE DATE(date) = CURDATE() - INTERVAL 1 DAY
ORDER BY equipment_id, start_time;
```

**Sample Timeline (TRK-012):**
06:00:00 - 06:15:23 RUN (15.4 min)
06:15:23 - 06:18:45 IDLE (3.4 min)
06:18:45 - 08:42:11 RUN (143.4 min)
08:42:11 - 09:03:00 IDLE (20.8 min)
09:10:00 - 11:25:34 RUN ⚠️ Gap: 7 min
11:25:34 - 11:48:12 DOWN (22.6 min)
11:48:12 - 11:52:00 READY (3.8 min)
11:52:00 - 13:59:45 RUN (127.8 min)

**Flags:** 1 gap >5min, 0 overlaps''';
  }
  
  static String _transitionMatrix() {
    return '''**Query: Compute transition matrix (From→To) for last week**

**SQL Query:**
```sql
WITH transitions AS (
  SELECT equipment_id, status AS from_status,
         LEAD(status) OVER (PARTITION BY equipment_id ORDER BY start_time) AS to_status
  FROM equipment_status_data
  WHERE date BETWEEN CURDATE() - INTERVAL 7 DAY AND CURDATE()
)
SELECT from_status, to_status, COUNT(*) AS transition_count
FROM transitions
GROUP BY from_status, to_status
ORDER BY transition_count DESC;
```

**Results:**
RUN → IDLE: 1,234 (45.2%)
IDLE → RUN: 1,189 (43.6%)
RUN → DOWN: 234 (8.6%)
DOWN → MAINT: 45 (1.6%)
MAINT → READY: 43 (1.6%)
READY → RUN: 41 (1.5%)

**Illegal Transitions Flagged:** ⚠️
DOWN → RUN: 12 (should go through READY)
MAINT → RUN: 5 (should go through READY)

**Compliance:** 99.3%''';
  }
  
  static String _availabilityKPIs() {
    return '''**Query: Calculate Availability %, Utilization %, Standby % by equipment_id for yesterday**

**SQL Query:**
```sql
SELECT equipment_id,
       SUM(CASE WHEN status = 'RUN' THEN duration ELSE 0 END) / SUM(duration) * 100 AS availability_percent,
       SUM(CASE WHEN status IN ('RUN','IDLE') THEN duration ELSE 0 END) / SUM(duration) * 100 AS utilization_percent,
       SUM(CASE WHEN status = 'STANDBY' THEN duration ELSE 0 END) / SUM(duration) * 100 AS standby_percent,
       SUM(duration) AS total_clocked_hours
FROM equipment_status_data
WHERE DATE(date) = CURDATE() - INTERVAL 1 DAY
GROUP BY equipment_id;
```

**Sample Results:**

**TRK-012:**
• Availability: 91.2%
• Utilization: 83.7%
• Standby: 7.5%
• Total Hours: 21.89h

**LDR-005:**
• Availability: 78.3%
• Utilization: 66.1%
• Standby: 12.2%
• Total Hours: 18.79h

**Fleet Average:** 87.3% availability''';
  }
  
  static String _mtbfMttr() {
    return '''**Query: Calculate MTBF (Mean Time Between Failures) and MTTR (Mean Time To Repair) per equipment**

**SQL Query:**
```sql
SELECT equipment_id,
       SUM(CASE WHEN status IN ('RUN','IDLE','STANDBY') THEN duration ELSE 0 END) / 
       NULLIF(COUNT(DISTINCT CASE WHEN status IN ('DOWN','MAINT') THEN DATE(start_time) END), 0) AS mtbf_hours,
       SUM(CASE WHEN status IN ('DOWN','MAINT') THEN duration ELSE 0 END) / 
       NULLIF(COUNT(CASE WHEN status IN ('DOWN','MAINT') THEN 1 END), 0) AS mttr_hours
FROM equipment_status_data
WHERE date >= CURDATE() - INTERVAL 30 DAY
GROUP BY equipment_id;
```

**Formulas:**
• MTBF = Total Operational Time / Number of Failures
• MTTR = Total Downtime / Number of Failures

**Sample Results:**

**Trucks:**
• MTBF: 127.4 hours
• MTTR: 2.3 hours
• 89 failure events

**Loaders:**
• MTBF: 98.6 hours (⚠️ Lowest)
• MTTR: 3.1 hours (⚠️ Highest)
• Needs attention

**Shovels:**
• MTBF: 156.3 hours (✓ Best)
• MTTR: 2.7 hours''';
  }
  
  static String _fleetUptime() {
    return '''**Query: Fleet-level uptime vs downtime by hour**

**SQL Query:**
```sql
SELECT DATE_FORMAT(start_time, '%Y-%m-%d %H:00') AS hour,
       SUM(CASE WHEN status IN ('RUN','IDLE','STANDBY') THEN duration ELSE 0 END) AS uptime_minutes,
       SUM(CASE WHEN status IN ('DOWN','MAINT') THEN duration ELSE 0 END) AS downtime_minutes,
       SUM(CASE WHEN status IN ('RUN','IDLE','STANDBY') THEN duration ELSE 0 END) / 
       SUM(duration) * 100 AS uptime_percent
FROM equipment_status_data
WHERE start_time >= NOW() - INTERVAL 48 HOUR
GROUP BY hour
ORDER BY hour;
```

**Sample Results:**

**⚠️ Flagged Hours (>20% below average):**
• Hour 14: 72.3% uptime (-22.1% vs avg 92.8%)
  Scheduled maintenance overlap
• Hour 23: 74.1% uptime (-20.1%)
  Multiple breakdowns
• Hour 42: 75.2% uptime (-19.0%)
  Weather-related

**Average:** 92.8% uptime, 7.2% downtime
**Peak:** Hour 19 (97.3% uptime)''';
  }
  
  static String _downtimeReasons() {
    return '''**Query: Top 10 downtime reasons with equipment IDs**

**SQL Query:**
```sql
SELECT downtime_reason,
       SUM(duration) AS total_minutes,
       COUNT(*) AS event_count,
       AVG(duration) AS mean_duration,
       GROUP_CONCAT(DISTINCT equipment_id ORDER BY equipment_id SEPARATOR ', ') AS equipment_ids
FROM equipment_status_data
WHERE status IN ('DOWN','MAINT')
  AND start_time >= NOW() - INTERVAL 1 DAY
GROUP BY downtime_reason
ORDER BY total_minutes DESC
LIMIT 10;
```

**Results:**

**1. Engine Failure**
• Total: 234 minutes
• Mean: 58.5 min/event (4 events)
• Equipment: TRK-023, TRK-041, LDR-005, SHV-003

**2. Hydraulic Leak**
• Total: 167 minutes
• Mean: 41.8 min/event (4 events)
• Equipment: TRK-012, TRK-034, LDR-002

**3. Tire Damage**
• Total: 143 minutes
• Equipment: TRK-015, TRK-029

**Total Downtime:** 892 minutes (3.7% of fleet hours)''';
  }
  
  static String _maxDowntimeAnalysis() {
    return '''**Query: Equipment with max downtime and preceding statuses**

**SQL Query:**
```sql
WITH daily_downtime AS (
    SELECT equipment_id,
           DATE(date) AS day,
           SUM(CASE WHEN status IN ('DOWN','MAINT') THEN duration ELSE 0 END) AS total_downtime
    FROM equipment_status_data
    WHERE DATE(date) = CURDATE() - INTERVAL 1 DAY
    GROUP BY equipment_id, day
    ORDER BY total_downtime DESC
    LIMIT 1
)
SELECT eds.equipment_id, eds.start_time, eds.end_time, eds.status, eds.duration
FROM equipment_status_data eds
JOIN daily_downtime dd ON eds.equipment_id = dd.equipment_id AND DATE(eds.date) = dd.day
WHERE eds.start_time >= dd.day
ORDER BY eds.start_time;
```

**Result: TRK-023 (3.9 hours downtime)**

**Down Event #1 (08:42-10:24, 102 min):**
Preceding:
• 08:30 RUN → Normal operation
• 08:42 DOWN → Engine overheat

**Down Event #2 (14:15-15:47, 92 min):**
Preceding:
• 14:05 RUN → Returning from dump
• 14:12 IDLE → Queued
• 14:15 DOWN → Hydraulic pressure drop

**Recommendation:** Level 2 inspection required''';
  }
  
  static String _shiftRecoveryComparison() {
    return '''**Query: Compare Shift A vs Shift B availability and recovery time**

**SQL Query:**
```sql
SELECT shift,
       SUM(CASE WHEN status IN ('RUN','IDLE','STANDBY') THEN duration ELSE 0 END) / SUM(duration) * 100 AS availability_percent,
       AVG(CASE WHEN status IN ('DOWN','MAINT') THEN duration ELSE NULL END) AS avg_recovery_time_minutes,
       COUNT(CASE WHEN status IN ('DOWN','MAINT') THEN 1 END) AS down_event_count
FROM equipment_status_data
WHERE date >= CURDATE() - INTERVAL 7 DAY
GROUP BY shift;
```

**Results:**

**Shift A (Day):**
• Availability: 91.2%
• Avg Recovery: 34.5 minutes
• DOWN Events: 23

**Shift B (Evening):**
• Availability: 87.8%
• Avg Recovery: 47.3 minutes
• DOWN Events: 31

**Difference:**
• +3.4% availability (Shift A better)
• -12.8 min recovery time (Shift A faster)

**t-test:** p=0.019 (✅ significant at p<0.05)

**Possible Reasons:**
• More experienced mechanics on day shift
• Better parts availability during day
• Faster response times in daylight''';
  }
  
  static String _weekdayStatusDistribution() {
    return '''**Query: Status distribution by weekday with z-score anomalies**

**SQL Query:**
```sql
WITH daily_status AS (
    SELECT DAYNAME(date) AS weekday,
           SUM(CASE WHEN status = 'RUN' THEN duration ELSE 0 END) / SUM(duration) * 100 AS run_percent
    FROM equipment_status_data
    WHERE date >= CURDATE() - INTERVAL 6 WEEK
    GROUP BY DATE(date)
)
SELECT weekday,
       AVG(run_percent) AS avg_run_percent,
       STDDEV(run_percent) AS stddev_run_percent
FROM daily_status
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
```

**Results:**

**⚠️ Anomalies:**
• Monday: 87.2% (z-score: -1.3, post-weekend issues)
• Sunday: 85.7% (z-score: -1.8, maintenance focus)

**Best Day:** Wednesday (92.1% avg availability)

**Recommendation:** Review Monday startup procedures''';
  }
  
  static String _gpsWorkZones() {
    return '''**Query: Trucks with RUN status outside assigned GPS work zones**

**SQL Query:**
```sql
SELECT equipment_id,
       SUM(CASE WHEN status = 'RUN' AND gps_zone != assigned_work_zone THEN duration ELSE 0 END) AS minutes_outside_zone,
       SUM(CASE WHEN status = 'RUN' THEN duration ELSE 0 END) AS total_run_minutes,
       (SUM(CASE WHEN status = 'RUN' AND gps_zone != assigned_work_zone THEN duration ELSE 0 END) / 
        SUM(CASE WHEN status = 'RUN' THEN duration ELSE 0 END) * 100) AS percent_outside
FROM equipment_status_data
WHERE start_time >= NOW() - INTERVAL 3 DAY
  AND status = 'RUN'
GROUP BY equipment_id
HAVING minutes_outside_zone > 0
ORDER BY minutes_outside_zone DESC;
```

**Results:**

**TRK-012:**
• RUN Minutes: 2,450 min
• Outside Zone: 89 min (3.6%)

**TRK-023:**
• RUN Minutes: 2,230 min
• Outside Assigned Zone: 156 min (7.0%) ⚠️

**TRK-034:**
• RUN Minutes: 2,180 min
• Outside Assigned Zone: 234 min (10.7%) ⚠️

**Fleet Average:** 4.8% outside zones

**Possible Causes:**
• Equipment reassigned without zone update
• GPS drift near zone boundaries
• Unauthorized equipment usage

**Flagged Units:** TRK-023, TRK-034 (>5% threshold)''';
  }
  
  static String _runSpeedAnomaly() {
    return '''**Query: RUN status records with speed = 0 for >15 minutes**

**SQL Query:**
```sql
SELECT equipment_id, start_time, end_time, duration
FROM equipment_status_data
WHERE status = 'RUN'
  AND speed = 0
  AND duration > 15
ORDER BY duration DESC;
```

**Anomalies Found:**

**1. TRK-012**
• Time: 08:15:00 - 08:32:00 (17 min)
• Suspected: GPS malfunction

**2. TRK-029**
• Time: 14:23:00 - 14:45:00 (22 min)
• Suspected: Status should be IDLE (waiting at scale)

**3. LDR-005**
• Time: 19:12:00 - 19:35:00 (23 min)
• Note: Normal for loaders during loading

**4. TRK-041**
• Time: 03:08:00 - 03:27:00 (19 min)
• Suspected: Sensor error

**Total:** 8 intervals, 6 likely sensor/labeling errors''';
  }
  
  static String _ingestionLatency() {
    return '''**Query: Report ingestion latency (created_at - end_time) >15 minutes**

**SQL Query:**
```sql
SELECT id,
       equipment_id,
       end_time,
       created_at,
       TIMESTAMPDIFF(MINUTE, end_time, created_at) AS latency_minutes
FROM equipment_status_data
WHERE created_at >= NOW() - INTERVAL 1 DAY
  AND TIMESTAMPDIFF(MINUTE, end_time, created_at) > 15
ORDER BY latency_minutes DESC;
```

**Latency Metrics:**
• Max: 23.4 minutes
• Mean: 4.7 minutes
• Median: 2.1 minutes

**Flagged Records (>15 min):** 23 records (0.4%)

**Examples:**
• ID 46234: End 08:15, Created 08:38 (23 min) ⚠️
• ID 46567: End 14:42, Created 15:01 (19 min) ⚠️
• ID 46889: End 19:33, Created 19:50 (17 min) ⚠️

**Root Causes:** Network issues, buffer overflow, queue backlog

**SLA Compliance:** 99.6%''';
  }
  
  static String _staleTelemetry() {
    return '''**Query: Equipment with no telemetry >2 hours during working time**

**SQL Query:**
```sql
SELECT equipment_id,
       MAX(end_time) AS last_telemetry,
       TIMESTAMPDIFF(MINUTE, MAX(end_time), NOW()) AS minutes_since_last_update
FROM equipment_status_data
GROUP BY equipment_id
HAVING minutes_since_last_update > 120
ORDER BY minutes_since_last_update DESC;
```

**Detection Rule:** No status change or heartbeat >2 hours during scheduled working time

**Stale Equipment Found:**

**1. TRK-034**
• Last Update: 2025-01-09 03:15:00
• Current Time: 2025-01-09 07:30:00
• Stale Duration: 4.25 hours ⚠️
• Last Status: RUN

**2. LDR-008**
• Last Update: 2025-01-09 05:42:00
• Current Time: 2025-01-09 07:30:00
• Stale Duration: 1.8 hours
• Last Status: IDLE

**3. SHV-006**
• Last Update: 2025-01-09 02:18:00
• Current Time: 2025-01-09 07:30:00
• Stale Duration: 5.2 hours ⚠️
• Last Status: MAINT

**Total Stale Units:** 3 (4.6% of fleet)

**Action Required:** Field technician dispatch to verify equipment status''';
  }
  
  static String _slaBreaches() {
    return '''**Query: List SLA breaches (DOWN >30 minutes without escalation)**

**SQL Query:**
```sql
SELECT equipment_id, start_time, end_time, duration,
       (duration - 30) AS sla_breach_minutes
FROM equipment_status_data
WHERE status = 'DOWN'
  AND duration > 30
  AND start_time >= CURDATE() - INTERVAL 3 DAY
ORDER BY duration DESC;
```

**SLA Rule:** DOWN status should not exceed 30 minutes

**Breaches Found:** 7 incidents

**1. TRK-023, 2025-01-08 08:42**
• Duration: 102 min ⚠️
• Delta: +72 min over SLA
• Resolved: 10:24

**2. TRK-041, 2025-01-08 14:15**
• Duration: 92 min ⚠️
• Delta: +62 min over SLA
• Resolved: 15:47

**3. LDR-005, 2025-01-07 11:30**
• Duration: 67 min ⚠️
• Delta: +37 min over SLA
• Resolved: 12:37

**SLA Compliance:** 92.3% (7 breaches / 91 DOWN events)''';
  }
  
  static String _alertSummary() {
    return '''**Query: Alert summary grouped by shift for yesterday**

**SQL Query:**
```sql
SELECT shift,
       COUNT(*) AS alerts_triggered,
       SUM(CASE WHEN acknowledged = 1 THEN 1 ELSE 0 END) AS alerts_acknowledged,
       SUM(CASE WHEN resolved = 1 THEN 1 ELSE 0 END) AS alerts_resolved,
       AVG(TIMESTAMPDIFF(MINUTE, alert_time, acknowledged_time)) AS avg_response_minutes
FROM equipment_alerts
WHERE DATE(alert_time) = CURDATE() - INTERVAL 1 DAY
GROUP BY shift;
```

**Results:**

**Shift A (06:00-14:00):**
• Triggered: 34
• Acknowledged: 32 (94.1%)
• Resolved: 28 (82.4%)
• Avg Response: 8.3 min

**Shift B (14:00-22:00):**
• Triggered: 41
• Acknowledged: 38 (92.7%)
• Resolved: 34 (82.9%)
• Avg Response: 11.7 min

**Shift C (22:00-06:00):**
• Triggered: 28
• Acknowledged: 25 (89.3%)
• Resolved: 21 (75.0%)
• Avg Response: 15.2 min

**24-Hour Total:** 103 triggered, 95 acknowledged (92.2%), 83 resolved (80.6%)
**Outstanding:** 12 alerts still open''';
  }
  
  static String _sessionsCrossingShifts() {
    return '''**Query: Sessions crossing shift boundaries without properly closing**

**SQL Query:**
```sql
SELECT equipment_id, start_time, end_time, status, shift
FROM equipment_status_data
WHERE (
    (HOUR(start_time) < 6 AND HOUR(end_time) >= 6) OR
    (HOUR(start_time) < 14 AND HOUR(end_time) >= 14) OR
    (HOUR(start_time) < 22 AND HOUR(end_time) >= 22)
)
AND DATE(start_time) >= CURDATE() - INTERVAL 7 DAY
ORDER BY start_time DESC;
```

**Problematic Sessions Found:** 12 records

**Example 1:**
• Equipment: TRK-012
• Start: 2025-01-08 13:45:00 (Shift A)
• End: 2025-01-08 14:23:00 (Shift B)
• Duration: 38 minutes
• Status: RUN
• Issue: Session not closed at shift boundary

**Example 2:**
• Equipment: LDR-005
• Start: 2025-01-07 21:52:00 (Shift B)
• End: 2025-01-07 22:18:00 (Shift C)
• Duration: 26 minutes
• Status: IDLE

**Recommendation:** Implement shift boundary splitting logic or update data collection to close sessions at shift changes (06:00, 14:00, 22:00)''';
  }
  
  static String _availabilityExplain() {
    return '''**Query: Explain availability calculation for specific equipment**

**SQL Query (Breakdown by Status):**
```sql
SELECT equipment_id,
       status,
       SUM(duration) AS total_minutes,
       (SUM(duration) / (SELECT SUM(duration) FROM equipment_status_data WHERE equipment_id = 'TRK-012' AND DATE(date) = CURDATE() - INTERVAL 1 DAY)) * 100 AS percent_of_day
FROM equipment_status_data
WHERE equipment_id = 'TRK-012'
  AND DATE(date) = CURDATE() - INTERVAL 1 DAY
GROUP BY equipment_id, status;
```

**Example: TRK-012 (Yesterday)**

**Formula:**
Availability % = [(Total Time - DOWN - MAINT) / Total Time] × 100

**Status Breakdown:**
• RUN: 892 min (61.9%)
• IDLE: 234 min (16.2%)
• STANDBY: 156 min (10.8%)
• DOWN: 98 min (6.8%)
• MAINT: 60 min (4.2%)

**Calculation:**
• Total Time: 1,440 minutes (24 hours)
• Operational Time: RUN + IDLE + STANDBY = 892 + 234 + 156 = 1,282 min
• Downtime: DOWN + MAINT = 98 + 60 = 158 min
• Availability = (1,282 / 1,440) × 100 = **89.0%**

**Alternative Formula (from downtime):**
Availability = [(1,440 - 158) / 1,440] × 100 = 89.0% ✓

**Interpretation:** TRK-012 was operationally available 89% of the day. The 11% unavailability was due to downtime (6.8% DOWN + 4.2% MAINT).''';
  }
}
