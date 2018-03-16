#include <SoftSerial.h>

int MotorSpeed = 1;

int RxD = 2;
int TxD = 3;

SoftSerial btSerialPort(RxD,TxD);

void setupBT() {
  btSerialPort.begin(9600); //Set BluetoothBee BaudRate to default baud rate 38400
}

// the setup routine runs once when you press reset:
void setup() {                
  // initialize the outputs.
  pinMode(MotorSpeed, OUTPUT);
  pinMode(RxD, INPUT);
  pinMode(TxD, OUTPUT);

  setupBT();
  analogWrite(MotorSpeed, 0);  
}

char recvChar;

class BTBuffer {
public:
  BTBuffer() {
    _buf[4] = 0; // always!
    clear();
  }
  ~BTBuffer() {
    
  }

  bool append(const char v) {
    if (v=='\n') {
      _buf[_pos] = '\n';
      return true;
    } else if (_pos<3 && isDigit(v)) {
      _buf[_pos++] = v;
    }
    return false;
  }

  int toInt() const {
    const char *p = _buf;
    int acc = 0;
    while (*p && *p!='\n') {
      acc = acc*10 + (*p++ - '0');
    }
    return acc;
  }

  const char *buf() const {
    return _buf;
  }

  void clear() {
    _pos = 0;
    *((int *)_buf) = 0;
  }

  bool empty() const {
    return (!_buf[0] || _buf[0]=='\n');
  }

private:
  char _buf[5];
  unsigned char _pos;
};

BTBuffer inBuf;

// the loop routine runs over and over again forever:
void loop() {
  while (btSerialPort.available()>0) {
    char inChar = btSerialPort.read();
    if (inBuf.append(inChar)) {
      if (!inBuf.empty()) {
        int val = inBuf.toInt();
        analogWrite(MotorSpeed, val);
        btSerialPort.write(inBuf.buf());
      }
      inBuf.clear();
    }
  }
}
