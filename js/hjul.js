 $(document).ready(function(){
     
    $(this).bind("contextmenu", function(e) {
        e.preventDefault();
    });
     
     var languages = $( '.lang-no, .lang-en, .lang-sa, .lang-kv' );
     var languageButtons = $( '#lang-no, #lang-en, #lang-sa, #lang-kv' );
     var activityTexts = $( '.forb_lofotfiske, .lofotfiske, .hjemmefiske, .forb_finnmarksfiske, .finnmarksfiske, .vaarknipe, .lamming, .vaaronna, .torving, .hoya, .seifiske, .hosting, .sildefiske, .poteter, .produksjon, .slakting' );
     
     //Vis og skjul språk
    
    $( languages ).hide();
    $('.lang-no').fadeIn('slow'); // Default språk
    $('#lang-no').css('opacity', '1'); // Norsk språkikon
	
	$('#lang-no').click(function(){
		$( languages ).hide();
		$('.lang-no').fadeIn('slow');
		$( languageButtons ).css('opacity', '.5');
		$(this).css('opacity', '1');
	});
	
	$('#lang-en').click(function(){
		$( languages ).hide();
		$('.lang-en').fadeIn('slow');
		$( languageButtons ).css('opacity', '.5');
		$(this).css('opacity', '1');

	});
	
	$('#lang-sa').click(function(){
		$( languages ).hide();
		$('.lang-sa').fadeIn('slow');
		$( languageButtons ).css('opacity', '.5');
		$(this).css('opacity', '1');
	});
	
		$('#lang-kv').click(function(){
		$( languages ).hide();
		$('.lang-kv').fadeIn('slow');
		$( languageButtons ).css('opacity', '.5');
		$(this).css('opacity', '1');
	});
	
	// Bobler - Aktiviteter 
	$('#forb_lofotfiske').click(function(){
		$( activityTexts ).hide();
		$('.forb_lofotfiske').fadeIn('slow');
	});
    
    $('#lofotfiske').click(function(){
		$( activityTexts ).hide();
		$('.lofotfiske').fadeIn('slow');
	});
	
	$('#hjemmefiske').click(function(){
		$( activityTexts ).hide();
		$('.hjemmefiske').fadeIn('slow');
	});
	
    $('#forb_finnmarksfiske').click(function(){
		$( activityTexts ).hide();
		$('.forb_finnmarksfiske').fadeIn('slow');
	});
	
	$('#finnmarksfiske').click(function(){
		$( activityTexts ).hide();
		$('.finnmarksfiske').fadeIn('slow');
	});
	
	$('#vaarknipe').click(function(){
		$( activityTexts ).hide();
		$('.vaarknipe').fadeIn('slow');
	});
	
	$('#lamming').click(function(){
		$( activityTexts ).hide();
		$('.lamming').fadeIn('slow');
	});
	
	$('#vaaronna').click(function(){
		$( activityTexts ).hide();
		$('.vaaronna').fadeIn('slow');
	});
	
	$('#torving').click(function(){
		$( activityTexts ).hide();
		$('.torving').fadeIn('slow');
	});
	
	$('#hoya').click(function(){
		$( activityTexts ).hide();
		$('.hoya').fadeIn('slow');
	});
	
	$('#seifiske').click(function(){
		$( activityTexts ).hide();
		$('.seifiske').fadeIn('slow');
	});
	
	$('#hosting').click(function(){
		$( activityTexts ).hide();
		$('.hosting').fadeIn('slow');
	});
	
	$('#sildefiske').click(function(){
		$( activityTexts ).hide();
		$('.sildefiske').fadeIn('slow');
	});
	
	$('#poteter').click(function(){
		$( activityTexts ).hide();
		$('.poteter').fadeIn('slow');
	});
	
	$('#produksjon').click(function(){
		$( activityTexts ).hide();
		$('.produksjon').fadeIn('slow');
	});
	
	$('#slakting').click(function(){
		$( activityTexts ).hide();
		$('.slakting').fadeIn('slow');
	});
	
	// Ikoneer - historiske bilder
	
	$('.close').click(function(){
    	$('.small-image').hide(); 
    	$('.info').removeClass('level-1');
    	$('.historical-image').removeClass('level-2');
    	$('.old-image').removeClass('slide-in');
    	$('.info').removeClass('slide-out');
    	$('.big-image').show();	 	
	});
	
	$('.big-image').click(function(){
    	$(this).hide();
    	$('.small-image').show();
    	$('.info').addClass('level-1');
    	$('.historical-image').addClass('level-2');
    	$('.old-image').addClass('slide-in');
    	$('.info').addClass('slide-out');
	});
	
	$('.small-image').click(function(){
    	$(this).hide();
    	$('.big-image').show();
    	$('.info').removeClass('level-1');
    	$('.historical-image').removeClass('level-2');
    	$('.old-image').removeClass('slide-in');
    	$('.info').removeClass('slide-out');
	});
	
	$.idleTimer(120000);


    $(document).bind("idle.idleTimer", function(){
     window.location.href = "index.html";
    });


	
});