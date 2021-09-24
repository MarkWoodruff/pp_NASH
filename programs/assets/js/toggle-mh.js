function toggleMH(element) {
  element.classList.toggle('hidden');
}

document.getElementById('toggle-mh').addEventListener('click', function(){
  Array.from(document.getElementsByClassName('mh-coding')).forEach(toggleMH);
});

function textMH(){
  var change = document.getElementById("toggle-mh");
  if (change.innerHTML == "Hide Coding")
  {
    change.innerHTML = "Show Coding";
  }
  else {
    change.innerHTML = "Hide Coding";
  }
}