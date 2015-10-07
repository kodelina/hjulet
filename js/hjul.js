 $(document).ready(function(){
     
     //Vis og skjul språk
	$(".lang-no", ".lang-en", ".lang-sa", ".lang-kv").hide(); 
	
	$('#lang-no').click(function(){
		$(".lang-en").hide();
		$(".lang-sa").hide();
		$(".lang-kv").hide();
		$(".lang-no").fadeIn("slow");
	});
	
	$('#lang-en').click(function(){
		$(".lang-no").hide();
		$(".lang-sa").hide();
		$(".lang-kv").hide();
		$(".lang-en").fadeIn("slow");
	});

	
	$('#lang-sa').click(function(){
		$(".lang-no").hide();
		$(".lang-en").hide();
		$(".lang-kv").hide();
		$(".lang-sa").fadeIn("slow");
	});
	
		$('#lang-kv').click(function(){
		$(".lang-no").hide();
		$(".lang-en").hide();
		$(".lang-sa").hide();
		$(".lang-kv").fadeIn("slow");
	});
	
	// Bobler - Aktiviteter 
	$('#forb_lofotfiske').click(function(){
		$(".hjemmefiske").hide();
		$(".lofotfiske").hide();
		$(".forb_lofotfiske").fadeIn("slow");
	});
    
    $('#lofotfiske').click(function(){
		$(".hjemmefiske").hide();
		$(".forb_lofotfiske").hide();
		$(".lofotfiske").fadeIn("slow");
	});
	
	$('#hjemmefiske').click(function(){
		$(".lofotfiske").hide();
		$(".forb_lofotfiske").hide();
		$(".hjemmefiske").fadeIn("slow");
	});
	
	// Ikoneer - historiske bilder
	
	$(".close").click(function(){
    	$('#icon-image').removeClass("small-image"); 
    	$('.info').removeClass("level-1");
    	$('.historical-image').removeClass("level-2");
    	$('.old-image').removeClass("slide-in");
    	$('.info').removeClass("slide-out");	 	
	});
	
	$('.big-image').click(function(){
    	$(this).hide();
    	$(".small-image").show();
    	$('.info').addClass("level-1");
    	$('.historical-image').addClass("level-2");
    	$('.old-image').addClass("slide-in");
    	$('.info').addClass("slide-out");
	});
	
	$('.small-image').click(function(){
    	$(this).hide();
    	$(".big-image").show();
    	$('.info').removeClass("level-1");
    	$('.historical-image').removeClass("level-2");
    	$('.old-image').removeClass("slide-in");
    	$('.info').removeClass("slide-out");
	});
	
});