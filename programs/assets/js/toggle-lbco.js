function toggleLBCO(element) {
  element.classList.toggle('hidden');
}

document.getElementById('toggle-lbco').addEventListener('click', function(){
  Array.from(document.getElementsByClassName('lbco-other')).forEach(toggleLBCO);
});

function textLBCO(){
  var change = document.getElementById("toggle-lbco");
  if (change.innerHTML == "Hide Other Vars")
  {
    change.innerHTML = "Show Other Vars";
  }
  else {
    change.innerHTML = "Hide Other Vars";
  }
}