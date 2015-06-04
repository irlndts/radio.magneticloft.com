$(document).ready(function () {
  $('[data-toggle="offcanvas"]').click(function () {
    $('.row-offcanvas').toggleClass('active')
  });
});





$(function(){
		$.ajax({
			type: "GET",
			url: "logic", // URL-адрес Perl-сценария
			contentType: "plain/text; charset=utf-8",
			
			// вызов сценария был *не* успешным
			error: function(XMLHttpRequest, textStatus, errorThrown) {
				$('div#play-now').text("responseText: " + XMLHttpRequest.responseText
					+ ", textStatus: " + textStatus
					+ ", errorThrown: " + errorThrown);
				$('div#play-last').addClass("error");
			}, // ошибка  
			// вызов сценария был успешным 
			// данные содержат JSON-значения, возвращенные Perl-сценарием 
			success: function(data){
				if (data.error) { // сценарий возвратил ошибку
					$('div#play-now').text("data.error: " + data.error);
					$('div#play-last').addClass("error");
				} // если
				else { // вход в систему был успешным
					$('div#play-now').text("data.error: " + data.status);
					//$('div#play-last').addClass("error");
					
					});
					
	
				} //иначе
			} // успех
		}); // ajax
	
		$('div#play-now').fadeIn();
		return false;
	});	