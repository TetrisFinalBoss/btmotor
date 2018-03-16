import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3
import QtBluetooth 5.9

ApplicationWindow {

    visible: true
    width: 640
    height: 480
    title: qsTr("DC Motor Control")

Item {
    id: top

    anchors.fill: parent

    Component.onCompleted: state = "search"

    property bool _found: false
    property string _deviceName: ""

    BluetoothDiscoveryModel {
        id: btDiscovery
        running: true
        discoveryMode: BluetoothDiscoveryModel.FullServiceDiscovery

        onRunningChanged: {
            if (!btDiscovery.running && top.state == "search" && !top._found) {
                searchBox._running = false
                searchBox.appendText("\nNothing found")
            }
        }

        onErrorChanged: {
            if (error != BluetoothDiscoveryModel.NoError && !btDiscovery.running) {
                searchBox._running = false
                searchBox.appendText("\n\nDiscovery failed!")
            }
        }

        onServiceDiscovered: {
            if (top._found) {
                return
            }

            top._found = true
            console.log("Found new service " + service.deviceAddress + " " + service.deviceName + " " + service.serviceName)
            searchBox.appendText("\nConnecting...")
            top._deviceName = service.deviceName
            socket.setService(service)
        }

        uuidFilter: "00001101-0000-1000-8000-00805F9B34FB"
    }

    BluetoothSocket {
        id: socket
        connected: true

        onSocketStateChanged: {
            switch (socketState) {
            case BluetoothSocket.Unconnected:
            case BluetoothSocket.NoServiceSet:
                searchBox._running = false
                searchBox.setText("\nNo connection")
                top.state = "search"
                break
            case BluetoothSocket.Connected:
                console.log("Connected!")
                top.state = "control"
                break
            }
        }

        onStringDataChanged: {
            console.log("Received data: " )

            var data = socket.stringData;
            console.log(top._deviceName + ": " + data);

            data = data.substring(0, data.indexOf('\n'))

            if (!controlBox._disabled && data.length>0) {
                currentVal.text = data
            }
        }
    }

    Rectangle {
        id: bckg
        z: 0
        anchors.fill: parent
        color: "#5d5b59"
    }

    Search {
        id: searchBox
        anchors.centerIn: top
        opacity: 1
    }

    Rectangle {
        id: controlBox
        opacity: 0
        anchors.centerIn: top

        color: "#d7d6d5"
        border.color: "black"
        border.width: 1
        radius: 5
        anchors.fill: parent
        anchors.margins: 10

        property bool _disabled: true

        function sendData() {
            if (_disabled) {
                socket.stringData = "0"
            } else {
                var data = Math.round(val.value * 255).toString()
                socket.stringData = data
            }
        }

        Text {
            id: currentVal
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            height: 50

            font.pixelSize: 40
            font.bold: true

            text: "OFF"
        }

        Dial {
            id: val
            value: 1.0
            from: 0.1

            anchors.top: currentVal.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            onMoved: {
                if (!controlBox._disabled) {
                    controlBox.sendData()
                }
            }
        }
        Button {
            id: swOn
            text: "Enable"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            anchors.top: val.bottom

            onClicked: {
                if (controlBox._disabled) {
                    controlBox._disabled = false
                    controlBox.sendData()
                }
            }
        }
        Button {
            id: swOff
            text: "Disable"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            anchors.top: swOn.bottom

            onClicked: {
                if (!controlBox._disabled) {
                    controlBox._disabled = true
                    controlBox.sendData()
                    currentVal.text = "OFF"
                }
            }
        }
    }

    states: [
        State {
            name: "search"
            PropertyChanges {
                target: searchBox
                opacity: 1
            }
            PropertyChanges {
                target: controlBox
                opacity: 0
            }
        },
        State {
            name: "control"
            PropertyChanges {
                target: searchBox
                opacity: 0
            }
            PropertyChanges {
                target: controlBox
                opacity: 1
            }
        }

    ]
}
}
