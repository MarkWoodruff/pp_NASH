function toggleLBCC(element) {
  element.classList.toggle('hidden');
}

document.getElementById('toggle-lbcc').addEventListener('click', function(){
  Array.from(document.getElementsByClassName('lbcc-other')).forEach(toggleLBCC);
});

function textLBCC(){
  var change = document.getElementById("toggle-lbcc");
  if (change.innerHTML == "Hide Other Vars")
  {
    change.innerHTML = "Show Other Vars";
  }
  else {
    change.innerHTML = "Hide Other Vars";
  }
}