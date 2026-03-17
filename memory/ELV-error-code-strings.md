# Error Code String Table

## Format: error_code -> status -> message

| Code | Status | English Message |
|-------|--------|----------------|
| 0 | OK | Normal |
| 1 | ERROR | Overcurrent - High current detected in driver |
| 2 | ERROR | Overload - Load exceeds rated load for 5 seconds or more |
| 3 | ERROR | Motor Feedback Signal Error - Hall signal abnormal or not connected |
| 4 | ERROR | Overvoltage - Input voltage exceeds upper limit |
| 5 | ERROR | Undervoltage - Input voltage below lower limit |
| 6 | ERROR | Driver Overtemperature - Driver temperature too high |
| 7 | ERROR | Startup Failure - Motor cannot start, possibly stuck or power line loose |
| 8 | ERROR | EEPROM Data Error - Internal data error, cannot be cleared by ALM-RST |
| 10 | ERROR | Motor Overtemperature - Motor temperature too high |
| 12 | ERROR | Overspeed - Motor speed exceeds set upper limit |
| 13 | ERROR | Encoder Error - Encoder not connected, overflow, or no Z signal |
| 14 | ERROR | Initial Operation Prohibited - FWD/REV input active when powering on |
| 15 | ERROR | External Stop - EXT-ERROR input signal active |
| 20 | ERROR | Hall Sequence Error - Hall sequence parameter setting error |
| 21 | WARN | Communication Command Error - Parameter out of range or command not supported |
| 22 | WARN | Parameter Setting Error - Parameter value incorrect |

---

## JSON Format

```json
{
  "error_strings": {
    "0": {"status": "OK", "message": "Normal"},
    "1": {"status": "ERROR", "message": "Overcurrent - High current detected in driver"},
    "2": {"status": "ERROR", "message": "Overload - Load exceeds rated load for 5 seconds or more"},
    "3": {"status": "ERROR", "message": "Motor Feedback Signal Error - Hall signal abnormal or not connected"},
    "4": {"status": "ERROR", "message": "Overvoltage - Input voltage exceeds upper limit"},
    "5": {"status": "ERROR", "message": "Undervoltage - Input voltage below lower limit"},
    "6": {"status": "ERROR", "message": "Driver Overtemperature - Driver temperature too high"},
    "7": {"status": "ERROR", "message": "Startup Failure - Motor cannot start"},
    "8": {"status": "ERROR", "message": "EEPROM Data Error - Internal data error"},
    "10": {"status": "ERROR", "message": "Motor Overtemperature - Motor temperature too high"},
    "12": {"status": "ERROR", "message": "Overspeed - Motor speed exceeds limit"},
    "13": {"status": "ERROR", "message": "Encoder Error - Encoder signal error"},
    "14": {"status": "ERROR", "message": "Initial Operation Prohibited - FWD/REV active at power on"},
    "15": {"status": "ERROR", "message": "External Stop - EXT-ERROR input active"},
    "20": {"status": "ERROR", "message": "Hall Sequence Error - Hall parameter setting error"},
    "21": {"status": "WARN", "message": "Communication Command Error - Parameter out of range"},
    "22": {"status": "WARN", "message": "Parameter Setting Error - Parameter value incorrect"}
  }
}
```

---

## C++ Function Example

```cpp
std::string getErrorString(int error_code) {
    switch(error_code) {
        case 0: return "Normal";
        case 1: return "Overcurrent - High current detected in driver";
        case 2: return "Overload - Load exceeds rated load for 5 seconds or more";
        case 3: return "Motor Feedback Signal Error - Hall signal abnormal or not connected";
        case 4: return "Overvoltage - Input voltage exceeds upper limit";
        case 5: return "Undervoltage - Input voltage below lower limit";
        case 6: return "Driver Overtemperature - Driver temperature too high";
        case 7: return "Startup Failure - Motor cannot start";
        case 8: return "EEPROM Data Error - Internal data error";
        case 10: return "Motor Overtemperature - Motor temperature too high";
        case 12: return "Overspeed - Motor speed exceeds set upper limit";
        case 13: return "Encoder Error - Encoder not connected, overflow, or no Z signal";
        case 14: return "Initial Operation Prohibited - FWD/REV input active when powering on";
        case 15: return "External Stop - EXT-ERROR input signal active";
        case 20: return "Hall Sequence Error - Hall sequence parameter setting error";
        case 21: return "Communication Command Error - Parameter out of range or command not supported";
        case 22: return "Parameter Setting Error - Parameter value incorrect";
        default: return "Unknown Error";
    }
}

std::string getErrorStatus(int error_code) {
    if (error_code == 0) return "OK";
    if (error_code == 21 || error_code == 22) return "WARN";
    return "ERROR";
}
```
