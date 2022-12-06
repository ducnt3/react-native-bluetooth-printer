# react-native-bluetooth-printer

HOLA SOY PIPECHELA...

EDITADO EN LA NUBE

React-Native plugin for the bluetooth ESC/POS printers.

Any questions or bug please raise a issue.

##Still under developement

#May support Android / IOS

## Installation

### Step 1

Install via github

```bash
npm install https://github.com/ducnt3/react-native-bluetooth-printer.git --save
```

### Step2

Link the plugin to your RN project

```bash
react-native link ducnt3/react-native-bluetooth-printer
```

Or you may need to link manually.
//TODO: manually link guilds.

### Step3

Refers to your JS files

```javascript
import {
  BluetoothManager,
  BluetoothEscposPrinter
} from "react-native-bluetooth-printer";
```

## Usage and APIs

### BluetoothManager

BluetoothManager is the module that for Bluetooth service management, supports Bluetooth status check, enable/disable Bluetooth service,scan devices,connect/unpaire devices.

- isBluetoothEnabled ==>
  async function, check whether Bluetooth service is enabled.
  //TODO: consider to return the the devices information already bound and paired here..

```javascript
BluetoothManager.isBluetoothEnabled().then(
  (enabled) => {
    alert(enabled); // enabled ==> true /false
  },
  (err) => {
    alert(err);
  }
);
```

- enableBluetooth ==> `diff + ANDROID ONLY`
  async function, enable the bluetooth service, returns the devices information already bound and paired. `diff - IOS would just resovle with nil`

```javascript
BluetoothManager.enableBluetooth().then(
  (r) => {
    var paired = [];
    if (r && r.length > 0) {
      for (var i = 0; i < r.length; i++) {
        try {
          paired.push(JSON.parse(r[i])); // NEED TO PARSE THE DEVICE INFORMATION
        } catch (e) {
          //ignore
        }
      }
    }
    console.log(JSON.stringify(paired));
  },
  (err) => {
    alert(err);
  }
);
```

- disableBluetooth ==> `diff + ANDROID ONLY`
  async function ,disable the bluetooth service. `diff - IOS would just resovle with nil`

```javascript
BluetoothManager.disableBluetooth().then(
  () => {
    // do something.
  },
  (err) => {
    alert(err);
  }
);
```

- scanDevices ==>
  async function , scans the bluetooth devices, returns devices found and pared after scan finish. Event [BluetoothManager.EVENT_DEVICE_ALREADY_PAIRED] would be emitted with devices bound; event [BluetoothManager.EVENT_DEVICE_FOUND] would be emitted (many time) as long as new devices found.

samples with events:

```javascript
DeviceEventEmitter.addListener(
  BluetoothManager.EVENT_DEVICE_ALREADY_PAIRED,
  (rsp) => {
    this._deviceAlreadPaired(rsp); // rsp.devices would returns the paired devices array in JSON string.
  }
);
DeviceEventEmitter.addListener(BluetoothManager.EVENT_DEVICE_FOUND, (rsp) => {
  this._deviceFoundEvent(rsp); // rsp.devices would returns the found device object in JSON string
});
```

samples with scanDevices function

```javascript
BluetoothManager.scanDevices().then(
  (scannedDevices) => {
    const parsedObj = JSON.parse(scannedDevices);
    this.setState(
      {
        pairedDs: this.state.pairedDs.cloneWithRows(parsedObj.paired || []),
        foundDs: this.state.foundDs.cloneWithRows(parsedObj.found || []),
        loading: false,
      },
      () => {
        this.paired = parsedObj.paired || [];
        this.found = parsedObj.found || [];
      }
    );
  },
  (er) => {
    this.setState({
      loading: false,
    });
    alert("error" + JSON.stringify(er));
  }
);
```

- connect ==>
  async function, connect the specified devices, if not bound, bound dailog promps.

```javascript
BluetoothManager.connect(rowData.address) // the device address scanned.
  .then(
    (s) => {
      this.setState({
        loading: false,
        boundAddress: rowData.address,
      });
    },
    (e) => {
      this.setState({
        loading: false,
      });
      alert(e);
    }
  );
```

- Events of BluetoothManager module

| Name/KEY                    | DESCRIPTION                                            |
| --------------------------- | ------------------------------------------------------ |
| EVENT_DEVICE_ALREADY_PAIRED | Emits the devices array already paired                 |
| EVENT_DEVICE_DISCOVER_DONE  | Emits when the scan done                               |
| EVENT_DEVICE_FOUND          | Emits when device found during scan                    |
| EVENT_CONNECTION_LOST       | Emits when device connection lost                      |
| EVENT_UNABLE_CONNECT        | Emits when error occurs while trying to connect device |
| EVENT_CONNECTED             | Emits when device connected                            |
| EVENT_BLUETOOTH_NOT_SUPPORT | Emits when device not support bluetooth(android only)  |

### BluetoothEscposPrinter

the printer for receipt printing, following ESC/POS command.

#### printerInit()

init the printer.

#### printAndFeed(int feed)

printer the buffer data and feed (feed lines).

#### printerLeftSpace(int sp)

set the printer left spaces.

#### printerLineSpace(int sp)

set the spaces between lines.

#### printerUnderLine(int line)

set the under line of the text, @param line -- 0 -off, 1 - on, 2 - deeper

#### printerAlign(int align)

set the printer alignment, constansts: BluetoothEscposPrinter.ALIGN.LEFT/BluetoothEscposPrinter.ALIGN.CENTER/BluetoothEscposPrinter.ALIGN.RIGHT.
Not works ant printPic() method.

#### printText(String text, ReadableMap options)

print text, options as following:

- encoding => text encoding, default GBK.
- codepage => codepage using, default 0.
- widthtimes => text font multi times in width, default 0.
- heigthTimes => text font multi times in height, default 0.
- fonttype => text font type, default 0.

Example usage:

```javascript
const printText = async (text, height = 0, width = 0) => {
  return await BluetoothEscposPrinter.printText(text, {
    encoding: "Cp857", // This is Turkish encoding. If you want to print English characters, you don't need to set this option.
    codepage: 13, // This is Turkish codepage. If you want to print English characters, you don't need to set this option.
    fonttype: 0, // This is default font type.
    widthtimes: width, // Text width times
    heigthtimes: height, // Text heigth time
  });
};
```

#### printColumn(ReadableArray columnWidths, ReadableArray columnAligns, ReadableArray columnTexts, ReadableMap options)

print texts in column, Parameters as following:

- columnWidths => int arrays, configs the width of each column, calculate by english character length. ex:the width of "abcdef" is 5 ,the width of "中文" is 4.
- columnAligns => arrays, alignment of each column, values is the same of printerAlign().
- columnTexts => arrays, the texts of each colunm to print.
- options => text print config options, the same of printText() options.

#### setWidth(int width)

sets the widht of the printer.

#### printPic(String base64encodeStr, ReadableMap options)

prints the image which encoded by base64, without schema.

- options: contains the params that may use in printing pic:
  "width": Picture width, basic on devices width(dots, 58mm-384);
  "left": Left padding of the picture, for the printing position adjustment.

Example usage:

```javascript
const printImage = async (base64Image, imageWidth = 384, leftPadding = 0) => {
  return await BluetoothEscposPrinter.printPic(base64Image, {
    width: imageWidth,
    left: leftPadding,
  });
};
```

#### rotate()

set the rotate of the line.

#### setBlob(int weight)

set blob of the line.

#### printQRCode(String content, int size, int correctionLevel, int leftPadding)

prints the qrcode.
content: string text value
size: integer size of qr code.
correctionLevel: L:1, M:0, Q:3, H:2
leftPadding: integer value for left padding of qrcode

Example usage:

```javascript
const printQRCode = async (qrCodeText, qrCodeWidth = 200, leftPadding = 90) => {
  return await BluetoothEscposPrinter.printQRCode(
    qrCodeText,
    qrCodeWidth,
    BluetoothEscposPrinter.ERROR_CORRECTION.H,
    leftPadding
  );
};
```

#### printBarCode(String str, int nType, int nWidthX, int nHeight, int nHriFontType, int nHriFontPosition)

prints the barcode.

Example usage:

```javascript
const printBarcode = async (
  barcodeText,
  barcodeType = BluetoothEscposPrinter.BARCODETYPE.JAN13
) => {
  return await BluetoothEscposPrinter.printBarCode(
    barcodeText,
    barcodeType,
    3,
    120,
    0,
    2
  );
};
```

### Demos of printing a receipt

```javascript
await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.CENTER);
await BluetoothEscposPrinter.setBlob(0);
await BluetoothEscposPrinter.printText("MY LOVED TITLE\n\r", {
  encoding: "GBK",
  codepage: 0,
  widthtimes: 3,
  heigthtimes: 3,
  fonttype: 1,
});
await BluetoothEscposPrinter.setBlob(0);
await BluetoothEscposPrinter.printText("SECOND TITLE\n\r", {
  encoding: "GBK",
  codepage: 0,
  widthtimes: 0,
  heigthtimes: 0,
  fonttype: 1,
});
await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.LEFT);
await BluetoothEscposPrinter.printText("Label：Value\n\r", {});
await BluetoothEscposPrinter.printText("Code：xsd201909210000001\n\r", {});
await BluetoothEscposPrinter.printText(
  "Date：" + dateFormat(new Date(), "yyyy-mm-dd h:MM:ss") + "\n\r",
  {}
);
await BluetoothEscposPrinter.printText("Number：18664896621\n\r", {});
await BluetoothEscposPrinter.printText(
  "--------------------------------\n\r",
  {}
);

await BluetoothEscposPrinter.printText("Amount：64000.00\n\r", {});
await BluetoothEscposPrinter.printText("Tax：0.00\n\r", {});
await BluetoothEscposPrinter.printText("Total：64000.00\n\r", {});
await BluetoothEscposPrinter.printText(
  "--------------------------------\n\r",
  {}
);
await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.CENTER);
await BluetoothEscposPrinter.printText("Thanks for payment\n\r\n\r\n\r", {});
await BluetoothEscposPrinter.printerAlign(BluetoothEscposPrinter.ALIGN.LEFT);
```
