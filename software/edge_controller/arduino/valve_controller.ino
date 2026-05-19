/*
 * ============================================================
 *  Smart Agri-Togo — Arduino Valve Controller Firmware
 *  File   : software/edge_controller/arduino/valve_controller.ino
 *  Author : Ounimborbitibou DJABON
 *
 *  Hardware:
 *    - Arduino Mega 2560
 *    - 4 × 8-channel relay boards (active LOW)
 *    - 25 solenoid valves (one per field cell, grouped by row)
 *    - 1 main pump relay
 *    - Connected to Raspberry Pi via USB Serial
 *
 *  Relay pin mapping:
 *    Row 0 (Onion  A) → Digital pin 22
 *    Row 1 (Onion  B) → Digital pin 23
 *    Row 2 (Carrot  ) → Digital pin 24
 *    Row 3 (Lettuce ) → Digital pin 25
 *    Row 4 (Maize   ) → Digital pin 26
 *    Pump             → Digital pin 27
 *
 *  Serial protocol (commands from Raspberry Pi):
 *    "CMD:VALVE_SET:<row>,<state>\n"  — row=0–4, state=0|1
 *    "CMD:PUMP_SET:<state>\n"         — state=0|1
 *    "CMD:ALL_CLOSE\n"               — emergency close all
 *    "CMD:STATUS\n"                  — return current states
 *
 *  Responses (back to Raspberry Pi):
 *    "OK:VALVE_SET:<row>,<state>\n"
 *    "OK:PUMP_SET:<state>\n"
 *    "OK:ALL_CLOSE\n"
 *    "OK:STATUS:<v0><v1><v2><v3><v4><pump>\n"  (e.g. "OK:STATUS:101000\n")
 *    "ERR:<code>:<message>\n"
 *
 *  Safety features:
 *    - Maximum valve open duration: 4 hours (enforced on Arduino)
 *    - Pump auto-stop if all valves close
 *    - Pump auto-start if any valve opens
 *    - Emergency ALL_CLOSE on Serial timeout (60 seconds)
 *    - Status LED blinks to show loop health
 * ============================================================
 */

#include <Arduino.h>

// ── Pin assignments ───────────────────────────────────────────
const int N_ROWS      = 5;
const int VALVE_PINS[N_ROWS] = {22, 23, 24, 25, 26};
const int PUMP_PIN    = 27;
const int STATUS_LED  = 13;   // built-in LED — blinks every loop

// ── Relay logic (active LOW = relay energises on LOW signal) ──
const int RELAY_ON  = LOW;
const int RELAY_OFF = HIGH;

// ── Safety constants ──────────────────────────────────────────
const unsigned long MAX_VALVE_OPEN_MS  = 4UL * 3600UL * 1000UL;  // 4 hours
const unsigned long SERIAL_TIMEOUT_MS  = 60000UL;                 // 60 seconds

// ── State variables ───────────────────────────────────────────
bool valve_states[N_ROWS]          = {false, false, false, false, false};
bool pump_state                    = false;
unsigned long valve_open_time[N_ROWS];   // millis() when each valve was opened
unsigned long last_serial_cmd_ms   = 0;  // timestamp of last received command

// ── Serial buffer ─────────────────────────────────────────────
String serial_buffer = "";


// ── Setup ─────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);

  // Initialise relay pins — all OFF at startup
  for (int i = 0; i < N_ROWS; i++) {
    pinMode(VALVE_PINS[i], OUTPUT);
    digitalWrite(VALVE_PINS[i], RELAY_OFF);
    valve_open_time[i] = 0;
  }
  pinMode(PUMP_PIN, OUTPUT);
  digitalWrite(PUMP_PIN, RELAY_OFF);

  pinMode(STATUS_LED, OUTPUT);

  // Signal ready to Raspberry Pi
  delay(500);
  Serial.println("OK:BOOT:SmartAgriTogo_ValveController_v1.0");

  last_serial_cmd_ms = millis();
}


// ── Main loop ─────────────────────────────────────────────────
void loop() {
  // 1. Process incoming serial commands
  read_serial();

  // 2. Safety checks
  check_valve_timeouts();
  check_serial_timeout();

  // 3. Heartbeat LED (blinks every second)
  static unsigned long last_blink = 0;
  if (millis() - last_blink > 1000) {
    digitalWrite(STATUS_LED, !digitalRead(STATUS_LED));
    last_blink = millis();
  }
}


// ── Serial communication ──────────────────────────────────────

void read_serial() {
  /*
   * Read characters from serial buffer until newline.
   * Process complete command when '\n' is received.
   */
  while (Serial.available() > 0) {
    char c = Serial.read();
    if (c == '\n') {
      serial_buffer.trim();
      if (serial_buffer.length() > 0) {
        process_command(serial_buffer);
        last_serial_cmd_ms = millis();
      }
      serial_buffer = "";
    } else {
      serial_buffer += c;
      // Prevent buffer overflow
      if (serial_buffer.length() > 64) {
        serial_buffer = "";
      }
    }
  }
}

void process_command(String cmd) {
  /*
   * Parse and execute a command from the Raspberry Pi.
   *
   * Expected format: "CMD:<action>:<data>"
   * Examples:
   *   "CMD:VALVE_SET:2,1"  → open valve row 2
   *   "CMD:PUMP_SET:0"     → stop pump
   *   "CMD:ALL_CLOSE"      → emergency stop
   *   "CMD:STATUS"         → report state
   */

  if (!cmd.startsWith("CMD:")) {
    Serial.println("ERR:PARSE:missing_CMD_prefix");
    return;
  }

  // Strip "CMD:" prefix
  String body = cmd.substring(4);

  // ── VALVE_SET ─────────────────────────────────────────
  if (body.startsWith("VALVE_SET:")) {
    String data  = body.substring(10);
    int    comma = data.indexOf(',');
    if (comma < 0) {
      Serial.println("ERR:VALVE_SET:invalid_format");
      return;
    }
    int row   = data.substring(0, comma).toInt();
    int state = data.substring(comma + 1).toInt();

    if (row < 0 || row >= N_ROWS) {
      Serial.println("ERR:VALVE_SET:invalid_row");
      return;
    }

    set_valve(row, state == 1);
    Serial.print("OK:VALVE_SET:");
    Serial.print(row);
    Serial.print(",");
    Serial.println(state);
  }

  // ── PUMP_SET ──────────────────────────────────────────
  else if (body.startsWith("PUMP_SET:")) {
    int state = body.substring(9).toInt();
    set_pump(state == 1);
    Serial.print("OK:PUMP_SET:");
    Serial.println(state);
  }

  // ── ALL_CLOSE (emergency stop) ────────────────────────
  else if (body == "ALL_CLOSE") {
    emergency_close_all();
    Serial.println("OK:ALL_CLOSE");
  }

  // ── STATUS ────────────────────────────────────────────
  else if (body == "STATUS") {
    send_status();
  }

  // ── Unknown command ───────────────────────────────────
  else {
    Serial.print("ERR:UNKNOWN:");
    Serial.println(body);
  }
}

void send_status() {
  /*
   * Send current valve and pump states to Raspberry Pi.
   * Format: "OK:STATUS:<v0><v1><v2><v3><v4><pump>"
   * Each character is '1' (open/on) or '0' (closed/off).
   * Example: "OK:STATUS:101000" = rows 0,2 open, pump on.
   */
  Serial.print("OK:STATUS:");
  for (int i = 0; i < N_ROWS; i++) {
    Serial.print(valve_states[i] ? '1' : '0');
  }
  Serial.println(pump_state ? '1' : '0');
}


// ── Valve and pump control ────────────────────────────────────

void set_valve(int row, bool open) {
  /*
   * Open or close a single valve relay.
   * Automatically manages pump:
   *   - Start pump when first valve opens
   *   - Stop pump when last valve closes
   */
  valve_states[row] = open;
  digitalWrite(VALVE_PINS[row], open ? RELAY_ON : RELAY_OFF);

  if (open) {
    valve_open_time[row] = millis();
    // Auto-start pump
    if (!pump_state) {
      set_pump(true);
    }
  } else {
    valve_open_time[row] = 0;
    // Auto-stop pump if no valves remain open
    bool any_open = false;
    for (int i = 0; i < N_ROWS; i++) {
      if (valve_states[i]) { any_open = true; break; }
    }
    if (!any_open) {
      set_pump(false);
    }
  }
}

void set_pump(bool on) {
  pump_state = on;
  digitalWrite(PUMP_PIN, on ? RELAY_ON : RELAY_OFF);
}

void emergency_close_all() {
  /*
   * Immediately close all valves and stop the pump.
   * Called on: ALL_CLOSE command, serial timeout, valve timeout.
   */
  for (int i = 0; i < N_ROWS; i++) {
    valve_states[i]    = false;
    valve_open_time[i] = 0;
    digitalWrite(VALVE_PINS[i], RELAY_OFF);
  }
  set_pump(false);
}


// ── Safety watchdog functions ─────────────────────────────────

void check_valve_timeouts() {
  /*
   * Close any valve that has been open longer than MAX_VALVE_OPEN_MS.
   * This prevents flooding in case the Raspberry Pi crashes mid-cycle.
   */
  unsigned long now = millis();
  for (int i = 0; i < N_ROWS; i++) {
    if (valve_states[i] && valve_open_time[i] > 0) {
      if (now - valve_open_time[i] > MAX_VALVE_OPEN_MS) {
        // Force close this valve
        set_valve(i, false);
        Serial.print("OK:SAFETY_CLOSE:row=");
        Serial.println(i);
      }
    }
  }
}

void check_serial_timeout() {
  /*
   * If no command has been received for SERIAL_TIMEOUT_MS,
   * trigger emergency close. This protects the field if the
   * Raspberry Pi crashes, reboots, or loses power.
   *
   * The RPi must send at least one command every 60 seconds
   * to keep the watchdog alive. The STATUS poll in the main
   * loop satisfies this requirement.
   */
  if (millis() - last_serial_cmd_ms > SERIAL_TIMEOUT_MS) {
    bool any_open = false;
    for (int i = 0; i < N_ROWS; i++) {
      if (valve_states[i]) { any_open = true; break; }
    }
    if (any_open) {
      emergency_close_all();
      Serial.println("OK:WATCHDOG:serial_timeout_all_closed");
    }
    // Reset timer to avoid spamming this message every loop
    last_serial_cmd_ms = millis();
  }
}
