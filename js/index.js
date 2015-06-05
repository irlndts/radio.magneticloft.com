$(document).ready(function () {
  $('[data-toggle="offcanvas"]').click(function () {
    $('.row-offcanvas').toggleClass('active')
  });

    $.ajax({
		type: "GET",
		url: "logic", // URL-адрес Perl-сценария
		contentType: "plain/text; charset=utf-8",
		
		// вызов сценария был *не* успешным
		error: function(XMLHttpRequest, textStatus, errorThrown) {
			$('a#play-now').text("responseText: " + XMLHttpRequest.responseText
				+ ", textStatus: " + textStatus
				+ ", errorThrown: " + errorThrown);
			$('a#play-last').addClass("error");
		}, // ошибка  
		// вызов сценария был успешным 
		// данные содержат JSON-значения, возвращенные Perl-сценарием 
		success: function(data){
			if (data.error) { // сценарий возвратил ошибку
				$('a#play-now').text("data.error: " + data.error);
				$('a#play-last').addClass("error");
			} // если
			else { // вход в систему был успешным
				$('a#play-now').text("data.error: " + data.status.icecast);
				//$('div#play-last').addClass("error");
				
			};
		} // успех
	}); // ajax

	$('div#play-now').fadeIn();

});

