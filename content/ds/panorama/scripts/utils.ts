function test()
{
    $.AsyncWebRequest(
		'http://127.0.0.1:8083/',
		{
			type: 'GET',
			dataType: 'text',
			contentType: 'application/json',
			cache: false,
			success: function(a){
				callback(a)
			}
		}
	)
}