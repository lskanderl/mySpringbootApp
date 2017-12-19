var RADAR_URL = "http://radar.lafox.net";
var MY_URL = "http://localhost:8080";
var detectedInvaders;

function getInvader() {
    $('#errorMessage').text("");
    $.get(MY_URL + "/invaders", function (data) {
        console.log(data);
        var n = 1;
        for (var name in data) {
            $("#map_" + n).text(data[name]);
            $("#name_" + n).val(name);
            n++;
        }
    });
}


function getMap() {
    $('#errorMessage').text("");
    $.get(MY_URL + "/map", function (data) {
        console.log(data);
        $("#radarMapId").text(data.id);
        $("#radarMap").val(data.map);
    });
}

function recognizeInvaders() {
    $('#errorMessage').text("");
    var formData = {
        "map": $("#radarMap").val(),
        "id": $("#radarMapId").text(),
        "invaders": [
            {
                "name": $("#name_1").val(),
                "map": $("#map_1").val(),
                "acceptablePointsCount": $("#acceptablePointsCount_1").val()
            },
            {
                "name": $("#name_2").val(),
                "map": $("#map_2").val(),
                "acceptablePointsCount": $("#acceptablePointsCount_2").val()
            },
            {
                "name": $("#name_3").val(),
                "map": $("#map_3").val(),
                "acceptablePointsCount": $("#acceptablePointsCount_3").val()
            }
        ]

    };
    console.log(formData);

    $.postJSON("/recognizeInvaders", formData,
        function (result) { // onSuccess
            console.log(result);
            detectedInvaders = result;
            $('#message').html(composeMessage(result));
        },
        function (result) { // onError
            // console.log(result);
            // showError(result);
        }
    );
}

function check() {
    $('#errorMessage').text("");
    var invaders = [];
    $.each(detectedInvaders, function (index, value) {
        invaders.push({"name": value.name, "x": value.x, "y": value.y});
    });
    console.log(invaders);
    var formData = {
        "mapId": $("#radarMapId").text(),
        "detectedInvaders": invaders
    };
    console.log(formData);

    $.postJSON(RADAR_URL + "/api/checkMyResult", formData,
        function (result) { // onSuccess
            console.log(result);
            $('#errorMessage').html("<h1>Найдено "+result.percentOfSuccessDetection+"% захватчиков.</h1>");
        },
        function (result) { // onError
            console.log(result);
            showError(result);
        }
    );
}


$(document).ready(function () {
    $.postJSON = function (url, data, onSuccess, onError) {
        return jQuery.ajax({
            'type': 'POST',
            'url': url,
            'contentType': 'application/json',
            'data': JSON.stringify(data),
            'dataType': 'json',
            'success': onSuccess,
            'error': onError
        });
    };

});

