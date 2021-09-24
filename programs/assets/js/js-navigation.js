	var navTrigger = document.querySelector(".js-navigation");
	var navCont = document.querySelector(".js-nav");

	navTrigger.addEventListener("click", function(){
  		navCont.classList.toggle("is-active");
  		mainContent.classList.toggle("nav-active");

  		if(navCont.classList.contains("is-active")){
      		navCont.setAttribute("aria-hidden", "false")
      		navTrigger.setAttribute("aria-expanded", "true")
    		}
    		else{
      			navCont.setAttribute("aria-hidden", "true")
      			navTrigger.setAttribute("aria-expanded", "false")
    			}
		}
	)