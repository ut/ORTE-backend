$(document).foundation();
$(document).ready(function() {
  const savedState = localStorage.getItem('info-wrapper-state');
  if (savedState === 'expanded') {
    $('#filter-wrapper-content').addClass('expanded');
    $('#info-wrapper-button').attr('aria-expanded', 'true');
  };            
  $(document).on('click', 'button[data-toggle]', function() {
    if ($('#filter-wrapper-content').hasClass('expanded')) {
      localStorage.setItem('info-wrapper-state', 'closed');
    } else {
      localStorage.setItem('info-wrapper-state', 'expanded');
    }
  });
});