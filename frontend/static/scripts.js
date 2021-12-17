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
            console.log(result.status_recieved_data);
            $("#mytable").remove();
            var table = '<table id="mytable" <tr><th width="20%" >Game date</th><th width="30%">Home - Away teams</th><th width="10%">Home - Away score</th><th width="40%">1st, 2nd, 3d game stars</th></tr ></table>';
            $('body').append(table);
            var trHTML = '';
            $.each(result, function (i, table) {
            trHTML += '<tr><td width="20%" align="center">' + table.date + '</td><td width="30%" align="center">' + table.teams + '</td><td width="10%" align="center">' + table.score + '</td><td width="40%" align="center">' + table.stars + '</td></tr>';
            });
            $('#mytable').append(trHTML);
        }
    });
}