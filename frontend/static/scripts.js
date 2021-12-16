function send_data(be_uri) {

    var date_start = new Date(parseInt(document.getElementById("date_start_id").valueAsNumber));
    var date_end = new Date(parseInt(document.getElementById("date_end_id").valueAsNumber));

    var server_data = [
        {"ds": date_start.toISOString().split('T')[0]},
        {"de": date_end.toISOString().split('T')[0]},
    ];

    $.ajax({
        type: "POST",
        url: be_uri,
        data: JSON.stringify(server_data),
        contentType: "application/json",
        dataType: 'json',
            success: function(result) {
                console.log("Result:");
                console.log(result);
            }
    });
}