function toggleLBCH(element) {
  element.classList.toggle('hidden');
}

document.getElementById('toggle-lbch').addEventListener('click', function(){
  Array.from(document.getElementsByClassName('lbch-other')).forEach(toggleLBCH);
});

function textLBCH(){
  var change = document.getElementById("toggle-lbch");
  if (change.innerHTML == "Hide Other Vars")
  {
    change.innerHTML = "Show Other Vars";
  }
  else {
    change.innerHTML = "Hide Other Vars";
  }
}