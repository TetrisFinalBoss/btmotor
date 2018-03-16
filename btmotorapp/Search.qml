import QtQuick 2.2

Rectangle {
    property bool _running: true

    function appendText(newText) {
        searchText.text += newText
    }

    function setText(newText) {
        searchText.text = newText
    }

    anchors.fill: parent
    anchors.margins: 10
    color: "#d7d6d5"
    border.color: "black"
    border.width: 1
    radius: 5

    Image {
        id: searchImage
        source: "images/search.png"
        anchors.centerIn: parent
        width: 128
        height: 128

        RotationAnimation on rotation {
            id: rAnimation
            target: searchImage
            easing.type: Easing.InOutBack
            property: "rotation"
            from: 0
            to: 360
            duration: 2000
            loops: Animation.Infinite
            alwaysRunToEnd: true
            running: _running
        }
    }

    Text {
        id: searchText

        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: searchImage.bottom

        text: qsTr("Searching...")
        color: "black"
    }
}
