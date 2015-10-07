 $(document).ready(function(){
     
     var languages = $( '.lang-no, .lang-en, .lang-sa, .lang-kv' );
     var activityTexts = $( '.forb_lofotfiske, .lofotfiske, .hjemmefiske ' );
     
     //Vis og skjul språk
	
	$('#lang-no').click(function(){
		$( languages ).hide();
		$('.lang-no').fadeIn('slow');
	});
	
	$('#lang-en').click(function(){
		$( languages ).hide();
		$('.lang-en').fadeIn('slow');
	});

	
	$('#lang-sa').click(function(){
		$( languages ).hide();
		$('.lang-sa').fadeIn('slow');
	});
	
		$('#lang-kv').click(function(){
		$( languages ).hide();
		$('.lang-kv').fadeIn('slow');
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
	
});